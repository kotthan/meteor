//
//  ViewController.swift
//  SKGameSample
//
//  Created by Kazuaki Oe on 2017/06/05.
//  Copyright © 2017年 Kazuaki Oe. All rights reserved.
//

import UIKit
import SpriteKit

@available(iOS 9.0, *)
class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

        let gameView = GameViewController.gameViewController()
		self.addChildViewController(gameView)
		self.view.addSubview(gameView.view)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override var prefersStatusBarHidden : Bool {
		return true
	}
	
}

