//
//  TCKTVMainButton.swift
//  tc
//
//  Created by Sasori on 16/6/28.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

@IBDesignable
class TCKTVMainButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Center image
        if let imageView = self.imageView {
            if UI_USER_INTERFACE_IDIOM() == .phone {
                self.titleLabel!.font = UIFont.systemFont(ofSize: 8)
                if let image = imageView.image {
                    var frame = imageView.frame
                    frame.size.width = image.size.width/1.8
                    frame.size.height = image.size.height/1.8
                    if UIScreen.main.scale == 2 {
                        frame.size.width = frame.size.width/1.5
                        frame.size.height = frame.size.height/1.5
                    }
                    imageView.frame = frame

                }
            }
            
            var center = imageView.center;
            center.x = self.frame.size.width/2;
            center.y = self.frame.size.height/2 - (self.titleLabel!.bounds.size.height)/2;
            self.imageView?.center = center;
            //Center text
            
            if let titleLabel = self.titleLabel {
                
                var newFrame = titleLabel.frame;
                newFrame.origin.x = 0;
                newFrame.origin.y = self.bounds.maxY - self.titleLabel!.frame.size.height;
                newFrame.size.width = self.frame.size.width;
                
                self.titleLabel?.frame = newFrame;
                self.titleLabel?.textAlignment = .center;
            }
        }
        
    }
}
