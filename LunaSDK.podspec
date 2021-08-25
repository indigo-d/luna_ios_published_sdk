
Pod::Spec.new do |s|
  s.name             = 'LunaSDK'
  s.version          = '0.1.73'
  s.summary          = 'SDK allowing iOS developers to enhance application with LunaTracker tracking capabilities'

  s.description      = <<-DESC
This is an early development version of a LunaTracker SDK.
                       DESC
  s.homepage         = 'https://lunanets.com'
  s.license          = { :type => 'to be defined', :file => 'LICENSE' }

  s.author           = { 'Luna Nets' => 'info@lunanets.com' }
  s.source           = { :http => 'https://github.com/indigo-d/luna_ios_published_sdk/releases/download/0.1.73.2/LunaSDK-0.1.73.2.zip' }

  s.ios.deployment_target = '10.0'

  s.vendored_frameworks = ['Frameworks/LunaSDK.xcframework']
    
   s.dependency 'Sodium'
   s.dependency 'iOSDFULibrary'
   s.dependency 'ProgressHUD'
   s.dependency 'MQTTClient'
   s.swift_version =  "5.0"
end
