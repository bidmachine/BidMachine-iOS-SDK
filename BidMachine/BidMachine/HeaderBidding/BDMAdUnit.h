//
//  BDMAdUnit.h
//  BidMachine
//
//  Created by Stas Kochkin on 18/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>


NS_ASSUME_NONNULL_BEGIN

@interface BDMAdUnit : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, assign, readonly) BDMAdUnitFormat format;
@property (nonatomic, copy,   readonly,  nonnull) BDMStringToStringMap *params;
@property (nonatomic, copy,   readonly, nullable) BDMStringToObjectMap *extras;

+ (instancetype)adUnitWithFormat:(BDMAdUnitFormat)format
                          params:(nonnull  BDMStringToStringMap *)params
                          extras:(nullable BDMStringToObjectMap *)extras;
                          

@end

NS_ASSUME_NONNULL_END
