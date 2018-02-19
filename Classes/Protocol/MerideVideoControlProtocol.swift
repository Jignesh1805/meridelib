//
//  MerideVideoControlProtocol.swift
//  meridelib
//
//  Created by Romal Tandel on 2/19/18.
//

import UIKit

typealias ResultBlock = (AnyObject?,NSError?)->Void

public protocol MerideVideoControlProtocol {
    
    func startDragProgressSlider(_ progress : UISlider)
    
    func endDragProgressSlider(_ progress : UISlider)
    
    
    func progressSliderValueChanged(_ progress : UISlider)
    
    
    func playAction(_ play:Bool)
    
    func seekToTime(_ time : Int)
    
    func nextAction(contentUrl:String)
    
    func totalTime()->Int
    
    
    func changeScreenStatus()
}


public protocol VideoStatusProtocol {
    
    func timeUpdate(_ time : Int64)
    
    
    func startLoading()
    
    
    func endLoading()
}

