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
    
    DWWXSDK *wxpay = [DWWXSDK wxSDK];
    NSString *fee = @"1";
    NSString *xmlString = [wxpay dw_obtainWXPayXmlAppid:@"wxd21cf7d764a8a393" mch_id:@"1481812502" partnerKey:@"wxsdlinwangd21cf7d764a8a393afgj6" body:@"测试" out_trade_no:[self generateTradeNumber] total_fee:[fee intValue] notify_url:@"www.baidu.com"];
    NSLog(@"%@", xmlString);
       [wxpay dw_wxRequestType:DWWXPayMoney xmlString:xmlString success:^(BOOL success) {
        NSLog(@"成功");
    } result:^(DWWXOperatingResult operatingResult, NSString *error, NSString *errorMsg) {
        NSLog(@"%ld---%@---%@", operatingResult, error, errorMsg);
    }];
    
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
