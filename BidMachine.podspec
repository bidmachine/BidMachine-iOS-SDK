Pod::Spec.new do |s|
  s.name         = "BidMachine"
  s.version      = "1.6.0-beta6"
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
    ss.dependency 'StackModules', '~> 0.8.0.3-Beta'
    ss.dependency 'StackIAB', '~> 0.5.0'
    ss.dependency 'Protobuf', '~> 3.9'
  end

  s.subspec 'Adapters' do |ss|
    ss.dependency 'BidMachine/AdColonyAdapter'
    ss.dependency 'BidMachine/FacebookAdapter'
    ss.dependency 'BidMachine/MyTargetAdapter'
    ss.dependency 'BidMachine/TapjoyAdapter'
    ss.dependency 'BidMachine/VungleAdapter'
    ss.dependency 'BidMachine/CriteoAdapter'
    ss.dependency 'BidMachine/AmazonAdapter'
    ss.dependency 'BidMachine/SmaatoAdapter'
  end

  s.subspec 'AdColonyAdapter' do |ss|
    ss.vendored_libraries = 'libBDMAdColonyAdapter.a'
    ss.dependency 'BidMachine/Core'
    ss.dependency 'AdColony', '4.3.0'
  end

  s.subspec 'FacebookAdapter' do |ss|
    ss.vendored_libraries = 'libBDMFacebookAdapter.a' 
    ss.dependency 'BidMachine/Core'
    ss.dependency 'FBAudienceNetwork', '5.10.1'
  end

  s.subspec 'MyTargetAdapter' do |ss|
    ss.vendored_libraries = 'libBDMMyTargetAdapter.a'
    ss.dependency 'BidMachine/Core' 
    ss.dependency 'myTargetSDK', '5.7.1'
  end

  s.subspec 'TapjoyAdapter' do |ss|
    ss.vendored_libraries = 'libBDMTapjoyAdapter.a'
    ss.dependency 'BidMachine/Core' 
    ss.dependency 'TapjoySDK', '12.6.1'
  end

  s.subspec 'VungleAdapter' do |ss|
    ss.vendored_libraries = 'libBDMVungleAdapter.a' 
    ss.dependency 'BidMachine/Core'
    ss.dependency 'VungleSDK-iOS', '6.7.0'
  end

  s.subspec 'CriteoAdapter' do |ss|
    ss.vendored_libraries = 'libBDMCriteoAdapter.a' 
    ss.dependency 'BidMachine/Core'
    ss.dependency 'CriteoPublisherSdk', '3.4.1'
  end

  s.subspec 'AmazonAdapter' do |ss|
    ss.vendored_libraries = 'BDMAmazonAdapter.embeddedframework/*.a' 
    ss.vendored_frameworks = 'BDMAmazonAdapter.embeddedframework/*.framework' 

    ss.dependency 'BidMachine/Core'
  end

  s.subspec 'SmaatoAdapter' do |ss|
    ss.vendored_libraries = 'libBDMSmaatoAdapter.a' 
    ss.dependency 'BidMachine/Core'
    ss.dependency 'smaato-ios-sdk', '21.5.2'
    ss.dependency 'smaato-ios-sdk/Modules/UnifiedBidding', '21.5.2'
  end
end
