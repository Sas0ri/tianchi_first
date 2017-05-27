//
//  FUISegmentedControl.h
//  FlatUIKitExample
//
//  Created by Alex Medearis on 5/17/13.
//
//

#import <UIKit/UIKit.h>

@interface FUISegmentedControl : UISegmentedControl

@property(nonatomic, readwrite, retain) UIColor *selectedColor;
@property(nonatomic, readwrite, retain) UIColor *deselectedColor;
@property(nonatomic, readwrite, retain) UIColor *dividerColor;
@property(nonatomic, readwrite) CGFloat cornerRadius;
@property(nonatomic, readwrite, retain) UIFont *selectedFont;
@property(nonatomic, readwrite, retain) UIFont *deselectedFont;
@property(nonatomic, readwrite, retain) UIColor *selectedFontColor;
@property(nonatomic, readwrite, retain) UIColor *deselectedFontColor;



@end
