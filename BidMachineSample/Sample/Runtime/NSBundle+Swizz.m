//
//  NSBundle+Swizz.m
//  Sample
//
//  Created by Ilia Lozhkin on 12/18/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

#import "NSBundle+Swizz.h"
#import <objc/runtime.h>

static char kBDMBundleSwizzledBundleKey;
static char kBDMBundleSwizzledDisplayName;
static char kBDMBundleSwizzledVersion;

@implementation NSBundle (BDMSwizz)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        
        SEL originalSelector = @selector(bundleIdentifier);
        SEL originalSelector2 = @selector(objectForInfoDictionaryKey:);
        
#pragma clang diagnostic pop
        
        SEL swizzledSelector = @selector(bdm_bundleIdentifier);
        SEL swizzledSelector2 = @selector(bdm_objectForInfoDictionaryKey:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        Method originalMethod2 = class_getInstanceMethod(class, originalSelector2);
        Method swizzledMethod2 = class_getInstanceMethod(class, swizzledSelector2);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        BOOL didAddMethod2 =
        class_addMethod(class,
                        originalSelector2,
                        method_getImplementation(swizzledMethod2),
                        method_getTypeEncoding(swizzledMethod2));
        
        if (didAddMethod2) {
            class_replaceMethod(class,
                                swizzledSelector2,
                                method_getImplementation(originalMethod2),
                                method_getTypeEncoding(originalMethod2));
        } else {
            method_exchangeImplementations(originalMethod2, swizzledMethod2);
        }
    });
}

- (void)setSwizzledVersion:(NSString *)version {
    objc_setAssociatedObject(self, &kBDMBundleSwizzledVersion, version, OBJC_ASSOCIATION_COPY);
}

- (void)setSwizzledBundle:(NSString *)bundle {
    objc_setAssociatedObject(self, &kBDMBundleSwizzledBundleKey, bundle, OBJC_ASSOCIATION_COPY);
}

- (void)setSwizzledDisplayName:(NSString *)displayName {
    objc_setAssociatedObject(self, &kBDMBundleSwizzledDisplayName, displayName, OBJC_ASSOCIATION_COPY);
}

- (NSString *)bdm_bundleIdentifier {
    NSString * swizzledBundle = objc_getAssociatedObject(self, &kBDMBundleSwizzledBundleKey);
    if (swizzledBundle) {
        return swizzledBundle;
    }
    return self.bdm_bundleIdentifier;
}

- (id)bdm_objectForInfoDictionaryKey:(NSString *)key {
    NSString * swizzledDisplayName = objc_getAssociatedObject(self, &kBDMBundleSwizzledDisplayName);
    NSString * swizzledVersion = objc_getAssociatedObject(self, &kBDMBundleSwizzledVersion);

    if ([key isEqualToString:(NSString *)kCFBundleNameKey] && swizzledDisplayName) {
        return swizzledDisplayName;
    } else if ([key isEqualToString:@"CFBundleShortVersionString"] && swizzledVersion) {
        return swizzledVersion;
    }
    return [self bdm_objectForInfoDictionaryKey:key];
}

@end
