//
//  MCNetworkTools.m
//  We all pay
//
//  Created by Mark Cornelisse on 18/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCNetworkTools.h"

BOOL isInternetConnection()
{
    BOOL returnValue = NO;
    
#ifdef TARGET_OS_MAC
    
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    
    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr*)&zeroAddress);
    
    
#elif TARGET_OS_IPHONE
    
    struct sockaddr_in address;
    size_t address_len = sizeof(address);
    memset(&address, 0, address_len);
    address.sin_len = address_len;
    address.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr*)&address);
    
#endif
    
    if (reachabilityRef != NULL)
    {
        SCNetworkReachabilityFlags flags = 0;
        
        if(SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
        {
            BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
            BOOL connectionRequired = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
            returnValue = (isReachable && !connectionRequired) ? YES : NO;
        }
        
        CFRelease(reachabilityRef);
    }
    
    return returnValue;
    
}
