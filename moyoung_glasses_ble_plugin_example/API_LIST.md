# MoYoung Glasses Flutter SDK API 列表 / API List
# Version: 1.1.0

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
| `cancelScan` | Future<void> | 取消扫描 / Cancel scan | 无 / None | 无 / None |

### 3. 设备连接 / Device Connection

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `connStateEveStm` | Stream<ConnectStateBean> | 连接状态事件流 / Connection state event stream | 无 / None | Stream: 连接状态变化 / Stream: Connection state changes |
| `connect` | Future<void> | 连接设备 / Connect to device | ConnectBean connectInfo: 连接信息 / Connection info | 无 / None |
| `disconnect` | Future<void> | 断开连接 / Disconnect device | 无 / None | 无 / None |
| `reconnect` | Future<void> | 重新连接之前连接的设备 / Reconnects the previously connected device | 无 / None | 无 / None |

### 4. 设备控制 / Device Control

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `restart` | Future<bool> | 重启设备 / Restart device | 无 / None | bool: 是否成功 / Whether successful |
| `reset` | Future<bool> | 重置设备 / Reset device | 无 / None | bool: 是否成功 / Whether successful |
| `shutdown` | Future<bool> | 关机 / Shutdown device | 无 / None | bool: 是否成功 / Whether successful |

### 5. 时间和语言 / Time and Language

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `syncTime` | Future<void> | 同步时间 / Sync time | 无 / None | 无 / None |
| `sendLanguage` | Future<void> | 发送语言设置 / Send language setting | int language: 语言代码 / Language code | 无 / None |
| `getLanguage` | Future<String> | 获取设备语言设置 / Get device language setting | 无 / None | String: 语言代码 / Language code |

### 6. 版本信息 / Version Information

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `queryDeviceVersion` | Future<String> | 查询设备版本 / Query device version | int versionType: 版本类型 / Version type | String: 版本号 / Version number |
| `getJLVersion` | Future<String> | 获取固件版本 / Get Firmware version | 无 / None | String: 固件版本 / Firmware version |
| `getQZVersion` | Future<String> | 获取影像系统版本 / Get Imaging System version | 无 / None | String: 影像系统版本 / Imaging System version |
| `getTPVersion` | Future<String> | 获取TP版本 / Get TP version | 无 / None | String: TP版本 / TP version |
| `getGithashVersion` | Future<String> | 获取Git哈希版本 / Get Githash version | 无 / None | String: Git哈希版本 / Githash version |

### 7. 电池信息 / Battery Information

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `queryBattery` | Future<Map<String, dynamic>> | 查询电池信息 / Query battery information | 无 / None | Map: {battery: 电量/battery level, charging: 充电状态/charging status} |
| `batteryEveStm` | Stream<Map<String, dynamic>> | 电池信息事件流 / Battery information event stream | 无 / None | Stream: 电池信息变化 / Stream: Battery information changes |

### 8. 拍照和录像 / Photo and Video

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `takePhoto` | Future<void> | 拍照 / Take photo | int photoMode: 拍照模式 / Photo mode | 无 / None |

### 9. Wi-Fi 功能 / Wi-Fi Functions

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `enableWifi` | Future<void> | 开启Wi-Fi / Enable Wi-Fi | int wifiType: Wi-Fi类型 / Wi-Fi type<br>String? ssid: 设备热点名称 / Device hotspot name<br>String? password: 设备热点密码 / Device hotspot password | 无 / None |
| `disableWifi` | Future<void> | 关闭Wi-Fi / Disable Wi-Fi | 无 / None | 无 / None |
| `connectToDeviceWifi` | Future<void> | 连接设备Wi-Fi / Connect device Wi-Fi | 无 / None | 无 / None |
| `actionResultEveStm` | Stream<Map<String, dynamic>> | Wi-Fi操作结果事件流 / Wi-Fi action result event stream | 无 / None | Stream: 操作结果 / Stream: Action results |

### 10. 音频控制 / Audio Control

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `setAudioControl` | Future<void> | 设置音频控制状态 / Set audio control state | int actionType: 动作类型 / Action type | 无 / None |
| `queryAudioState` | Future<int> | 查询音频状态 / Query audio state | 无 / None | int: 音频状态 / Audio state |
| `audioStateEveStm` | Stream<Map<String, dynamic>> | 音频状态事件流 / Audio state event stream | 无 / None | Stream: 音频状态变化 / Stream: Audio state changes |
| `audioTalkStateEveStm` | Stream<Map<String, dynamic>> | 音频对讲状态事件流 / Audio talk state event stream | 无 / None | Stream: 对讲状态变化 / Stream: Talk state changes |
| `audioDataEveStm` | Stream<Map<String, dynamic>> | 音频数据事件流 / Audio data event stream | 无 / None | Stream: 音频数据 / Stream: Audio data |

