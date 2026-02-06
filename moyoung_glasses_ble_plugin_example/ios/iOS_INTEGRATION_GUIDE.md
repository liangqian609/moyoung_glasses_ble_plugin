# MoYoung 智能眼镜插件 iOS 接入指南
# MoYoung Smart Glasses Plugin iOS Integration Guide

> 📖 本指南专为技术新手设计，手把手教你如何在 iOS 项目中集成 MoYoung 智能眼镜插件。
> 📖 This guide is designed for technical beginners, providing step-by-step instructions on how to integrate the MoYoung smart glasses plugin in your iOS project.

## 📋 前置要求
## 📋 Prerequisites

- Flutter SDK >= 3.0.0
- Xcode >= 14.0
- iOS 设备或模拟器（iOS 12.0+）
- 开发者账号（真机调试需要）
- iOS device or simulator (iOS 12.0+)
- Developer account (required for real device debugging)

## 🚀 快速开始
## 🚀 Quick Start

### 1. 添加依赖
### 1. Add Dependency

在你的 Flutter 项目的 `pubspec.yaml` 文件中添加：
Add the following to your Flutter project's `pubspec.yaml` file:

```yaml
dependencies:
  moyoung_glasses_ble_plugin: ^1.0.1
```

然后运行：
Then run:
```bash
flutter pub get
```

### 2. iOS 配置
### 2. iOS Configuration

#### 2.1 配置 Podfile
#### 2.1 Configure Podfile

打开 `ios/Podfile` 文件，替换为以下内容：
Open the `ios/Podfile` file and replace it with the following content:

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# 使用 CDN 源
# Use CDN source
source 'https://cdn.cocoapods.org/'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  pod 'SwiftProtobuf', '1.29.0'
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      # 设置最低部署目标
      # Set minimum deployment target
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      # 排除模拟器架构以避免冲突
      # Exclude simulator architectures to avoid conflicts
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'i386 arm64'
      # 不支持 BITCODE
      # Disable BITCODE
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      # 解决swift模块问题
      # Fix Swift module issues
      config.build_settings['SWIFT_VERSION'] = '5.0'
      # 只构建活动架构
      # Build active architecture only
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      # 设置有效架构
      # Set valid architectures
      config.build_settings['VALID_ARCHS'] = 'arm64'
      
      # 特殊处理 SwiftProtobuf 符号兼容性
      # Special handling for SwiftProtobuf symbol compatibility
      if target.name == 'SwiftProtobuf'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
      end
    end
  end
end
```

#### 2.2 配置 Info.plist
#### 2.2 Configure Info.plist

打开 `ios/Runner/Info.plist` 文件，在 `<dict>` 标签内添加以下配置：
Open the `ios/Runner/Info.plist` file and add the following configuration inside the `<dict>` tag:

```xml
<!-- 蓝牙权限描述 -->
<!-- Bluetooth permission description -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>此应用需要蓝牙权限来连接智能眼镜</string>
<string>This app needs Bluetooth permission to connect with smart glasses</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>此应用需要蓝牙权限来连接智能眼镜</string>
<string>This app needs Bluetooth permission to connect with smart glasses</string>

<!-- 位置权限（蓝牙扫描需要） -->
<!-- Location permission (required for Bluetooth scanning) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>此应用需要位置权限来扫描蓝牙设备</string>
<string>This app needs location permission to scan for Bluetooth devices</string>

<!-- Wi-Fi 热点配置权限（文件同步功能需要） -->
<!-- Wi-Fi hotspot configuration permission (required for file sync feature) -->
<key>NSHotspotConfigurationUsageDescription</key>
<string>此应用需要配置 Wi-Fi 热点来连接您的设备</string>
<string>This app needs to configure Wi-Fi hotspot to connect to your device</string>
<key>NEHotspotConfiguration</key>
<true/>

<!-- 存储权限（文件下载功能需要） -->
<!-- Storage permission (required for file download feature) -->
<key>NSDocumentsFolderUsageDescription</key>
<string>此应用需要访问文档文件夹来保存下载的文件</string>
<string>This app needs access to documents folder to save downloaded files</string>
<key>NSDownloadsFolderUsageDescription</key>
<string>此应用需要访问下载文件夹来保存媒体文件</string>
<string>This app needs access to downloads folder to save media files</string>

<!-- 蓝牙后台模式 -->
<!-- Bluetooth background modes -->
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
    <string>bluetooth-peripheral</string>
</array>
```

### 3. 安装依赖
### 3. Install Dependencies

在项目根目录的 iOS 文件夹中运行：
Run the following in the iOS folder of your project root:

```bash
cd ios
pod install
```

如果遇到问题，可以先清理再安装：
If you encounter issues, you can clean and reinstall:

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
```

