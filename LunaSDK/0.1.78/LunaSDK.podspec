
Pod::Spec.new do |s|
  s.name             = 'LunaSDK'
  s.version          = '0.1.78'
  s.summary          = 'First release of LunaSDK'

  s.description      = <<-DESC
  This is an early development version of a LunaTracker SDK. 
                       DESC
  s.homepage         = 'https://lunanets.com'
  s.license          = { :type => 'Copyright', :text => 'Copyright 2021 LunaNets' }

  s.author           = { 'Luna Nets' => 'info@lunanets.com' }
  s.source           = { :http => 'https://github.com/indigo-d/luna_ios_published_sdk/releases/download/v0.1.78/LunaSDK-0.1.78.zip' }

  s.ios.deployment_target = '10.0'

  s.vendored_frameworks = ['Frameworks/LunaSDK.xcframework']
    
   s.dependency 'Sodium'
   s.dependency 'iOSDFULibrary'
   s.dependency 'ProgressHUD'
   s.dependency 'MQTTClient'
   s.swift_version =  "5.0"

   s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386', 'EXCLUDED_ARCHS[sdk=iphoneos*]' => 'i386'  }
   s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386', 'EXCLUDED_ARCHS[sdk=iphoneos*]' => 'i386'  }
   
   #s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end