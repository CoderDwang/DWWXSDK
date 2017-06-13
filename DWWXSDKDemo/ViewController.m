//
//  ViewController.m
//  DWWXPayDemo
//
//  Created by dwang.vip on 2017/6/12.
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
    [self shareText];
}

/** 登录授权 */
- (void)loginOAuth {
    DWWXSDK *wxsdk = [DWWXSDK wxSDK];
    [wxsdk dw_wxLoginOAuthWXAppid:@"appid" wxSecret:@"秘钥" wxState:@"用于保持请求和回调的状态，授权请求后原样带回给第三方。该参数可用于防止csrf攻击（跨站请求伪造攻击），建议第三方带上该参数，可设置为简单的随机数加session进行校验" successBlock:^(DWWeChatProfileModel *profileModel) {
        NSLog(@"%@\n%@\n%@", profileModel.nickname, profileModel.headimgurl, profileModel.unionid);
    } errorBlock:^(NSError *error, NSInteger errcode, NSString *errmsg) {
        NSLog(@"%@\n%ld\n%@", error, errcode, errmsg);
    }];
}

/** 单独获取用户信息/必须是在已经获取登录授权之后调用此接口,否则之后走error */
- (void)getUserinfo {
    DWWXSDK *wxsdk = [DWWXSDK wxSDK];
    [wxsdk dw_wxLoginUserInfoWXAppid:@"appid" successBlock:^(DWWeChatProfileModel *profileModel) {
        NSLog(@"%@\n%@\n%@", profileModel.nickname, profileModel.headimgurl, profileModel.unionid);
    } errorBlock:^(NSInteger errcode, NSString *errmsg) {
        NSLog(@"%ld\n%@", errcode, errmsg);
    }];
}

/** 单独刷新令牌过期时间 */
- (void)updataAccessToken {
    DWWXSDK *wxsdk = [DWWXSDK wxSDK];
    [wxsdk dw_wxLoginUpDataAccessTokenWXAppid:@"appid" successBlock:^(NSString *access_token, CGFloat expires_in, NSString *refresh_token, NSString *openid, NSString *scope) {
        NSLog(@"%@\n%f\n%@\n%@\n%@", access_token, expires_in, refresh_token, openid, scope);
    } errorBlock:^(NSInteger errcode, NSString *errmsg) {
        NSLog(@"%ld\n%@", errcode, errmsg);
    }];
}

/** 微信支付 */
- (void)pay {
    DWWXSDK *wxsdk = [DWWXSDK wxSDK];
    NSString *xmlString = [wxsdk dw_obtainWXPayXmlAppid:@"appid" mch_id:@"商户号" partnerKey:@"商户Key密钥" body:@"商品描述" out_trade_no:@"商户订单号" total_fee:[@"订单总金额,单位为分" intValue] notify_url:@"接收微信支付异步通知回调地址，通知url必须为直接可访问的url，不能携带参数"];
    [wxsdk dw_wxRequestType:DWWXPayMoney xmlString:xmlString success:^(BOOL success) {
        NSLog(@"支付成功");
    } result:^(DWWXOperatingResult operatingResult, NSString *error, NSString *errorMsg) {
        NSLog(@"错误码:%ld\n%@\n错误Log:%@", operatingResult, error, errorMsg);
    }];
}

/** 订单状态查询 */
- (void)orderquery {
    DWWXSDK *wxsdk = [DWWXSDK wxSDK];
    NSString *xmlString = [wxsdk dw_obtainWXQueryOrderXmlAppid:@"appid" mch_id:@"商户号" partnerKey:@"商户Key密钥" out_trade_no:@"查询的订单号"];
    [wxsdk dw_wxRequestType:DWWXOrderquery xmlString:xmlString success:^(BOOL success) {
        NSLog(@"此订单已支付成功");
    } result:^(DWWXOperatingResult operatingResult, NSString *error, NSString *errorMsg) {
        NSLog(@"错误码:%ld\n%@\n错误Log:%@", operatingResult, error, errorMsg);
    }];
}

/** 分享文本内容 */
- (void)shareText {
    DWWXSDK *wxsdk = [DWWXSDK wxSDK];
    [wxsdk dw_wxShareMsg:@"测试分享文本" wxShareScene:DWWXShareSession wxShareSuccess:^(BOOL success) {
        NSLog(@"分享成功");
    } wxShareResultError:^(DWWXOperatingResult operatingResult, NSString *error, NSString *errorMsg) {
        NSLog(@"%ld\n%@\n%@", operatingResult, error, errorMsg);
    }];
}

/** 分享image */
- (void)shareImage {
    DWWXSDK *wxsdk = [DWWXSDK wxSDK];
    [wxsdk dw_wxShareImage:[UIImage imageNamed:@"缩略图"] wxFilePath:[[NSBundle mainBundle] pathForResource:@"真实数据内容" ofType:@"jpg"] wxImageTitle:@"测试分享图片" wxImageDescription:@"测试分享图片" wxShareScene:DWWXShareTimeline wxShareSuccess:^(BOOL success) {
        NSLog(@"分享成功");
    } wxShareResultError:^(DWWXOperatingResult operatingResult, NSString *error, NSString *errorMsg) {
        NSLog(@"%ld\n%@\n%@", operatingResult, error, errorMsg);
    }];
}

@end
