//
//  BDMContextualProtocol.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BDMContextualProtocol <NSCopying>
/// The count of impressions for a specific placement type in a given app session
@property(nonatomic, assign) NSUInteger impressions;
/// The total duration of time a user has spent so far in a specific app session expressed in seconds
@property(nonatomic, assign) NSUInteger sessionDuration;
/// The percentage of clicks/impressions per user per placement type over a given number of impressions, where 5 represents a 5% CTR
@property(nonatomic, assign) NSUInteger clickRate;
/// The percentage of successful completions/impressions for a user per placement type for a given number of impressions, where 70 represents a 70% completion rate.
/// This only applies to Rewarded and Video placement types
@property(nonatomic, assign) NSUInteger completionRate;
/// An integer value indicating if the user clicked on the last impression in a given session per placement type, where "1" = user clicked, "0" - user didn't click
@property(nonatomic, assign) NSUInteger lastClickForImpression;
/// The last app bundle the user saw on the previous impression in a given session per placement type
@property(nonatomic,   copy) NSString *lastBundle;
/// The last advertiser domain the user saw on the previous impression in a given session per placement type
@property(nonatomic,   copy) NSString *lastAdomain;


@end
