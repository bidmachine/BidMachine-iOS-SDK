//
//  BDMPrivateDefines.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "BDMPrivateDefines.h"

NSInteger const BDMEventError = 1000;

NSInteger const BDMEventTrackingError = 1001;

NSString *NSStringFromBDMEvent(BDMEvent event) {
    switch (event) {
        case BDMEventCreativeLoading: return @"Creative loading"; break;
        case BDMEventClick: return @"User interaction"; break;
        case BDMEventClosed: return @"Closing"; break;
        case BDMEventViewable: return @"Viewable"; break;
        case BDMEventDestroyed: return @"Destroying"; break;
        case BDMEventImpression: return @"Impression"; break;
        case BDMEventAuction: return @"Auction"; break;
        case BDMEventAuctionExpired: return @"Auction Expired"; break;
        case BDMEventAuctionDestroyed: return @"Auction Destroyed"; break;
        case BDMEventInitialisation: return @"Initialisation"; break;
        case BDMEventHeaderBiddingNetworkInitializing: return @"Header Bidding network initialisation"; break;
        case BDMEventHeaderBiddingNetworkPreparing: return @"Header Bidding network preparing"; break;
        case BDMEventHeaderBiddingAllHeaderBiddingNetworksPrepared: return @"Header Bidding preparation"; break;
    }
    return @"unspecified";
}

BDMEvent BDMEventFromNSString(NSString *event) {
    if ([event isEqualToString:@"Creative loading"]) {
        return BDMEventCreativeLoading;
    } else if ([event isEqualToString:@"User interaction"]) {
        return BDMEventClick;
    } else if ([event isEqualToString:@"Closing"]) {
        return BDMEventClosed;
    } else if ([event isEqualToString:@"Viewable"]) {
        return BDMEventViewable;
    } else if ([event isEqualToString:@"Destroying"]) {
        return BDMEventDestroyed;
    } else if ([event isEqualToString:@"Impression"]) {
        return BDMEventImpression;
    } else if ([event isEqualToString:@"Auction"]) {
        return BDMEventAuction;
    } else if ([event isEqualToString:@"Auction Expired"]) {
        return BDMEventAuctionExpired;
    } else if ([event isEqualToString:@"Auction Destroyed"]) {
        return BDMEventAuctionDestroyed;
    } else if ([event isEqualToString:@"Initialisation"]) {
        return BDMEventInitialisation;
    } else if ([event isEqualToString:@"Header Bidding network initialisation"]) {
        return BDMEventHeaderBiddingNetworkInitializing;
    } else if ([event isEqualToString:@"Header Bidding network preparing"]) {
        return BDMEventHeaderBiddingNetworkPreparing;
    } else if ([event isEqualToString:@"Header Bidding preparation"]) {
        return BDMEventHeaderBiddingAllHeaderBiddingNetworksPrepared;
    }
    return 0;
}

NSString *NSStringFromBDMErrorCode(BDMErrorCode code) {
    switch (code) {
        case BDMErrorCodeInternal: return @"Internal"; break;
        case BDMErrorCodeTimeout: return @"Timeout"; break;
        case BDMErrorCodeException: return @"Exception"; break;
        case BDMErrorCodeNoContent: return @"No content"; break;
        case BDMErrorCodeWasClosed: return @"Was closed"; break;
        case BDMErrorCodeUnknown: return @"Unknown"; break;
        case BDMErrorCodeBadContent: return @"Bad content"; break;
        case BDMErrorCodeWasExpired: return @"Was expired"; break;
        case BDMErrorCodeNoConnection: return @"No internet connection"; break;
        case BDMErrorCodeWasDestroyed: return @"Was destroyed"; break;
        case BDMErrorCodeHTTPBadRequest: return @"Bad request"; break;
        case BDMErrorCodeHTTPServerError: return @"Internal server error"; break;
        case BDMErrorCodeHeaderBiddingNetwork: return @"Ad Network specific error"; break;
    }
}

NSString *NSStringFromBDMInternalPlacementType(BDMInternalPlacementType type) {
    switch (type) {
        case BDMInternalPlacementTypeInterstitial: return @"Interstitial"; break;
        case BDMInternalPlacementTypeRewardedVideo: return  @"RewardedVideo"; break;
        case BDMInternalPlacementTypeBanner: return @"Banner"; break;
        case BDMInternalPlacementTypeNative: return @"Native"; break;
    }
    return @"Session";
}

BDMInternalPlacementType BDMInternalPlacementTypeFromNSString(NSString *type) {
    if ([type isEqualToString:@"Interstitial"]) {
        return BDMInternalPlacementTypeInterstitial;
    } else if ([type isEqualToString:@"RewardedVideo"]) {
        return BDMInternalPlacementTypeRewardedVideo;
    } else if ([type isEqualToString:@"Banner"]) {
        return BDMInternalPlacementTypeBanner;
    } else if ([type isEqualToString:@"Native"]) {
        return BDMInternalPlacementTypeNative;
    } else {
        return 0;
    }
}
