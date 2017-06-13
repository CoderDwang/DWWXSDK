//
//  DWWXPay.m
//  DWWXPayDemo
//
//  Created by 四海全球 on 2017/6/12.
//  Copyright © 2017年 dwang. All rights reserved.
//

#import "DWWXSDK.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/socket.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <arpa/inet.h>

@interface DWWXPayXmlParser : NSObject<NSXMLParserDelegate> {
    NSXMLParser* xmlParser;
    NSMutableString* valBuffer;
    NSMutableDictionary* dictionary;
    NSError* lastError;
}
/** xml解析 */
+ (NSDictionary*)dw_parseData:(NSData*)data;
@end

@interface DWWXSDK ()
/** 商户密钥 */
@property(nonatomic, copy) NSString *partnerKey;
@end

#define WXPayURLString @"https://api.mch.weixin.qq.com/pay/unifiedorder"
#define WXQueryOrderURLString @"https://api.mch.weixin.qq.com/pay/orderquery"

@implementation DWWXSDK

+ (instancetype)wxSDK {
    static dispatch_once_t onceToken;
    static DWWXSDK *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}
+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self wxSDK];
}

#pragma mark - 检测是否安装微信
+ (BOOL)dw_isWXAppInstalled {
    return [WXApi isWXAppInstalled];
}

#pragma mark - 判断当前微信的版本是否支持OpenApi
+ (BOOL)dw_isWXAppSupportApi {
    return [WXApi isWXAppSupportApi];
}

#pragma mark - 获取微信的itunes安装地址
+ (NSString *)dw_getWXAppInstallUrl {
    return [WXApi getWXAppInstallUrl];
}

#pragma mark - 获取当前微信SDK的版本号
+ (NSString *)dw_getApiVersion {
    return [WXApi getApiVersion];
}

#pragma mark - 向微信终端程序注册第三方应用
- (BOOL)dw_registerApp:(NSString *)appid enableMTA:(BOOL)isEnableMTA {
    BOOL registerAppid = [WXApi registerApp:appid enableMTA:isEnableMTA];
    return registerAppid;
}
- (BOOL)dw_registerApp:(NSString *)appid {
    BOOL registerAppid = [WXApi registerApp:appid];
    return registerAppid;
}

#pragma mark - 获取支付最终发送的xml字符串
- (NSString *)dw_obtainWXPayXmlAppid:(NSString *)appid mch_id:(NSString *)mch_id partnerKey:(NSString *)partnerKey body:(NSString *)body out_trade_no:(NSString *)out_trade_no total_fee:(int)total_fee notify_url:(NSString *)notify_url {
    self.partnerKey = partnerKey;
    NSString *nonce_str = [NSString dw_obtainRandomNumber];
    NSString *spbill_create_ip = [NSString dw_obtainIPAddress];
    NSString *string = [NSString stringWithFormat:@"appid=%@&body=%@&mch_id=%@&nonce_str=%@&notify_url=%@&out_trade_no=%@&spbill_create_ip=%@&total_fee=%d&trade_type=APP",
                                                    appid,
                                                    body,
                                                    mch_id,
                                                    nonce_str,
                                                    notify_url,
                                                    out_trade_no,
                                                    spbill_create_ip,
                                                    total_fee];
    NSString *stringSignTemp = [NSString stringWithFormat:@"%@&key=%@",string,partnerKey];
    NSString *sign = [NSString dw_md5String:stringSignTemp];
    NSString *xmlString = [NSString dw_obtainWXPayXmlAppid:appid mch_id:mch_id nonce_str:nonce_str sign:sign body:body out_trade_no:out_trade_no total_fee:total_fee spbill_create_ip:spbill_create_ip notify_url:notify_url trade_type:@"APP"];
    return [NSString stringWithString:xmlString];
}

#pragma mark - 获取查询订单最终发送的xml字符串
- (NSString *)dw_obtainWXQueryOrderXmlAppid:(NSString *)appid mch_id:(NSString *)mch_id partnerKey:(NSString *)partnerKey out_trade_no:(NSString *)out_trade_no {
    self.partnerKey = partnerKey;
    NSString *nonce_str = [NSString dw_obtainRandomNumber];
    NSString *string = [NSString stringWithFormat:@"appid=%@&mch_id=%@&nonce_str=%@&out_trade_no=%@",
                                                    appid,
                                                    mch_id,
                                                    nonce_str,
                                                    out_trade_no];
    NSString *stringSignTemp = [NSString stringWithFormat:@"%@&key=%@",string,partnerKey];
    NSString *sign = [NSString dw_md5String:stringSignTemp];
    NSString *xmlString = [NSString dw_obtainWXQueryOrderXmlAppid:appid mch_id:mch_id nonce_str:nonce_str out_trade_no:out_trade_no sign:sign];
    return [NSString stringWithString:xmlString];
}

