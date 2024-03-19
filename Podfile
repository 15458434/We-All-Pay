source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '15.0'

target 'We all pay' do
    use_frameworks!
    inhibit_all_warnings!
    
    pod 'FirebaseAnalytics'
    pod 'FirebaseCrashlytics'
    pod 'FirebaseRemoteConfig'
    pod 'Google-Mobile-Ads-SDK'
    pod 'GoogleMobileAdsMediationFacebook', '~> 6.14' # 19-Mar-24 Explicit version added because dependencies were broken and an older version was selected. Test to use without in the future.
    #pod 'GoogleMobileAdsMediationAdColony' #19-Mar-24 AdColony disabled. Adapter doesn't initialize. Can't get into AdColony account. 
    #pod 'GoogleMobileAdsMediationAppLovin' #19-Mar-24 AppLovin disabled. Adapter doesn't initialize. Can't get into AppLovin account. 
    pod 'PersonalizedAdConsent'
    pod 'GoogleMobileAdsMediationTestSuite', :configurations => ['AdTest']
    
    target 'We all pay Tests' do
        inherit! :search_paths
        pod 'FirebaseCore'
    end
    
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
