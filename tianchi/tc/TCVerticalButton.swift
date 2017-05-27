//
//  TCVerticalButton.swift
//  tc
//
//  Created by Sasori on 16/6/17.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

@IBDesignable
class TCVerticalButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
    // Center image
        if let imageView = self.imageView {
            var center = imageView.center;
            center.x = self.frame.size.width/2;
            center.y = self.frame.size.height/2 - (5 + self.titleLabel!.bounds.size.height)/2;
            self.imageView?.center = center;
            //Center text
            
            if let titleLabel = self.titleLabel {
                var newFrame = titleLabel.frame;
                newFrame.origin.x = 0;
                newFrame.origin.y = imageView.frame.maxY + 5;
                newFrame.size.width = self.frame.size.width;
                
                self.titleLabel?.frame = newFrame;
                self.titleLabel?.textAlignment = .center;
            }
        }

    }

}
