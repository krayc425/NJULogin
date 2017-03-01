//
//  NJULoginViewController.m
//  NJULOGIN
//
//  Created by 宋 奎熹 on 2017/2/28.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "NJULoginViewController.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import "BEMCheckBox.h"
#import "HTPressableButton.h"
#import "UIColor+HTColor.h"

#define TEST_URL @"http://p.nju.edu.cn/portal_io/login"

#define LOGIN_URL @"http://p.nju.edu.cn/portal_io/login"
#define LOGOUT_URL @"http://p.nju.edu.cn/portal_io/logout"
#define CHECK_STATUS_URL @"http://p.nju.edu.cn/portal_io/getinfo"

#define SCREEN_WIDTH    ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT   ([[UIScreen mainScreen] bounds].size.height)

typedef NS_ENUM(NSInteger, LogStatus){
    Login = 0,
    Logout,
    LogDisabled
};

@interface NJULoginViewController () <BEMCheckBoxDelegate>

@property (nonnull, nonatomic) HTPressableButton *actionButton;

@property (nonatomic,strong) Reachability *reachability;

@property (nonatomic) NSInteger logStatus;

@end

@implementation NJULoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.autologinBox setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"AUTO_LOGIN"]];
    [self.autologinBox setBoxType:BEMBoxTypeSquare];
    [self.autologinBox setOnCheckColor:[UIColor whiteColor]];
    [self.autologinBox setOnFillColor:[UIColor colorWithRed:1.0 green:0.4 blue:0 alpha:1.0]];
    [self.autologinBox setOnTintColor:[UIColor colorWithRed:1.0 green:0.4 blue:0 alpha:1.0]];
    [self.autologinBox setLineWidth:3.0f];
    [self.autologinBox setOnAnimationType:BEMAnimationTypeBounce];
    [self.autologinBox setOffAnimationType:BEMAnimationTypeBounce];
    
    NSString *username = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    self.usernameText.text = username;
    NSString *password = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
    self.passwordText.text = password;
    
    self.actionButton = [[HTPressableButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 75,
                                                                            SCREEN_HEIGHT * 0.65,
                                                                            150,
                                                                            150)
                                                     buttonStyle:HTPressableButtonStyleCircular];
    [self.actionButton setStyle:HTPressableButtonStyleCircular];
    [self.actionButton addTarget:self action:@selector(logAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actionButton];
    
    [self setNetwork];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [self checkStatus];
}

#pragma mark - Network

- (void)setNetwork{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    self.internetReachability = [Reachability reachabilityWithHostName:TEST_URL];
    [self.internetReachability startNotifier];
    [self reachability:self.internetReachability];
}

#pragma mark - reachabilityChanged

- (void)reachabilityChanged:(NSNotification *)note{
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self reachability:curReach];
}

- (void)reachability:(Reachability *)reachability{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    NSString *statusString = @"";
    switch (netStatus){
        case NotReachable:
        {
            statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
            connectionRequired = NO;
            break;
        }
        case ReachableViaWWAN:
        {
            statusString = NSLocalizedString(@"Reachable WWAN", @"");
            break;
        }
        case ReachableViaWiFi:
        {
            statusString= NSLocalizedString(@"Reachable WiFi", @"");
            break;
        }
    }
    
    [self checkStatus];
    
    if (connectionRequired){
        NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
        statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
    }
    
    NSLog(@"connection status = [%@]",statusString);
}

- (void)checkStatus{
    
    self.logStatus = LogDisabled;
    [self refreshActionButton];
    
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
              
              switch ([resultDict[@"reply_code"] intValue]) {
                  case 2:
                  {
                      self.logStatus = Logout;
                  }
                      break;
                  case 0:
                  {
                      self.logStatus = Login;
                  }
                      break;
                  default:
                  {
                      self.logStatus = LogDisabled;
                  }
                      break;
              }
              
              [self refreshActionButton];
              
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"%@",error);
          }];
    
}

- (void)refreshActionButton{
    switch (self.logStatus) {
        case LogDisabled:
        {
            [self.actionButton setDisabledButtonColor:[UIColor lightGrayColor]];
            [self.actionButton setDisabledShadowColor:[UIColor grayColor]];
            [self.actionButton setTitle:@"DISABLED" forState:UIControlStateNormal];
            self.actionButton.enabled = NO;
        }
            break;
        case Login:
        {
            [self.actionButton setTitle:@"LOGOUT" forState:UIControlStateNormal];
            self.actionButton.buttonColor = [UIColor ht_grapeFruitColor];
            self.actionButton.shadowColor = [UIColor ht_grapeFruitDarkColor];
            self.actionButton.enabled = YES;
        }
            break;
        case Logout:
        {
            [self.actionButton setTitle:@"LOGIN" forState:UIControlStateNormal];
            self.actionButton.buttonColor = [UIColor ht_mintColor];
            self.actionButton.shadowColor = [UIColor ht_mintDarkColor];
            self.actionButton.enabled = YES;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Actions;

- (void)login{
    
    if(self.logStatus == LogDisabled){
        return;
    }
    
    NSDictionary *tmpDict = @{
                              @"username" : [NSString stringWithString:self.usernameText.text],
                              @"password" : [NSString stringWithString:self.passwordText.text],
                              };
    
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
              
              [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithString:self.usernameText.text] forKey:@"username"];
              [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithString:self.passwordText.text] forKey:@"password"];
              
              NSDictionary *resultDict = (NSDictionary *)responseObject;
              
              UIAlertController *alertC = [UIAlertController alertControllerWithTitle:resultDict[@"reply_msg"]
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
              UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action){
                                                                   [self checkStatus];
                                                               }];
              [alertC addAction:okAction];
              [self presentViewController:alertC animated:YES completion:nil];
              
          }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              
              UIAlertController *alertC = [UIAlertController alertControllerWithTitle:error.description
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
              UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action){
                                                                   [self checkStatus];
                                                               }];
              [alertC addAction:okAction];
              [self presentViewController:alertC animated:YES completion:nil];
              
          }];
}

- (void)logout{
    
    if(self.logStatus == LogDisabled){
        return;
    }
    
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
              
              UIAlertController *alertC = [UIAlertController alertControllerWithTitle:resultDict[@"reply_msg"]
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
              UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action){
                                                                   [self checkStatus];
                                                               }];
              [alertC addAction:okAction];
              [self presentViewController:alertC animated:YES completion:nil];
              
          }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              
              UIAlertController *alertC = [UIAlertController alertControllerWithTitle:error.description
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
              UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action){
                                                                   [self checkStatus];
                                                               }];
              [alertC addAction:okAction];
              [self presentViewController:alertC animated:YES completion:nil];
              
          }];
}

- (void)logAction{
    if(self.logStatus == Logout){
        [self login];
    }else{
        [self logout];
    }
}

#pragma mark - BEMCheckBox Delegate

- (void)didTapCheckBox:(BEMCheckBox *)checkBox{
    if(checkBox == self.autologinBox){
        [[NSUserDefaults standardUserDefaults] setBool:[checkBox on] forKey:@"AUTO_LOGIN"];
    }
}

@end
