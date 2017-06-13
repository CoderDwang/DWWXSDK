Pod::Spec.new do |s|
  s.name         = "DWWXSDK"
  s.version      = "0.0.1"
  s.summary      = "微信支付、订单状态查询、登录授权、分享"
  s.description  = <<-DESC
  *本库基于微信SDK1.7.7开发，将微信支付、订单状态查询、登录授权、分享功能简化至极*
                   DESC
  s.homepage     = "https://github.com/dwanghello/DWWXSDK"
  s.license      = "MIT"
  s.author       = { "dwang" => "dwang.hello@outlook.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/dwanghello/DWWXSDK.git", :tag => s.version.to_s}
  s.source_files = "DWWXSDK", "DWWXSDK/**/*.{h,m}"
  s.frameworks   = "SystemConfiguration", "CoreTelephony", "Foundation", "Security", "CFNetwork", "UIKit"
  s.dependency "WechatOpenSDK", "~> 1.7.7"

end
