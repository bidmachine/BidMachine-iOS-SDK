//
//  BDMNASTEventController.h
//  BDMNASTAdapter
//
//  Created by Ilia Lozhkin on 08.09.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

@import StackNASTKit;


NS_ASSUME_NONNULL_BEGIN

@class BDMNASTEventController;

@protocol BDMNASTEventControllerDelegate <NSObject>

@optional
- (void)eventControllerTrackAction:(BDMNASTEventController *)controller;
- (void)eventControllerTrackFinish:(BDMNASTEventController *)controller;
- (void)eventControllerTrackImpression:(BDMNASTEventController *)controller;
- (void)eventControllerTrackViewability:(BDMNASTEventController *)controller;

@end

@protocol BDMNASTActionEventController <NSObject>

- (void)trackAction;

@end

@protocol BDMNASTAdapterEventController <NSObject>

- (void)trackFinish;
- (void)trackImpression;
- (void)trackViewability;

@end

@interface BDMNASTEventController : NSObject <BDMNASTActionEventController, BDMNASTAdapterEventController>

- (instancetype)initWithAd:(STKNASTAd *)ad delegate:(id<BDMNASTEventControllerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
