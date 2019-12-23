//
//  RNDCname.m
//  Pods
//
//  Created by Namit on 23/12/19.
//

#import "RNDnsCname.h"

#include <dns_sd.h>
@implementation RNDnsCname

static completionBlock blockOne;
+ (completionBlock) blockOne
{ @synchronized(self) { return blockOne; } }
+ (void) setBlockOne:(completionBlock)val
{ @synchronized(self) { blockOne = val; } }

+ (void) getCNAME:(NSString*)domainURL withCompletion:(void(^)(NSString* result))callback {
        RNDnsCname.blockOne = callback;
        DNSServiceRef serviceRef;
        DNSServiceErrorType error;
        error = DNSServiceQueryRecord(&serviceRef, 0, 0, domainURL.UTF8String, kDNSServiceType_CNAME, kDNSServiceClass_IN, queryCallback, NULL);
        if (error != kDNSServiceErr_NoError){
            NSLog(@"DNS Service error");
            callback(nil);
        }
        DNSServiceProcessResult(serviceRef);
        DNSServiceRefDeallocate(serviceRef);
}

static void queryCallback(DNSServiceRef sdRef,
                          DNSServiceFlags flags,
                          uint32_t interfaceIndex,
                          DNSServiceErrorType errorCode,
                          const char *fullname,
                          uint16_t rrtype,
                          uint16_t rrclass,
                          uint16_t rdlen,
                          const void *rdata,
                          uint32_t ttl,
                          void *context) {
    if (errorCode == kDNSServiceErr_NoError && rdlen > 1) {
        NSMutableData *txtData = [NSMutableData dataWithCapacity:rdlen];
        for (uint16_t i = 1; i < rdlen; i += 256) {
            [txtData appendBytes:rdata + i length:MIN(rdlen - i, 255)];
        }
        NSString *cdn = [[NSString alloc] initWithBytes:txtData.bytes length:txtData.length encoding:NSASCIIStringEncoding];
        RNDnsCname.blockOne(cdn);
    }
}
@end
