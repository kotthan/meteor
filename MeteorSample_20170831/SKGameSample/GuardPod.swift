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
    enum guardState{    //ガード状態
        case enable     //ガード可
        case disable    //ガード不可
        case guarding   //ガード中
    }
    var guardStatus = guardState.enable //ガード状態
    
    init() {
        //テクスチャアトラス作成
        for i in 0...3 {
            podTexture.append(SKTexture(imageNamed: imageName + String(i)))
        }
        super.init(texture: podTexture[3], color: UIColor.clear, size: CGSize.zero)
        //ガード回復タイマー
    }

    //ガード回復
    //ガード減らす
    //ガード破損
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