#pragma mark - 发送微信支付/查询订单请求
- (void)dw_wxRequestType:(DWWXRequestType)wxRequestType xmlString:(NSString *)xmlString success:(DWWXOperatingSuccess)success result:(DWWXOperatingErrorResult)result {
    __weak __typeof(self)weakSelf = self;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:wxRequestType==DWWXPayMoney?WXPayURLString:WXQueryOrderURLString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
    [request setHTTPBody:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *respParams = [DWWXPayXmlParser dw_parseData:data];
            DWWeChatModel *weChatModel = [DWWeChatModel weChatModelWithDictionary:respParams];
            if (wxRequestType == DWWXOrderquery) {//订单查询
                if ([weChatModel.return_code isEqualToString:@"SUCCESS"]) {
                    if ([weChatModel.result_code isEqualToString:@"SUCCESS"]) {
                        if ([weChatModel.trade_state isEqualToString:@"SUCCESS"]) {
                            success(YES);
                            return;
                        }else if ([weChatModel.trade_state isEqualToString:@"REFUND"]) {
                            result(DWWXOrderqueryResultTypeRefund, weChatModel.trade_state, @"转入退款");
                        }else if ([weChatModel.trade_state isEqualToString:@"NOTPAY"]) {
                            result(DWWXOrderqueryResultTypeNotPay, weChatModel.trade_state, @"未支付");
                        }else if ([weChatModel.trade_state isEqualToString:@"CLOSED"]) {
                            result(DWWXOrderqueryResultTypeClosed, weChatModel.trade_state, @"已关闭");
                        }else if ([weChatModel.trade_state isEqualToString:@"REVOKED"]) {
                            result(DWWXOrderqueryResultTypeRevoked, weChatModel.trade_state, @"已撤消");
                        }else if ([weChatModel.trade_state isEqualToString:@"USERPAYING"]) {
                            result(DWWXOrderqueryResultTypeUserPaying, weChatModel.trade_state, @"用户支付中");
                        }else if ([weChatModel.trade_state isEqualToString:@"PAYERROR"]) {
                            result(DWWXOrderqueryResultTypePayFailed, weChatModel.trade_state, @"交易失败");
                        }
                    }else {
                        if ([weChatModel.err_code isEqualToString:@"ORDERNOTEXIST"]) {
                            result(DWWXOrderqueryResultTypeNotExist, weChatModel.err_code, @"此交易订单号不存在,该API只能查提交支付交易返回成功的订单，请商户检查需要查询的订单号是否正确");
                        }else if ([weChatModel.err_code isEqualToString:@"SYSTEMERROR"]) {
                            result(DWWXOrderqueryResultTypeSystemError, weChatModel.err_code, @"系统错误，系统异常，请再调用发起查询");
                        }
                    }
                }else {
                    result(DWWXOrderqueryResultTypeUnknown, weChatModel.return_msg, @"返回信息，如非空，为错误原因");
                }
            }else {
                if ([weChatModel.return_code isEqualToString:@"SUCCESS"]) {
                    if ([weChatModel.result_code isEqualToString:@"SUCCESS"]) {
                        PayReq *payReq = [[PayReq alloc] init];
                        payReq.partnerId = weChatModel.mch_id;
                        payReq.prepayId = weChatModel.prepay_id;
                        payReq.package = @"Sign=WXPay";
                        payReq.nonceStr = weChatModel.nonce_str;
                        time_t now;
                        time(&now);
                        payReq.timeStamp = (UInt32)[[NSString stringWithFormat:@"%ld", now] integerValue];
                        NSString *string = [NSString stringWithFormat:@"appid=%@&noncestr=%@&package=%@&partnerid=%@&prepayid=%@&timestamp=%d",
                                            weChatModel.appid,
                                            payReq.nonceStr,
                                            payReq.package,
                                            payReq.partnerId,
                                            payReq.prepayId,
                                            payReq.timeStamp];
                        NSString *stringSignTemp = [NSString stringWithFormat:@"%@&key=%@",string,weakSelf.partnerKey];
                        payReq.sign = [[NSString dw_md5String:stringSignTemp] uppercaseString];
                        [WXApi sendReq:payReq];
                        weakSelf.wxPayOperatingSuccess = ^(BOOL paySuccess) {
                            success(paySuccess);
                        };
                        weakSelf.wxOperatingErrorResult = ^(DWWXOperatingResult operatingResult, NSString *error, NSString *errorMsg) {
                            result(operatingResult, error, errorMsg);
                        };
                    }else {
                       if ([weChatModel.err_code isEqualToString:@"SYSTEMERROR"]) {
                            result(DWWXPayResultTypeSystemError, weChatModel.err_code, @"系统异常，请用相同参数重新调用");
                       }else if ([weChatModel.err_code isEqualToString:@"INVALID_REQUEST"]){
                           result(DWWXPayResultTypeUnknown, weChatModel.err_code, @"无效的请求");
                       }else {
                           result(DWWXPayResultTypeUnknown, weChatModel.err_code, weChatModel.err_code_des);
                       }
                    }
                }else {
                    result(DWWXPayResultTypeUnknown, weChatModel.return_msg, @"返回信息，如非空，为错误原因");
                }
            }
        }else {
            result(MAXFLOAT, @"请求失败", @"未能完成请求微信数据");
        }
    }];
    [dataTask resume];
}

