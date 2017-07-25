//
//  AppDelegate.m
//  DWWXPayDemo
//
//  Created by 四海全球 on 2017/6/12.
//  Copyright © 2017年 dwang. All rights reserved.
//

#import "AppDelegate.h"
#import "DWWXSDK.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"是否安装微信:%d", [DWWXSDK dw_isWXAppInstalled]);
    NSLog(@"是否支持OpenApi:%d", [DWWXSDK dw_isWXAppSupportApi]);
    NSLog(@"微信的itunes安装地址:%@", [DWWXSDK dw_getWXAppInstallUrl]);
    NSLog(@"当前微信SDK的版本号:%@", [DWWXSDK dw_getApiVersion]);
    [DWWXSDK dw_registerApp:@"appid"];
    return YES;
}


//--------------------------------------------------------------------------------
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:[DWWXSDK wxSDK]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:[DWWXSDK wxSDK]];
}

//此方法是由于系统版本更新而出现的方法
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary*)options{
    
    return [WXApi handleOpenURL:url delegate:[DWWXSDK wxSDK]];
    
}
//***********************************************************************************

@end
