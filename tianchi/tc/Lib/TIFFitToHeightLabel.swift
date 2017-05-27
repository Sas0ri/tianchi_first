//
//  TIFFitToHeightLabel.swift
//  tc
//
//  Created by Sasori on 16/8/31.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class TIFFitToHeightLabel: UILabel {
    
    @IBInspectable var minFontSize:CGFloat = 12 {
        didSet {
            font = fontToFitHeight()
        }
    }
    
    @IBInspectable var maxFontSize:CGFloat = 30 {
        didSet {
            font = fontToFitHeight()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        font = fontToFitHeight()
    }
    
    // Returns an UIFont that fits the new label's height.
    fileprivate func fontToFitHeight() -> UIFont {
        
        var minFontSize: CGFloat = self.minFontSize
        var maxFontSize: CGFloat = self.maxFontSize
        var fontSizeAverage: CGFloat = 0
        var textAndLabelHeightDiff: CGFloat = 0
        
        while (minFontSize <= maxFontSize) {
            fontSizeAverage = minFontSize + (maxFontSize - minFontSize) / 2
            
            if let labelText: NSString = text as! NSString {
                let labelHeight = frame.size.height
                
                let testStringHeight = labelText.size(
                    attributes: [NSFontAttributeName: font.withSize(fontSizeAverage)]
                    ).height
                
                textAndLabelHeightDiff = labelHeight - testStringHeight
                
                if (fontSizeAverage == minFontSize || fontSizeAverage == maxFontSize) {
                    if (textAndLabelHeightDiff < 0) {
                        return font.withSize(fontSizeAverage - 1)
                    }
                    return font.withSize(fontSizeAverage)
                }
                
                if (textAndLabelHeightDiff < 0) {
                    maxFontSize = fontSizeAverage - 1
                    
                } else if (textAndLabelHeightDiff > 0) {
                    minFontSize = fontSizeAverage + 1
                    
                } else {
                    return font.withSize(fontSizeAverage)
                }
            }
        }
        return font.withSize(fontSizeAverage)
    }
}
