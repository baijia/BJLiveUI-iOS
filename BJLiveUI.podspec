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

    s.source        = { :git => 'https://github.com/baijia/BJLiveUI-iOS.git', :tag => s.version.to_s }
    
    s.ios.preserve_paths       = 'frameworks/BJLiveUI.framework'
    s.ios.source_files         = 'frameworks/BJLiveUI.framework/Versions/A/Headers/**/*.h'
    s.ios.public_header_files  = 'frameworks/BJLiveUI.framework/Versions/A/Headers/**/*.h'
    s.ios.resource             = 'frameworks/BJLiveUI.framework/Versions/A/Resources/**/*'
    s.ios.vendored_frameworks  = 'frameworks/BJLiveUI.framework'

    # s.preserve_paths = ['FilesToSave', 'MoreFilesToSave']

    s.frameworks    = ['CoreGraphics', 'Foundation', 'MobileCoreServices', 'Photos', 'SafariServices', 'UIKit', 'WebKit']
    # s.libraries     = ['iconv', 'xml2']

    s.xcconfig      = {
        'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
        'ENABLE_BITCODE' => 'NO',
        'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) PODSPEC_NAME=#{s.name} PODSPEC_VERSION=#{s.version}'
    }

    s.dependency 'BJLiveBase'
    s.dependency 'BJLiveBase/Base'
    s.dependency 'BJLiveBase/Auth'
    s.dependency 'BJLiveBase/Ext'
    s.dependency 'BJLiveBase/HUD'
    s.dependency 'BJLiveBase/Masonry'
    s.dependency 'BJLiveBase/Networking'
    s.dependency 'BJLiveBase/WebImage/AFNetworking'

    s.dependency 'BJLiveCore', '~> 1.1.0'
    s.dependency 'Masonry'
    s.dependency 'MBProgressHUD', '~> 1.0'
    s.dependency 'QBImagePickerController', '~> 3.0'

end
