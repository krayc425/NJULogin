//
//  CANetworkManager.h
//  ChefAdia
//
//  Created by 宋 奎熹 on 2016/11/17.
//  Copyright © 2016年 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CANetworkManager : NSObject

+ (_Nonnull instancetype)shareInstance;

- (void)checkNetwork;

@end
