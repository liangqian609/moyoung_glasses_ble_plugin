# MoYoung Glasses Flutter SDK API 列表 / API List
# Version: 1.0.0

## 概述 / Overview

MoYoung Glasses Flutter SDK 是一个统一的 Flutter 插件，封装了 Android 和 iOS 原生 SDK，提供与 MoYoung 智能眼镜进行蓝牙通信的能力。

MoYoung Glasses Flutter SDK is a unified Flutter plugin that wraps the native Android and iOS SDKs, providing the ability to communicate with MoYoung smart glasses via Bluetooth.

**主入口文件 / Main Entry File**: `lib/moyoung_glasses_ble.dart`  
**主类 / Main Class**: `MoYoungGlassesBle`

---

## API 分类 / API Categories

### 1. 蓝牙基础功能 / Bluetooth Basic Functions

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `checkBluetoothEnable` | Future<bool> | 检查蓝牙是否开启 / Check if Bluetooth is enabled | 无 / None | bool: 蓝牙是否开启 / Whether Bluetooth is enabled |

### 2. 设备扫描 / Device Scan

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `bleScanEveStm` | Stream<BleScanBean> | 扫描设备事件流 / Scan device event stream | 无 / None | Stream: 扫描到的设备信息 / Stream: Scanned device information |
| `startScan` | Future<bool> | 开始扫描设备 / Start scanning devices | int scanPeriod: 扫描时长(秒) / Scan duration(seconds) | bool: 是否成功开始扫描 / Whether scanning started successfully |
| `stopScan` | Future<void> | 停止扫描设备 / Stop scanning devices | 无 / None | 无 / None |

### 3. 设备连接 / Device Connection

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `connStateEveStm` | Stream<ConnectStateBean> | 连接状态事件流 / Connection state event stream | 无 / None | Stream: 连接状态变化 / Stream: Connection state changes |
| `connect` | Future<void> | 连接设备 / Connect to device | String connectInfo: JSON格式的连接信息 / Connection info in JSON format | 无 / None |
| `disconnect` | Future<bool> | 断开连接 / Disconnect device | 无 / None | bool: 是否断开成功 / Whether disconnection was successful |
| `connectedDevice` | Future<String> | 获取已连接设备 / Get connected device | 无 / None | String: 设备信息(JSON格式) / Device information (JSON format) |
| `removeBond` | Future<bool> | 移除绑定 / Remove device bonding | 无 / None | bool: 是否移除成功 / Whether removal was successful |

### 4. 设备控制 / Device Control

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `restart` | Future<bool> | 重启设备 / Restart device | 无 / None | bool: 是否成功 / Whether successful |
| `shutdown` | Future<bool> | 关机 / Shutdown device | 无 / None | bool: 是否成功 / Whether successful |
| `factoryReset` | Future<bool> | 恢复出厂设置 / Factory reset | 无 / None | bool: 是否成功 / Whether successful |

### 5. 电池信息 / Battery Information

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `queryBattery` | Future<Map<String, dynamic>> | 查询电池信息 / Query battery information | 无 / None | Map: {battery: 电量/battery level, charging: 充电状态/charging status} |
| `batteryEveStm` | Stream<Map<String, dynamic>> | 电池信息事件流 / Battery information event stream | 无 / None | Stream: 电池信息变化 / Stream: Battery information changes |

### 6. 版本信息 / Version Information

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `queryDeviceVersion` | Future<String> | 查询设备版本 / Query device version | int versionType: 版本类型 / Version type | String: 版本号 / Version number |
| `queryJLVersion` | Future<String> | 查询固件版本 / Query Firmware version | 无 / None | String: 版本号 / Version number |
| `queryQZVersion` | Future<String> | 查询影像系统版本 / Query Imaging System version | 无 / None | String: 版本号 / Version number |
| `queryGithashVersion` | Future<String> | 查询Git哈希版本 / Query Git hash version | 无 / None | String: 哈希值 / Hash value |

