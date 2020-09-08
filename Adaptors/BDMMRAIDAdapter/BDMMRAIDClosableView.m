//
//  BDMMRAIDClosableView.m
//  BDMMRAIDAdapter
//
//  Created by Stas Kochkin on 03/06/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import StackFoundation;

#import "BDMMRAIDClosableView.h"


static CGFloat const kBDMMRAIDCloseControlInset     = 5.f;
static CGFloat const kBDMMRAIDCloseControlSize      = 40.f;

@interface BDMMRAIDClosableView ()

@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, strong) STKCircleTimerButton *button;
@property (nonatomic,   copy) void(^userActionCallback)(BDMMRAIDClosableView *);

@end

@implementation BDMMRAIDClosableView

+ (instancetype)closableView:(NSTimeInterval)timeout action:(void (^)(BDMMRAIDClosableView *))action {
    return [[self alloc] initWithTimeout:timeout action:action];
}

- (instancetype)initWithTimeout:(NSTimeInterval)timeout action:(void (^)(BDMMRAIDClosableView *))action {
    if (self = [super init]) {
        self.timeout = timeout;
        self.userActionCallback = [action copy];
        [self addContentInsent:UIEdgeInsetsMake(kBDMMRAIDCloseControlInset,
                                                kBDMMRAIDCloseControlInset,
                                                kBDMMRAIDCloseControlInset,
                                                kBDMMRAIDCloseControlInset)];
    }
    return self;
}

- (void)render:(UIView *)superview {
    if (self.superview) {
        [self removeFromSuperview];
        [self.button removeFromSuperview];
    }
    [self layoutInSuperview: superview];
    
    __weak typeof(self) weakSelf = self;
    self.button = [STKCircleTimerButton timerWithTimeInterval:self.timeout completion:^(STKCircleTimerButton * button) {
        [weakSelf addTarget:weakSelf action:@selector(closeTouched:)];
    }];
    self.button.builder.appendFillColor(UIColor.stk_fromHex(@"#52000000"));
    [self layoutButton];
    [self.button fire];
}

- (void)layoutButton {
    self.contentView = self.button;
}

- (void)layoutInSuperview:(UIView *)superview {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [superview addSubview:self];
    
    NSLayoutConstraint *top;
    NSLayoutConstraint *right;
    NSLayoutConstraint *width = [self.widthAnchor constraintEqualToConstant:kBDMMRAIDCloseControlSize];
    NSLayoutConstraint *height = [self.heightAnchor constraintEqualToConstant:kBDMMRAIDCloseControlSize];
    
    if (@available(iOS 11, *)) {
        top = [self.topAnchor constraintEqualToAnchor:superview.safeAreaLayoutGuide.topAnchor];
        right = [self.rightAnchor constraintEqualToAnchor:superview.safeAreaLayoutGuide.rightAnchor];
    } else {
        top = [self.topAnchor constraintEqualToAnchor:superview.topAnchor];
        right = [self.rightAnchor constraintEqualToAnchor:superview.rightAnchor];
    }
    
    [NSLayoutConstraint activateConstraints:@[top, right,width, height ]];
}

- (void)closeTouched:(id)sender {
    STK_RUN_BLOCK(self.userActionCallback, self);
    self.userActionCallback = nil;
}

@end
