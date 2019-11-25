//
//  ADCOMAd_Display_Native+BDMSdk.m
//  BidMachine
//
//  Created by Stas Kochkin on 29/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "ADCOMAd_Display_Native+BDMSdk.h"
#import <StackFoundation/StackFoundation.h>


@implementation ADCOMAd_Display_Native (BDMSdk)

- (NSMutableDictionary *)JSONRepresentation {
    NSMutableDictionary *nast = NSMutableDictionary.dictionary;
    
    if (self.hasLink) {
        NSMutableDictionary *link = NSMutableDictionary.dictionary;
        [link setObject:self.link.URL forKey:@"url"];
        [link setObject:self.link.trkrArray forKey:@"clicktrackers"];
        [nast setObject:link forKey:@"link"];
    }
    
    //TODO: Return implementation with type ADCOMNativeImageAssetType_NativeImageAssetTypeMainImage
    if (self.assetArray_Count > 0) {
        STKAny *assets = ANY(self.assetArray).flatMap(^id(ADCOMAd_Display_Native_Asset *obj) {
            if (obj.hasTitle) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(123) forKey:@"id"];
                [value setObject:obj.title.text forKey:@"text"];
                [asset setObject:value forKey:@"title"];
                return asset;
            }
            
            if (obj.hasImage && obj.id_p == 124) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(124) forKey:@"id"];
                [asset setObject:@(obj.image.w) forKey:@"w"];
                [asset setObject:@(obj.image.h) forKey:@"h"];
                [value setObject:obj.image.URL forKey:@"url"];
                [asset setObject:value forKey:@"img"];
                return asset;
            }
            
            if (obj.hasImage && obj.id_p == 128) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(128) forKey:@"id"];
                [asset setObject:@(obj.image.w) forKey:@"w"];
                [asset setObject:@(obj.image.h) forKey:@"h"];
                [value setObject:obj.image.URL forKey:@"url"];
                [asset setObject:value forKey:@"img"];
                return asset;
            }
            
            if (obj.hasVideo) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(4) forKey:@"id"];
                [value setObject:obj.video.adm forKey:@"vasttag"];
                [asset setObject:value forKey:@"video"];
                return asset;
            }
            
            if (obj.hasData_p && obj.id_p == 127) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(127) forKey:@"id"];
                [value setObject:obj.data_p.value forKey:@"value"];
                [asset setObject:value forKey:@"data"];
                return asset;
            }
            
            if (obj.hasData_p && obj.id_p == 7) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(7) forKey:@"id"];
                [value setObject:obj.data_p.value forKey:@"value"];
                [asset setObject:value forKey:@"data"];
                return asset;
            }
            
            if (obj.hasData_p && obj.id_p == 8) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(8) forKey:@"id"];
                [value setObject:obj.data_p.value forKey:@"value"];
                [asset setObject:value forKey:@"data"];
                return asset;
            }
            
            return nil;
        });
        [nast setObject:assets.array forKey:@"assets"];
    }
    
    return nast;
}

@end
