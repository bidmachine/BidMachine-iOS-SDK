//
//  NSError+BDMMRAIDAdapter.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>


/// Error NRAID category
@interface NSError (BDMMRAIDAdapter)
/// Create MRAID error with description
+ (NSError *(^)(NSString *))bdm_error;

@end
