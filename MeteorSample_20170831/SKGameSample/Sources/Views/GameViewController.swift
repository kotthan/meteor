//
//  GameViewController.swift
//

import UIKit
import SpriteKit

@available(iOS 9.0, *)
class GameViewController: UIViewController {

	var gameView: GameView!
	var gameScene: GameScene!
    var titleScene: GameView!
	
	class func gameViewController() -> GameViewController {
		let gameView = GameViewController(nibName: "GameViewController", bundle: nil)
		let frame = UIScreen.main.bounds
		gameView.view.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
		return gameView
	}
	
    override func viewDidLoad() {
        
		super.viewDidLoad()
        
		//===================
		//Game View作成
		//===================
		let frame = UIScreen.main.bounds
		self.gameView = GameView(frame: CGRect(x: 0,y: 0,width: frame.size.width,height: frame.size.height))
		self.gameView.allowsTransparency = true
		self.gameView.ignoresSiblingOrder = true
		self.view.addSubview(self.gameView)
		self.view.sendSubview(toBack: self.gameView)
		//デバッグ表示
//		self.gameView.showsFPS = true
//		self.gameView.showsNodeCount = true
//		self.gameView.showsPhysics = true
		
		//===================
		// Game Scene作成
		//===================
		
        self.gameScene = GameScene(size: CGSize(width: frame.size.width,height: frame.size.height))
		self.gameScene.scaleMode = .aspectFill
		//シーンをビューと同じサイズに調整する
		self.gameScene.size = CGSize(width: frame.size.width, height: frame.size.height)
		// ゲームシーンを表示
		self.gameView.presentScene(self.gameScene)
        
        /*
        //===================
        // Title Scene作成
        //===================
        self.titleScene = GameScene(size: CGSize(width: frame.size.width,height: frame.size.height))
        self.titleScene.scaleMode = .aspectFill
        //シーンをビューと同じサイズに調整する
        self.titleScene.size = CGSize(width: frame.size.width, height: frame.size.height)
        // ゲームシーンを表示
        self.gameView.presentScene(self.titleScene)
 */
    }

	override func viewDidAppear(_ animated: Bool)
    {
	}
	
	@IBOutlet weak var jumpButton: UIButton!
	@IBAction func jumpButtonAction(_ sender: AnyObject)
    {
		gameScene.startButtonAction()
        jumpButton.isHidden = true
	}
}
