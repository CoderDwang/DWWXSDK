//
//  ViewController.m
//  DWWXPayDemo
//
//  Created by 四海全球 on 2017/6/12.
//  Copyright © 2017年 dwang. All rights reserved.
//

#import "ViewController.h"
#import "DWWXSDK.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    DWWXSDK *wxsdk = [DWWXSDK wxSDK];

//    [wxsdk dw_wxShareMsg:@"测试分享文本" wxShareScene:DWWXShareSession wxShareSuccess:^(BOOL success) {
//        NSLog(@"分享成功");
//    } wxShareResultError:^(DWWXOperatingResult operatingResult, NSString *error, NSString *errorMsg) {
//        NSLog(@"%ld\n%@\n%@", operatingResult, error, errorMsg);
//    }];
    [wxsdk dw_wxShareImage:[UIImage imageNamed:@"bg"] wxFilePath:[[NSBundle mainBundle] pathForResource:@"shareImage" ofType:@"jpg"] wxImageTitle:@"测试分享图片" wxImageDescription:@"测试分享图片" wxShareScene:DWWXShareTimeline wxShareSuccess:^(BOOL success) {
        NSLog(@"分享成功");
    } wxShareResultError:^(DWWXOperatingResult operatingResult, NSString *error, NSString *errorMsg) {
        NSLog(@"%ld\n%@\n%@", operatingResult, error, errorMsg);
    }];
//    /** 登录授权 */
//    [wxsdk dw_wxLoginOAuthWXAppid:@"wxd21cf7d764a8a393" wxSecret:@"88704af549141ff62c5b1413f1697981" wxState:@"vip.dwang" successBlock:^(DWWeChatProfileModel *profileModel) {
//        NSLog(@"%@\n%@\n%@", profileModel.nickname, profileModel.headimgurl, profileModel.unionid);
//    } errorBlock:^(NSError *error, NSInteger errcode, NSString *errmsg) {
//        NSLog(@"%@\n%ld\n%@", error, errcode, errmsg);
//    }];
//
//    /** 单独获取用户信息 */
//    [wxsdk dw_wxLoginUserInfoWXAppid:@"wxd21cf7d764a8a393" successBlock:^(DWWeChatProfileModel *profileModel) {
//        NSLog(@"%@\n%@\n%@", profileModel.nickname, profileModel.headimgurl, profileModel.unionid);
//    } errorBlock:^(NSInteger errcode, NSString *errmsg) {
//        NSLog(@"%ld\n%@", errcode, errmsg);
//    }];
//    
//    /** 单独刷新令牌过期时间 */
//    [wxsdk dw_wxLoginUpDataAccessTokenWXAppid:@"wxd21cf7d764a8a393" successBlock:^(NSString *access_token, CGFloat expires_in, NSString *refresh_token, NSString *openid, NSString *scope) {
//        NSLog(@"%@\n%f\n%@\n%@\n%@", access_token, expires_in, refresh_token, openid, scope);
//    } errorBlock:^(NSInteger errcode, NSString *errmsg) {
//        NSLog(@"%ld\n%@", errcode, errmsg);
//    }];
}

-(NSString *)generateTradeNumber{
    static int kNumber = 12;
    NSString *sourceStr = @"0123456789";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++) {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    //  NSLog(@"随机字符串:%@",resultStr);
    return resultStr;
}

@end
