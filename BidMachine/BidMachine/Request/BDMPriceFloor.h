//
//  BDMPriceFloor.h
//  BidMachine
//
//  Created by Stas Kochkin on 05/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>

BDM_SUBCLASSING_RESTRICTED
/**
 Bid object
 */
@interface BDMPriceFloor : NSObject
/**
 Bid identifier
 */
@property (copy, nonatomic, readwrite, nonnull) NSString * ID;
/**
 Bidfloor for bid
 */
@property (copy, nonatomic, readwrite, nonnull) NSDecimalNumber * value;
@end
