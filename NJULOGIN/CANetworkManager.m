//
//  CANetworkManager.m
//  ChefAdia
//
//  Created by 宋 奎熹 on 2016/11/17.
//  Copyright © 2016年 宋 奎熹. All rights reserved.
//

#import "CANetworkManager.h"
#import "Reachability.h"
#import "AFNetworking.h"
#import "JSONKit.h"

#define TEST_URL @"http://p.nju.edu.cn"

@implementation CANetworkManager

static CANetworkManager* _instance = nil;

#pragma mark - CONSTRUCTORS

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [CANetworkManager shareInstance] ;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - NETWORK UTILITIES

- (BOOL)check{
    Reachability *r = [Reachability reachabilityWithHostName:TEST_URL];
    return r.isReachable;
}

- (void)checkNetwork{
    Reachability *reach = [Reachability reachabilityWithHostName:TEST_URL];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [reach startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)notification {
    Boolean isConnected;
    Reachability *reach = [notification object];
    
    if (![reach isReachable]) {
        isConnected = NO;
    } else {
        if ([reach currentReachabilityStatus] == ReachableViaWiFi) {
            isConnected = YES;
        } else if ([reach currentReachabilityStatus] == ReachableViaWWAN) {
            isConnected = YES;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connection" object:[NSNumber numberWithBool:isConnected]];
    
    [[NSUserDefaults standardUserDefaults] setBool:isConnected forKey:@"ISCONNECTED"];
}

@end
