//
//  MerideVideoControlView.swift
//  meridelib
//
//  Created by Romal Tandel on 2/19/18.
//

import UIKit
import AVKit
import MediaPlayer

extension UIImage{
    class func localImageWithName(_ name:String)->UIImage?{
        return UIImage(named: "\(name)", in: Bundle(for: MerideVideoControlView.self), compatibleWith: nil)
    }
}

class MerideVideoControlView: UIView ,VideoStatusProtocol{
    //create object
    var controlledView : MerideVideoControlProtocol?
    var selectBlock : ResultBlock?
    var changeQualityBlock : ResultBlock?
    
    let volumeView = MPVolumeView()
    //end
    
    //variable declaration video controller view
    fileprivate let VideoControlTopBarHeight : CGFloat = 25.0
    fileprivate let VideoControlBottomBarHeight : CGFloat = 25.0
    fileprivate let VideoControlPlayBtnWidth : CGFloat = 60.0
    fileprivate let VideoControlTimeLabelWidth : CGFloat = 50.0
    fileprivate let VideoControlTimeLabelFontSize : CGFloat = 10.0
    fileprivate let VideoControlVideoNameLabelFontSize : CGFloat = 16.0
    fileprivate let VideoControlAnimationTimeinterval = 0.4
    fileprivate let VideoControlAutoHiddenTime = 3.0
    fileprivate let PanDistance : CGFloat = 100.0
    fileprivate let PerPanMove  : Float = 1.0
    
    fileprivate var panIsVertical = true
    fileprivate var startPanTime : Float = 0
    var isShowing = true
    var editing = false
    public static var isFullScreen = false
    //end
    
    //video controller properties
    let topBar : UIView
    let bottomBar : UIView
    let playButton : UIButton
    let fullScreenButton : UIButton
    let volumeButton : UIButton
    let settingQualityButton : UIButton
    let progressSlider : UISlider
    let volumeSlider : UISlider
    let startTimeLabel : UILabel
    let totalTimeLabel : UILabel
    let videoNameLabel : UILabel
    let backButton : UIButton
    let indicatorView : UIActivityIndicatorView
    //end
    
    fileprivate var texts = ["AUTO","720HD", "540p", "360p","234p"]
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    let progressView : PlayerProgressView
    let pan : UIPanGestureRecognizer
    
    
    var isPlaying = false{
        didSet{
            var name : String
            if isPlaying {
                name = "btn_pause"
            }else{
                name = "btn_play"
            }
            playButton.setBackgroundImage(UIImage.localImageWithName(name), for: UIControlState())
        }
    }
    
