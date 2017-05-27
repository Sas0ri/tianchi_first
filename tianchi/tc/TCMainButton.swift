//
//  TCMainButton.swift
//  tc
//
//  Created by Sasori on 16/6/28.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

@IBDesignable
class TCMainButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Center image
        if let imageView = self.imageView {
            
            var frame = imageView.frame
            frame.size.height = 72/155*self.bounds.size.height
            frame.size.width = frame.size.height
            imageView.frame = frame
            
            var center = imageView.center;
            center.x = self.frame.size.width/2;
            center.y = self.frame.size.height/2 - (5 + self.titleLabel!.bounds.size.height)/2;
            self.imageView?.center = center;
            //Center text
            
        }
        
    }

}
