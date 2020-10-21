//
//  NSBundle+Swizz.h
//  Sample
//
//  Created by Ilia Lozhkin on 12/18/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (BDMSwizz)

- (void)setSwizzledBundle:(NSString *)bundle;
- (void)setSwizzledDisplayName:(NSString *)displayName;
- (void)setSwizzledVersion:(NSString *)version;

@end
