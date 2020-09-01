//
//  BDMPrivateDefines.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>

FOUNDATION_EXPORT NSInteger const BDMEventError;

FOUNDATION_EXPORT NSInteger const BDMEventTrackingError;

typedef NS_ENUM(NSInteger, BDMEvent) {
    BDMEventCreativeLoading = 500,
    BDMEventImpression = 501,
    BDMEventViewable = 502,
    BDMEventClick = 503,
    BDMEventClosed = 504,
    BDMEventDestroyed = 505,
    BDMEventInitialisation = 506,
    BDMEventAuction = 507,
    BDMEventAuctionExpired = 509,
    BDMEventAuctionDestroyed = 510,
    BDMEventHeaderBiddingNetworkInitializing = 701,
    BDMEventHeaderBiddingNetworkPreparing = 702,
    BDMEventHeaderBiddingAllHeaderBiddingNetworksPrepared = 703
};



FOUNDATION_EXTERN NSString *NSStringFromBDMEvent(BDMEvent event);

FOUNDATION_EXTERN BDMEvent BDMEventFromNSString(NSString *event);

FOUNDATION_EXTERN NSString *NSStringFromBDMErrorCode(BDMErrorCode code);

FOUNDATION_EXTERN NSString *NSStringFromBDMInternalPlacementType(BDMInternalPlacementType type);

FOUNDATION_EXTERN BDMInternalPlacementType BDMInternalPlacementTypeFromNSString(NSString *type);