### 7. 时间和语言 / Time and Language

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `syncTime` | Future<void> | 同步时间 / Sync time | 无 / None | 无 / None |
| `sendLanguage` | Future<bool> | 发送语言设置 / Send language setting | int languageType: 语言类型 / Language type | bool: 是否成功 / Whether successful |

### 8. 音频控制 / Audio Control

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `setAudioControl` | Future<void> | 设置音频控制状态 / Set audio control state | int actionType: 动作类型 / Action type | 无 / None |
| `queryAudioState` | Future<int> | 查询音频状态 / Query audio state | 无 / None | int: 音频状态 / Audio state |
| `audioStateEveStm` | Stream<Map<String, dynamic>> | 音频状态事件流 / Audio state event stream | 无 / None | Stream: 音频状态变化 / Stream: Audio state changes |
| `audioTalkStateEveStm` | Stream<Map<String, dynamic>> | 音频对讲状态事件流 / Audio talk state event stream | 无 / None | Stream: 对讲状态变化 / Stream: Talk state changes |
| `audioDataEveStm` | Stream<Map<String, dynamic>> | 音频数据事件流 / Audio data event stream | 无 / None | Stream: 音频数据 / Stream: Audio data |

### 9. 拍照和录像 / Photo and Video

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `takePhoto` | Future<bool> | 拍照 / Take photo | 无 / None | bool: 是否成功 / Whether successful |
| `startVideoRecord` | Future<bool> | 开始录像 / Start video recording | 无 / None | bool: 是否成功 / Whether successful |
| `stopVideoRecord` | Future<bool> | 停止录像 / Stop video recording | 无 / None | bool: 是否成功 / Whether successful |
| `setVideoConfig` | Future<bool> | 设置录像配置 / Set video configuration | int frameRate: 帧率 / Frame rate<br>int maxDuration: 最大时长 / Max duration | bool: 是否成功 / Whether successful |

### 10. 文件管理 / File Management

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `getFileCount` | Future<int> | 查询文件数量 / Query file count | 无 / None | int: 文件数量 / File count |
| `deleteFile` | Future<bool> | 删除文件 / Delete file | int fileType: 删除类型(0=全部,1=照片,2=视频,3=指定) / Delete type<br>String fileName: 文件名 / File name | bool: 是否成功 / Whether successful |
| `setFileSyncModeEnter` | Future<bool> | 进入文件同步模式 / Enter file sync mode | int wifiCtrl: Wi-Fi控制类型 / Wi-Fi control type | bool: 是否成功 / Whether successful |
| `setFileSyncModeExit` | Future<bool> | 退出文件同步模式 / Exit file sync mode | 无 / None | bool: 是否成功 / Whether successful |
| `fileBaseUrlEveStm` | Stream<String> | 文件BaseUrl事件流 / File BaseUrl event stream | 无 / None | Stream: BaseUrl变化 / Stream: BaseUrl changes |

### 11. Wi-Fi 功能 / Wi-Fi Functions

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `enableWifi` | Future<void> | 开启Wi-Fi / Enable Wi-Fi | 无 / None | 无 / None |
| `disableWifi` | Future<void> | 关闭Wi-Fi / Disable Wi-Fi | 无 / None | 无 / None |
| `getWifiSSID` | Future<String> | 获取Wi-Fi SSID / Get Wi-Fi SSID | 无 / None | String: SSID |
| `actionResultEveStm` | Stream<Map<String, dynamic>> | Wi-Fi操作结果事件流 / Wi-Fi action result event stream | 无 / None | Stream: 操作结果 / Stream: Action results |

### 12. AI 功能 / AI Functions

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `setAIReplyStatus` | Future<bool> | 设置AI回复状态 / Set AI reply status | int status: 状态类型 / Status type | bool: 是否成功 / Whether successful |
| `exitAIReply` | Future<bool> | 退出语音 / Exit voice | 无 / None | bool: 是否成功 / Whether successful |
| `aiImageDataEveStm` | Stream<Map<String, dynamic>> | AI识别图片数据事件流 / AI recognition image data event stream | 无 / None | Stream: 图片数据 / Stream: Image data |

