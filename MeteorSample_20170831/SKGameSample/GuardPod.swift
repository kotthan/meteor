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
    let maxCount = 3    //最大ガード回数
    var count = 0  //initでmaxCountに設定される
    let recoverCountTime:Double = 1.0 //ガードを１回復するまでの時間
    let recoverBrokenTime:Double = 3.0  //破壊状態から回復するまでの時間
    let actionKey = "recover"
    let countLabel = SKLabelNode()  //テスト表示用 
    
    init() {
        //テクスチャアトラス作成
        for i in 0...maxCount {
            podTexture.append(SKTexture(imageNamed: imageName + String(i)))
        }
        super.init(texture: podTexture[maxCount], color: UIColor.clear, size: CGSize.zero)
        self.count = self.maxCount
        //デバッグ用ラベル
        countLabel.text = String(self.count)
        countLabel.position = CGPoint(x: -10, y: -10) //ポッドの左下
        countLabel.zPosition = self.zPosition + 1
        self.addChild(countLabel)
    }

    //ガード回復
    @objc func addCount(_ num: Int = 1){
        self.count += num
        countLabel.text = String(self.count)
        //最大値を超える場合は最大値にする
        if( self.count >= self.maxCount ){
            self.count = self.maxCount
            //ガード可とする
            self.guardStatus = .enable
        }
        else{
            //回復Action追加
            let act1 = SKAction.wait(forDuration: self.recoverCountTime)
            let act2 = SKAction.run{self.addCount()}
            let acts = SKAction.sequence([act1,act2])
            self.run(acts, withKey: self.actionKey)
        }
    }

    //ガード減らす
    func subCount(_ num: Int = 1){
        self.count -= num
        countLabel.text = String(self.count)
        if( self.count <= 0 ){
            self.broken()
        }
        //回復のAcitonが予定されていない場合
        if( self.action(forKey: actionKey) == nil ){
            //回復Action追加
            let act1 = SKAction.wait(forDuration: self.recoverCountTime)
            let act2 = SKAction.run{self.addCount()}
            let acts = SKAction.sequence([act1,act2])
            self.run(acts, withKey: self.actionKey)
        }
    }
    
    //ガード破損
    func broken(){
        self.count = 0
        countLabel.text = String(self.count)
        //通常の回復Actionをキャンセル
        self.removeAllActions()
        //全快までのスケジュール追加
        let act1 = SKAction.wait(forDuration: self.recoverBrokenTime)
        let act2 = SKAction.run{self.addCount(self.maxCount)}
        let acts = SKAction.sequence([act1,act2])
        self.run(acts, withKey: self.actionKey)
        //ガード不可状態にする
        self.guardStatus = .disable
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
