Pod::Spec.new do |s|
  s.name         = "DWWXSDK"
  s.version      = "0.0.1"
  s.summary      = "基于微信SDK1.7.7的封装文件"
  s.description  = <<-DESC
  基于微信SDK1.7.7,支持登录授权、支付、订单状态查询、分享，一句代码搞定这些功能
                   DESC
  s.homepage     = "https://github.com/dwanghello/DWWXSDK"
  s.license      = "MIT"
  s.author             = { "dwanghello" => "dwang.hello@outlook.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/dwanghello/DWWXSDK.git", :tag => s.version.to_s }
  s.source_files  = "DWWXSDK", "DWWXSDK/**/*.{h,m}"
end
