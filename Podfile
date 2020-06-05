platform :ios, '9.0'
workspace 'BidMachine.xcworkspace'

# Use Appodeal CocoaPods repo for adapters dependencies
source 'https://github.com/appodeal/CocoaPods.git'
# Use official CocoaPods repo for test dependecies
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
install! 'cocoapods', :deterministic_uuids => false, :warn_for_multiple_pod_sources => false

def protobuf
  pod 'StackAPI/BidMachine', '~> 0.2.0', :inhibit_warnings => true
  pod 'Protobuf', :inhibit_warnings => true
end

def nast
  pod 'StackIAB/StackNASTKit', '~> 0.5.0'
  pod 'StackIAB/StackRichMedia', '~> 0.5.0'
end

def mraid
  pod 'StackIAB/StackMRAIDKit', '~> 0.5.0'
end

def vast 
  pod 'StackIAB/StackVASTKit', '~> 0.5.0'
end

def toasts
  pod 'Toast-Swift', '~> 4.0.0', :inhibit_warnings => true
end

def stack_modules
  pod 'StackModules', '~> 0.7'
  pod 'StackModules/StackFoundation', '~> 0.7'
  pod 'StackModules/StackUIKit', '~> 0.7'
end

def vungle
  pod 'VungleSDK-iOS', '6.5.2'
end

def adcolony
  pod 'AdColony', '4.1.4'
end

def my_target 
  pod 'myTargetSDK', '5.4.2'
end

def tapjoy
  pod 'TapjoySDK', '12.4.2'
end

def facebook
  pod 'FBAudienceNetwork', '5.7.1'
end

def criteo
  pod 'CriteoPublisherSdk', '3.4.1'
end

def mintegral
  pod 'MintegralAdSDK/BidInterstitialVideoAd', '6.0.0.0'
  pod 'MintegralAdSDK/BidRewardVideoAd', '6.0.0.0'
end

def amazon
  pod 'DTBiOSSDK', '3.0.0'
end

def smaato
  pod 'smaato-ios-sdk', '21.2.2'
  pod 'smaato-ios-sdk/Modules/UnifiedBidding', '21.2.2'
end

# Targets configuration
target 'BidMachine' do
  project 'BidMachine/BidMachine.xcodeproj'
  protobuf
  stack_modules
end

target 'BDMMRAIDAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  stack_modules
  mraid
end

target 'BDMNASTAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  stack_modules
  nast
end

target 'BDMCriteoAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  criteo
  stack_modules
end

target 'BDMVASTAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  stack_modules
  vast
end

target 'BDMMyTargetAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  my_target
  stack_modules
end

target 'BDMAdColonyAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  adcolony
  stack_modules
end

target 'BDMVungleAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  vungle
  stack_modules
end

target 'BDMTapjoyAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  tapjoy
  stack_modules
end

target 'BDMFacebookAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  facebook
  stack_modules
end

target 'BDMMintegralAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  mintegral
  stack_modules
end

target 'BDMAmazonAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  amazon
  stack_modules
end

target 'BDMSmaatoAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  smaato
  stack_modules
end

target 'Sample' do
  project 'Sample/Sample.xcodeproj'
  mraid
  vast
  nast
  my_target
  adcolony
  vungle
  tapjoy
  facebook
  mintegral
  amazon
  smaato
  criteo
  stack_modules
  protobuf
  toasts
end

target 'BidMachineTests' do
  project 'BidMachine/BidMachine.xcodeproj'
  pod "Kiwi"
  stack_modules
end
