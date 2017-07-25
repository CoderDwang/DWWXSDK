[![GitHub stars](https://img.shields.io/github/stars/dwanghello/DWWXSDK.svg)](https://github.com/asiosldh/DWWXSDK/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/dwanghello/DWWXSDK.svg)](https://github.com/asiosldh/DWWXSDK/forkgazers)
# DWWXSDK
### 此工程基于Xcode8.3.3创建，低版本Xcode打开可能会无法使用

---

### *如果感觉不错，请给个Star支持一下*
#### *使用中如果遇到什么问题可以联系我*
##### *QQ群:577506623*
![QQ群](https://github.com/dwanghello/DWTransform/blob/master/QQ群.png)
##### *e-mail:dwang.hello@outlook.com*

---
如果使用了pod导入了微信的SDK，则可直接将[本文件](https://github.com/dwanghello/DWWXSDK/tree/master/DWWXSDK)导入到工程中使用,如果未使用pod导入可以参考[微信官方SDK手动导入方法](https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=1417694084&token=&lang=zh_CN),将微信SDK导入完成后,将本文件引入到工程中即可使用

---
#### 以下内容皆认为是已将微信SDK与本文件成功集成到工程中
- 检查是否安装微信

        NSLog(@"是否安装微信:%d", [DWWXSDK dw_isWXAppInstalled]);
- 判断当前微信的版本是否支持OpenApi

        NSLog(@"是否支持OpenApi:%d", [DWWXSDK dw_isWXAppSupportApi]);
- 获取微信的itunes安装地址

        NSLog(@"微信的itunes安装地址:%@", [DWWXSDK dw_getWXAppInstallUrl]);
        
- 获取当前微信SDK的版本号

        NSLog(@"当前微信SDK的版本号:%@", [DWWXSDK dw_getApiVersion]);
- 在<strong>- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions</strong>方法中加入以下代码

        [DWWXSDK dw_registerApp:@"appid"];
        return YES;

- 在info.plist中加入以下内容
        
        <dict>
        <key>NSAllowsArbitraryLoads</key>
	       <true/>
	       <key>NSExceptionDomains</key>
	       <dict>
		<key>qq.com</key>
		<dict>
			<key>NSExceptionAllowsInsecureHTTPLoads</key>
			<true/>
			<key>NSExceptionRequiresForwardSecrecy</key>
			<false/>
			<key>NSIncludesSubdomains</key>
			<true/>
		</dict>
	       </dict>
        <array>
	       <dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLName</key>
		<string>vip.dwang.DWWXPayDemo</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>vip.dwang</string>
		</array>
	       </dict>
	       <dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLName</key>
		<string>weixin</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>appid</string>
		</array>
	       </dict>
        </array>
        <array>
	       <string>wechat</string>
	       <string>weixin</string>
        </array>
- info图片示例
![info图片示例](https://github.com/dwanghello/DWWXSDK/blob/master/示例/info.png)



- 重写以下三个方法,直接copy即可
    
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
- AppDelegate图片示例
![AppDelegate](https://github.com/dwanghello/DWWXSDK/blob/master/示例/AppDelegate.png)

- 以下内容为DWWXSDK中的一些方法的调用示例
    - 登录授权
            
            DWWXSDK *wxsdk = [DWWXSDK wxSDK];
            [wxsdk dw_wxLoginOAuthWXAppid:@"appid" wxSecret:@"秘钥" wxState:@"用于保持请求和回调的状态，授权请求后原样带回给第三方。该参数可用于防止csrf攻击（跨站请求伪造攻击），建议第三方带上该参数，可设置为简单的随机数加session进行校验" successBlock:^(DWWeChatProfileModel *profileModel) {
            NSLog(@"%@\n%@\n%@", profileModel.nickname, profileModel.headimgurl, profileModel.unionid);
            } errorBlock:^(NSError *error, NSInteger errcode, NSString *errmsg) {
            NSLog(@"%@\n%ld\n%@", error, errcode, errmsg);
            }];
    - 单独获取用户信息/必须是在已经获取登录授权之后调用此接口,否则之后走error
            
            DWWXSDK *wxsdk = [DWWXSDK wxSDK];
            [wxsdk dw_wxLoginUserInfoWXAppid:@"appid" successBlock:^(DWWeChatProfileModel *profileModel) {
            NSLog(@"%@\n%@\n%@", profileModel.nickname, profileModel.headimgurl, profileModel.unionid);
            } errorBlock:^(NSInteger errcode, NSString *errmsg) {
            NSLog(@"%ld\n%@", errcode, errmsg);
            }];
    - 单独刷新令牌过期时间
        
            DWWXSDK *wxsdk = [DWWXSDK wxSDK];
            [wxsdk dw_wxLoginUpDataAccessTokenWXAppid:@"appid" successBlock:^(NSString *access_token, CGFloat expires_in, NSString *refresh_token, NSString *openid, NSString *scope) {NSLog(@"%@\n%f\n%@\n%@\n%@", access_token, expires_in, refresh_token, openid, scope);
            } errorBlock:^(NSInteger errcode, NSString *errmsg) {
            NSLog(@"%ld\n%@", errcode, errmsg);
            }];
    - 微信支付
    
            DWWXSDK *wxsdk = [DWWXSDK wxSDK];
            NSString *xmlString = [wxsdk dw_obtainWXPayXmlAppid:@"appid" mch_id:@"商户号" partnerKey:@"商户Key密钥" body:@"商品描述" out_trade_no:@"商户订单号" total_fee:[@"订单总金额,单位为分" intValue] notify_url:@"接收微信支付异步通知回调地址，通知url必须为直接可访问的url，不能携带参数"];
            [wxsdk dw_wxRequestType:DWWXPayMoney xmlString:xmlString success:^(BOOL success) {
            NSLog(@"支付成功");
            } result:^(DWWXOperatingResult operatingResult, NSString *error, NSString *errorMsg) {
            NSLog(@"错误码:%ld\n%@\n错误Log:%@", operatingResult, error, errorMsg);
            }];
    - 订单状态查询

            DWWXSDK *wxsdk = [DWWXSDK wxSDK];
            NSString *xmlString = [wxsdk dw_obtainWXQueryOrderXmlAppid:@"appid" mch_id:@"商户号" partnerKey:@"商户Key密钥" out_trade_no:@"查询的订单号"];
            [wxsdk dw_wxRequestType:DWWXOrderquery xmlString:xmlString success:^(BOOL success) {
            NSLog(@"此订单已支付成功");
            } result:^(DWWXOperatingResult operatingResult, NSString *error, NSString *errorMsg) {
            NSLog(@"错误码:%ld\n%@\n错误Log:%@", operatingResult, error, errorMsg);
            }];
    - 分享纯文本内容
        
            DWWXSDK *wxsdk = [DWWXSDK wxSDK];
            [wxsdk dw_wxShareMsg:@"测试分享文本" wxShareScene:DWWXShareSession wxShareSuccess:^(BOOL success) {
            NSLog(@"分享成功");
            } wxShareResultError:^(DWWXOperatingResult operatingResult, NSString *error, NSString *errorMsg) {
            NSLog(@"%ld\n%@\n%@", operatingResult, error, errorMsg);
            }];
    - 分享image、音频、网页、小程序皆与分享纯文本内容相似
    - DWWXSDK部分方法调用图片示例
    ![AppDelegate](https://github.com/dwanghello/DWWXSDK/blob/master/示例/DWWXSDK部分方法调用示例.png)

- 统计代码行数

		find . "(" -name "*.m" -or -name "*.mm" -or -name "*.cpp" -or -name "*.h" -or -name "*.rss" ")" -print | xargs wc -l
- 其中 -name  "*.m" 就表示扩展名为.m的文件。同时要统计java文件和xml文件的命令分别是：

		find . "(" -name "*.java"  ")" -print | xargs wc -l
		以及：
		find . "(" -name "*.xml"  ")" -print | xargs wc -l


