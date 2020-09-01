//
//  BDMContextualData.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BDMContextualData : NSObject

@property(nonatomic, assign) NSUInteger impressions;
@property(nonatomic, assign) NSUInteger clicks;
@property(nonatomic, assign) NSUInteger completions;
@property(nonatomic, assign) BOOL lastClickForImpression;

@end

NS_ASSUME_NONNULL_END
