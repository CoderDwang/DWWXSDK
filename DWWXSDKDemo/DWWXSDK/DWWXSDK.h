//
//  DWWXPay.h
//  DWWXPayDemo
//
//  Created by dwang.vip on 2017/6/12.
//  Copyright © 2017年 dwang. All rights reserved.


/*****************************此文件基于微信SDK 1.7.7版本******************************/


#import <Foundation/Foundation.h>
#import "WXApi.h"
@class DWWeChatProfileModel;

typedef enum : NSUInteger {
    /** 微信支付 */
    DWWXPayMoney,
    /** 订单查询 */
    DWWXOrderquery
} DWWXRequestType;

typedef enum : NSUInteger {
    /** 发送到聊天界面 */
    DWWXShareSession,
    /** 发送到朋友圈 */
    DWWXShareTimeline,
    /** 添加到微信收藏 */
    DWWXShareFavorite,
} DWWXShareScene;

typedef NS_ENUM(NSUInteger, DWWXOperatingResult) {
    /** 转入退款 */
    DWWXOrderqueryResultTypeRefund = 0,
    
    /** 未支付 */
    DWWXOrderqueryResultTypeNotPay,
    
    /** 交易已关闭 */
    DWWXOrderqueryResultTypeClosed,
    
    /** 已撤销（刷卡支付） */
    DWWXOrderqueryResultTypeRevoked,
    
    /** 用户支付中 */
    DWWXOrderqueryResultTypeUserPaying,
    
    /** 交易失败(其他原因，如银行返回失败) */
    DWWXOrderqueryResultTypePayFailed,
    
    /** 此交易订单号不存在,该API只能查提交支付交易返回成功的订单，请商户检查需要查询的订单号是否正确 */
    DWWXOrderqueryResultTypeNotExist,
    
    /** 系统错误，系统异常，请再调用发起查询 */
    DWWXOrderqueryResultTypeSystemError,
    
    /** 其它原因 */
    DWWXOrderqueryResultTypeUnknown,
    
    /** 用户点击取消并返回 */
    DWWXPayResultTypeUserCancel,
    
    /** 发送失败 */
    DWWXPayResultTypeSentFail,
    
    /** 普通错误类型 */
    DWWXPayResultTypeCommon,
    
    /** 授权失败 */
    DWWXPayResultTypeAuthDeny,
    
    /** 微信不支持 */
    DWWXPayResultTypeUnsupport,
    
    /** 其它原因 */
    DWWXPayResultTypeUnknown,
    
    /** 系统异常 */
    DWWXPayResultTypeSystemError,
    
    /** 用户点击取消并返回 */
    DWWXShareResultTypeUserCancel,
    
    /** 发送失败 */
    DWWXShareResultTypeSentFail,
    
    /** 其它原因 */
    DWWXShareResultTypeUnknown
};

@interface DWWXSDK : NSObject<WXApiDelegate>

/** 支付成功的回调 */
typedef void (^DWWXOperatingSuccess)(BOOL success);
/** 错误回调 */
typedef void (^DWWXOperatingErrorResult)(DWWXOperatingResult operatingResult, NSString *error, NSString *errorMsg);
@property(nonatomic, copy) DWWXOperatingSuccess wxPayOperatingSuccess;
@property(nonatomic, copy) DWWXOperatingErrorResult wxOperatingErrorResult;

/** 登录成功获取用户信息的回调 */
typedef void (^DWWXLoginSuccess)(DWWeChatProfileModel *profileModel);
/** 登录失败的回调 */
typedef void (^DWWXLoginErrorResult)(NSError *error, NSInteger errcode, NSString *errmsg);
@property(nonatomic, copy) DWWXLoginSuccess wxProfileModel;
@property(nonatomic, copy) DWWXLoginErrorResult wxLoginErrorResult;

/** 分享成功的回调 */
typedef void (^DWShareSuccess)(BOOL success);
@property(nonatomic, copy) DWShareSuccess shareSuccess;

/**
 *  单例创建支付对象
 *
 */
+ (instancetype)wxSDK;

/**
 *  向微信终端程序注册第三方应用。
 *
 *  @param appid        微信开发者ID
 *  @param isEnableMTA  是否支持MTA数据上报
 *  @return 成功返回YES，失败返回NO。
 */
+ (BOOL)dw_registerApp:(NSString *)appid enableMTA:(BOOL)isEnableMTA;

/**
 向微信终端程序注册第三方应用。

 @param appid 微信开发者ID
 @return 是否注册成功
 */
+ (BOOL)dw_registerApp:(NSString *)appid;

