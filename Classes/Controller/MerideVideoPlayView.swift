//
//  File.swift
//  meridelib
//
//  Created by Romal Tandel on 2/19/18.
//

import UIKit
import AVFoundation
let KPlayerStatus = "status"
typealias ActionBlock = () -> Void
let ScreenHeight = UIScreen.main.bounds.height
let ScreenWidth = UIScreen.main.bounds.width

public enum VideoSourceType {
    case local,online
}


public class MerideVideoPlayView: UIView ,MerideVideoControlProtocol{
    public var title : String?{
        didSet{
            self.controlView.videoNameLabel.text = title
        }
    }
    var autoStart : Bool = true
    var fullScreenBlock : ActionBlock?
    var exitFullScreenBlock : ActionBlock?
    var loadCompletedBlock : ActionBlock?
    var videoStatusDelegate : VideoStatusProtocol?
    let controlView : MerideVideoControlView
    var isPlaying = false
    var isFullScreen = false
    
    fileprivate let player : AVPlayer
    fileprivate let playerLayer : AVPlayerLayer
    fileprivate var playItem : AVPlayerItem?
    fileprivate var oldFrame : CGRect?
    fileprivate var oldSuperView : UIView?
    
    fileprivate let KFullScreenAnimateDuration = 0.3
    public override init(frame: CGRect) {
        controlView = MerideVideoControlView.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        player = AVPlayer.init()
        playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = controlView.frame
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        self.layer.addSublayer(playerLayer)
        self.addSubview(controlView)
        controlView.controlledView = self
        self.videoStatusDelegate = controlView
        self.regObserver()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func regObserver(){
        self.player.addPeriodicTimeObserver(forInterval: CMTime(value: 1,timescale: 1), queue: DispatchQueue.main) {[weak self] (time) in
            if time.timescale != 0{
                self?.videoStatusDelegate?.timeUpdate(time.value/Int64(time.timescale))
            }
        }
    }
    
    //overide method for slider
    public func startDragProgressSlider(_ progress : UISlider){
    }
    public func endDragProgressSlider(_ progress : UISlider){
    }
    public func progressSliderValueChanged(_ progress : UISlider){
    }
    
    public func sliderBeginTouch(_ slider : UISlider){
        self.player.pause()
    }
    public func sliderTouchCancel(_ slider : UISlider){
        self.player.play()
    }
    public func sliderValueChanged(_ slider : UISlider){
        if slider.maximumValue == 0 {
            return
        }
        self.playItem?.seek(to: CMTime(value: CMTimeValue(slider.value),timescale: 1), completionHandler: {[weak self] (res) in
            if res{
                self?.play()
            }
        })
    }
    //end
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == KPlayerStatus {
            if self.playItem?.status  == AVPlayerItemStatus.readyToPlay {
                self.videoLoadCompleted()
            }
            if self.playItem?.status  == AVPlayerItemStatus.failed {
                self.videoLoadFailed()
            }
        }
    }
    public func videoLoadCompleted(){
        self.videoStatusDelegate?.endLoading()
        self.loadCompletedBlock?()
        if autoStart == true || self.playItem!.duration.timescale == 0{
            //self.play()
        }
    }
    
    public func videoLoadFailed(){
        self.controlView.progressSlider.maximumValue =  0
        self.controlView.playButton.isHidden = false
        self.controlView.indicatorView.isHidden = true
        self.controlView.indicatorView.stopAnimating()
        print("video load failed")
    }
    //this func used for convert time to minute and second
    public func formatTime(_ time : Int) -> String{
        let minutesElapsed = Float(time)/60.0
        let secondsElapsed = fmod(Float(time), 60.0)
        let timeElapsedString = NSString.init(format: "%02.0f:%02.0f", minutesElapsed,secondsElapsed)
        return timeElapsedString as String
    }
    //end
    
    //this func use for string to url convert
    public func playUrl(_ videoSource : String , type : VideoSourceType){
        let contentUrl : URL?
        switch type {
        case .local:
            contentUrl = URL(fileURLWithPath: videoSource)
        case .online:
            contentUrl = URL.init(string: videoSource)
        }
        guard contentUrl != nil else {
            return
        }
        replaceContentURL(contentUrl)
    }
    //end
    public func replaceContentURL(_ contentURL : URL?){
        if contentURL != nil {
            self.player.pause()
            self.videoStatusDelegate?.startLoading()
            self.playItem?.removeObserver(self, forKeyPath: KPlayerStatus)
            let movieAsset = AVURLAsset.init(url: contentURL!)
            self.playItem = AVPlayerItem.init(asset: movieAsset)
            self.player.replaceCurrentItem(with: self.playItem!)
            let options = NSKeyValueObservingOptions([.new, .old])
            playItem?.addObserver(self, forKeyPath: KPlayerStatus, options: options, context: nil)
        }
    }
    
