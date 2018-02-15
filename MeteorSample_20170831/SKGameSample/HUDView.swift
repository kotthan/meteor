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
        scoreLabel.layer.position = CGPoint(x: 0,
                                            y: self.frame.height / 2 )
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
