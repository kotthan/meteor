//
//  PauseButton.swift
//  SKGameSample
//
//  Created by Ryota on 2018/02/11.
//  Copyright © 2018年 STUDIO SHIN. All rights reserved.
//

import UIKit

class PauseButton: UIButton {
    
    let pauseImage = UIImage(named:"pause")         //ポーズ時の画像
    let restartImage = UIImage(named:"restart")     //再開時の画像
    let buttonSize = CGSize(width: 50, height: 50)  //ボタンのサイズ
    
    enum ImageType{
        case Pause
        case Restart
    }
    
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
    }
    
    //ボタンの画像を変更する
    func setImage(type: ImageType) {
        switch type {
        case .Pause:
            self.setImage(pauseImage, for: .normal)
        case .Restart:
            self.setImage(restartImage, for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
