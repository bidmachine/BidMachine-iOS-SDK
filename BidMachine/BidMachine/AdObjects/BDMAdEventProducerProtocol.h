//
//  BDMEventProtocol.h
//  BidMachine
//
//  Created by Stas Kochkin on 27/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BDMAdEventProducer;
/// Event producer handler protocol
@protocol BDMAdEventProducerDelegate <NSObject>
@optional
/// Producer did log user action
/// @param producer On screen ad
- (void)didProduceUserAction:(nonnull id<BDMAdEventProducer>)producer;
/// Producer did log finish
/// @param producer On screen ad
- (void)didProduceFinish:(nonnull id<BDMAdEventProducer>)producer;
/// Producer did log viewability
/// @param producer On screen ad
- (void)didProduceViewability:(nonnull id<BDMAdEventProducer>)producer;
/// Producer did log impression
/// @param producer On screen ad
- (void)didProduceImpression:(nonnull id<BDMAdEventProducer>)producer;

@end
/// Producer of ad events
@protocol BDMAdEventProducer <NSObject>
/// Delegate of producer
@property (nonatomic, weak, nullable) id<BDMAdEventProducerDelegate> producerDelegate;

@end
