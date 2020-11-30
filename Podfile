platform :ios, '9.0'
workspace 'BidMachine.xcworkspace'

# Use Appodeal CocoaPods repo for adapters dependencies
source 'https://github.com/appodeal/CocoaPods.git'
# Use official CocoaPods repo for test dependecies
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
install! 'cocoapods', :deterministic_uuids => false, :warn_for_multiple_pod_sources => false

def protobuf
  pod 'StackAPI/BidMachine', '~> 0.6.0', :inhibit_warnings => true
  pod 'Protobuf', :inhibit_warnings => true
end

def nast
  pod 'StackIAB/StackNASTKit', '~> 1.1.0'
  pod 'StackIAB/StackRichMedia', '~> 1.1.0'
end

def mraid
  pod 'StackIAB/StackMRAIDKit', '~> 1.1.0'
end

def vast 
  pod 'StackIAB/StackVASTKit', '~> 1.1.0'
end

def toasts
  pod 'Toast-Swift', '~> 4.0.0', :inhibit_warnings => true
end

def stack_modules
  pod 'StackModules', '~> 1.0.0'
  pod 'StackModules/StackFoundation', '~> 1.0.0'
  pod 'StackModules/StackUIKit', '~> 1.0.0'
end

def vungle
  pod 'VungleSDK-iOS', '6.8.1'
end

def adcolony
  pod 'AdColony', '4.4.1.1'
end

def my_target 
  pod 'myTargetSDK', '5.9.3'
end

def tapjoy
  pod 'TapjoySDK', '12.7.0'
end

def facebook
  pod 'FBAudienceNetwork', '6.2.0'
end

def criteo
  pod 'CriteoPublisherSdk', '4.0.1'
end

def amazon
  pod 'AmazonPublisherServicesSDK', '3.3.0'
end

def smaato
  pod 'smaato-ios-sdk', '21.6.6'
  pod 'smaato-ios-sdk/Modules/UnifiedBidding', '21.6.6'
end

def approll
  pod 'AppRollSDK', '3.1.2'
end

# Targets configuration
target 'BidMachine' do
  project 'BidMachine/BidMachine.xcodeproj'
  protobuf
  stack_modules
end

target 'BDMMRAIDAdapter' do
  project 'BidMachine-iOS-Adaptors/Adaptors.xcodeproj'
  stack_modules
  mraid
end

target 'BDMNASTAdapter' do
  project 'BidMachine-iOS-Adaptors/Adaptors.xcodeproj'
  stack_modules
  nast
end

target 'BDMCriteoAdapter' do
  project 'BidMachine-iOS-Adaptors/Adaptors.xcodeproj'
  criteo
  stack_modules
end

target 'BDMVASTAdapter' do
  project 'BidMachine-iOS-Adaptors/Adaptors.xcodeproj'
  stack_modules
  vast
end

target 'BDMMyTargetAdapter' do
  project 'BidMachine-iOS-Adaptors/Adaptors.xcodeproj'
  my_target
  stack_modules
end

target 'BDMAdColonyAdapter' do
  project 'BidMachine-iOS-Adaptors/Adaptors.xcodeproj'
  adcolony
  stack_modules
end

target 'BDMVungleAdapter' do
  project 'BidMachine-iOS-Adaptors/Adaptors.xcodeproj'
  vungle
  stack_modules
end

target 'BDMTapjoyAdapter' do
  project 'BidMachine-iOS-Adaptors/Adaptors.xcodeproj'
  tapjoy
  stack_modules
end

target 'BDMFacebookAdapter' do
  project 'BidMachine-iOS-Adaptors/Adaptors.xcodeproj'
  facebook
  stack_modules
end

target 'BDMAmazonAdapter' do
  project 'BidMachine-iOS-Adaptors/Adaptors.xcodeproj'
  amazon
  stack_modules
end

target 'BDMSmaatoAdapter' do
  project 'BidMachine-iOS-Adaptors/Adaptors.xcodeproj'
  smaato
  stack_modules
end

target 'BDMAppRollAdapter' do
  project 'BidMachine-iOS-Adaptors/Adaptors.xcodeproj'
  approll
  stack_modules
end

target 'Sample' do
  project 'BidMachineSample/Sample.xcodeproj'
  mraid
  vast
  nast
  my_target
  adcolony
  vungle
  tapjoy
  facebook
  amazon
  smaato
  criteo
  approll
  stack_modules
  protobuf
  toasts
end

target 'BidMachineTests' do
  project 'BidMachine/BidMachine.xcodeproj'
  pod "Kiwi"
  stack_modules
end