#pragma mark - 微信支付完成后回调
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *payResp = (PayResp *)resp;
        switch (payResp.errCode) {
            case WXSuccess:{
                if (self.wxPayOperatingSuccess) {
                    self.wxPayOperatingSuccess(YES);
                }
            }break;
            case WXErrCodeUserCancel: {
                if (self.wxOperatingErrorResult) {
                    self.wxOperatingErrorResult(DWWXPayResultTypeCancel, payResp.errStr, @"用户点击取消并返回");
                }
            }
                break;
            case WXErrCodeCommon: {
                if (self.wxOperatingErrorResult) {
                    self.wxOperatingErrorResult(WXErrCodeCommon, payResp.errStr, @"普通错误类型");
                }
            }break;
            case WXErrCodeSentFail: {
                if (self.wxOperatingErrorResult) {
                    self.wxOperatingErrorResult(WXErrCodeSentFail, payResp.errStr, @"发送失败");
                }
            }break;
            case WXErrCodeAuthDeny: {
                if (self.wxOperatingErrorResult) {
                    self.wxOperatingErrorResult(WXErrCodeAuthDeny, payResp.errStr, @"授权失败");
                }
            }break;
            case WXErrCodeUnsupport: {
                if (self.wxOperatingErrorResult) {
                    self.wxOperatingErrorResult(WXErrCodeUnsupport, payResp.errStr, @"微信不支持");
                }
            }break;
            default:
                break;
        }
    }
}

@end

/** 数据模型 */
@implementation DWWeChatModel
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
+ (instancetype)weChatModelWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    //防止程序case
}
@end

/** xml解析 */
@implementation DWWXPayXmlParser
+ (NSDictionary*)dw_parseData:(NSData*)data {
    DWWXPayXmlParser* parser = [[DWWXPayXmlParser alloc] init];
    return [parser dw_parseData:data];
}
- (NSDictionary*)dw_parseData:(NSData*)data {
    lastError = nil;
    dictionary = [NSMutableDictionary new];
    valBuffer = [NSMutableString string];
    xmlParser = [[NSXMLParser alloc] initWithData:data];
    [xmlParser setDelegate:self];
    [xmlParser parse];
    if(lastError)
        return nil;
    return [dictionary copy];
}
- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string{
    [valBuffer setString:string];
}

