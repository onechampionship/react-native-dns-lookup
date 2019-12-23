
#import <React/RCTBridgeModule.h>

#import <CFNetwork/CFNetwork.h>
#import <netinet/in.h>
#import <netdb.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/ethernet.h>
#import <net/if_dl.h>


#import "RNDnsLookup.h"
#import "RNDnsCname.h"

@interface RNDnsLookup () <RCTBridgeModule>
@end

@implementation RNDnsLookup

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(getIpAddresses: (NSString *) hostname
                  resolve: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject)
{
    NSLog(@"[RNDnsLookup] Starting DNS lookup on hostname.");
    
    NSError * error;
    NSArray * addresses = [self performDnsLookup:hostname error:&error];
    
    if (addresses == nil) {
        NSLog(@"[RNDnsLookup] %@", error.userInfo[NSDebugDescriptionErrorKey]);
        NSString * errorCode = [NSString stringWithFormat:@"%ld", (long) error.code];
        reject(errorCode, error.userInfo[NSDebugDescriptionErrorKey], error);
    } else {
        NSLog(@"[RNDnsLookup] DNS lookup succeeded.");
        resolve(addresses);
    }
}

RCT_EXPORT_METHOD(getCName: (NSString *) hostname
                  resolve: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject)
{
    NSLog(@"[RNDnsLookup] Starting DNS lookup for CName on hostname.");
    
    NSError *error;
    
    [RNDnsCname getCNAME:hostname withCompletion:^(NSString *result) {
        if (result == nil){
            NSLog(@"RNDnsLookup error");
            NSString *errorCode = [NSString stringWithFormat:@"%d", 101];
            reject(errorCode, @"RNDnsLookup error", error);
        }else{
            NSLog(@"[RNDnsLookup] CName lookup succeeded.");
            resolve(result);
        }
    }];
}

// Helper method to perform the DNS lookup.
- (NSArray *) performDnsLookup: (NSString *) hostname
                             error: (NSError ** _Nonnull) error
{
    if (hostname == nil) {
        *error = [NSError errorWithDomain:NSGenericException code: kCFHostErrorUnknown userInfo: @{ NSDebugDescriptionErrorKey:@"Hostname cannot be null." }];
        return nil;
    }
    
    CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef) hostname);
    if (hostRef == nil) {
        *error = [NSError errorWithDomain:NSGenericException code: kCFHostErrorUnknown userInfo: @{NSDebugDescriptionErrorKey:@"Failed to create host."}];
        return nil;
    }
    
    BOOL didStart = CFHostStartInfoResolution(hostRef, kCFHostAddresses, nil);
    if (!didStart) {
        *error = [NSError errorWithDomain:NSGenericException code: kCFHostErrorUnknown userInfo: @{NSDebugDescriptionErrorKey:@"Failed to start."}];
        CFRelease(hostRef);
        return nil;
    }
    
    CFArrayRef addressesRef = CFHostGetAddressing(hostRef, nil);
    if (addressesRef == nil) {
        *error = [NSError errorWithDomain:NSGenericException code: kCFHostErrorUnknown userInfo: @{NSDebugDescriptionErrorKey:@"Failed to get addresses."}];
        CFRelease(hostRef);
        return nil;
    }
    
    // Convert these addresses into strings.
    NSMutableArray * addresses = [NSMutableArray array];
    char ipAddress[INET6_ADDRSTRLEN];
    CFIndex numAddresses = CFArrayGetCount(addressesRef);
    for (CFIndex currentIndex = 0; currentIndex < numAddresses; currentIndex++) {
        struct sockaddr *address = (struct sockaddr *)CFDataGetBytePtr(CFArrayGetValueAtIndex(addressesRef, currentIndex));
        getnameinfo(address, address->sa_len, ipAddress, INET6_ADDRSTRLEN, nil, 0, NI_NUMERICHOST);
        [addresses addObject:[NSString stringWithCString:ipAddress encoding:NSASCIIStringEncoding]];
    }
    CFRelease(hostRef);
    return addresses;
}

@end
