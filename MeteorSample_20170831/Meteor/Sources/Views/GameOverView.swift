//
//  GameOverView.swift
//  Meteor
//
//  Created by Ryota on 2018/02/12.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class GameOverView: UIView {
    
    init(score:Int, highScore:Int) {
        //画面と同じサイズで作成
        super.init(frame: CGRect(origin: CGPoint.zero, size: GameScene.ScreenSize))
        //背景色
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        //スコアラベル
        let scoreLabel = UILabel( )
        scoreLabel.text = "Score: " + String( score )
        scoreLabel.sizeToFit()
        scoreLabel.textColor = UIColor.white
        scoreLabel.layer.position.y = self.frame.size.height/4
        scoreLabel.layer.position.x = self.frame.size.width/2
        self.addSubview(scoreLabel)
        //ハイスコアラベル
        let highScoreLabel = UILabel( )
        highScoreLabel.text = "High Score: " + String( highScore )
        highScoreLabel.sizeToFit()
        highScoreLabel.textColor = UIColor.white
        highScoreLabel.layer.position.y = self.frame.size.height/4 + scoreLabel.frame.size.height
        highScoreLabel.layer.position.x = self.frame.size.width/2
        self.addSubview(highScoreLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
