//
//  File.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2017/08/16.
//  Copyright © 2017年 Kazuaki Oe. All rights reserved.
//

import Foundation
import SpriteKit

@available(iOS 9.0, *)
class TitleScene: SKScene{
    override func didMove(to view: SKView) {
        //この画面に来た時にStartラベルを表示
        let label = SKLabelNode()
        label.text = "Start"
        label.position = CGPoint(x: 100, y: 70)
        self.addChild(label)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first as UITouch? {
            //タッチを検出した時にGameSceneを呼び出す
            var gameScene = GameScene()
            var gameView = GameView()
            gameScene = GameScene(size: CGSize(width: frame.size.width,height: frame.size.height))
            gameScene.scaleMode = .aspectFill
            //シーンをビューと同じサイズに調整する
            gameScene.size = CGSize(width: frame.size.width, height: frame.size.height)
            // ゲームシーンを表示
            view?.presentScene(gameScene)
        }
    }
    
}

