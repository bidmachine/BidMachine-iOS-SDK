//
//  BDMMRAIDClosableView.h
//  BDMMRAIDAdapter
//
//  Created by Stas Kochkin on 03/06/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import StackUIKit;

/// Subclass of STKInteractionView
@interface BDMMRAIDClosableView : STKInteractionView
/// Render close view on container view
/// @param superview Container for view
- (void)render:(UIView *)superview;
/// Instance initialize class method
/// @param timeout Close view deleay. Default - 0
/// @param action Action completion block. Called when was tap on view
+ (instancetype)closableView:(NSTimeInterval)timeout action:(void (^)(BDMMRAIDClosableView *))action;

@end

