Pod::Spec.new do |s|
  s.name         = "BidMachine"
  s.version      = "1.3.2"
  s.summary      = "BidMachine iOS SDK"

  s.description  = <<-DESC
                   iOS client side of bid machine
                   DESC

  s.homepage     = "https://bidmachine.io"

  s.license      = { :type => 'GPL 3.0', :file => 'LICENSE' }
  s.author       = { "Stack" => "https://explorestack.com/bidmachine/" }

  s.platform     = :ios, '9.0'
  s.source       = { :http => "https://s3-us-west-1.amazonaws.com/appodeal-ios/BidMachine/#{s.version}/BidMachine-SDK-iOS-#{s.version}.zip" }

  s.frameworks = "AdSupport", "SystemConfiguration", "CoreTelephony", "SafariServices", "StoreKit"
  s.libraries = "xml2", "z"

  s.default_subspec = 'Core'
  
  s.subspec 'Core' do |ss|
    ss.vendored_frameworks = "BidMachine.framework"
    ss.dependency 'StackModules', '~> 0.6.3'
    ss.dependency 'StackIAB', '~> 0.5.0'
    ss.dependency 'Protobuf', '~> 3.9'
  end

  s.subspec 'AdColonyAdapter' do |ss|
    ss.vendored_libraries = 'libBDMAdColonyAdapter.a'
    ss.dependency 'BidMachine/Core'
    ss.dependency 'AdColony', '~> 3.3'
  end

  s.subspec 'FacebookAdapter' do |ss|
    ss.vendored_libraries = 'libBDMFacebookAdapter.a' 
    ss.dependency 'BidMachine/Core'
    ss.dependency 'FBAudienceNetwork', '~> 5.4'
  end

  s.subspec 'MyTargetAdapter' do |ss|
    ss.vendored_libraries = 'libBDMMyTargetAdapter.a'
    ss.dependency 'BidMachine/Core' 
    ss.dependency 'myTargetSDK', '~> 5.3'
  end

  s.subspec 'TapjoyAdapter' do |ss|
    ss.vendored_libraries = 'libBDMTapjoyAdapter.a'
    ss.dependency 'BidMachine/Core' 
    ss.dependency 'TapjoySDK', '~> 12.3'
  end

  s.subspec 'VungleAdapter' do |ss|
    ss.vendored_libraries = 'libBDMVungleAdapter.a' 
    ss.dependency 'BidMachine/Core'
    ss.dependency 'VungleSDK-iOS', '~> 6.3'
  end

  s.subspec 'MintegralAdapter' do |ss|
    ss.vendored_libraries = 'libBDMMintegralAdapter.a' 
    ss.dependency 'BidMachine/Core'
    ss.dependency 'MintegralAdSDK/BidInterstitialVideoAd', '~> 5.6'
    ss.dependency 'MintegralAdSDK/BidRewardVideoAd', '~> 5.6'
  end

  s.subspec 'CriteoAdapter' do |ss|
    ss.vendored_libraries = 'libBDMCriteoAdapter.a' 
    ss.dependency 'BidMachine/Core'
  end

  s.subspec 'AmazonAdapter' do |ss|
    ss.vendored_libraries = 'BDMAmazonAdapter.embeddedframework/*.a' 
    ss.vendored_frameworks = 'BDMAmazonAdapter.embeddedframework/*.framework' 

    ss.dependency 'BidMachine/Core'
  end
end