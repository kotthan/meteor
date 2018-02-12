//
//  File.swift
//  SKGameSample
//
//  Created by Kazuaki Oe on 2018/02/12.
//  Copyright © 2018年 STUDIO SHIN. All rights reserved.
//

import SpriteKit

class GuardPod: SKSpriteNode {
    
    var names: [String] = ["Pod1","Pod2","Pos3","Pod4"]
    var name: [SKSpriteNode] = []
    var meteores: [SKSpriteNode] = []
    
    func buildMeteor (size: Double, meteorString: String, meteorZ: Double){
        self.firstBuildFlg = false
        self.buildFlg = false
        let texture = SKTexture(imageNamed: meteorString)
        let meteor = SKSpriteNode(texture: texture)
        meteor.zPosition = CGFloat(meteorZ)
        meteor.size = CGSize(width: texture.size().width, height: texture.size().height)
        meteor.xScale = CGFloat(size)
        meteor.yScale = CGFloat(size)
        if meteores.isEmpty
        {
            //meteor.position = CGPoint(x: 187, y: self.meteorPos + (meteor.size.height)/2)
            meteor.position = CGPoint(x:187, y: self.playerBaseNode.position.y + 700 + (meteor.size.height) / 2)
        } else
        {
            meteor.position = CGPoint(x: 187, y: (meteores.first?.position.y)!)
        }
        meteor.physicsBody = SKPhysicsBody(texture: texture, size: meteor.size)
        meteor.physicsBody?.affectedByGravity = false
        meteor.physicsBody?.categoryBitMask = 0b1000                         //接触判定用マスク設定
        meteor.physicsBody?.collisionBitMask = 0b0000                        //接触対象をなしに設定
        meteor.physicsBody?.contactTestBitMask = 0b0010 | 0b10000 | 0b100000 | 0b0100 //接触対象を各Shapeとプレイヤーに設定
        meteor.name = "meteor"//meteorString
        self.addChild(meteor)
        //print("---meteor\(meteorString)を生成しました---")
        self.meteores.append(meteor)
        if( debug ){    //デバッグ用
            //addBodyFrame(node: meteor)  //枠を表示
        }
    }
    
    var string = 
    let GUard = UIImage(named:"pause")         //ポーズ時の画像
    let restartImage = UIImage(named:"restart")     //再開時の画像
    let buttonSize = CGSize(width: 50, height: 50)  //ボタンのサイズ
    var isPaused = false                            //ポーズ中かどうか
    private var resume: (() -> Void)?               //再開時に呼ばれる関数
    private var pause: (() -> Void)?               //再開時に呼ばれる関数
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //サイズ設定
        self.frame = CGRect(origin: .zero, size: buttonSize)
        //ポーズボタン画像を設定
        self.setImage(pauseImage, for: .normal)
        //frameサイズに画像を合わせる
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        //背景は透明
        self.backgroundColor = UIColor.clear
        //ボタン押下時に呼ばれる関数の設定
        self.addTarget(self, action: #selector(self.tapped(sender:)), for: .touchUpInside)
    }
    
}
