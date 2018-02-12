//
//  GuardPod.swift
//  SKGameSample
//
//  Created by Ryota on 2018/02/13.
//  Copyright © 2018年 STUDIO SHIN. All rights reserved.
//

import SpriteKit

class GuardPod: SKSpriteNode {
    
    var podTexture:[SKTexture] = []
    let imageName = "pod"
    
    init() {
        //テクスチャアトラス作成
        for i in 0...3 {
            podTexture.append(SKTexture(imageNamed: imageName + String(i)))
        }
        super.init(texture: podTexture[3], color: UIColor.clear, size: CGSize.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
