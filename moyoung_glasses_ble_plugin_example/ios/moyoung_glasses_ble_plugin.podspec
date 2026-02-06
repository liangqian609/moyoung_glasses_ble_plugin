#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint moyoung_ble_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'moyoung_glasses_ble_plugin'
  s.version          = '1.0.0'
  s.summary          = 'A comprehensive Flutter plugin for MoYoung smart glasses.'
  s.description      = <<-DESC
A comprehensive Flutter plugin for MoYoung smart glasses, providing 50+ features including:
• Bluetooth communication and device management
• Camera control (photo/video recording)
• Audio recording and playback
• File management and synchronization
• OTA firmware upgrade
• AI voice assistant and image recognition
• Real-time translation
• Wi-Fi management
• Battery monitoring
• Internationalization (Chinese/English)

Supports Android and iOS platforms with native SDK integration.
                       DESC
  s.homepage         = 'https://www.moyoung.com/en/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'MoYoung' => 'jack@moyoung.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{h,m,swift}'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64',
    'SWIFT_VERSION' => '5.0',
    'VALID_ARCHS' => 'arm64',
    'ONLY_ACTIVE_ARCH' => 'YES'
  }

  # 智能眼镜 SDK (Smart Glasses SDK) - 只使用 vendored_frameworks
  s.vendored_frameworks = 'Frameworks/CRPSmartGlasses.framework', 'Frameworks/JL_OTALib.framework', 'Frameworks/JL_HashPair.framework', 'Frameworks/JLLogHelper.framework', 'Frameworks/SpeexKit.framework', 'Frameworks/MZEncryptSDK.framework', 'Frameworks/openssl.framework'

  s.dependency 'SwiftProtobuf'
  s.dependency 'AFNetworking', '~> 4.0'

  
#   s.preserve_paths = 'CRPSmartBand.framework', 'OTAFramework.framework', 'RTKLEFoundation.framework', 'RTKOTASDK.framework'
#   s.xcconfig = { 'OTHER_LDFLAGS' => '-framework CRPSmartBand -framework OTAFramework -framework RTKLEFoundation -framework RTKOTASDK' }
#   s.vendored_frameworks = 'CRPSmartBand.framework', 'OTAFramework.framework', 'RTKLEFoundation.framework', 'RTKOTASDK.framework'
  
end
