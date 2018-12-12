source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

platform :ios, '10.0'

target 'We all pay' do
    
pod 'Firebase/Core'
pod 'Firebase/AdMob'
pod 'PersonalizedAdConsent'

    target 'We all pay Tests' do
        inherit! :search_paths
        pod 'Firebase/Core'
    end

end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-We all pay/Pods-We all pay-acknowledgements.plist', 'Going Dutch/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
