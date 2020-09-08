//
//  BDMNASTActionController.h
//  BDMNASTAdapter
//
//  Created by Ilia Lozhkin on 08.09.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

#import "BDMNASTEventController.h"


NS_ASSUME_NONNULL_BEGIN

@interface BDMNASTActionController : NSObject

@property(nonatomic, weak) id<BDMNASTActionEventController> eventController;

- (instancetype)initWithAd:(STKNASTAd *)ad
                      info:(NSDictionary<NSString *,NSString *> *)info;

- (void)registerClickableViews:(NSArray <UIView *>*)clickableViews;

- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