/**
 获取付款需要的xml

 @param appid 微信开放平台审核通过的应用APPID
 @param mch_id 微信支付分配的商户号
 @param partnerKey 商户Key密钥/key设置路径：微信商户平台(pay.weixin.qq.com)-->账户设置-->API安全-->密钥设置
 @param body 商品描述
 @param out_trade_no 商户订单号
 @param total_fee 订单总金额，单位为分
 @param notify_url 接收微信支付异步通知回调地址，通知url必须为直接可访问的url，不能携带参数。
 @return xmlString
 */
- (NSString *)dw_obtainWXPayXmlAppid:(NSString *)appid mch_id:(NSString *)mch_id partnerKey:(NSString *)partnerKey body:(NSString *)body out_trade_no:(NSString *)out_trade_no total_fee:(int)total_fee notify_url:(NSString *)notify_url;

/**
 获取查询订单需要的xml

 @param appid 微信开放平台审核通过的应用APPID
 @param mch_id 微信支付分配的商户号
 @param partnerKey 商户Key密钥/key设置路径：微信商户平台(pay.weixin.qq.com)-->账户设置-->API安全-->密钥设置
 @param out_trade_no 商户订单号
 @return xmlString
 */
- (NSString *)dw_obtainWXQueryOrderXmlAppid:(NSString *)appid mch_id:(NSString *)mch_id partnerKey:(NSString *)partnerKey out_trade_no:(NSString *)out_trade_no;


/**
 调起支付/查询订单

 @param wxRequestType 操作类型
 @param xmlString 发送的xml数据
 @param success 成功
 @param result 失败
 */
- (void)dw_wxRequestType:(DWWXRequestType)wxRequestType xmlString:(NSString *)xmlString success:(DWWXOperatingSuccess)success result:(DWWXOperatingErrorResult)result;

/**
 微信登录

 @param wxAppid 微信开放平台审核通过的应用APPID
 @param wxSecret 应用密钥AppSecret，在微信开放平台提交应用审核通过后获得
 @param wxState 用于保持请求和回调的状态，授权请求后原样带回给第三方。该参数可用于防止csrf攻击（跨站请求伪造攻击），建议第三方带上该参数，可设置为简单的随机数加session进行校验
 @param successBlock 登录成功后获取用户信息的block
 @param errorBlock 登录失败的Block
 */
- (void)dw_wxLoginOAuthWXAppid:(NSString *)wxAppid wxSecret:(NSString *)wxSecret wxState:(NSString *)wxState successBlock:(DWWXLoginSuccess)successBlock errorBlock:(DWWXLoginErrorResult)errorBlock;

/**
 获取个人信息

 @param wxAppid 微信开放平台审核通过的应用APPID
 @param successBlock 成功获取用户信息的block
 @param errorBlock 信息获取失败,可能需要重新调起微信授权
 */
- (void)dw_wxLoginUserInfoWXAppid:(NSString *)wxAppid successBlock:(DWWXLoginSuccess)successBlock errorBlock:(void(^)(NSInteger errcode, NSString *errmsg))errorBlock;

/**
 刷新或续期access_token使用

 @param wxAppid 微信开放平台审核通过的应用APPID
 @param successBlock 成功刷新或续期access_token的block
 @param errorBlock 刷新失败的block
 */
- (void)dw_wxLoginUpDataAccessTokenWXAppid:(NSString *)wxAppid successBlock:(void(^)(NSString *access_token, CGFloat expires_in, NSString *refresh_token, NSString *openid, NSString *scope))successBlock errorBlock:(void(^)(NSInteger errcode, NSString *errmsg))errorBlock;

/**
 分享文本至微信

 @param wxMsg 分享的文字内容
 @param wxShareScene 分享的目标场景
 @param wxShareSuccess 分享成功的回调
 @param wxShareResultError 分享失败的回调
 */
- (void)dw_wxShareMsg:(NSString *)wxMsg wxShareScene:(DWWXShareScene)wxShareScene wxShareSuccess:(DWShareSuccess)wxShareSuccess wxShareResultError:(DWWXOperatingErrorResult)wxShareResultError;

/**
 分享图片至微信

 @param wxImage 缩略图
 @param wxFilePath 图片真实数据内容/大小不能超过10M
 @param wxImageTitle 标题
 @param wxImageDescription 描述
 @param wxShareScene 分享的目标场景
 @param wxShareSuccess 分享成功的回调
 @param wxShareResultError 分享失败的回调
 */
