//
//  RNDCname.h
//  Pods
//
//  Created by Namit on 23/12/19.
//

#import <Foundation/Foundation.h>

typedef void (^completionBlock)(NSString* result);
@interface RNDnsCname : NSObject
+ (void) getCNAME:(NSString*)domainURL withCompletion:(void(^)(NSString* result))callback;
@end
