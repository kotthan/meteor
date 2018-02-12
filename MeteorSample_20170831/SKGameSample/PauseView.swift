//
//  PauseView.swift
//  SKGameSample
//
//  Created by Ryota on 2018/02/12.
//  Copyright © 2018年 STUDIO SHIN. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class PauseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //画面と同じサイズ
        self.frame = CGRect(origin: CGPoint.zero, size: GameScene.ScreenSize)
        //背景色
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

