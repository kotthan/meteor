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

    //ポーズ時の動作を設定する関数
    func setPauseFunc(action: @escaping () -> Void) {
        self.pause = action
    }
    
    //ポーズ解除時の動作を設定する関数
    func setResumeFunc(action: @escaping () -> Void) {
        self.resume = action
    }

    func pauseAction(){
        isPaused = true
        self.setImage(restartImage, for: .normal)
        self.pause?()
    }
    func resumeAction(){
        isPaused = false
        self.setImage(pauseImage, for: .normal)
        self.resume?()
    }
    
    @objc func tapped(sender: PauseButton) {
        isPaused = !isPaused
        if( isPaused == true ){
            self.setImage(restartImage, for: .normal)
            self.pause?()
        }
        else{
            self.setImage(pauseImage, for: .normal)
            self.resume?()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
