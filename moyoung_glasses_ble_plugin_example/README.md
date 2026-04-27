# MoYoung Glasses BLE Plugin - Example

This repository contains the example application for the [moyoung_glasses_ble_plugin](https://pub.dev/packages/moyoung_glasses_ble_plugin) Flutter package.

## 📱 About the Plugin

`moyoung_glasses_ble_plugin` is a comprehensive Flutter plugin for MoYoung smart glasses, providing 50+ features including:

- 📡 Bluetooth communication and device management
- 📸 Camera control (photo/video recording)
- 🎵 Audio recording and playback
- 📁 File management and synchronization
- 🔄 OTA firmware upgrades
- 🤖 AI voice assistant and image recognition
- 🌍 Real-time translation
- 📶 Wi-Fi management
- 🔋 Battery monitoring
- 🌐 Internationalization (Chinese/English)

## 🚀 Quick Start

### Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  moyoung_glasses_ble_plugin: ^1.2.2
```

### Basic Usage

```dart
import 'package:moyoung_glasses_ble_plugin/moyoung_glasses_ble.dart';

final MoYoungGlassesBle _glasses = MoYoungGlassesBle();

// Check Bluetooth status
bool isEnabled = await _glasses.checkBluetoothEnable;

// Start scanning
await _glasses.startScan(10);

// Connect to device
await _glasses.connect('{"address":"XX:XX:XX:XX:XX:XX"}');

// Take photo
await _glasses.takePhoto();
```

## 📖 Documentation

- **[API Documentation](./API_LIST.md)** - Complete API reference
- **[CHANGELOG](./CHANGELOG.md)** - Version history and updates
- **[Detailed Example Guide](./README_GLASSES.md)** - Comprehensive example documentation (Chinese/English)

## 🏃‍♂️ Run the Example

1. Clone this repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## 📋 Requirements

- Flutter SDK >= 3.0.0
- Android SDK >= 21 (Android 5.0)
- iOS >= 11.0
- Bluetooth LE support
- A MoYoung smart glasses device

## 📄 License

This example is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## 🔗 Links

- **Pub.dev Package**: https://pub.dev/packages/moyoung_glasses_ble_plugin
- **Technical Support**: jack@moyoung.com

## 📞 Support

For technical support and questions:
- Email: jack@moyoung.com
- GitHub Issues: [Create an issue](https://github.com/liangqian609/moyoung_glasses_ble_plugin/issues)

---

*Last Updated: 2026-04-27*