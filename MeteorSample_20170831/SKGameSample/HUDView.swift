//
//  HUDView.swift
//  SKGameSample
//
//  Created by Ryota on 2018/02/15.
//  Copyright © 2018年 STUDIO SHIN. All rights reserved.
//

import UIKit

class HUDView: UIView {
    
    let scoreLabel = UILabel()
    
    override init(frame:CGRect){
        super.init(frame:frame)
        scoreLabel.textColor = UIColor.white
        scoreLabel.text = "SCORE:"
        scoreLabel.sizeToFit()
        scoreLabel.layer.anchorPoint = CGPoint(x: 0, y: 0)//左上
        scoreLabel.layer.position = CGPoint(x: 10, y: 25 )//適当な余白
        addSubview(scoreLabel)
    }

    func drawScore(score: Int){
        scoreLabel.text = "SCORE:" + String(score)
        scoreLabel.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
