Pod::Spec.new do |s|
  s.name             = 'AbstractHTTP'
  s.version          = '0.7.03'
  s.summary          = 'Abstract HTTP processing library.'
  s.homepage         = 'https://github.com/Kibaan/AbstractHTTP-iOS'
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author           = { 'altonotes' => 'kibaan@altonotes.co.jp' }
  s.source           = { :git => 'https://github.com/Kibaan/AbstractHTTP-iOS.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.1'
  s.source_files = 'AbstractHTTP/AbstractHTTP/**/*.{swift,xib}'
end