    override init(frame: CGRect) {
        pan = UIPanGestureRecognizer()
        
        topBar = UIView()
        topBar.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        bottomBar = UIView()
        bottomBar.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        playButton = UIButton.init(type: UIButtonType.custom)
        playButton.setBackgroundImage(UIImage.localImageWithName("btn_play"), for: UIControlState())
        
        fullScreenButton = UIButton.init(type: UIButtonType.custom)
        fullScreenButton.setBackgroundImage(UIImage.localImageWithName("full_screen"), for: UIControlState())
        fullScreenButton.frame = CGRect(x: 0,y: 0,width: VideoControlBottomBarHeight,height: VideoControlBottomBarHeight)
        
        volumeButton = UIButton.init(type: UIButtonType.custom)
        volumeButton.setBackgroundImage(UIImage.localImageWithName("volume"), for: UIControlState())
        volumeButton.frame = CGRect(x: 0,y: 0,width: VideoControlBottomBarHeight,height: VideoControlBottomBarHeight)
        
        settingQualityButton = UIButton.init(type: UIButtonType.custom)
        settingQualityButton.setBackgroundImage(UIImage.localImageWithName("settings"), for: UIControlState())
        settingQualityButton.frame = CGRect(x: 0,y: 0,width: VideoControlBottomBarHeight,height: VideoControlBottomBarHeight)
        
        progressSlider = UISlider()
        progressSlider.isContinuous = true
        
        volumeSlider = UISlider()
        volumeSlider.isContinuous = true
        volumeSlider.isHidden = true
        volumeSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        
        startTimeLabel = UILabel()
        startTimeLabel.font = UIFont.systemFont(ofSize: VideoControlTimeLabelFontSize)
        startTimeLabel.textColor = UIColor.white
        startTimeLabel.textAlignment = NSTextAlignment.center
        
        totalTimeLabel = UILabel()
        totalTimeLabel.font = UIFont.systemFont(ofSize: VideoControlTimeLabelFontSize)
        totalTimeLabel.textColor = UIColor.white
        totalTimeLabel.textAlignment = NSTextAlignment.center
        
        videoNameLabel = UILabel()
        videoNameLabel.font = UIFont.systemFont(ofSize: VideoControlVideoNameLabelFontSize)
        videoNameLabel.textColor = UIColor.white
        
        backButton = UIButton.init(type: UIButtonType.custom)
        indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        
        //let bundleIdentifier = "mosaicolab.meride.meridelib"
        //let bundle = Bundle(identifier: bundleIdentifier)
        //let bundle = Bundle(for: PlayerProgressView.self)
      //  progressView = bundle.loadNibNamed("PlayerProgressView", owner: nil, options: nil)?.first as! PlayerProgressView
//        progressView = Bundle.main.loadNibNamed("PlayerProgressView", owner: nil, options: nil)![0] as! PlayerProgressView

        var bundle = Bundle(for: PlayerProgressView.self)
        var banners = bundle.loadNibNamed("PlayerProgressView", owner: nil, options: nil)
        progressView = banners as! PlayerProgressView
        progressView.frame = CGRect(x: 0, y: 0, width: 120, height: 100)
        progressView.isHidden = true
        
        
        super.init(frame: frame)
        
        topBar.addSubview(videoNameLabel)
        bottomBar.addSubview(startTimeLabel)
        bottomBar.addSubview(progressSlider)
        bottomBar.addSubview(totalTimeLabel)
        bottomBar.addSubview(fullScreenButton)
        bottomBar.addSubview(settingQualityButton)
        
        self.addSubview(topBar)
        self.addSubview(indicatorView)
        self.addSubview(playButton)
        self.addSubview(bottomBar)
        self.addSubview(progressView)
        progressView.center = self.center
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(MerideVideoControlView.onTap(_:)))
        self.addGestureRecognizer(tapGesture)
        
        
        pan.addTarget(self, action: #selector(MerideVideoControlView.panAction(_:)))
        self.addGestureRecognizer(pan)
        
        self.regObserver()
    }
    func regObserver(){
        self.progressSlider.addTarget(self, action: #selector(MerideVideoControlView.sliderTouchUp(_:)), for: UIControlEvents.touchUpInside)
        self.progressSlider.addTarget(self, action: #selector(MerideVideoControlView.sliderTouchUp(_:)), for: UIControlEvents.touchUpOutside)
        self.progressSlider.addTarget(self, action: #selector(MerideVideoControlView.sliderBeginTouch(_:)), for: UIControlEvents.touchDown)
        self.progressSlider.addTarget(self, action: #selector(MerideVideoControlView.sliderTouchCancel(_:)), for: UIControlEvents.touchCancel)
        self.progressSlider.addTarget(self, action: #selector(MerideVideoControlView.sliderValueChanged(_:)), for: UIControlEvents.valueChanged)
        self.fullScreenButton.addTarget(self, action: #selector(MerideVideoControlView.changeScreenStatus), for: UIControlEvents.touchUpInside)
        self.settingQualityButton.addTarget(self, action: #selector(MerideVideoControlView.changeVideoQuality), for: UIControlEvents.touchUpInside)
        self.playButton.addTarget(self, action: #selector(MerideVideoControlView.playButtonAction(_:)), for: UIControlEvents.touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topBar.frame = CGRect(x : self.bounds.minX, y : self.bounds.minY, width:  self.bounds.maxX, height : VideoControlTopBarHeight);
        videoNameLabel.frame = CGRect(x: 10, y: 0, width: topBar.frame.size.width, height: topBar.frame.size.height);
        backButton.frame = CGRect(x: 0, y: 0, width: VideoControlTopBarHeight, height: VideoControlTopBarHeight);
        
        bottomBar.frame = CGRect(x: self.bounds.minX, y: self.bounds.maxY - VideoControlBottomBarHeight, width: self.bounds.maxX, height: VideoControlBottomBarHeight);
        
        playButton.frame = CGRect( x: self.frame.size.width/2-VideoControlPlayBtnWidth/2, y: self.frame.size.height/2-VideoControlPlayBtnWidth/2 , width: VideoControlPlayBtnWidth,height: VideoControlPlayBtnWidth);
        
        fullScreenButton.frame = CGRect(x: bottomBar.bounds.maxX - fullScreenButton.bounds.width, y: bottomBar.bounds.height/2 - fullScreenButton.bounds.height/2, width: VideoControlBottomBarHeight, height: VideoControlBottomBarHeight);
        
        settingQualityButton.frame = CGRect(x: (fullScreenButton.frame.minX - settingQualityButton.bounds.width) - 10, y: bottomBar.bounds.height/2 - settingQualityButton.bounds.height/2, width: VideoControlBottomBarHeight, height: VideoControlBottomBarHeight);
        
        totalTimeLabel.frame = CGRect(x: settingQualityButton.frame.minX - VideoControlTimeLabelWidth, y: startTimeLabel.frame.minY, width: VideoControlTimeLabelWidth,  height: bottomBar.frame.height);
        
        progressSlider.frame = CGRect(x: VideoControlTimeLabelWidth, y: bottomBar.bounds.maxY/2 - progressSlider.bounds.maxY/2, width: self.bounds.maxX - VideoControlTimeLabelWidth*2  - (fullScreenButton.bounds.maxX  + settingQualityButton.bounds.maxX), height: progressSlider.bounds.maxY);
        
        
        startTimeLabel.frame = CGRect(x: 0, y: 0, width: VideoControlTimeLabelWidth, height: bottomBar.frame.height);
        
        indicatorView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY);
        
        progressView.frame = CGRect(x: 0, y: 0, width: 140, height: 100)
        progressView.center = self.center
        
    }
    
    @objc public func onTap(_ tap : UITapGestureRecognizer){
        if isShowing {
            hideDirect()
        }else{
            show()
        }
    }
    
    @objc public func panAction(_ ges : UIPanGestureRecognizer){
        let ve = ges.velocity(in: self)
        // print(ges.state)
        switch ges.state {
            
        case .began:
            panIsVertical = abs(ve.x) < abs(ve.y)
            startPanTime = progressSlider.value
            
        case .changed:
            guard abs(ve.x)>PanDistance || abs(ve.y) > PanDistance else {
                return
            }
            if panIsVertical {
                if (abs(ve.y) > PanDistance) {
                    // let isFullScreen = UserDefaults.standard.bool(forKey: "isFullScreen")
                    
                    if ges.location(in: self).x<200 {
                        if (ve.y > PanDistance) {
                            UIScreen.main.brightness -= 0.01;
                        }
                        if (ve.y < -PanDistance){
                            UIScreen.main.brightness += 0.01;
                        }
                    }
                    
                    if (ges.location(in: self).x > self.frame.width-200) {
                        if (ve.y > PanDistance) {
                            if MerideVideoControlView.isFullScreen {
                                if let view = volumeView.subviews.first as? UISlider{
                                    view.value -= 0.01
                                    MPVolumeView().transform = MPVolumeView().transform.rotated(by: CGFloat(Double.pi))//CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
                                }
                            }else{
                                if let view = volumeView.subviews.first as? UISlider{
                                    view.value -= 0.01
                                }
                            }
                        }
                        if (ve.y < -PanDistance){
                            if MerideVideoControlView.isFullScreen {
                                if let view = volumeView.subviews.first as? UISlider{
                                    view.value += 0.01
                                    MPVolumeView().transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
                                }
                            }else{
                                if let view = volumeView.subviews.first as? UISlider{
                                    view.value += 0.01
                                }
                            }
                        }
                    }
                }
            }else{
                
            }
            break
        case .ended:
            editing = false
            if panIsVertical == false{
                progressView.isHidden = true
                startLoading()
                controlledView?.seekToTime(Int(progressSlider.value))
            }
            // print("End....")
            break
        case .cancelled:
            editing = false
            progressView.isHidden = true
            //print("Cancelled....")
            break
        case .failed:
            editing = false
            progressView.isHidden = true
            // print("Failed....")
            break
        default:
            // print("default....")
            break
        }
    }
    
    @objc public func playButtonAction(_ playBtn : UIButton){
        isPlaying = !isPlaying
        controlledView?.playAction(isPlaying)
    }
    
    @objc public func sliderTouchUp(_ slider : UISlider){
        startLoading()
        controlledView?.seekToTime(Int(slider.value))
        editing = false
    }
    
    @objc public func sliderBeginTouch(_ slider : UISlider){
        editing = true
    }
    @objc public func sliderTouchCancel(_ slider : UISlider){
        editing = false
    }
    
    @objc public func changeScreenStatus(){
        controlledView?.changeScreenStatus()
    }
    
    @objc public func sliderValueChanged(_ slider : UISlider){
        timeUpdateDirect(Int64(slider.value))
    }
    
    @objc public func changeVolume(){
        volumeSlider.isHidden = false
    }
    @objc func sliderChanged(slider: UISlider) {
        setVolumeTo(volume: slider.value)
    }
    func setVolumeTo(volume: Float) {
        (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(volume, animated: false)
    }
    
    @objc public func changeVideoQuality(){
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 100, height: 140))
        tableView.backgroundColor = UIColor.black
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        self.popover = Popover(options: self.popoverOptions)
        // let isFullScreen = UserDefaults.standard.bool(forKey: "isFullScreen")
        if MerideVideoControlView.isFullScreen {
            tableView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        }
        self.popover.show(tableView, fromView: self.settingQualityButton)
    }
    
    fileprivate func timeUpdateDirect(_ time: Int64) {
        let currentTime = time
        progressSlider.value = Float(currentTime)
        progressSlider.minimumTrackTintColor = UIColor(red: 41/255, green: 171/255, blue: 226/255, alpha: 1.0)
        let minutesElapsed = Float(currentTime)/60.0
        let secondsElapsed = fmod(Float(currentTime), 60.0)
        let timeElapsedString = NSString.init(format: "%02.0f:%02.0f", minutesElapsed,secondsElapsed)
        startTimeLabel.text = timeElapsedString as String
    }
    
    func timeUpdate(_ time: Int64) {
        guard editing == false else {
            return
        }
        timeUpdateDirect(time)
    }
    
    func startLoading() {
        isPlaying = false
        playButton.isHidden = true
        cancelFadeControlBar()
        indicatorView.isHidden = false
        indicatorView.startAnimating()
    }
    
    func endLoading() {
        if let totalTime = controlledView?.totalTime(){
            totalTimeLabel.text = formatTime(totalTime)
            progressSlider.maximumValue =  Float(totalTime)
        }
        playButton.isHidden = false
        indicatorView.isHidden = true
        indicatorView.stopAnimating()
        isPlaying = true
        self.show()
    }
    
    func formatTime(_ time : Int) -> String{
        let minutesElapsed = Float(time)/60.0
        let secondsElapsed = fmod(Float(time), 60.0)
        let timeElapsedString = NSString.init(format: "%02.0f:%02.0f", minutesElapsed,secondsElapsed)
        return timeElapsedString as String
    }
    
    @objc public func hide(){
        if !isShowing {
            return
        }
        if isPlaying == false{
            return
        }
        
        if editing == true{
            return
        }
        self.hideDirect()
    }
    public func getObject(objectMeride:MediaModel){
        UserDefaults.standard.set(objectMeride.objectVideo?.iphone, forKey: "URLString")
        UserDefaults.standard.set(objectMeride.title, forKey: "TITLE")
    }
    
    func hideDirect(){
        UIView.animate(withDuration: VideoControlAnimationTimeinterval, animations: { [unowned self] in
            self.topBar.alpha = 0.0
            self.bottomBar.alpha = 0.0
            self.playButton.alpha = 0.0
            }, completion: { [weak self] (res) in
                self?.isShowing = false
        })
    }
    
    func show(){
        if isShowing {
            return;
        }
        UIView.animate(withDuration: VideoControlAnimationTimeinterval, animations: { [unowned self] in
            self.topBar.alpha = 1.0
            self.bottomBar.alpha = 1.0
            self.playButton.alpha = 1.0
            }, completion: { [weak self] (res) in
                self?.isShowing = true
                self?.fadeControlBar()
        })
    }
    
    func fadeControlBar(){
        if !isShowing {
            return
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MerideVideoControlView.hide), object: nil)
        self.perform(#selector(MerideVideoControlView.hide), with: nil, afterDelay: VideoControlAutoHiddenTime)
    }
    func cancelFadeControlBar(){
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MerideVideoControlView.hide), object: nil)
    }
    
}
//set data for popoverview (e.g videoqualitysetting pop box data set)
extension MerideVideoControlView: UITableViewDataSource , UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = self.texts[(indexPath as NSIndexPath).row]
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont(name:"Avenir", size:13)
        cell.backgroundColor = UIColor.black
        cell.textLabel?.textAlignment = .center
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var contentUrl = UserDefaults.standard.string(forKey: "URLString")
        let oldcontentUrl = contentUrl
        self.popover.dismiss()
        if texts[indexPath.row] == "234p" {
            contentUrl = contentUrl?.replacingOccurrences(of: "master", with: "index_0")
        }else if texts[indexPath.row] == "360p" {
            contentUrl = contentUrl?.replacingOccurrences(of: "master", with: "index_1")
        }else if texts[indexPath.row] == "540p" {
            contentUrl = contentUrl?.replacingOccurrences(of: "master", with: "index_2")
        }else if texts[indexPath.row] == "720HD"{
            contentUrl = contentUrl?.replacingOccurrences(of: "master", with: "index_3")
        }else{
            contentUrl = oldcontentUrl
        }
        controlledView?.nextAction(contentUrl:contentUrl!)
    }
}
//end