- (void)dw_wxShareImage:(UIImage *)wxImage wxFilePath:(NSString *)wxFilePath wxImageTitle:(NSString *)wxImageTitle wxImageDescription:(NSString *)wxImageDescription wxShareScene:(DWWXShareScene)wxShareScene wxShareSuccess:(DWShareSuccess)wxShareSuccess wxShareResultError:(DWWXOperatingErrorResult)wxShareResultError;

/**
 分享音乐至微信

 @param wxMUString 音乐网页的url地址
 @param wxMDataUString 音乐数据url地址
 @param wxMTitle 标题
 @param wxMDescription 描述
 @param wxMImage 缩略图
 @param wxShareScene 分享的目标场景
 @param wxShareSuccess 分享成功的回调
 @param wxShareResultError 分享失败的回调
 */
- (void)dw_wxShareMusic:(NSString *)wxMUString wxMDataUString:(NSString *)wxMDataUString wxMTitle:(NSString *)wxMTitle wxMDescription:(NSString *)wxMDescription wxMImage:(UIImage *)wxMImage wxShareScene:(DWWXShareScene)wxShareScene wxShareSuccess:(DWShareSuccess)wxShareSuccess wxShareResultError:(DWWXOperatingErrorResult)wxShareResultError;

/**
 分享视频至微信

 @param wxVUString 视频网页的url地址
 @param wxVTitle 标题
 @param wxVDescription 描述
 @param wxVimage 缩略图
 @param wxShareScene 分享的目标场景
 @param wxShareSuccess 分享成功的回调
 @param wxShareResultError 分享失败的回调
 */
- (void)dw_wxShareVideo:(NSString *)wxVUString wxVTitle:(NSString *)wxVTitle wxVDescription:(NSString *)wxVDescription wxVImage:(UIImage *)wxVimage wxShareScene:(DWWXShareScene)wxShareScene wxShareSuccess:(DWShareSuccess)wxShareSuccess wxShareResultError:(DWWXOperatingErrorResult)wxShareResultError;

/**
 分享网页至微信

 @param wxWUString 网页的url地址
 @param wxWTitle 标题
 @param wxWDescription 描述
 @param wxWImage 缩略图
 @param wxShareScene 分享的目标场景
 @param wxShareSuccess 分享成功的回调
 @param wxShareResultError 分享失败的回调
 */
- (void)dw_wxShareWeb:(NSString *)wxWUString wxWTitle:(NSString *)wxWTitle wxWDescription:(NSString *)wxWDescription wxWImage:(UIImage *)wxWImage wxShareScene:(DWWXShareScene)wxShareScene wxShareSuccess:(DWShareSuccess)wxShareSuccess wxShareResultError:(DWWXOperatingErrorResult)wxShareResultError;

/**
 分享小程序至微信好友/目前仅支持分享小程序类型消息至会话。

 @param wxWebPageUString 低版本网页链接
 @param wxMiniUserName 小程序username
 @param wxMiniPath 小程序页面的路径
 @param wxMiniTitle 标题
 @param wxMiniDescription 描述
 @param wxMiniImage 缩略图
 @param wxShareSuccess 分享成功的回调
 @param wxShareResultError 分享失败的回调
 */
- (void)dw_wxShareMiniProgramOBJ:(NSString *)wxWebPageUString wxMiniUserName:(NSString *)wxMiniUserName wxMiniPath:(NSString *)wxMiniPath wxMiniTitle:(NSString *)wxMiniTitle wxMiniDescription:(NSString *)wxMiniDescription wxMiniImage:(UIImage *)wxMiniImage wxShareSuccess:(DWShareSuccess)wxShareSuccess wxShareResultError:(DWWXOperatingErrorResult)wxShareResultError;

/** 退出微信登录后需要清除UserDefaults中存储的内容 */
+ (void)dw_removeAllWXLoginUserDefaultsObjects;

/** 检查是否安装微信 */
+ (BOOL)dw_isWXAppInstalled;

/** 判断当前微信的版本是否支持OpenApi */
+ (BOOL)dw_isWXAppSupportApi;

/** 获取微信的itunes安装地址 */
+ (NSString *)dw_getWXAppInstallUrl;

/** 获取当前微信SDK的版本号 */
+ (NSString *)dw_getApiVersion;

@end


@interface DWWeChatModel : NSObject

/**
 *  此字段是通信标识，非交易标识，交易是否成功需要查看result_code来判断
 *  SUCCESS/FAIL
 */
@property (copy, nonatomic) NSString *return_code;

/**
 *  返回信息，如非空，为错误原因
 *  签名失败
 *  参数格式校验错误
 */
@property (copy, nonatomic) NSString *return_msg;