- (void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName{
    if([valBuffer isEqualToString:@"\n"]==NO &&
       [elementName isEqualToString:@"root"]==NO) {
        [dictionary setObject:[valBuffer copy] forKey:elementName];
    }
}
- (void)parser:(NSXMLParser*)parser parseErrorOccurred:(NSError*)parseError {
    lastError = parseError;
}
- (void)parser:(NSXMLParser*)parser validationErrorOccurred:(NSError*)validationError {
    lastError = validationError;
}
@end

/** 字符处理 */
@implementation NSString (Extension)
+ (NSString *)dw_md5String:(NSString *)string {
    const char *myPasswd = [string UTF8String ];
    unsigned char mdc[ 16 ];
    CC_MD5 (myPasswd, ( CC_LONG ) strlen (myPasswd), mdc);
    NSMutableString *md5String = [ NSMutableString string ];
    for ( int i = 0 ; i< 16 ; i++) {
        [md5String appendFormat : @"%02x" ,mdc[i]];
    }
    NSString *md5Str = [md5String uppercaseString];
    return md5Str;
}
+ (NSString *)dw_obtainRandomNumber {
    NSArray *sourceStr = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",
                           @"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",
                           @"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",
                           @"U",@"V",@"W",@"X",@"Y",@"Z"];
    NSString *resultStr = [[NSMutableString alloc] init];
    for (int i = 0; i < 32; i ++) {
        int value = arc4random() % 32;
        resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@",sourceStr[value]]];
    }
    return [NSString stringWithString:resultStr];
}
+ (NSString *)dw_obtainIPAddress {
    int sockfd =socket(AF_INET,SOCK_DGRAM, 0);
    //    if (sockfd <</span> 0) return nil;
    NSMutableArray *ips = [NSMutableArray array];
    int BUFFERSIZE =4096;
    struct ifconf ifc;
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifreq *ifr, ifrcopy;
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    if (ioctl(sockfd,SIOCGIFCONF, &ifc) >= 0) {
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ) {
                    ifr = (struct ifreq *)ptr;
            int len =sizeof(struct sockaddr);
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            ptr += sizeof(ifr->ifr_name) + len;
            if (ifr->ifr_addr.sa_family !=AF_INET) continue;
            if ((cptr = (char *)strchr(ifr->ifr_name,':')) != NULL) *cptr = 0;
            if (strncmp(lastname, ifr->ifr_name,IFNAMSIZ) == 0)continue;
            memcpy(lastname, ifr->ifr_name,IFNAMSIZ);
            ifrcopy = *ifr;
            ioctl(sockfd,SIOCGIFFLAGS, &ifrcopy);
            if ((ifrcopy.ifr_flags &IFF_UP) == 0)continue;
            NSString *ip = [NSString stringWithFormat:@"%s",inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            [ips addObject:ip];
        }
    }
    close(sockfd);
    NSString *deviceIP =@"";
    for (int i=0; i < ips.count; i++) {
        if (ips.count >0) {
            deviceIP = [NSString stringWithFormat:@"%@",ips.lastObject];
        }
    }
    return deviceIP;
}
+ (NSString *)dw_obtainWXPayXmlAppid:(NSString *)appid mch_id:(NSString *)mch_id nonce_str:(NSString *)nonce_str sign:(NSString *)sign body:(NSString *)body out_trade_no:(NSString *)out_trade_no total_fee:(int)total_fee spbill_create_ip:(NSString *)spbill_create_ip notify_url:(NSString *)notify_url trade_type:(NSString *)trade_type {
    NSString *xmlString = [NSString stringWithFormat:@"<xml><appid>%@</appid><body>%@</body><mch_id>%@</mch_id><nonce_str>%@</nonce_str><notify_url>%@</notify_url><out_trade_no>%@</out_trade_no><spbill_create_ip>%@</spbill_create_ip><total_fee>%d</total_fee><trade_type>%@</trade_type><sign>%@</sign></xml>",
                                                           appid,
                                                           body,
                                                           mch_id,
                                                           nonce_str,
                                                           notify_url,
                                                           out_trade_no,
                                                           spbill_create_ip,
                                                           total_fee,
                                                           trade_type,
                                                            sign];
    return [NSString stringWithString:xmlString];
}
+ (NSString *)dw_obtainWXQueryOrderXmlAppid:(NSString *)appid mch_id:(NSString *)mch_id nonce_str:(NSString *)nonce_str out_trade_no:(NSString *)out_trade_no sign:(NSString *)sign {
    NSString *xmlString = [NSString stringWithFormat:@"<xml><appid>%@</appid><mch_id>%@</mch_id><nonce_str>%@</nonce_str><out_trade_no>%@</out_trade_no><sign>%@</sign></xml>",
                                                           appid,
                                                           mch_id,
                                                           nonce_str,
                                                           out_trade_no,
                                                           sign];
    return [NSString stringWithString:xmlString];
}
@end
