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
    [[DWWXSDK wxSDK] dw_registerApp:@"wxd21cf7d764a8a393"];
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
