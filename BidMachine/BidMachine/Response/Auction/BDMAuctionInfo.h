//
//  BDMAuctionInfo.h
//  BidMachine
//
//  Created by Stas Kochkin on 22/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>

BDM_SUBCLASSING_RESTRICTED
/**
 Information of performed auction
 */
@interface BDMAuctionInfo : NSObject <NSCopying>
/**
 Identifier of win ad
 */
@property (nonatomic, copy, readonly, nullable) NSString * bidID;
/**
 Creative ID
 */
@property (nonatomic, copy, readonly, nullable) NSString * creativeID;
/**
 Creative deal id
 */
@property (nonatomic, copy, readonly, nullable) NSString * dealID;
/**
 Creative cid
 */
@property (nonatomic, copy, readonly, nullable) NSString * cID;
/**
 Ad domains array
 */
@property (nonatomic, copy, readonly, nullable) NSArray <NSString *> * adDomains;
/**
 Demand name
 */
@property (nonatomic, copy, readonly, nullable) NSString * demandSource;
/**
 Auction price
 */
@property (nonatomic, copy, readonly, nullable) NSNumber * price;
/**
 Creative format
*/
@property (nonatomic, assign, readonly) BDMCreativeFormat format;
/**
 Creative custom parameters
*/
@property (nonatomic, copy, readonly, nonnull) BDMStringToObjectMap *customParams;
/**
 Transform model to key-value map
*/
- (nonnull NSDictionary *)extras __deprecated_msg("Will be removed in future versions");
/**
 Transform model to key-value map
*/
- (nonnull NSDictionary *)extrasWithCustomParams:(nullable NSDictionary *)params __deprecated_msg("Will be removed in future versions");

@end