/**
 *  应用APPID
 */
@property (copy, nonatomic) NSString *appid;

/**
 *  商户号
 */
@property (copy, nonatomic) NSString *mch_id;

/**
 *  设备号，
 */
@property (copy, nonatomic) NSString *device_info;

/**
 *  随机字符串
 */
@property (copy, nonatomic) NSString *nonce_str;

/**
 *  签名
 */
@property (copy, nonatomic) NSString* sign;

/**
 *  业务结果
 */
@property (copy, nonatomic) NSString *result_code;

/**
 *  错误代码
 */
@property (copy, nonatomic) NSString *err_code;

/**
 *  错误代码描述
 */
@property (copy, nonatomic) NSString *err_code_des;

/**
 *  交易类型
 */
@property (copy, nonatomic) NSString *trade_type;

/**
 *  预支付交易会话标识
 */
@property (copy, nonatomic) NSString *prepay_id;

/***********************************以下为微信登录的数据模型*************************************/

/** 接口调用凭证 */
@property(nonatomic, copy) NSString *access_token;

/** access_token接口调用凭证超时时间，单位（秒） */
@property(nonatomic, assign) CGFloat expires_in;

/** 用户刷新access_token */
@property(nonatomic, copy) NSString *refresh_token;

/** 授权用户唯一标识 */
@property(nonatomic, copy) NSString *openid;

/** 用户授权的作用域，使用逗号（,）分隔 */
@property(nonatomic, copy) NSString *scope;

/**  当且仅当该移动应用已获得该用户的userinfo授权时，才会出现该字段 */
@property(nonatomic, copy) NSString *unionid;

/** 错误码 */
@property(nonatomic, assign) NSInteger errcode;

/** 错误日志 */
@property(nonatomic, copy) NSString *errmsg;

/**
 *  交易状态
 */
@property (copy, nonatomic) NSString *trade_state;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
+ (instancetype)weChatModelWithDictionary:(NSDictionary *)dict;
@end

/************************************微信登录成功后获取的用户个人信息*****************************************/
@interface DWWeChatProfileModel : NSObject

/** 普通用户的标识，对当前开发者帐号唯一 */
@property(nonatomic, copy) NSString *openid;

/** 普通用户昵称 */
@property(nonatomic, copy) NSString *nickname;

/** 普通用户性别，1为男性，2为女性 */
@property(nonatomic, assign) NSInteger sex;

/** 普通用户个人资料填写的省份 */
@property(nonatomic, copy) NSString *province;

/** 普通用户个人资料填写的城市 */
@property(nonatomic, copy) NSString *city;

/** 国家，如中国为CN */
@property(nonatomic, copy) NSString *country;

/** 用户头像，最后一个数值代表正方形头像大小（有0、46、64、96、132数值可选，0代表640*640正方形头像），用户没有头像时该项为空 */
@property(nonatomic, copy) NSString *headimgurl;

/** 用户特权信息，json数组，如微信沃卡用户为（chinaunicom） */
@property(nonatomic, strong) NSArray *privilege;

/** 用户统一标识。针对一个微信开放平台帐号下的应用，同一用户的unionid是唯一的。 */
@property(nonatomic, copy) NSString *unionid;

/** 错误码 */
@property(nonatomic, assign) NSInteger errcode;

/** 错误日志 */
@property(nonatomic, copy) NSString *errmsg;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
+ (instancetype)weChatProfileModelWithDictionary:(NSDictionary *)dict;

@end

/************************************字符串扩展*****************************************/
@interface NSString (Extension)
/** md5 一般加密 */
+ (NSString *)dw_md5String:(NSString *)string;

/** 获取随机数 */
+ (NSString *)dw_obtainRandomNumber;

/** 获取IP地址 */
+ (NSString *)dw_obtainIPAddress;

/** 获取付款XML字符串 */
+ (NSString *)dw_obtainWXPayXmlAppid:(NSString *)appid mch_id:(NSString *)mch_id nonce_str:(NSString *)nonce_str sign:(NSString *)sign body:(NSString *)body out_trade_no:(NSString *)out_trade_no total_fee:(int)total_fee spbill_create_ip:(NSString *)spbill_create_ip notify_url:(NSString *)notify_url trade_type:(NSString *)trade_type;

/** 获取查询订单XML字符串 */
+ (NSString *)dw_obtainWXQueryOrderXmlAppid:(NSString *)appid mch_id:(NSString *)mch_id nonce_str:(NSString *)nonce_str out_trade_no:(NSString *)out_trade_no sign:(NSString *)sign;
@end