### 13. OTA 升级 / OTA Upgrade

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `checkLatestVersion` | Future<Map<String, dynamic>> | 检查最新版本 / Check latest version | String fw1Ver: 固件版本 / Firmware version<br>String fw2Ver: 影像系统版本 / Imaging System version<br>String mac: MAC地址 / MAC address | Map: 结构化检查结果 / Structured check result |
| `startJLOTA` | Future<bool> | 开始杰里OTA升级 / Start JL OTA upgrade | String path: 固件文件路径 / Firmware file path | bool: 是否成功 / Whether successful |
| `cancelJLOTA` | Future<bool> | 取消杰里OTA升级 / Cancel JL OTA upgrade | 无 / None | bool: 是否成功 / Whether successful |
| `setOTAModeEnter` | Future<bool> | 进入全志OTA模式 / Enter QZ OTA mode | int wifiCtrl: Wi-Fi控制类型 / Wi-Fi control type | bool: 是否成功 / Whether successful |
| `sendOTAPackageInfo` | Future<bool> | 发送OTA包信息 / Send OTA package info | Map<String, dynamic> otaPackageInfo: OTA包信息 / OTA package info | bool: 是否成功 / Whether successful |
| `otaStateEveStm` | Stream<Map<String, dynamic>> | OTA升级状态事件流 / OTA state event stream | 无 / None | Stream: OTA状态 / Stream: OTA state |

### 14. 设备管理 / Device Management

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `clearPairInfo` | Future<bool> | 清除设备配对信息 / Clear device pairing info | 无 / None | bool: 是否成功 / Whether successful |
| `getDeviceUUID` | Future<String> | 获取设备UUID / Get device UUID | 无 / None | String: 设备UUID / Device UUID |
| `getConnectedDevices` | Future<List<Map<String, dynamic>>> | 获取已连接设备列表 / Get connected devices list | 无 / None | List: 设备列表 / Device list |
| `setAppErrorCode` | Future<bool> | 设置APP错误码 / Set app error code | int code: 错误码 / Error code | bool: 是否成功 / Whether successful |

### 15. 版本信息 / Version Information

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `getJLVersion` | Future<String> | 获取固件版本 / Get Firmware version | 无 / None | String: 固件版本 / Firmware version |
| `getQZVersion` | Future<String> | 获取影像系统版本 / Get Imaging System version | 无 / None | String: 影像系统版本 / Imaging System version |
| `getGithashVersion` | Future<String> | 获取Git哈希版本 / Get Githash version | 无 / None | String: Git哈希版本 / Githash version |
| `getRunningStatus` | Future<String> | 获取设备运行状态 / Get device running status | 无 / None | String: 运行状态 / Running status |

### 16. 语音唤醒 / Voice Wakeup

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `getVoiceWakeupState` | Future<bool> | 获取语音唤醒状态 / Get voice wakeup state | 无 / None | bool: 唤醒状态 / Wakeup state |
| `setVoiceWakeup` | Future<bool> | 设置语音唤醒 / Set voice wakeup | int actionType: 动作类型 / Action type | bool: 是否成功 / Whether successful |

### 14. 事件流 / Event Streams

