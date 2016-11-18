Pod::Spec.new do |s|
  s.name         = 'NCWeibo'
  s.version      = '0.2.0'
  s.summary      = 'Another non-official Sina Weibo SDK in Objective-C.'
  s.homepage     = 'https://github.com/nickcheng/NCWeibo'
  s.license      = { :type=>'MIT', :file=>'LICENSE' }
  s.author       = { 'nickcheng' => 'n@nickcheng.com' }
  s.source       = { :git => 'https://github.com/nickcheng/NCWeibo.git', :tag => '#{s.version}' }
  s.platform     = :ios, '8.0'
  s.source_files = 'NCWeibo/**/*.{h,m}', 'libWeiboSDK/*.{h,m}'
  s.resource     = 'libWeiboSDK/WeiboSDK.bundle'
  s.vendored_libraries  = 'libWeiboSDK/libWeiboSDK.a'
  s.public_header_files = 'NCWeibo/**/*.h'
  s.frameworks   = 'SystemConfiguration', 'Security', 'MobileCoreServices', 'ImageIO', 'CoreText', 'QuartzCore', 'UIKit', 'Foundation', 'CoreGraphics','CoreTelephony'
  s.libraries    = 'sqlite3', 'z'
  s.requires_arc = true
  s.dependency 'SAMKeychain', '~> 1.5.2'
end