### 11. AI 功能 / AI Functions

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `setAIReplyStatus` | Future<bool> | 设置AI回复状态 / Set AI reply status | int status: 状态类型 / Status type | bool: 是否成功 / Whether successful |
| `exitAIReply` | Future<bool> | 退出语音 / Exit voice reply | 无 / None | bool: 是否成功 / Whether successful |
| `aiImageDataEveStm` | Stream<Map<String, dynamic>> | AI识别图片数据事件流 / AI recognition image data event stream | 无 / None | Stream: 图片数据 / Stream: Image data |

### 12. 文件管理 / File Management

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `getFileCount` | Future<void> | 查询文件数量 / Query file count | 无 / None | 无 / None |
| `getFileSyncType` | Future<int> | 查询文件同步方式 / Query file sync type | 无 / None | int: 同步方式 / Sync type |
| `deleteFile` | Future<bool> | 删除文件 / Delete file | int fileType: 删除类型 / Delete type<br>String fileName: 文件名 / File name | bool: 是否成功 / Whether successful |
| `downloadMediaFilesToDir` | Future<Map<String, dynamic>> | 下载媒体文件到指定目录 / Download media files to specified directory | String targetDir: 目标目录 / Target directory | Map: 下载结果 / Download result |
| `setFileSyncModeEnter` | Future<bool> | 进入文件同步模式 / Enter file sync mode | int wifiCtrl: Wi-Fi控制类型 / Wi-Fi control type | bool: 是否成功 / Whether successful |
| `setFileSyncModeExit` | Future<bool> | 退出文件同步模式 / Exit file sync mode | 无 / None | bool: 是否成功 / Whether successful |
| `fileBaseUrlEveStm` | Stream<String> | 文件BaseUrl事件流 / File BaseUrl event stream | 无 / None | Stream: BaseUrl变化 / Stream: BaseUrl changes |
| `mediaFileCountEveStm` | Stream<Map<String, dynamic>> | 媒体文件数量事件流 / Media file count event stream | 无 / None | Stream: 文件数量 / Stream: File count |
| `mediaDownloadProgress` | Stream<Map<String, dynamic>> | 媒体下载进度事件流 / Media download progress event stream | 无 / None | Stream: 下载进度 / Stream: Download progress |

### 13. 音频录制 / Audio Recording

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `setAudioRecord` | Future<bool> | 设置音频录制 / Set audio recording | int type: 录音类型 / Record type | bool: 是否成功 / Whether successful |
| `getAudioRecordState` | Future<Map<String, int>> | 获取音频录制状态 / Get audio recording state | 无 / None | Map: {type: 类型, totalTime: 总时长} / Map: {type: Type, totalTime: Total duration} |

### 14. 设备管理 / Device Management

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `clearPairInfo` | Future<bool> | 清除设备配对信息 / Clear device pairing info | 无 / None | bool: 是否成功 / Whether successful |
| `getDeviceUUID` | Future<String> | 获取设备UUID / Get device UUID | 无 / None | String: 设备UUID / Device UUID |
| `getConnectedDevices` | Future<List<Map<String, dynamic>>> | 获取已连接设备列表 / Get connected devices list | 无 / None | List: 设备列表 / Device list |
| `setAppErrorCode` | Future<bool> | 设置APP错误码 / Set app error code | int code: 错误码 / Error code | bool: 是否成功 / Whether successful |

### 15. 语音唤醒 / Voice Wakeup

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `getVoiceWakeupState` | Future<bool> | 获取语音唤醒状态 / Get voice wakeup state | 无 / None | bool: 唤醒状态 / Wakeup state |
| `setVoiceWakeup` | Future<bool> | 设置语音唤醒 / Set voice wakeup | bool enable: 是否启用 / Whether to enable | bool: 是否成功 / Whether successful |

### 16. 佩戴检测 / Wear Detection (iOS Only)

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `getWearCheckState` | Future<bool> | 获取佩戴检查状态 / Get wear check state | 无 / None | bool: 佩戴状态 / Wear state |
| `setWearCheckState` | Future<bool> | 设置佩戴检查状态 / Set wear check state | bool enable: 是否启用 / Whether to enable | bool: 是否成功 / Whether successful |

