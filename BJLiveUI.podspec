Pod::Spec.new do |s|

    s.name          = 'BJLiveUI'
    s.version       = '0.1.0'
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
    s.ios.preserve_paths       = 'BJLiveUI.framework'
    s.ios.source_files         = 'BJLiveUI.framework/Versions/A/Headers/**/*.h'
    s.ios.public_header_files  = 'BJLiveUI.framework/Versions/A/Headers/**/*.h'
    s.ios.resource             = 'BJLiveUI.framework/Versions/A/Resources/**/*'
    s.ios.vendored_frameworks  = 'BJLiveUI.framework'
    s.frameworks    = ['CoreGraphics', 'Foundation', 'MobileCoreServices', 'Photos', 'UIKit', 'WebKit']

    # s.xcconfig = { 'ENABLE_BITCODE' => 'NO' }
    s.xcconfig = {
        'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
        'ENABLE_BITCODE' => 'NO'
    }

    s.dependency 'BJLiveCore', '~> 0.4.0'
    s.dependency 'Masonry'
    s.dependency 'MBProgressHUD', '~> 1.0'
    s.dependency 'QBImagePickerController', '~> 3.0'

    # DEPRECATED
    s.dependency 'libextobjc/EXTScope'

end
