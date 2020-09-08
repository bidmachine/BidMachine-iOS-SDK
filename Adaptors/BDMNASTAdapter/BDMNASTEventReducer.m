//
//  BDMNASTEventReducer.m
//  BDMNASTAdapter
//
//  Created by Ilia Lozhkin on 08.09.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

@import StackFoundation;

#import "BDMNASTEventReducer.h"


@interface BDMNASTEventReducer ()

@property (nonatomic, copy) NSArray <NSURL *> *clickTracking;
@property (nonatomic, copy) NSArray <NSURL *> *finishTracking;
@property (nonatomic, copy) NSArray <NSURL *> *impressionTracking;
@property (nonatomic, copy) NSArray <NSURL *> *viewabilityTracking;
@property (nonatomic, weak) id<BDMNASTEventReducerDelegate> delegate;

@end

@implementation BDMNASTEventReducer

- (instancetype)initWithAd:(STKNASTAd *)ad delegate:(id<BDMNASTEventReducerDelegate>)delegate {
    if (self = [super init]) {
        _delegate               = delegate;
        _clickTracking          = ad.clickTrackers;
        _finishTracking         = ad.finishTrackers;
        _impressionTracking     = ad.impressionTrackers;
    }
    
    return self;
}

#pragma mark - Events

- (void)trackAction {
    [STKThirdPartyEventTracker sendTrackingEvents:self.clickTracking];
    if ([self.delegate respondsToSelector:@selector(eventReducerTrackAction:)]) {
        [self.delegate eventReducerTrackAction:self];
    }
}

- (void)trackFinish {
    [STKThirdPartyEventTracker sendTrackingEvents:self.finishTracking];
    if ([self.delegate respondsToSelector:@selector(eventReducerTrackFinish:)]) {
        [self.delegate eventReducerTrackFinish:self];
    }
}

- (void)trackImpression {
    [STKThirdPartyEventTracker sendTrackingEvents:self.impressionTracking];
   if ([self.delegate respondsToSelector:@selector(eventReducerTrackImpression:)]) {
        [self.delegate eventReducerTrackImpression:self];
    }
}

- (void)trackViewability {
    [STKThirdPartyEventTracker sendTrackingEvents:self.viewabilityTracking];
    if ([self.delegate respondsToSelector:@selector(eventReducerTrackViewability:)]) {
        [self.delegate eventReducerTrackViewability:self];
    }
}

@end
