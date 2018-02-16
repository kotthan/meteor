//
//  IconButton.swift
//  Meteor
//
//  Created by Ryota on 2018/02/12.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import UIKit

class IconButton: UIButton {
    
    let iconSize = 75.0
    
    init(image:String, color:UIColor = .white){
        super.init(frame: CGRect(x: 0, y: 0, width: iconSize, height: iconSize ))
        self.frame = CGRect(x: 0, y: 0, width: iconSize, height: iconSize )
        self.setImage(UIImage(named:image)?.withRenderingMode(.alwaysTemplate), for: .normal)                //画像
        self.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)          //余白
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFit   //ボタンのサイズに画像を合わせる
        self.backgroundColor = color                                     //背景色
        self.tintColor = UIColor.white                                   //画像の色
        self.layer.cornerRadius = 10.0                                   //角の丸み
        //btn.layer.borderColor = UIColor.white.cgColor                   //枠線の色
        //btn.layer.borderWidth = 5                                       //枠線の太さ
        self.layer.anchorPoint = CGPoint(x: 0, y: 1)                     //アンカーポイントを左下にする
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
