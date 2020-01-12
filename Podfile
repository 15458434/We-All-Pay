source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

platform :ios, '12.0'

target 'We all pay' do
    
pod 'Firebase/Core'
pod 'Firebase/AdMob'
pod 'GoogleMobileAdsMediationFacebook'
pod 'GoogleMobileAdsMediationInMobi'
pod 'PersonalizedAdConsent'
#pod 'GoogleMobileAdsMediationTestSuite', :configurations => ['Debug'], :path => '/path/to/GoogleMobileAdsMediationTestSuite/'

    target 'We all pay Tests' do
        inherit! :search_paths
        pod 'Firebase/Core'
    end

end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-We all pay/Pods-We all pay-acknowledgements.plist', 'Going Dutch/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