    //play video func
    public func play(){
        if isKeyPresentInUserDefaults(key: "TITLE"){
            let titleString = UserDefaults.standard.string(forKey: "TITLE")!
            title = titleString
        }
        if isKeyPresentInUserDefaults(key: "URLString"){
            let contentUrl = UserDefaults.standard.string(forKey: "URLString")
            playUrl(contentUrl!, type: .online)
        }
        DispatchQueue.main.async {
            self.player.play()
            self.controlView.isPlaying = true
            self.controlView.fadeControlBar()
        }
    }
    //end
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    //pause video func
    public func pause(){
        self.player.pause()
        self.controlView.isPlaying = false
        self.controlView.cancelFadeControlBar()
    }
    //end
    
    //user change screen status fullscreen or normal
    public func changeScreenStatus(){
        if self.isFullScreen {
            self.exitFullScreenAction()
        }else{
            self.fullScreenAction()
        }
    }
    //end
    //user change fullscreen call this func
    public func fullScreenAction(){
        self.oldFrame = self.frame;
        self.oldSuperView = self.superview
        let fullScreenFrame = CGRect(x: 0 , y : 0, width : ScreenWidth, height: ScreenHeight)
        
        var keyWindow = UIApplication.shared.keyWindow
        if keyWindow == nil {
            keyWindow = UIApplication.shared.windows[0]
        }
        
        
        UIView.animate(withDuration: KFullScreenAnimateDuration, animations: { [weak self] in
            if self != nil{
                keyWindow?.addSubview(self!)
            }
            
            self?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2.0))
            
            self?.changeFrame(fullScreenFrame)
            
            
            }, completion: {[weak self] (res) in
                self?.isFullScreen = true
                // UserDefaults.standard.set(self?.isFullScreen, forKey: "isFullScreen")
                MerideVideoControlView.isFullScreen = true
                self?.controlView.fullScreenButton.setBackgroundImage(UIImage.localImageWithName("exit_full_screen"), for: UIControlState())
                UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.none)
        })
    }
    //end
    
    //user change exitfullsreen call this func
    public func exitFullScreenAction(){
        UIView.animate(withDuration: KFullScreenAnimateDuration, animations: { [weak self] in
            if self != nil{
                self?.oldSuperView?.addSubview(self!)
                self?.transform = CGAffineTransform(rotationAngle: 0.0)
                
                self?.changeFrame(self!.oldFrame!)
                
            }
            
            }, completion: {[weak self] (res) in
                self?.isFullScreen = false
                //UserDefaults.standard.set(self?.isFullScreen, forKey: "isFullScreen")
                MerideVideoControlView.isFullScreen = false
                self?.controlView.fullScreenButton.setBackgroundImage(UIImage.localImageWithName("full_screen"), for: UIControlState())
                UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
        })
    }
    //end
    public func changeFrame(_ frame:CGRect){
        self.frame = frame
        self.controlView.frame = self.bounds
        self.controlView.setNeedsLayout()
        self.controlView.layoutIfNeeded()
        self.playerLayer.frame = self.bounds
        
    }
    
    public func playAction(_ play:Bool){
        if play {
            print("play ")
            //self.play()
            self.player.play()
        }else{
            self.player.pause()
        }
    }
    
    //user change videoquality
    public func nextAction(contentUrl:String){
        let cUrl : URL?
        cUrl = URL.init(string: contentUrl)
        if cUrl != nil {
            self.player.pause()
            self.playItem?.removeObserver(self, forKeyPath: KPlayerStatus)
            let movieAsset = AVURLAsset.init(url: cUrl!)
            self.playItem = AVPlayerItem.init(asset: movieAsset)
            playItem?.seek(to: (playItem?.currentTime())!)
            self.player.replaceCurrentItem(with: self.playItem!)
            let options = NSKeyValueObservingOptions([.new, .old])
            playItem?.addObserver(self, forKeyPath: KPlayerStatus, options: options, context: nil)
            self.videoStatusDelegate?.startLoading()
            seekToTime(Int(controlView.progressSlider.value))
            self.player.play()
        }
    }
    public func seekToTime(_ time : Int){
        self.player.pause()
        self.playItem?.seek(to: CMTime(value: CMTimeValue(time),timescale: 1), completionHandler: {[weak self] (res) in
            if res{
                self?.player.play()
                self?.videoStatusDelegate?.endLoading()
            }
        })
    }
    //this func use for total time estimate for video
    public func totalTime()->Int{
        if self.playItem!.duration.timescale != 0 {
            return Int(self.playItem!.duration.value)/Int(self.playItem!.duration.timescale)
        }
        return 0
    }
    //end
}

