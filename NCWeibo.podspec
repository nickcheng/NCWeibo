Pod::Spec.new do |s|
  s.name         = "NCWeibo"
  s.version      = "0.1.9"
  s.summary      = "Another non-official Sina Weibo SDK in Objective-C."
  s.homepage     = "https://github.com/nickcheng/NCWeibo"
  s.license      = {:type=>'MIT', :file=>"LICENSE"}
  s.author       = { "nickcheng" => "n@nickcheng.com" }
  s.source       = { :git => "https://github.com/nickcheng/NCWeibo.git", :tag => "0.1.9" }
  s.platform     = :ios, '6.0'
  s.source_files = 'NCWeibo/**/*.{h,m}'
  s.public_header_files = 'NCWeibo/**/*.h'
  s.frameworks = 'SystemConfiguration', 'Security', 'MobileCoreServices'
  s.requires_arc = true
  s.dependency 'SSKeychain', '~> 1.2'
  s.dependency 'AFNetworking', '~> 2.4'
  s.dependency 'MBProgressHUD', '~> 0.9'
end