| 事件流 / Event Stream | 类型 / Type | 说明 / Description | 数据类型 / Data Type |
|-------|------|------|---------|
| `sdkLogEveStm` | Stream<String> | SDK日志事件流 / SDK log event stream | String: 日志内容 / Log content |
| `runningStatusEveStm` | Stream<Map<String, dynamic>> | 运行状态事件流 / Running status event stream | Map: 状态信息 / Status information |
| `bluetoothStateEveStm` | Stream<Map<String, dynamic>> | 蓝牙状态事件流 / Bluetooth state event stream | Map: 蓝牙状态 / Bluetooth state |
| `ackErrorEveStm` | Stream<Map<String, dynamic>> | ACK错误事件流 / ACK error event stream | Map: 错误信息 / Error information |
| `translateAudioDataEveStm` | Stream<Map<String, dynamic>> | 翻译音频数据事件流 / Translation audio data event stream | Map: 音频数据 / Audio data |
| `pcmAudioDataEveStm` | Stream<Map<String, dynamic>> | PCM音频数据事件流 / PCM audio data event stream | Map: 音频数据 / Audio data |

### 15. OTA 升级 / OTA Upgrade

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `startJLOTA` | Future<bool> | 开始杰里OTA升级 / Start JL OTA upgrade | String path: 文件路径 / File path | bool: 是否成功 / Whether successful |
| `otaStateEveStm` | Stream<Map<String, dynamic>> | OTA升级状态事件流 / OTA upgrade status event stream | 无 / None | Stream: 升级状态 / Stream: Upgrade status |

### 16. 其他功能 / Other Functions

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `setFindPhone` | Future<bool> | 设置查找手机 / Set find phone | bool on: 是否开启 / Whether to enable | bool: 是否成功 / Whether successful |
| `setSedentary` | Future<bool> | 设置久坐提醒 / Set sedentary reminder | int on: 是否开启 / Whether to enable | bool: 是否成功 / Whether successful |
| `setWeather` | Future<bool> | 设置天气 / Set weather | int weatherType: 天气类型 / Weather type | bool: 是否成功 / Whether successful |
| `setUserModel` | Future<bool> | 设置用户模型 / Set user model | int sex: 性别 / Gender<br>int height: 身高 / Height<br>int weight: 体重 / Weight | bool: 是否成功 / Whether successful |

---

## 数据模型 / Data Models

### BleScanBean
- `name`: String - 设备名称 / Device name
- `address`: String - 设备地址 / Device address
- `rssi`: int - 信号强度 / Signal strength
- `isBind`: bool - 是否已绑定 / Whether bonded

### ConnectStateBean
- `connectState`: int - 连接状态 / Connection state (0=断开/Disconnected, 1=连接中/Connecting, 2=已连接/Connected, 3=断开中/Disconnecting)

---

## 使用示例 / Usage Example

```dart
import 'package:moyoung_glasses_ble_plugin/moyoung_glasses_ble.dart';

// 创建实例 / Create instance
final glasses = MoYoungGlassesBle();

// 检查蓝牙 / Check Bluetooth
bool isEnabled = await glasses.checkBluetoothEnable;

// 开始扫描 / Start scanning
glasses.startScan(10);

// 监听扫描结果 / Listen to scan results
glasses.bleScanEveStm.listen((device) {
  print('发现设备 / Found device: ${device.name}');
});

// 连接设备 / Connect device
await glasses.connect('{"address":"XX:XX:XX:XX:XX:XX"}');

// 监听连接状态 / Listen to connection state
glasses.connStateEveStm.listen((state) {
  print('连接状态 / Connection state: ${state.connectState}');
});

// 查询电池 / Query battery
Map<String, dynamic> battery = await glasses.queryBattery();
print('电量 / Battery: ${battery['battery']}%, 充电中 / Charging: ${battery['charging']}');
```

---

## 注意事项 / Notes

1. 所有蓝牙操作需要确保蓝牙权限已获取 / All Bluetooth operations require Bluetooth permissions
2. 连接设备前需要先扫描并获取设备地址 / Need to scan and get device address before connecting
3. 某些功能（如Wi-Fi文件传输）需要电量大于20% / Some features (like Wi-Fi file transfer) require battery > 20%
4. OTA升级功能需要特定固件支持 / OTA upgrade requires specific firmware support
5. iOS和Android部分功能可能有差异，请参考平台特定说明 / Some features may differ between iOS and Android, please refer to platform-specific documentation
