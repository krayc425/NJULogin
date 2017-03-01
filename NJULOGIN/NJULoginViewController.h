//
//  NJULoginViewController.h
//  NJULOGIN
//
//  Created by 宋 奎熹 on 2017/2/28.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "YoshikoTextField.h"
#import "BEMCheckBox.h"
#import "HTPressableButton.h"

@interface NJULoginViewController : UIViewController

@property (nonnull, nonatomic) Reachability *internetReachability;

@property (nonnull, nonatomic) IBOutlet YoshikoTextField *usernameText;
@property (nonnull, nonatomic) IBOutlet YoshikoTextField *passwordText;
@property (nonnull, nonatomic) IBOutlet BEMCheckBox *autologinBox;

- (void)checkStatus;
- (void)login;
- (void)logout;

@end
