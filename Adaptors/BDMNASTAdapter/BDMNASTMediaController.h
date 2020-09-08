//
//  BDMNASTMediaController.h
//  BDMNASTAdapter
//
//  Created by Ilia Lozhkin on 08.09.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

#import "BDMNASTEventController.h"


NS_ASSUME_NONNULL_BEGIN

@interface BDMNASTMediaController : NSObject

@property (nonatomic, assign, readonly) BOOL video;

@property (nonatomic, weak) id<BDMNASTActionEventController> eventController;

- (instancetype)initWithAd:(STKNASTAd *)ad;

- (void)renderInContainer:(UIView *)container controller:(UIViewController *)controller;

- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
