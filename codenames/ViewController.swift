//
//  ViewController.swift
//  codenames
//
//  Created by Fritz Huie on 2/17/16.
//  Copyright © 2016 Fritz. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    var gameScene = CodeNamesGameScene()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = CodeNamesGameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}