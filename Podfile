source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'

target 'We all pay' do
  use_frameworks!
  inhibit_all_warnings!
  
  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/AdMob'
  pod 'GoogleMobileAdsMediationFacebook'
  pod 'GoogleMobileAdsMediationInMobi'
  pod 'GoogleMobileAdsMediationAdColony'
  pod 'GoogleMobileAdsMediationAppLovin'
  pod 'GoogleMobileAdsMediationMoPub'
  pod 'PersonalizedAdConsent'
  pod 'GoogleMobileAdsMediationTestSuite', :configurations => ['AdTest']
  
  target 'We all pay Tests' do
    inherit! :search_paths
    pod 'Firebase/Core'
  end
  
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-We all pay/Pods-We all pay-acknowledgements.plist', 'Going Dutch/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
         if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
           config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
         end
      end
  end
end
