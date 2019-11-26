//
//  BDMSdkConfiguration.h
//  BidMachine
//
//  Created by Stas Kochkin on 03/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMTargeting.h>

BDM_SUBCLASSING_RESTRICTED
/**
 SDK configuration for initialisation
 */
@interface BDMSdkConfiguration : NSObject <NSCopying, NSSecureCoding>
/**
 Targeting data. Can be nil
 */
@property (copy, nonatomic, readwrite, nullable) BDMTargeting *targeting;
/**
 Enables/disables test mode
 */
@property (assign, nonatomic, readwrite) BOOL testMode;
/**
 Base URL for SDK initialisation
 */
@property (copy, nonatomic, readwrite, nonnull) NSURL *baseURL;
@end

