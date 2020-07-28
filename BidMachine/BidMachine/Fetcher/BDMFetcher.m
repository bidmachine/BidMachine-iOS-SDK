//
//  BDMFetcher.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 27.07.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "BDMFetcher+Private.h"
#import <StackFoundation/StackFoundation.h>
#import "BDMRequestStorage+Private.h"
#import "BDMRequest+Private.h"

BDMFetcherRange BDMFetcherRangeMake(float _location, float _length) {
    BDMFetcherRange res;
    res.location = _location;
    res.length = _length;
    return res;
}

BOOL BDMFetcherRangeContains(BDMFetcherRange _range, float value) {
    BOOL atStart = _range.location <= value;
    BOOL atFinish = (_range.location + _range.length) > value;
    return atStart && atFinish;
}

@interface BDMDefaultFetcher: NSObject <BDMFetcherProtocol>

@end

@implementation BDMDefaultFetcher

- (NSString *)format {
    return @"0.00";
}

- (NSNumberFormatterRoundingMode)roundingMode {
    return NSNumberFormatterRoundCeiling;
}

@end

@interface BDMFetcher ()

@property (nonatomic, strong) NSNumberFormatter *formatter;
@property (nonatomic, strong) NSMutableArray <id<BDMFetcherPresetProtocol>> *presets;

@end

@implementation BDMFetcher

+ (instancetype)shared {
    static BDMFetcher *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [BDMFetcher privateInit];
    });
    return _instance;
}

+ (instancetype)privateInit {
    BDMFetcher *fetcher = BDMFetcher.new;
    fetcher.presets = NSMutableArray.new;
    return fetcher;
}

- (NSNumberFormatter *)formatter {
    if (!_formatter) {
        _formatter = [NSNumberFormatter new];
        _formatter.numberStyle = NSNumberFormatterDecimalStyle;
        _formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _formatter.roundingMode = NSNumberFormatterRoundCeiling;
        _formatter.positiveFormat = @"0.00";
    }
    return _formatter;
}

- (void)registerPresset:(id<BDMFetcherPresetProtocol>)preset {
    if (preset == nil) {
        return;
    }
    [self.presets addObject:preset];
}

- (NSString *)fetchPrice:(NSNumber *)price
                    type:(BDMInternalPlacementType)type
           serverPresets:(NSArray <id<BDMFetcherPresetProtocol>> *)serverPresets
             userFetcher:(id<BDMFetcherProtocol>)userFetcher
{
    if (!price) {
        return nil;
    }
    
    id<BDMFetcherProtocol> preset = userFetcher;
    if (preset) {
        return [self priceFromFetcher:preset price:price];
    }
    
    preset = [self presetfromPresets:self.presets type:type price:price];
    if (preset) {
        return [self priceFromFetcher:preset price:price];
    }
    
    preset = [self presetfromPresets:serverPresets type:type price:price];
    if (preset) {
        return [self priceFromFetcher:preset price:price];
    }
    
    return [self priceFromFetcher:BDMDefaultFetcher.new price:price];
}


- (NSString *)priceFromFetcher:(id<BDMFetcherProtocol>)fetcher price:(NSNumber *)price {
    if (!fetcher) {
        return nil;
    }
    
    [self.formatter setPositiveFormat:fetcher.format];
    [self.formatter setRoundingMode:fetcher.roundingMode];
    return [self.formatter stringFromNumber:price];
}


#pragma mark - Private

- (id<BDMFetcherProtocol>)presetfromPresets:(NSArray <id<BDMFetcherPresetProtocol>> *)presets
                                       type:(BDMInternalPlacementType)type
                                      price:(NSNumber *)price
{
    return [presets stk_filter:^BOOL(id<BDMFetcherPresetProtocol> _Nonnull obj) {
        return (obj.type == type) && BDMFetcherRangeContains(obj.range, price.floatValue);
    }].firstObject;
}

@end

@implementation BDMFetcher (Request)

- (NSDictionary *)fetchParamsFromRequest:(BDMRequest *)request {
    return [self fetchParamsFromRequest:request fetcher:nil];
}

- (NSDictionary *)fetchParamsFromRequest:(BDMRequest *)request fetcher:(id<BDMFetcherProtocol>)fetcher {
    if (!request) {
        return nil;
    }
    
    NSString *price = [self fetchPrice:request.info.price
                                  type:request.placementType
                         serverPresets:nil
                           userFetcher:fetcher];
    [[BDMRequestStorage shared] saveRequest:request withPrice:price type:request.placementType];
    
    NSMutableDictionary *extras = [NSMutableDictionary new];
    extras[@"bm_id"] = request.info.bidID;
    extras[@"bm_pf"] = price;
    extras[@"bm_ad_type"] = NSStringFromBDMCreativeFormat(request.info.format);
    
    if (request.info.customParams) {
        [extras addEntriesFromDictionary:request.info.customParams];
    }
    return extras;
}

@end
