//
//  BDMNASTEventController.m
//  BDMNASTAdapter
//
//  Created by Ilia Lozhkin on 08.09.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

@import StackFoundation;

#import "BDMNASTEventController.h"


@interface BDMNASTEventController ()

@property (nonatomic, copy) NSArray <NSURL *> *clickTracking;
@property (nonatomic, copy) NSArray <NSURL *> *finishTracking;
@property (nonatomic, copy) NSArray <NSURL *> *impressionTracking;
@property (nonatomic, copy) NSArray <NSURL *> *viewabilityTracking;
@property (nonatomic, weak) id<BDMNASTEventControllerDelegate> delegate;

@end

@implementation BDMNASTEventController

- (instancetype)initWithAd:(STKNASTAd *)ad delegate:(id<BDMNASTEventControllerDelegate>)delegate {
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
    if ([self.delegate respondsToSelector:@selector(eventControllerTrackAction:)]) {
        [self.delegate eventControllerTrackAction:self];
    }
}

- (void)trackFinish {
    [STKThirdPartyEventTracker sendTrackingEvents:self.finishTracking];
    if ([self.delegate respondsToSelector:@selector(eventControllerTrackFinish:)]) {
        [self.delegate eventControllerTrackFinish:self];
    }
}

- (void)trackImpression {
    [STKThirdPartyEventTracker sendTrackingEvents:self.impressionTracking];
   if ([self.delegate respondsToSelector:@selector(eventControllerTrackImpression:)]) {
        [self.delegate eventControllerTrackImpression:self];
    }
}

- (void)trackViewability {
    [STKThirdPartyEventTracker sendTrackingEvents:self.viewabilityTracking];
    if ([self.delegate respondsToSelector:@selector(eventControllerTrackViewability:)]) {
        [self.delegate eventControllerTrackViewability:self];
    }
}

@end
