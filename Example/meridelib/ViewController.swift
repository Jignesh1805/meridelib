//
//  ViewController.swift
//  meridelib
//
//  Created by Jignesh1805 on 02/19/2018.
//  Copyright (c) 2018 Jignesh1805. All rights reserved.
//

import UIKit
import meridelib
class ViewController: UIViewController , OnMerideInitilizeListener{
   // @IBOutlet weak var videoView: MerideVideoPlayView!
    let playView = MerideVideoPlayView(frame: CGRect(x:0 , y: 15 , width: UIScreen.main.bounds.width ,height:UIScreen.main.bounds.width*0.7))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(playView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        Meride.initilize(listener: self)
    }
    func onMerideInitilizedSucess(successMessage: String) {
        print(successMessage)
       /*  let playView = MerideVideoPlayView(frame: CGRect(x:0 , y: 15 , width: UIScreen.main.bounds.width ,height:UIScreen.main.bounds.width*0.7))
        videoView = playView
        self.view.addSubview(videoView)
        videoView.play()*/
     playView.play()

    }
    func onMerideInitilizedError(errorMessage: String) {
        print(errorMessage)
    }
    
    func noInternetConnection(message: String) {
        print(message)
    }
}

