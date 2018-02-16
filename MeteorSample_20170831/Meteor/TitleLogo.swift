//
//  File.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/02/16.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class TitleLogo
{
    scaleAction(){
        let action1 = SKAction.scale(to: 1.3, duration: 0.5)
        let action2 = SKAction.wait(forDuration: 0.5)
        let action3 = SKAction.scale(to: 1.0, duration: 0.5)
        let action4 = SKAction.wait(forDuration: 0.5)
        let action5 = SKAction.scale(to: 0.7, duration: 0.5)

    }
    let action1 = SKAction.scale(to: 1.3, duration: 0.5)
    let action2 = SKAction.wait(forDuration: 0.5)
    let action3 = SKAction.scale(to: 1.0, duration: 0.5)
    let action4 = SKAction.wait(forDuration: 0.5)
    let action5 = SKAction.scale(to: 0.7, duration: 0.5)
    let actiom = SKAction.sequence([])
    
    init(image:String, color:UIColor = .white){
        super.init(frame: CGRect(x: 0, y: 0, width: iconSize, height: iconSize ))
        self.frame = CGRect(x: 0, y: 0, width: iconSize, height: iconSize )
        self.setImage(UIImage(named:image)?.withRenderingMode(.alwaysTemplate), for: .normal)                //画像

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
