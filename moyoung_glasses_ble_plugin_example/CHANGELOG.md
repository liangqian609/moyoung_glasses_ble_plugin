# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-23

### First Official Release

This is the first stable release of the MoYoung Smart Glasses Flutter SDK, providing comprehensive support for MoYoung smart glasses across Android and iOS platforms.

### Features

**Core Functionality**
- **Device Scanning** - Bluetooth Low Energy device discovery and scanning
- **Device Connection** - Connect, disconnect, and manage device bonding
- **Device Control** - Restart, shutdown, factory reset operations
- **Battery Monitoring** - Real-time battery level and charging status
- **Time Synchronization** - Sync device time with mobile device

**Smart Glasses Features**
- **Camera Control** - Take photos and record videos remotely
- **Audio Features** - Audio recording, playback, and voice control
- **File Management** - Access and manage files on the glasses
- **Wi-Fi Support** - Enable/disable Wi-Fi and file synchronization
- **Display Control** - Screen brightness and display settings

**Advanced Features**
- **OTA Updates** - Over-the-air firmware updates (JL and Allwinner)
- **AI Integration** - AI voice replies and image recognition
- **Real-time Translation** - Voice translation capabilities
- **Voice Wake-up** - Smart voice activation features
- **Location Services** - GPS and positioning features
- **Health Monitoring** - Step counting, heart rate, sleep tracking

### Technical Improvements

**Package Structure**
- **Package Name** - Updated to `moyoung_glasses_ble_plugin` for better clarity
- **Architecture** - Clean separation between platform channels and business logic
- **Documentation** - Comprehensive API documentation and examples

**Platform Support**
- **Android** - Full support for Android 5.0+ (API 21+)
- **iOS** - Full support for iOS 11.0+
- **Flutter** - Compatible with Flutter 3.0+

**Build System**
- **Android Build** - APK builds successfully
- **iOS Build** - Runner.app builds successfully (76.0MB)
- **Testing** - Comprehensive example application with all features

### API Coverage

**50+ Methods Available**
- Device scanning and connection management
- Camera and media controls
- Audio recording and playback
- File operations and Wi-Fi management
- Health and fitness data
- OTA updates and system controls
- AI and translation features

### Technical Details
- **Flutter 3.0+** - Support for latest Flutter versions
- **Android API 21+** - Android 5.0+ support
- **iOS 11.0+** - iOS 11.0+ support
- **Bluetooth BLE** - Low Energy Bluetooth communication
- **High Performance** - Optimized async processing and event streams

---

## [0.9.0] - 2026-01-20

### Added
- **File Sync Mode Control** - Added setFileSyncModeEnter and setFileSyncModeExit methods
- **Allwinner OTA Features** - Added setOTAModeEnter and sendOTAPackageInfo methods
- **App Error Code Setting** - Added setAppErrorCode method
- **Device List Query** - Added getConnectedDevices method

### Changed
- **Interface Optimization** - Unified method naming conventions
- **Performance Improvements** - Enhanced Bluetooth connection stability

### Fixed
- **Connection Issues** - Fixed device connection/disconnection problems
- **Memory Leaks** - Fixed memory leaks in event stream listeners

---

### Supported Platforms
- **Android** - API 21+ (Android 5.0+)
- **iOS** - iOS 11.0+
- **Flutter** - 3.0.0+

### Links
- **Homepage**: https://www.moyoung.com/en/
