//
//  NJUTableViewController.h
//  NJULOGIN
//
//  Created by 宋 奎熹 on 2016/12/18.
//  Copyright © 2016年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NJUTableViewController : UITableViewController

@property (nonnull, nonatomic) IBOutlet UITextField *usernameText;
@property (nonnull, nonatomic) IBOutlet UITextField *passwordText;
@property (nonnull, nonatomic) IBOutlet UISwitch *autologinSwitch;
@property (nonnull, nonatomic) IBOutlet UIButton *actionButton;

- (void)login;
- (void)logout;

@end
