Pod::Spec.new do |s|

    s.name          = 'BJLiveUI'
    s.version       = '0.2.0-alpha02'
    s.summary       = 'BJLiveUI SDK.'
    s.description   = 'BJLiveUI SDK for iOS.'

    s.homepage      = 'http://www.baijiacloud.com/'
    s.license       = 'MIT'
    s.author        = { 'MingLQ'=>'minglq.9@gmail.com' }

    s.platform      = :ios, '8.0'
    s.ios.deployment_target = '8.0'

    # git
    s.source        = {
        :git => 'https://github.com/baijia/BJLiveUI-iOS.git',
        :tag => s.version.to_s
    }
    s.ios.preserve_paths       = 'frameworks/BJLiveUI.framework'
    s.ios.source_files         = 'frameworks/BJLiveUI.framework/Versions/A/Headers/**/*.h'
    s.ios.public_header_files  = 'frameworks/BJLiveUI.framework/Versions/A/Headers/**/*.h'
    s.ios.resource             = 'frameworks/BJLiveUI.framework/Versions/A/Resources/**/*'
    s.ios.vendored_frameworks  = 'frameworks/BJLiveUI.framework'
    s.frameworks    = ['CoreGraphics', 'Foundation', 'MobileCoreServices', 'Photos', 'SafariServices', 'UIKit', 'WebKit']

    # s.xcconfig = { 'ENABLE_BITCODE' => 'NO' }
    s.xcconfig = {
        'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
        'ENABLE_BITCODE' => 'NO'
    }

    s.dependency 'BJLiveBase', '~> 0.1.0-alpha'
    s.dependency 'BJLiveBase/Base'
    s.dependency 'BJLiveBase/Auth'
    s.dependency 'BJLiveBase/Ext'
    s.dependency 'BJLiveBase/HUD'
    s.dependency 'BJLiveBase/Masonry'
    s.dependency 'BJLiveBase/Networking'
    s.dependency 'BJLiveBase/WebImage/AFNetworking'

    s.dependency 'BJLiveCore', '~> 0.6.0-alpha02'
    s.dependency 'Masonry'
    s.dependency 'MBProgressHUD'
    s.dependency 'QBImagePickerController', '~> 3.0'

end