### 4. 运行项目
### 4. Run Project

现在你可以运行项目了：
Now you can run the project:

```bash
# 运行到模拟器
# Run on simulator
flutter run

# 运行到真机（需要先连接设备）
# Run on real device (need to connect device first)
flutter run -d "Your device name"
```

## 🔧 常见问题解决
## 🔧 Troubleshooting

### 问题 1：SwiftProtobuf 符号找不到
### Problem 1: SwiftProtobuf Symbol Not Found

**错误信息**：
**Error Message**:
```
dyld: Symbol not found: _$s13SwiftProtobuf19_ProtoNameProvidingP17_protobuf_nameMapAA01_dH0VvgZTq
```

**解决方案**：
**Solution**:
1. 确认 Podfile 中包含了所有必要的配置（见上面的 Podfile 配置）
   1. Make sure Podfile contains all necessary configurations (see Podfile configuration above)
2. 清理并重新安装 pods：
   2. Clean and reinstall pods:
   ```bash
   cd ios
   rm -rf Pods Podfile.lock .symlinks
   pod install
   ```
3. 清理 Flutter 项目：
   3. Clean Flutter project:
   ```bash
   flutter clean
   flutter pub get
   ```

### 问题 2：蓝牙权限错误
### Problem 2: Bluetooth Permission Error

**错误信息**：
**Error Message**:
```
State restoration of CBCentralManager is only allowed for applications that have specified the "bluetooth-central" background mode
```

**解决方案**：
**Solution**:
确保 Info.plist 中添加了 `UIBackgroundModes` 配置（见上面的配置）。
Ensure Info.plist includes `UIBackgroundModes` configuration (see configuration above).

### 问题 3：构建失败
### Problem 3: Build Failure

**解决方案**：
**Solution**:
1. 检查 Xcode 版本是否 >= 14.0
   1. Check if Xcode version >= 14.0
2. 确认 iOS 部署目标设置为 12.0
   2. Confirm iOS deployment target is set to 12.0
3. 在 Xcode 中打开项目，检查签名配置
   3. Open project in Xcode and check signing configuration

## 📱 真机调试注意事项
## 📱 Real Device Debugging Notes

1. **开发者账号**：需要 Apple 开发者账号才能在真机上运行
   1. **Developer Account**: Apple Developer account required for real device debugging
2. **设备信任**：首次运行需要在设备上信任开发者证书
   2. **Device Trust**: Need to trust developer certificate on first run
   - 设置 → 通用 → VPN 与设备管理 → 信任应用
   - Settings → General → VPN & Device Management → Trust App
3. **蓝牙权限**：首次使用时会弹出权限请求，需要点击“允许”
   3. **Bluetooth Permission**: Permission dialog will appear on first use, need to click “Allow”

## 📶 Wi-Fi 文件同步功能
## 📶 Wi-Fi File Sync Feature

### 重要权限说明
### Important Permission Notice

Wi-Fi 文件同步功能需要以下**关键权限**：

The Wi-Fi file sync feature requires the following **critical permissions**:

```xml
<!-- Wi-Fi 热点配置权限 -->
<key>NSHotspotConfigurationUsageDescription</key>
<string>此应用需要配置 Wi-Fi 热点来连接您的设备</string>
<key>NEHotspotConfiguration</key>
<true/>
```

### 功能特性
### Feature Highlights

- **自动连接设备热点**：应用可以自动连接到智能眼镜的 Wi-Fi 热点
  - **Automatic device hotspot connection**: The app can automatically connect to the smart glasses' Wi-Fi hotspot
- **可配置热点信息**：支持自定义设备热点名称和密码
  - **Configurable hotspot info**: Supports custom device hotspot name and password
- **文件列表获取**：通过 HTTP 协议获取设备上的媒体文件列表
  - **File list retrieval**: Get media file list from device via HTTP protocol
- **批量下载支持**：支持单个或批量下载媒体文件
  - **Batch download support**: Supports single or batch media file downloads

### 使用流程
### Usage Flow

1. **配置 Wi-Fi 信息**：在应用中设置设备热点名称和密码
   - **Configure Wi-Fi info**: Set device hotspot name and password in the app
2. **开启文件同步**：调用 `enableWifi()` 方法开启设备 Wi-Fi
   - **Enable file sync**: Call `enableWifi()` method to enable device Wi-Fi
3. **自动连接**：底层自动延时 10 秒后连接设备热点，无需手动处理
   - **Automatic connection**: Bottom layer automatically waits 10 seconds then connects to device hotspot, no manual handling needed
