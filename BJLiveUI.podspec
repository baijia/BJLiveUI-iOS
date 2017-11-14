Pod::Spec.new do |s|

    s.name          = 'BJLiveUI'
    s.version       = '1.1.0'
    s.summary       = 'BJLiveUI SDK.'
    s.description   = 'BJLiveUI SDK for iOS.'

    s.homepage      = 'http://www.baijiayun.com/'
    s.license       = 'MIT'
    s.author        = { 'MingLQ' => 'minglq.9@gmail.com' }

    s.platform      = :ios
    s.ios.deployment_target = '8.0'

    s.source        = {
        :git => 'https://github.com/baijia/BJLiveUI-iOS.git',
        :tag => s.version.to_s
    }
    s.xcconfig      = {
        'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
        'ENABLE_BITCODE' => 'NO',
        'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) PODSPEC_NAME=#{s.name} PODSPEC_VERSION=#{s.version}'
    }

    s.default_subspecs = ['static']

    s.subspec 'static' do |ss|
        ss.vendored_frameworks  = 'frameworks/BJLiveUI.framework'
        ss.dependency 'BJLiveUI/static.dependencies'
    end
    s.subspec 'static.source' do |ss|
        ss.public_header_files = [
            'classes/**/BJLiveUI.h',
            'classes/**/BJLRoomViewController.h',
            'classes/**/BJLOverlayViewController.h',
            'classes/**/BJLOverlayContainerController.h'
        ]
        ss.source_files  = ['classes', 'classes/**/*.{h,m}']
        ss.resources     = [
            'images/**/*.xcassets',
            'strings/**/*.lproj'
        ]
        ss.dependency 'BJLiveUI/static.dependencies'
    end
    s.subspec 'static.dependencies' do |ss|
        ss.frameworks = ['CoreGraphics', 'Foundation', 'MobileCoreServices', 'Photos', 'SafariServices', 'UIKit', 'WebKit']
        ss.dependency 'BJLiveBase'
        ss.dependency 'BJLiveBase/Base'
        ss.dependency 'BJLiveBase/Auth'
        ss.dependency 'BJLiveBase/Ext'
        ss.dependency 'BJLiveBase/HUD'
        ss.dependency 'BJLiveBase/Masonry'
        ss.dependency 'BJLiveBase/Networking'
        ss.dependency 'BJLiveBase/WebImage/AFNetworking'
        ss.dependency 'BJLiveCore', '1.1.0'
        ss.dependency 'Masonry'
        ss.dependency 'MBProgressHUD', '~> 1.0'
        ss.dependency 'QBImagePickerController', '~> 3.0'
    end

end
