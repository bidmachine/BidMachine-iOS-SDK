//
//  BDMNASTEventReducer.h
//  BDMNASTAdapter
//
//  Created by Ilia Lozhkin on 08.09.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

@import StackNASTKit;


NS_ASSUME_NONNULL_BEGIN

@class BDMNASTEventReducer;

@protocol BDMNASTEventReducerDelegate <NSObject>

@optional
- (void)eventReducerTrackAction:(BDMNASTEventReducer *)reducer;
- (void)eventReducerTrackFinish:(BDMNASTEventReducer *)reducer;
- (void)eventReducerTrackImpression:(BDMNASTEventReducer *)reducer;
- (void)eventReducerTrackViewability:(BDMNASTEventReducer *)reducer;

@end

@protocol BDMNASTEventActionReducer <NSObject>

- (void)trackAction;

@end

@protocol BDMNASTEventAdapterReducer <NSObject>

- (void)trackFinish;
- (void)trackImpression;
- (void)trackViewability;

@end

@interface BDMNASTEventReducer : NSObject <BDMNASTEventActionReducer, BDMNASTEventAdapterReducer>

- (instancetype)initWithAd:(STKNASTAd *)ad delegate:(id<BDMNASTEventReducerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