### 17. 运行状态 / Running Status

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `getRunningStatus` | Future<String> | 获取设备运行状态 / Get device running status | 无 / None | String: 运行状态 / Running status |
| `runningStatusEveStm` | Stream<Map<String, dynamic>> | 运行状态事件流 / Running status event stream | 无 / None | Stream: 状态信息 / Stream: Status information |

### 18. OTA 升级 / OTA Upgrade

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `checkLatestVersion` | Future<Map<String, dynamic>> | 检查最新版本 / Check latest version | String fw1Ver: 固件版本 / Firmware version<br>String fw2Ver: 影像系统版本 / Imaging System version<br>String mac: MAC地址 / MAC address | Map: 结构化检查结果 / Structured check result |
| `startJLOTA` | Future<bool> | 开始杰里OTA升级 / Start JL OTA upgrade | String path: 固件文件路径 / Firmware file path | bool: 是否成功 / Whether successful |
| `cancelJLOTA` | Future<bool> | 取消杰里OTA升级 / Cancel JL OTA upgrade | 无 / None | bool: 是否成功 / Whether successful |
| `setOTAModeEnter` | Future<bool> | 进入全志OTA模式 / Enter QZ OTA mode | int wifiCtrl: Wi-Fi控制类型 / Wi-Fi control type | bool: 是否成功 / Whether successful |
| `sendOTAPackageInfo` | Future<bool> | 发送OTA包信息 / Send OTA package info | Map<String, dynamic> otaPackageInfo: OTA包信息 / OTA package info | bool: 是否成功 / Whether successful |
| `otaStateEveStm` | Stream<Map<String, dynamic>> | OTA升级状态事件流 / OTA state event stream | 无 / None | Stream: OTA状态 / Stream: OTA state |

### 19. 音频解码 / Audio Decoding

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `opusDecode` | Future<bool> | 解码 Opus 文件为 PCM / Decode Opus file to PCM | String pathOpus: Opus文件路径 / Opus file path<br>String pathPcm: PCM文件路径 / PCM file path | bool: 是否成功 / Whether successful |

### 20. 测试方法 / Test Method

| 方法 / Method | 类型 / Type | 说明 / Description | 参数 / Parameters | 返回值 / Return |
|-----|------|------|------|--------|
| `testMethod` | Future<String> | 测试方法 / Test method | 无 / None | String: 测试结果 / Test result |

### 21. 事件流 / Event Streams

| 事件流 / Event Stream | 类型 / Type | 说明 / Description | 数据类型 / Data Type |
|-------|------|------|---------|
| `sdkLogEveStm` | Stream<String> | SDK日志事件流 / SDK log event stream | String: 日志内容 / Log content |
| `bluetoothStateEveStm` | Stream<Map<String, dynamic>> | 蓝牙状态事件流 / Bluetooth state event stream | Map: 蓝牙状态 / Bluetooth state |
| `ackErrorEveStm` | Stream<Map<String, dynamic>> | ACK错误事件流 / ACK error event stream | Map: 错误信息 / Error information |
| `translateAudioDataEveStm` | Stream<Map<String, dynamic>> | 翻译音频数据事件流 / Translation audio data event stream | Map: 音频数据 / Audio data |
| `pcmAudioDataEveStm` | Stream<Uint8List> | PCM音频数据事件流 / PCM audio data event stream | Uint8List: 音频数据 / Audio data |
| `aiConversationEveStm` | Stream<Map<String, dynamic>> | AI对话事件流 / AI conversation event stream | Map: 对话数据 / Conversation data |

---

## 注意事项 / Notes

1. 所有蓝牙操作需要确保蓝牙权限已获取 / All Bluetooth operations require Bluetooth permissions
2. 连接设备前需要先扫描并获取设备地址 / Need to scan and get device address before connecting
3. 某些功能（如Wi-Fi文件传输）需要电量大于20% / Some features (like Wi-Fi file transfer) require battery > 20%
4. OTA升级功能需要特定固件支持 / OTA upgrade requires specific firmware support
5. iOS和Android部分功能可能有差异，请参考平台特定说明 / Some features may differ between iOS and Android, please refer to platform-specific documentation
6. 佩戴检测功能仅支持iOS / Wear detection feature is iOS only
7. 文件下载结果通过 `mediaDownloadProgress` 事件流返回 / File download results are returned via `mediaDownloadProgress` event stream
