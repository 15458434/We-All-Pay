source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '15.0'

target 'We all pay' do
    use_frameworks!
    inhibit_all_warnings!

    pod 'FirebaseAnalytics'
    pod 'FirebaseCrashlytics'
    pod 'FirebaseRemoteConfig'
    pod 'Google-Mobile-Ads-SDK'
    pod 'GoogleMobileAdsMediationFacebook'
    pod 'GoogleMobileAdsMediationTestSuite', :configurations => ['AdTest']
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-We all pay/Pods-We all pay-acknowledgements.plist', 'Going Dutch/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
            end
        end
    end
end
