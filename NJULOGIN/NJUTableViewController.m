//
//  NJUTableViewController.m
//  NJULOGIN
//
//  Created by 宋 奎熹 on 2016/12/18.
//  Copyright © 2016年 宋 奎熹. All rights reserved.
//

#import "NJUTableViewController.h"
#import "AFNetworking.h"
#import "CANetworkManager.h"

#define LOGIN_URL @"http://p.nju.edu.cn/portal_io/login"
#define LOGOUT_URL @"http://p.nju.edu.cn/portal_io/logout"
#define CHECK_STATUS_URL @"http://p.nju.edu.cn/portal_io/getinfo"

@interface NJUTableViewController ()

@end

@implementation NJUTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[CANetworkManager shareInstance] checkNetwork];
    
//    if([[NSUserDefaults standardUserDefaults] boolForKey:@"IS_CONNECT"]){
//        [self reloadTableView];
//    }else{
//        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"尚未连接校园网"
//                                                                        message:nil
//                                                                 preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
//                                                           style:UIAlertActionStyleDefault
//                                                         handler:^(UIAlertAction *action){
//                                                             [self.navigationController popToRootViewControllerAnimated:YES];
//                                                         }];
//        [alertC addAction:okAction];
//        [self presentViewController:alertC animated:YES completion:nil];
//    }
}

- (void)reloadTableView{
//    [self checkStatus];
}

- (void)checkStatus{
    
    __weak typeof(self) weakSelf = self;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/plain",
                                                         @"text/html",
                                                         @"application/json",
                                                         nil];
    [manager POST:CHECK_STATUS_URL
       parameters:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
              
              NSDictionary *resultDict = (NSDictionary *)responseObject;
              
              NSLog(@"%d", [resultDict[@"reply_code"] intValue]);
              
              switch ([resultDict[@"reply_code"] intValue]) {
                  case 2:
                      [self.actionButton.titleLabel setText: @"Login"];
                      break;
                  case 0:
                      [self.actionButton.titleLabel setText: @"Logout"];
                      break;
                  default:
                      break;
              }
              
              [weakSelf.tableView reloadData];
              
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"%@",error);
          }];

}

- (void)login{
    NSDictionary *tmpDict = @{
                              @"username" : [NSString stringWithString:self.usernameText.text],
                              @"password" : [NSString stringWithString:self.passwordText.text],
                              };
    
//    NSLog(@"%@", [tmpDict description]);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/plain",
                                                         @"text/html",
                                                         @"application/json",
                                                         nil];
    [manager POST:LOGIN_URL
       parameters:tmpDict
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
              
              NSDictionary *resultDict = (NSDictionary *)responseObject;
              
//              for(NSString *key in resultDict){
//                  NSLog(@"key   : %@", key);
//                  NSLog(@"value : %@", resultDict[key]);
              //              }
              [self checkStatus];

              
              UIAlertController *alertC = [UIAlertController alertControllerWithTitle:resultDict[@"reply_msg"]
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
              UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:nil];
              [alertC addAction:okAction];
              [self presentViewController:alertC animated:YES completion:nil];
              
              
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"%@",error);
          }];
}

- (void)logout{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/plain",
                                                         @"text/html",
                                                         @"application/json",
                                                         nil];
    [manager POST:LOGOUT_URL
       parameters:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
              
              NSDictionary *resultDict = (NSDictionary *)responseObject;
              
//              for(NSString *key in resultDict){
//                  NSLog(@"key   : %@", key);
//                  NSLog(@"value : %@", resultDict[key]);
              //              }
              [self checkStatus];

              
              UIAlertController *alertC = [UIAlertController alertControllerWithTitle:resultDict[@"reply_msg"]
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
              UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:nil];
              [alertC addAction:okAction];
              [self presentViewController:alertC animated:YES completion:nil];
              
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"%@",error);
          }];
}

- (IBAction)buttonAction:(id)sender{
    if([self.actionButton.titleLabel.text isEqualToString:@"Login"]){
        [self login];
    }else{
        [self logout];
    }
}

- (IBAction)logoutAction:(id)sender{
    [self logout];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 1;
        default:
            return 0;
    }
}

@end