4. **获取文件列表**：连接成功后自动获取文件列表
   - **Get file list**: Automatically get file list after successful connection
5. **下载文件**：选择需要的文件进行下载
   - **Download files**: Select needed files for download

> ⚠️ **重要提示 / Important Note**: 
> 底层已自动处理 Wi-Fi 开启后的延时连接逻辑。调用 `enableWifi()` 后，系统会自动在 10 秒后尝试连接设备热点，开发者无需在 Flutter 端手动处理延时。
> The bottom layer automatically handles the delayed connection logic after Wi-Fi is enabled. After calling `enableWifi()`, the system will automatically attempt to connect to the device hotspot after 10 seconds, developers do not need to manually handle the delay on the Flutter side.

### 故障排除
### Troubleshooting

**问题**：Wi-Fi 连接显示错误但系统弹出了连接提示
**Problem**: Wi-Fi connection shows error but system displays connection prompt

**原因**：NEHotspotConfiguration 的两阶段行为
**Reason**: Two-stage behavior of NEHotspotConfiguration

NEHotspotConfiguration 在 iOS 中的行为分为两个阶段：

| 阶段 | 表现 | 说明 |
|------|------|------|
| 1. 请求连接 | 系统弹出"XX 想要加入 Wi-Fi 网络？"提示 | ✅ 所有 iOS 版本都支持 |
| 2. 实际连接 | 用户点击"加入"后的连接过程 | ⚠️ 可能受系统限制影响 |

**解决方案**：
**Solution**:

1. **看到系统提示时**：
   - **When you see the system prompt**:
   - 点击"加入"或"Join"按钮
   - 等待连接完成
   - 如果成功，状态会显示"已连接"

2. **如果连接失败**：
   - **If connection fails**:
   - 打开 设置 → Wi-Fi
   - 手动连接到设备热点（默认：Glass-01）
   - 输入密码（默认：12345678）
   - 返回应用点击"检查连接"验证

3. **提高成功率的方法**：
   - **To improve success rate**:
   - 确保设备距离手机较近（信号强）
   - 在应用前台操作（不要切到后台）
   - 关闭其他不必要的 Wi-Fi 连接
   - 重启设备可能解决临时问题

## 🎯 快速测试代码
## 🎯 Quick Test Code

在你的 Dart 代码中添加以下测试代码：
Add the following test code to your Dart code:

```dart
import 'package:moyoung_glasses_ble_plugin/moyoung_glasses_ble_plugin.dart';

// 初始化插件
// Initialize plugin
final glasses = MoYoungGlassesBlePlugin();

// 连接眼镜
// Connect glasses
try {
  await glasses.connect();
  print('连接成功！');
  print('Connection successful!');
} catch (e) {
  print('连接失败：$e');
  print('Connection failed: $e');
}

// 监听连接状态
// Listen to connection state
glasses.connStateEveStm.listen((state) {
  print('连接状态：${state.status}');
  print('Connection status: ${state.status}');
});

// 监听电量
// Listen to battery level
glasses.batteryEveStm.listen((battery) {
  print('电量：${battery['level']}%');
  print('Battery level: ${battery['level']}%');
});
```

## 💡 小贴士
## 💡 Tips

1. **使用模拟器开发**：如果没有真机，可以在模拟器上开发大部分功能
   1. **Use Simulator for Development**: If you don't have a real device, you can develop most features on simulator
2. **查看日志**：使用 `flutter logs` 查看详细的运行日志
   2. **View Logs**: Use `flutter logs` to view detailed runtime logs
3. **示例项目**：参考 [GitHub 示例](https://github.com/liangqian609/moyoung_glasses_ble_plugin) 了解更多用法
   3. **Example Project**: Refer to [GitHub Example](https://github.com/liangqian609/moyoung_glasses_ble_plugin) for more usage

## 🆘 获取帮助
## 🆘 Get Help

如果遇到问题：
If you encounter issues:

1. 查看 [常见问题](https://github.com/liangqian609/moyoung_glasses_ble_plugin/issues)
   1. Check [FAQ](https://github.com/liangqian609/moyoung_glasses_ble_plugin/issues)
2. 发送邮件至：jack@moyoung.com
   2. Send email to: jack@moyoung.com
3. 访问官网：https://www.moyoung.com/en/
   3. Visit website: https://www.moyoung.com/en/

---

🎉 恭喜！你已经成功集成了 MoYoung 智能眼镜插件。现在可以开始开发你的智能眼镜应用了！
🎉 Congratulations! You have successfully integrated the MoYoung smart glasses plugin. Now you can start developing your smart glasses application!
