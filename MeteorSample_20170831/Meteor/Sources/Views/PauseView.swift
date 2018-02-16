//
//  PauseView.swift
//  Meteor
//
//  Created by Ryota on 2018/02/12.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class PauseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //背景色
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

