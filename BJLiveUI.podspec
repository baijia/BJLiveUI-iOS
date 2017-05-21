Pod::Spec.new do |s|
  s.name = "BJLiveUI"
  s.version = "0.0.5-dylib"
  s.summary = "BJLiveUI SDK."
  s.description = 'BJLiveUI SDK for iOS.'
  s.license = 'MIT'
  s.authors = {"MingLQ"=>"minglq.9@gmail.com"}
  s.homepage = 'http://www.baijiacloud.com/'

  s.ios.deployment_target    = '8.0'

  # git
  s.source = { :git => "https://github.com/baijia/BJLiveUI-iOS.git", :tag => "#{s.version}" }
  s.ios.preserve_paths       = 'BJLiveUI.framework'
  s.ios.public_header_files  = 'BJLiveUI.framework/Versions/A/Headers/**/*.h'
  s.ios.source_files         = 'BJLiveUI.framework/Versions/A/Headers/**/*.h'
  s.ios.resource             = 'BJLiveUI.framework/Versions/A/Resources/**/*'
  s.ios.vendored_frameworks  = 'BJLiveUI.framework'
  s.frameworks = ['CoreGraphics', 'Foundation', 'UIKit']

  s.requires_arc = true
  s.xcconfig = { "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" => "YES" }

  s.dependency 'BJLiveCore', '~> 0.3.0-dylib'
  s.dependency "libextobjc/EXTScope"
  s.dependency 'Masonry'
  s.dependency 'MBProgressHUD', '~> 1.0'
  s.dependency 'UITextView+Placeholder'
  s.dependency 'QBImagePickerController', '~> 3.0'

end
