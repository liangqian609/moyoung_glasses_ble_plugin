import 'package:flutter/material.dart';
import 'app_zh.dart';
import 'app_en.dart';

/// 应用字符串管理类
/// Application String Management Class
class AppStrings {
  static const _supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  static Locale _currentLocale = Locale('zh', 'CN');

  static Locale get currentLocale => _currentLocale;

  static void setLocale(Locale locale) {
    if (_supportedLocales.contains(locale)) {
      _currentLocale = locale;
    }
  }

  // 判断当前是否为中文
  static bool get isZh => _currentLocale.languageCode == 'zh';

  // ==================== 主要界面 / Main UI ====================
  
  /// 应用标题
  static String get title => isZh ? AppZh.title : AppEn.title;
  
  /// 蓝牙检查
  static String get bluetoothCheck => isZh ? AppZh.bluetoothCheck : AppEn.bluetoothCheck;
  
  /// 开始扫描
  static String get startScan => isZh ? AppZh.startScan : AppEn.startScan;
  
  /// 停止扫描
  static String get stopScan => isZh ? AppZh.stopScan : AppEn.stopScan;
  
  /// 连接设备
  static String get connectDevice => isZh ? AppZh.connectDevice : AppEn.connectDevice;
  
  /// 断开连接
  static String get disconnectDevice => isZh ? AppZh.disconnectDevice : AppEn.disconnectDevice;
  
  /// 已连接
  static String get connected => isZh ? AppZh.connected : AppEn.connected;
  
  static String get connectedDevices => isZh ? AppZh.connectedDevices : AppEn.connectedDevices;
  
  static String get refresh => isZh ? AppZh.refresh : AppEn.refresh;
  
  /// 未连接
  static String get disconnected => isZh ? AppZh.disconnected : AppEn.disconnected;
  
  /// 电池电量
  static String get batteryLevel => isZh ? AppZh.batteryLevel : AppEn.batteryLevel;
  
  /// 充电中
  static String get charging => isZh ? AppZh.charging : AppEn.charging;
  
  /// 查询电池
  static String get queryBattery => isZh ? AppZh.queryBattery : AppEn.queryBattery;
  
  /// 拍照
  static String get takePhoto => isZh ? AppZh.takePhoto : AppEn.takePhoto;
  
  /// 开始录像
  static String get startVideo => isZh ? AppZh.startVideo : AppEn.startVideo;
  
  /// 停止录像
  static String get stopVideo => isZh ? AppZh.stopVideo : AppEn.stopVideo;
  
  /// 开启Wi-Fi
  static String get enableWifi => isZh ? AppZh.enableWifi : AppEn.enableWifi;
  
  /// 关闭Wi-Fi
  static String get disableWifi => isZh ? AppZh.disableWifi : AppEn.disableWifi;
  
  /// OTA升级
  static String get otaUpgrade => isZh ? AppZh.otaUpgrade : AppEn.otaUpgrade;
  
  /// 杰里OTA升级
  static String get jlOtaUpgrade => isZh ? AppZh.jlOtaUpgrade : AppEn.jlOtaUpgrade;
  
  /// 取消杰里OTA
  static String get cancelJlOta => isZh ? AppZh.cancelJlOta : AppEn.cancelJlOta;
  
  /// 全志OTA升级
  static String get qzOtaUpgrade => isZh ? AppZh.qzOtaUpgrade : AppEn.qzOtaUpgrade;
  
  /// 设置语音唤醒
  static String get setVoiceWakeup => isZh ? AppZh.setVoiceWakeup : AppEn.setVoiceWakeup;
  
  /// 退出语音
  static String get exitVoice => isZh ? AppZh.exitVoice : AppEn.exitVoice;
  
  /// 中文
  static String get chinese => isZh ? AppZh.chinese : AppEn.chinese;
  
  /// English
  static String get english => isZh ? AppZh.english : AppEn.english;
  
  // ==================== 提示信息 / Toast Messages ====================
  
  /// 请先连接设备
  static String get pleaseConnectDevice => isZh ? AppZh.pleaseConnectDevice : AppEn.pleaseConnectDevice;
  
  /// 操作成功
  static String get operationSuccess => isZh ? AppZh.operationSuccess : AppEn.operationSuccess;
  
  /// 操作失败
  static String get operationFailed => isZh ? AppZh.operationFailed : AppEn.operationFailed;
  
  /// 正在连接设备...
  static String get connectingDevice => isZh ? AppZh.connectingDevice : AppEn.connectingDevice;
  
  /// 连接成功
  static String get connectSuccess => isZh ? AppZh.connectSuccess : AppEn.connectSuccess;
  
  /// 连接失败
  static String connectFailed(String error) => isZh ? AppZh.connectFailed(error) : AppEn.connectFailed(error);
  
  /// 已断开连接
  static String get disconnectedSuccess => isZh ? AppZh.disconnectedSuccess : AppEn.disconnectedSuccess;
  
  /// 正在取消OTA升级...
  static String get cancellingOta => isZh ? AppZh.cancellingOta : AppEn.cancellingOta;
  
  /// OTA升级已取消
  static String get otaCancelled => isZh ? AppZh.otaCancelled : AppEn.otaCancelled;
  
  /// 取消OTA升级失败
  static String get cancelOtaFailed => isZh ? AppZh.cancelOtaFailed : AppEn.cancelOtaFailed;
  
  /// 杰里OTA升级已启动
  static String get jlOtaStarted => isZh ? AppZh.jlOtaStarted : AppEn.jlOtaStarted;
  
  /// 杰里OTA升级启动失败
  static String get jlOtaStartFailed => isZh ? AppZh.jlOtaStartFailed : AppEn.jlOtaStartFailed;
  
  /// 全志OTA功能暂未实现
  static String get qzOtaNotImplemented => isZh ? AppZh.qzOtaNotImplemented : AppEn.qzOtaNotImplemented;
  
  // ==================== 功能模块 / Feature Modules ====================
  
  /// 基础功能
  static String get basicFunctions => isZh ? AppZh.basicFunctions : AppEn.basicFunctions;
  
  /// 眼镜功能
  static String get glassesFunctions => isZh ? AppZh.glassesFunctions : AppEn.glassesFunctions;
  
  /// 音频功能
  static String get audioFunctions => isZh ? AppZh.audioFunctions : AppEn.audioFunctions;
  
  /// 文件管理
  static String get fileManagement => isZh ? AppZh.fileManagement : AppEn.fileManagement;
  
  /// 录音功能
  static String get recordFunctions => isZh ? AppZh.recordFunctions : AppEn.recordFunctions;
  
  /// 用户信息
  static String get userInfo => isZh ? AppZh.userInfo : AppEn.userInfo;
  
  /// 直播功能
  static String get liveFunctions => isZh ? AppZh.liveFunctions : AppEn.liveFunctions;
  
  /// 设备管理
  static String get deviceManagement => isZh ? AppZh.deviceManagement : AppEn.deviceManagement;
  
  /// OTA升级功能
  static String get otaFunctions => isZh ? AppZh.otaFunctions : AppEn.otaFunctions;
  
  /// 待实现功能
  static String get todoFunctions => isZh ? AppZh.todoFunctions : AppEn.todoFunctions;
  
  // ==================== 其他常用字符串 / Other Common Strings ====================
  
  /// 扫描设备
  static String get scanDevice => isZh ? AppZh.scanDevice : AppEn.scanDevice;
  
  /// 扫描并连接智能眼镜
  static String get scanAndConnect => isZh ? AppZh.scanAndConnect : AppEn.scanAndConnect;
  
  /// 申请权限
  static String get requestPermission => isZh ? AppZh.requestPermission : AppEn.requestPermission;
  
  /// 连接设备
  static String get connect => isZh ? AppZh.connect : AppEn.connect;
  
  /// 断开设备
  static String get disconnect => isZh ? AppZh.disconnect : AppEn.disconnect;
  
  /// 同步时间
  static String get syncTime => isZh ? AppZh.syncTime : AppEn.syncTime;
  
  /// 查询版本
  static String get queryVersion => isZh ? AppZh.queryVersion : AppEn.queryVersion;
  
  /// 重启设备
  static String get restartDevice => isZh ? AppZh.restartDevice : AppEn.restartDevice;
  
  /// 关闭设备
  static String get shutdownDevice => isZh ? AppZh.shutdownDevice : AppEn.shutdownDevice;
  
  /// 恢复出厂设置
  static String get factoryReset => isZh ? AppZh.factoryReset : AppEn.factoryReset;
  
  /// 检查固件更新
  static String get checkFirmwareUpdate => isZh ? AppZh.checkFirmwareUpdate : AppEn.checkFirmwareUpdate;
  
  /// 选择固件文件进行升级
  static String get selectFirmware => isZh ? AppZh.selectFirmware : AppEn.selectFirmware;
  
  /// 仅杰里芯片可取消
  static String get onlyJlCancellable => isZh ? AppZh.onlyJlCancellable : AppEn.onlyJlCancellable;
  
  /// 通过WiFi升级固件（不可取消）
  static String get wifiOtaNote => isZh ? AppZh.wifiOtaNote : AppEn.wifiOtaNote;
  
  /// 请选择固件文件...
  static String get selectFirmwareFile => isZh ? AppZh.selectFirmwareFile : AppEn.selectFirmwareFile;
  
  // ==================== 状态文本 / Status Text ====================
  
  /// 申请权限
  static String get requestPermissionStatus => isZh ? AppZh.requestPermissionStatus : AppEn.requestPermissionStatus;
  
  /// 未连接
  static String get disconnectedStatus => isZh ? AppZh.disconnectedStatus : AppEn.disconnectedStatus;
  
  /// 未知
  static String get unknownStatus => isZh ? AppZh.unknownStatus : AppEn.unknownStatus;
  
  /// 等待接收...
  static String get waitingToReceive => isZh ? AppZh.waitingToReceive : AppEn.waitingToReceive;
  
  /// 无音频数据
  static String get noAudioData => isZh ? AppZh.noAudioData : AppEn.noAudioData;
  
  /// 无AI识别图片数据
  static String get noAiImageData => isZh ? AppZh.noAiImageData : AppEn.noAiImageData;
  
  /// 无翻译音频数据
  static String get noTranslationAudio => isZh ? AppZh.noTranslationAudio : AppEn.noTranslationAudio;
  
  /// 无PCM音频数据
  static String get noPcmAudio => isZh ? AppZh.noPcmAudio : AppEn.noPcmAudio;
  
  /// 点击获取
  static String get clickToGet => isZh ? AppZh.clickToGet : AppEn.clickToGet;
  
  /// 等待OTA状态
  static String get waitingOtaStatus => isZh ? AppZh.waitingOtaStatus : AppEn.waitingOtaStatus;
  
  /// 等待操作结果
  static String get waitingActionResult => isZh ? AppZh.waitingActionResult : AppEn.waitingActionResult;
  
  /// 等待SDK日志
  static String get waitingSdkLog => isZh ? AppZh.waitingSdkLog : AppEn.waitingSdkLog;
  
  /// 未设置
  static String get notSet => isZh ? AppZh.notSet : AppEn.notSet;
  
  /// 获取中...
  static String get getting => isZh ? AppZh.getting : AppEn.getting;
  
  /// 不支持或错误
  static String get notSupportedOrError => isZh ? AppZh.notSupportedOrError : AppEn.notSupportedOrError;
  
  // ==================== 功能子标题 / Feature Subtitles ====================
  
  /// 显示当前设备连接状态
  static String get showConnectionStatus => isZh ? AppZh.showConnectionStatus : AppEn.showConnectionStatus;
  
  /// 移除断开连接
  static String get removeAndDisconnect => isZh ? AppZh.removeAndDisconnect : AppEn.removeAndDisconnect;
  
  /// 重新连接设备
  static String get reconnectDevice => isZh ? AppZh.reconnectDevice : AppEn.reconnectDevice;
  
  /// 重新连接上次设备
  static String get reconnectLastDevice => isZh ? AppZh.reconnectLastDevice : AppEn.reconnectLastDevice;
  
  /// 重新连接中
  static String get reconnecting => isZh ? AppZh.reconnecting : AppEn.reconnecting;
  
  /// 重新连接命令已发送
  static String get reconnectCommandSent => isZh ? AppZh.reconnectCommandSent : AppEn.reconnectCommandSent;
  
  /// 重新连接失败
  static String get reconnectFailed => isZh ? AppZh.reconnectFailed : AppEn.reconnectFailed;
  
  /// 设备控制
  static String get deviceControl => isZh ? AppZh.deviceControl : AppEn.deviceControl;
  
  /// 佩戴检查
  static String get wearCheck => isZh ? AppZh.wearCheck : AppEn.wearCheck;
  
  /// 查询佩戴检查状态
  static String get queryWearCheckState => isZh ? AppZh.queryWearCheckState : AppEn.queryWearCheckState;
  
  /// 设置佩戴检查状态
  static String get setWearCheckState => isZh ? AppZh.setWearCheckState : AppEn.setWearCheckState;
  
  /// 设置佩戴检查描述
  static String get setWearCheckDesc => isZh ? AppZh.setWearCheckDesc : AppEn.setWearCheckDesc;
  
  /// 启用佩戴检查
  static String get enableWearCheck => isZh ? AppZh.enableWearCheck : AppEn.enableWearCheck;
  
  /// 佩戴检查对话框描述
  static String get wearCheckDialogDesc => isZh ? AppZh.wearCheckDialogDesc : AppEn.wearCheckDialogDesc;
  
  /// 佩戴检查状态提示
  static String wearCheckStateToast(String state) => isZh ? AppZh.wearCheckStateToast(state) : AppEn.wearCheckStateToast(state);
  
  /// 查询佩戴检查失败
  static String get queryWearCheckFailed => isZh ? AppZh.queryWearCheckFailed : AppEn.queryWearCheckFailed;
  
  /// 设置佩戴检查成功
  static String get setWearCheckSuccess => isZh ? AppZh.setWearCheckSuccess : AppEn.setWearCheckSuccess;
  
  /// 设置佩戴检查失败
  static String get setWearCheckFailed => isZh ? AppZh.setWearCheckFailed : AppEn.setWearCheckFailed;
  
  /// 取消
  static String get cancel => isZh ? AppZh.cancel : AppEn.cancel;
  
  /// 确认
  static String get confirm => isZh ? AppZh.confirm : AppEn.confirm;
  
  /// 同步设备时间
  static String get syncDeviceTime => isZh ? AppZh.syncDeviceTime : AppEn.syncDeviceTime;
  
  /// 设置眼镜语言
  static String get setGlassesLanguage => isZh ? AppZh.setGlassesLanguage : AppEn.setGlassesLanguage;
  
  /// 重启智能眼镜
  static String get restartGlasses => isZh ? AppZh.restartGlasses : AppEn.restartGlasses;
  
  /// 恢复出厂设置
  static String get factoryResetGlasses => isZh ? AppZh.factoryResetGlasses : AppEn.factoryResetGlasses;
  
  /// 关闭智能眼镜
  static String get shutdownGlasses => isZh ? AppZh.shutdownGlasses : AppEn.shutdownGlasses;
  
  /// 眼镜功能
  static String get glassesFeatures => isZh ? AppZh.glassesFeatures : AppEn.glassesFeatures;
  
  /// 控制眼镜拍照
  static String get controlPhoto => isZh ? AppZh.controlPhoto : AppEn.controlPhoto;
  
  /// 开始录像功能
  static String get startVideoFunction => isZh ? AppZh.startVideoFunction : AppEn.startVideoFunction;
  
  /// 停止录像功能
  static String get stopVideoFunction => isZh ? AppZh.stopVideoFunction : AppEn.stopVideoFunction;
  
  /// 音频控制功能
  static String get audioControlFunction => isZh ? AppZh.audioControlFunction : AppEn.audioControlFunction;
  
  /// AI对话监听
  static String get aiConversationListen => isZh ? AppZh.aiConversationListen : AppEn.aiConversationListen;
  
  /// AI对话状态
  static String get aiConversationStatus => isZh ? AppZh.aiConversationStatus : AppEn.aiConversationStatus;
  
  /// AI状态-未开始
  static String get aiStatusNotStarted => isZh ? AppZh.aiStatusNotStarted : AppEn.aiStatusNotStarted;
  
  /// AI状态-开始
  static String get aiStatusStarted => isZh ? AppZh.aiStatusStarted : AppEn.aiStatusStarted;
  
  /// AI状态-结束
  static String get aiStatusEnded => isZh ? AppZh.aiStatusEnded : AppEn.aiStatusEnded;
  
  /// 获取运行状态AI功能
  static String get aiFunctions => isZh ? AppZh.aiFunctions : AppEn.aiFunctions;
  
  /// 主动退出语音回复状态
  static String get exitVoiceReply => isZh ? AppZh.exitVoiceReply : AppEn.exitVoiceReply;
  
  /// Wi-Fi功能（文件同步）
  static String get wifiFileSync => isZh ? AppZh.wifiFileSync : AppEn.wifiFileSync;
  
  /// 开启文件传输服务
  static String get enableFileTransfer => isZh ? AppZh.enableFileTransfer : AppEn.enableFileTransfer;
  
  /// 关闭文件传输服务
  static String get disableFileTransfer => isZh ? AppZh.disableFileTransfer : AppEn.disableFileTransfer;
  
  /// 获取录像默认参数
  static String get getDefaultVideoParams => isZh ? AppZh.getDefaultVideoParams : AppEn.getDefaultVideoParams;
  
  /// 录音功能
  static String get recordFunction => isZh ? AppZh.recordFunction : AppEn.recordFunction;
  
  /// 设置录音控制状态
  static String get setRecordControl => isZh ? AppZh.setRecordControl : AppEn.setRecordControl;
  
  /// 停止录音控制
  static String get stopRecordControl => isZh ? AppZh.stopRecordControl : AppEn.stopRecordControl;
  
  /// 用户信息和设置
  static String get userInfoSettings => isZh ? AppZh.userInfoSettings : AppEn.userInfoSettings;
  
  /// 设置用户基本信息
  static String get setUserInfo => isZh ? AppZh.setUserInfo : AppEn.setUserInfo;
  
  /// 直播功能
  static String get liveFunction => isZh ? AppZh.liveFunction : AppEn.liveFunction;
  
  /// 进入直播模式
  static String get enterLiveMode => isZh ? AppZh.enterLiveMode : AppEn.enterLiveMode;
  
  /// 退出直播模式
  static String get exitLiveMode => isZh ? AppZh.exitLiveMode : AppEn.exitLiveMode;
  
  /// 进入文件同步模式
  static String get enterFileSyncMode => isZh ? AppZh.enterFileSyncMode : AppEn.enterFileSyncMode;
  
  /// 退出文件同步模式
  static String get exitFileSyncMode => isZh ? AppZh.exitFileSyncMode : AppEn.exitFileSyncMode;
  
  /// 媒体文件管理
  static String get mediaFileManagement => isZh ? AppZh.mediaFileManagement : AppEn.mediaFileManagement;
  
  /// 打开文件管理
  static String get openFileManager => isZh ? AppZh.openFileManager : AppEn.openFileManager;
  
  /// 管理和下载文件
  static String get manageDownloadFiles => isZh ? AppZh.manageDownloadFiles : AppEn.manageDownloadFiles;
  
  /// Wi-Fi状态
  static String get wifiStatus => isZh ? AppZh.wifiStatus : AppEn.wifiStatus;
  
  /// 文件统计
  static String get fileStatistics => isZh ? AppZh.fileStatistics : AppEn.fileStatistics;
  
  /// 总文件数
  static String get totalFiles => isZh ? AppZh.totalFiles : AppEn.totalFiles;
  
  /// 已选择
  static String get selectedFiles => isZh ? AppZh.selectedFiles : AppEn.selectedFiles;
  
  /// 已下载
  static String get downloadedFiles => isZh ? AppZh.downloadedFiles : AppEn.downloadedFiles;
  
  /// 下载进度
  static String get downloadProgress => isZh ? AppZh.downloadProgress : AppEn.downloadProgress;
  
  /// 暂无文件
  static String get noFiles => isZh ? AppZh.noFiles : AppEn.noFiles;
  
  /// 基础URL
  static String get baseUrl => isZh ? AppZh.baseUrl : AppEn.baseUrl;
  
  /// 下载位置
  static String get downloadLocation => isZh ? AppZh.downloadLocation : AppEn.downloadLocation;
  
  /// 全选
  static String get selectAll => isZh ? AppZh.selectAll : AppEn.selectAll;
  
  /// 批量下载
  static String get batchDownload => isZh ? AppZh.batchDownload : AppEn.batchDownload;
  
  /// 批量删除
  static String get batchDelete => isZh ? AppZh.batchDelete : AppEn.batchDelete;
  
  /// 下载中
  static String get downloading => isZh ? AppZh.downloading : AppEn.downloading;
  
  /// Wi-Fi已开启
  static String get wifiEnabled => isZh ? AppZh.wifiEnabled : AppEn.wifiEnabled;
  
  /// Wi-Fi已关闭
  static String get wifiDisabled => isZh ? AppZh.wifiDisabled : AppEn.wifiDisabled;
  
  /// 开启Wi-Fi失败
  static String get enableWifiFailed => isZh ? AppZh.enableWifiFailed : AppEn.enableWifiFailed;
  
  /// 关闭Wi-Fi失败
  static String get disableWifiFailed => isZh ? AppZh.disableWifiFailed : AppEn.disableWifiFailed;
  
  /// 获取文件列表失败
  static String get getFileListFailed => isZh ? AppZh.getFileListFailed : AppEn.getFileListFailed;
  
  /// 删除成功
  static String get deleteSuccess => isZh ? AppZh.deleteSuccess : AppEn.deleteSuccess;
  
  /// 删除失败
  static String get deleteFailed => isZh ? AppZh.deleteFailed : AppEn.deleteFailed;
  
  /// 批量删除成功
  static String get batchDeleteSuccess => isZh ? AppZh.batchDeleteSuccess : AppEn.batchDeleteSuccess;
  
  /// 批量删除失败
  static String get batchDeleteFailed => isZh ? AppZh.batchDeleteFailed : AppEn.batchDeleteFailed;
  
  /// 路径已复制到剪贴板
  static String get pathCopied => isZh ? AppZh.pathCopied : AppEn.pathCopied;
  
  /// 打开文件夹功能即将上线
  static String get openFolderFeatureComingSoon => isZh ? AppZh.openFolderFeatureComingSoon : AppEn.openFolderFeatureComingSoon;
  
  /// 确认删除
  static String get confirmDelete => isZh ? AppZh.confirmDelete : AppEn.confirmDelete;
  
  /// 确认批量删除
  static String get confirmBatchDelete => isZh ? AppZh.confirmBatchDelete : AppEn.confirmBatchDelete;
  
  /// 确认删除文件
  static String get confirmDeleteFile => isZh ? AppZh.confirmDeleteFile : AppEn.confirmDeleteFile;
  
  /// 确认删除文件
  static String get confirmDeleteFiles => isZh ? AppZh.confirmDeleteFiles : AppEn.confirmDeleteFiles;
  
  /// 个文件
  static String get files => isZh ? AppZh.files : AppEn.files;
  
  /// 删除
  static String get delete => isZh ? AppZh.delete : AppEn.delete;
  
  /// 批量下载完成
  static String get batchDownloadComplete => isZh ? AppZh.batchDownloadComplete : AppEn.batchDownloadComplete;
  
  /// 文件已下载到：
  static String get filesDownloadedTo => isZh ? AppZh.filesDownloadedTo : AppEn.filesDownloadedTo;
  
  /// 共下载文件
  static String get totalFilesDownloaded => isZh ? AppZh.totalFilesDownloaded : AppEn.totalFilesDownloaded;
  
  /// 打开文件夹
  static String get openFolder => isZh ? AppZh.openFolder : AppEn.openFolder;
  
  // ==================== 动态消息 / Dynamic Messages ====================
  
  /// 收到文件BaseUrl: {0}
  static String receivedFileBaseUrl(String url) => isZh 
    ? AppZh.receivedFileBaseUrl(url) : AppEn.receivedFileBaseUrl(url);
  
  /// 收到音频数据: 帧{0}, 大小{1}字节
  static String receivedAudioData(int frame, int size) => isZh
    ? AppZh.receivedAudioData(frame, size) : AppEn.receivedAudioData(frame, size);
  
  /// 错误: {0} - {1}
  static String errorMessage(String code, String message) => isZh
    ? AppZh.errorMessage(code, message) : AppEn.errorMessage(code, message);
  
  /// 电量: {0}{1}
  static String batteryDisplay(String level, bool charging) => isZh
    ? AppZh.batteryDisplay(level, charging) : AppEn.batteryDisplay(level, charging);
  
  // ==================== 更多状态文本 / More Status Text ====================
  
  /// 音频空闲
  static String get audioIdle => isZh ? AppZh.audioIdle : AppEn.audioIdle;
  
  /// 录音中
  static String get recording => isZh ? AppZh.recording : AppEn.recording;
  
  /// 音频暂停
  static String get audioPaused => isZh ? AppZh.audioPaused : AppEn.audioPaused;
  
  /// 未知音频状态
  static String get unknownAudioStatus => isZh ? AppZh.unknownAudioStatus : AppEn.unknownAudioStatus;
  
  /// 收到图片数据
  static String receivedImageData(int bytes) => isZh 
    ? AppZh.receivedImageData(bytes) : AppEn.receivedImageData(bytes);
  
  /// 接收图片数据中
  static String receivingImageData(int bytes) => isZh 
    ? AppZh.receivingImageData(bytes) : AppEn.receivingImageData(bytes);
  
  /// OTA升级状态
  static String get otaUpgradeStatus => isZh
    ? AppZh.otaUpgradeStatus : AppEn.otaUpgradeStatus;
  
  /// 日志: {0}
  static String logMessage(String log) => isZh
    ? AppZh.logMessage(log) : AppEn.logMessage(log);
  
  /// 已连接
  static String get connectedStatus => isZh ? AppZh.connectedStatus : AppEn.connectedStatus;
  
  /// 连接中
  static String get connectingStatus => isZh ? AppZh.connectingStatus : AppEn.connectingStatus;
  
  /// 智能眼镜测试
  static String get smartGlassesTest => isZh ? AppZh.smartGlassesTest : AppEn.smartGlassesTest;
  
  /// 请先开启蓝牙
  static String get pleaseEnableBluetooth => isZh ? AppZh.pleaseEnableBluetooth : AppEn.pleaseEnableBluetooth;
  
  /// 正在扫描
  static String get scanning => isZh ? AppZh.scanning : AppEn.scanning;
  
  /// 正在扫描... ({0} 个设备)
  static String scanningWithCount(int count) => isZh
    ? AppZh.scanningWithCount.replaceAll('{0}', count.toString())
    : AppEn.scanningWithCount.replaceAll('{0}', count.toString());
  
  /// 已发现 {0} 个设备
  static String devicesFound(int count) => isZh
    ? AppZh.devicesFound.replaceAll('{0}', count.toString())
    : AppEn.devicesFound.replaceAll('{0}', count.toString());
  
  /// 正在搜索设备...
  static String get searchingForDevices => isZh ? AppZh.searchingForDevices : AppEn.searchingForDevices;
  
  /// 点击扫描按钮搜索设备
  static String get clickToScan => isZh ? AppZh.clickToScan : AppEn.clickToScan;
  
  /// 停止
  static String get stop => isZh ? AppZh.stop : AppEn.stop;
  
  /// 扫描
  static String get scan => isZh ? AppZh.scan : AppEn.scan;
  
  /// 正在连接 {0}
  static String connectingToDevice(String deviceName) => isZh
    ? AppZh.connectingToDevice.replaceAll('{0}', deviceName)
    : AppEn.connectingToDevice.replaceAll('{0}', deviceName);
  
  /// 连接失败: {0}
  static String connectionFailed(String error) => isZh
    ? AppZh.connectionFailed.replaceAll('{0}', error)
    : AppEn.connectionFailed.replaceAll('{0}', error);
  
  /// 扫描失败: {0}
  static String scanFailed(String error) => isZh
    ? AppZh.scanFailed.replaceAll('{0}', error)
    : AppEn.scanFailed.replaceAll('{0}', error);
  
  /// 未知设备
  static String get unknownDevice => isZh ? AppZh.unknownDevice : AppEn.unknownDevice;
  
  /// 信号强度
  static String get signalStrength => isZh ? AppZh.signalStrength : AppEn.signalStrength;
  
  /// 杰理
  static String get jieLi => isZh ? AppZh.jieLi : AppEn.jieLi;
  
  /// 全志
  static String get quanZhi => isZh ? AppZh.quanZhi : AppEn.quanZhi;
  
  /// 已断开
  static String get disconnectedDone => isZh ? AppZh.disconnectedDone : AppEn.disconnectedDone;
  
  /// 断开中
  static String get disconnecting => isZh ? AppZh.disconnecting : AppEn.disconnecting;
  
  /// 未知状态
  static String get unknownConnectionState => isZh ? AppZh.unknownConnectionState : AppEn.unknownConnectionState;
  
  /// 蓝牙重置中
  static String get bluetoothResetting => isZh ? AppZh.bluetoothResetting : AppEn.bluetoothResetting;
  
  /// 蓝牙不可用
  static String get bluetoothUnavailable => isZh ? AppZh.bluetoothUnavailable : AppEn.bluetoothUnavailable;
  
  /// 蓝牙未授权
  static String get bluetoothUnauthorized => isZh ? AppZh.bluetoothUnauthorized : AppEn.bluetoothUnauthorized;
  
  /// 蓝牙可用
  static String get bluetoothAvailable => isZh ? AppZh.bluetoothAvailable : AppEn.bluetoothAvailable;
  
  /// 蓝牙受限
  static String get bluetoothLimiting => isZh ? AppZh.bluetoothLimiting : AppEn.bluetoothLimiting;
  
  /// 蓝牙开启中
  static String get bluetoothTurningOn => isZh ? AppZh.bluetoothTurningOn : AppEn.bluetoothTurningOn;
  
  /// 蓝牙已开启
  static String get bluetoothOn => isZh ? AppZh.bluetoothOn : AppEn.bluetoothOn;
  
  /// 蓝牙关闭中
  static String get bluetoothTurningOff => isZh ? AppZh.bluetoothTurningOff : AppEn.bluetoothTurningOff;
  
  /// 蓝牙已关闭
  static String get bluetoothOff => isZh ? AppZh.bluetoothOff : AppEn.bluetoothOff;
  
  /// 再按一次退出app
  static String get pressAgainToExit => isZh ? AppZh.pressAgainToExit : AppEn.pressAgainToExit;
  
  /// 蓝牙状态
  static String get bluetoothStatus => isZh ? AppZh.bluetoothStatus : AppEn.bluetoothStatus;
  
  /// 显示连接状态
  static String get showConnectionStatusTitle => isZh ? AppZh.showConnectionStatusTitle : AppEn.showConnectionStatusTitle;
  
  /// 断开并移除设备
  static String get disconnectAndRemove => isZh ? AppZh.disconnectAndRemove : AppEn.disconnectAndRemove;
  
  /// 发送语言设置
  static String get sendLanguageSettings => isZh ? AppZh.sendLanguageSettings : AppEn.sendLanguageSettings;
  
  // ==================== Toast 消息 / Toast Messages ====================
  
  /// 电量过低（{0}），无法进入文件同步模式\n请先充电至 20% 以上
  static String lowBatteryWarning(String battery) => isZh
    ? AppZh.lowBatteryWarning(battery) : AppEn.lowBatteryWarning(battery);
  
  /// 已进入文件同步模式（Wi-Fi 已开启）
  static String get enteredFileSyncMode => isZh ? AppZh.enteredFileSyncMode : AppEn.enteredFileSyncMode;
  
  /// 进入文件同步模式失败
  static String get enterFileSyncModeFailed => isZh ? AppZh.enterFileSyncModeFailed : AppEn.enterFileSyncModeFailed;
  
  /// 已退出文件同步模式（Wi-Fi 已关闭）
  static String get exitedFileSyncMode => isZh ? AppZh.exitedFileSyncMode : AppEn.exitedFileSyncMode;
  
  /// 退出文件同步模式失败
  static String get exitFileSyncModeFailed => isZh ? AppZh.exitFileSyncModeFailed : AppEn.exitFileSyncModeFailed;
  
  /// 录像参数: {0}
  static String videoParams(String configStr) => isZh
    ? AppZh.videoParams(configStr) : AppEn.videoParams(configStr);
  
  /// 录音状态: {0}, 时长: {1}秒
  static String recordingStatus(String stateText, int totalTime) => isZh
    ? AppZh.recordingStatus(stateText, totalTime) : AppEn.recordingStatus(stateText, totalTime);
  
  /// 查询录音状态超时
  static String get queryRecordStatusTimeout => isZh ? AppZh.queryRecordStatusTimeout : AppEn.queryRecordStatusTimeout;
  
  /// 音频控制已设置: {0}
  static String audioControlSet(String actionText) => isZh
    ? AppZh.audioControlSet(actionText) : AppEn.audioControlSet(actionText);
  
  /// 音频状态: {0}
  static String audioStatus(String stateText) => isZh
    ? AppZh.audioStatus(stateText) : AppEn.audioStatus(stateText);
  
  /// AI回复状态已设置: {0}
  static String aiReplyStatusSet(String statusText) => isZh
    ? AppZh.aiReplyStatusSet(statusText) : AppEn.aiReplyStatusSet(statusText);
  
  /// 设备中共有 {0} 个文件
  static String deviceFileCount(int count) => isZh
    ? AppZh.deviceFileCount(count) : AppEn.deviceFileCount(count);
  
  /// 当前文件同步方式: {0}
  static String currentFileSyncMethod(String typeStr) => isZh
    ? AppZh.currentFileSyncMethod(typeStr) : AppEn.currentFileSyncMethod(typeStr);
  
  /// 设置用户信息失败
  static String get setUserInfoFailed => isZh ? AppZh.setUserInfoFailed : AppEn.setUserInfoFailed;
  
  /// 闹钟设置成功（7:30）
  static String get alarmSetSuccess => isZh ? AppZh.alarmSetSuccess : AppEn.alarmSetSuccess;
  
  /// 设置闹钟失败
  static String get setAlarmFailed => isZh ? AppZh.setAlarmFailed : AppEn.setAlarmFailed;
  
  /// 当前语言: {0}
  static String currentLanguage(String language) => isZh
    ? AppZh.currentLanguage(language) : AppEn.currentLanguage(language);
  
  /// 录像参数: 帧率: {0}fps, 最大时长: {1}秒
  static String videoConfigParams(int frameRate, int maxDuration) => isZh
    ? AppZh.videoConfigParams(frameRate, maxDuration) : AppEn.videoConfigParams(frameRate, maxDuration);
  
  /// 拍照指令已发送
  static String get photoCommandSent => isZh ? AppZh.photoCommandSent : AppEn.photoCommandSent;
  
  /// 拍照失败
  static String get photoFailed => isZh ? AppZh.photoFailed : AppEn.photoFailed;
  
  /// 拍照模式
  static String get photoMode => isZh ? AppZh.photoMode : AppEn.photoMode;
  
  /// 普通拍照
  static String get normalPhoto => isZh ? AppZh.normalPhoto : AppEn.normalPhoto;
  
  /// AI识别拍照
  static String get aiRecognitionPhoto => isZh ? AppZh.aiRecognitionPhoto : AppEn.aiRecognitionPhoto;
  
  /// 连拍
  static String get continuousPhoto => isZh ? AppZh.continuousPhoto : AppEn.continuousPhoto;
  
  /// 同声传译
  static String get simultaneousInterpretation => isZh ? AppZh.simultaneousInterpretation : AppEn.simultaneousInterpretation;
  
  /// 同声传译状态
  static String get simultaneousInterpretationStatus => isZh ? AppZh.simultaneousInterpretationStatus : AppEn.simultaneousInterpretationStatus;
  
  /// 开始同声传译
  static String get startSimultaneousInterpretation => isZh ? AppZh.startSimultaneousInterpretation : AppEn.startSimultaneousInterpretation;
  
  /// 暂停同声传译
  static String get pauseSimultaneousInterpretation => isZh ? AppZh.pauseSimultaneousInterpretation : AppEn.pauseSimultaneousInterpretation;
  
  /// 停止同声传译
  static String get stopSimultaneousInterpretation => isZh ? AppZh.stopSimultaneousInterpretation : AppEn.stopSimultaneousInterpretation;
  
  /// 同声传译未开始
  static String get simultaneousInterpretationNotStarted => isZh ? AppZh.simultaneousInterpretationNotStarted : AppEn.simultaneousInterpretationNotStarted;
  
  /// 同声传译进行中
  static String get simultaneousInterpretationStarted => isZh ? AppZh.simultaneousInterpretationStarted : AppEn.simultaneousInterpretationStarted;
  
  /// 同声传译已暂停
  static String get simultaneousInterpretationPaused => isZh ? AppZh.simultaneousInterpretationPaused : AppEn.simultaneousInterpretationPaused;
  
  /// 同声传译已停止
  static String get simultaneousInterpretationStopped => isZh ? AppZh.simultaneousInterpretationStopped : AppEn.simultaneousInterpretationStopped;
  
  /// 指令已发送
  static String get commandSent => isZh ? AppZh.commandSent : AppEn.commandSent;
  
  /// 失败
  static String get failed => isZh ? AppZh.failed : AppEn.failed;
  
  /// 同声传译状态设置
  static String simultaneousInterpretationStatusSet(String action) => isZh ? AppZh.simultaneousInterpretationStatusSet(action) : AppEn.simultaneousInterpretationStatusSet(action);
  
  /// 设置同声传译失败
  static String get setSimultaneousInterpretationFailed => isZh ? AppZh.setSimultaneousInterpretationFailed : AppEn.setSimultaneousInterpretationFailed;
  
  /// 录像开始成功
  static String get videoStartSuccess => isZh ? AppZh.videoStartSuccess : AppEn.videoStartSuccess;
  
  /// 开始录像失败
  static String get videoStartFailed => isZh ? AppZh.videoStartFailed : AppEn.videoStartFailed;
  
  /// 录像停止指令已发送
  static String get videoStopCommandSent => isZh ? AppZh.videoStopCommandSent : AppEn.videoStopCommandSent;
  
  /// 停止录像失败
  static String get videoStopFailed => isZh ? AppZh.videoStopFailed : AppEn.videoStopFailed;
  
  /// 设备重启成功
  static String get deviceRestartSuccess => isZh ? AppZh.deviceRestartSuccess : AppEn.deviceRestartSuccess;
  
  /// 设备重启失败
  static String get deviceRestartFailed => isZh ? AppZh.deviceRestartFailed : AppEn.deviceRestartFailed;
  
  /// 电池电量: {0}{1}
  static String batteryLevelToast(String level, bool charging) => isZh
    ? AppZh.batteryLevelToast(level, charging) : AppEn.batteryLevelToast(level, charging);
  
  /// 电池查询失败
  static String get batteryQueryFailed => isZh ? AppZh.batteryQueryFailed : AppEn.batteryQueryFailed;
  
  // ==================== 更多功能按钮 / More Function Buttons ====================
  
  /// 获取录音状态
  static String get getRecordStatus => isZh ? AppZh.getRecordStatus : AppEn.getRecordStatus;
  
  /// 获取设备语言
  static String get getDeviceLanguage => isZh ? AppZh.getDeviceLanguage : AppEn.getDeviceLanguage;
  
  /// 获取设备UUID
  static String get getDeviceUUID => isZh ? AppZh.getDeviceUUID : AppEn.getDeviceUUID;
  
  /// 获取语音唤醒状态
  static String get getVoiceWakeupStatus => isZh ? AppZh.getVoiceWakeupStatus : AppEn.getVoiceWakeupStatus;
  
  /// 获取运行状态
  static String get getRunningStatus => isZh ? AppZh.getRunningStatus : AppEn.getRunningStatus;
  
  /// 获取OTA状态
  static String get getOtaStatus => isZh ? AppZh.getOtaStatus : AppEn.getOtaStatus;
  
  /// 获取操作结果
  static String get getActionResult => isZh ? AppZh.getActionResult : AppEn.getActionResult;
  
  /// 获取SDK日志
  static String get getSdkLog => isZh ? AppZh.getSdkLog : AppEn.getSdkLog;
  
  /// OTA升级功能
  static String get otaUpgradeFunction => isZh ? AppZh.otaUpgradeFunction : AppEn.otaUpgradeFunction;
  
  /// 当前版本信息
  static String get currentVersionInfo => isZh ? AppZh.currentVersionInfo : AppEn.currentVersionInfo;
  
  /// 版本信息
  static String get versionInfo => isZh ? AppZh.versionInfo : AppEn.versionInfo;
  
  /// 查询设备版本
  static String get queryDeviceVersion => isZh ? AppZh.queryDeviceVersion : AppEn.queryDeviceVersion;
  
  /// 查询固件版本
  static String get queryJLVersion => isZh ? AppZh.queryJLVersion : AppEn.queryJLVersion;
  
  /// 查询影像系统版本
  static String get queryAllwinnerVersion => isZh ? AppZh.queryAllwinnerVersion : AppEn.queryAllwinnerVersion;
  
  /// 查询TP版本
  static String get queryTPVersion => isZh ? AppZh.queryTPVersion : AppEn.queryTPVersion;
  
  /// 文件管理功能
  static String get fileManagementFunction => isZh ? AppZh.fileManagementFunction : AppEn.fileManagementFunction;
  
  /// 设备管理功能
  static String get deviceManagementFunction => isZh ? AppZh.deviceManagementFunction : AppEn.deviceManagementFunction;
  
  // ==================== 状态标签 / Status Labels ====================
  
  /// 音频数据状态
  static String get audioDataStatus => isZh ? AppZh.audioDataStatus : AppEn.audioDataStatus;
  
  /// 停止音频状态
  static String get stopAudioStatus => isZh ? AppZh.stopAudioStatus : AppEn.stopAudioStatus;
  
  /// 音频控制状态
  static String get audioControlStatus => isZh ? AppZh.audioControlStatus : AppEn.audioControlStatus;
  
  /// AI识别图片数据
  static String get aiImageDataStatus => isZh ? AppZh.aiImageDataStatus : AppEn.aiImageDataStatus;
  
  /// 翻译音频数据
  static String get translationAudioData => isZh ? AppZh.translationAudioData : AppEn.translationAudioData;
  
  /// 设置录像默认参数
  static String get setVideoDefaultParams => isZh ? AppZh.setVideoDefaultParams : AppEn.setVideoDefaultParams;
  
  /// PCM音频数据
  static String get pcmAudioStatus => isZh ? AppZh.pcmAudioStatus : AppEn.pcmAudioStatus;
  
  // ==================== 更多Toast消息 / More Toast Messages ====================
  
  /// 获取录音状态失败
  static String get getRecordStatusFailed => isZh ? AppZh.getRecordStatusFailed : AppEn.getRecordStatusFailed;
  
  /// 获取设备UUID超时
  static String get getDeviceUuidTimeout => isZh ? AppZh.getDeviceUuidTimeout : AppEn.getDeviceUuidTimeout;
  
  /// 获取设备UUID失败
  static String get getDeviceUuidFailed => isZh ? AppZh.getDeviceUuidFailed : AppEn.getDeviceUuidFailed;
  
  // ==================== 子标题和描述 / Subtitles and Descriptions ====================
  
  /// 停止音频控制状态
  static String get stopAudioControlState => isZh ? AppZh.stopAudioControlState : AppEn.stopAudioControlState;
  
  /// 主动退出语音回复状态
  static String get exitVoiceReplyState => isZh ? AppZh.exitVoiceReplyState : AppEn.exitVoiceReplyState;
  
  /// 获取录像默认参数
  static String get getVideoDefaultParams => isZh ? AppZh.getVideoDefaultParams : AppEn.getVideoDefaultParams;
  
  /// 检查是否有新版本
  static String get checkForNewVersion => isZh ? AppZh.checkForNewVersion : AppEn.checkForNewVersion;
  
  /// 查询设备中的文件数量
  static String get queryFileCount => isZh ? AppZh.queryFileCount : AppEn.queryFileCount;
  
  /// 查询当前文件同步方式
  static String get queryFileSyncMethod => isZh ? AppZh.queryFileSyncMethod : AppEn.queryFileSyncMethod;
  
  /// 删除指定的媒体文件
  static String get deleteMediaFile => isZh ? AppZh.deleteMediaFile : AppEn.deleteMediaFile;
  
  /// 清除设备配对信息
  static String get clearPairInfo => isZh ? AppZh.clearPairInfo : AppEn.clearPairInfo;
  
  // ==================== 更多状态文本 / More Status Text ====================
  
  /// 获取中...
  static String get gettingStatus => isZh ? AppZh.gettingStatus : AppEn.gettingStatus;
  
  /// 不支持或错误
  static String get notSupportedOrErrorStatus => isZh ? AppZh.notSupportedOrErrorStatus : AppEn.notSupportedOrErrorStatus;
  
  /// 设备不支持此功能
  static String get deviceNotSupported => isZh ? AppZh.deviceNotSupported : AppEn.deviceNotSupported;
  
  /// 获取失败
  static String get getFailed => isZh ? AppZh.getFailed : AppEn.getFailed;
  
  /// SDK未返回
  static String get sdkNotReturned => isZh ? AppZh.sdkNotReturned : AppEn.sdkNotReturned;
  
  /// 设备UUID: {0}
  static String deviceUuid(String uuid) => isZh
    ? AppZh.deviceUuid(uuid) : AppEn.deviceUuid(uuid);
  
  /// 发送
  static String get send => isZh ? AppZh.send : AppEn.send;
  
  /// 开始AI回复
  static String get startAiReply => isZh ? AppZh.startAiReply : AppEn.startAiReply;
  
  /// 完成AI回复
  static String get completeAiReply => isZh ? AppZh.completeAiReply : AppEn.completeAiReply;
  
  /// 中断AI回复
  static String get interruptAiReply => isZh ? AppZh.interruptAiReply : AppEn.interruptAiReply;
  
  // ==================== 初始状态文本 / Initial Status Text ====================
  
  /// 未知
  static String get unknown => isZh ? AppZh.unknown : AppEn.unknown;
  
  /// 无翻译音频数据
  static String get noTranslationAudioData => isZh ? AppZh.noTranslationAudio : AppEn.noTranslationAudio;
  
  /// 无PCM音频数据
  static String get noPcmAudioData => isZh ? AppZh.noPcmAudio : AppEn.noPcmAudio;
  
  // ==================== 下拉选项文本 / Dropdown Options ====================
  
  /// 帧率 (fps)
  static String get frameRate => isZh ? AppZh.frameRate : AppEn.frameRate;
  
  /// 最大时长
  static String get maxDuration => isZh ? AppZh.maxDuration : AppEn.maxDuration;
  
  /// WiFi操作结果
  static String get wifiOperationResult => isZh ? AppZh.wifiOperationResult : AppEn.wifiOperationResult;
  
  /// (code=0成功)
  static String get codeZeroSuccess => isZh ? AppZh.codeZeroSuccess : AppEn.codeZeroSuccess;
  
  // ==================== 音频控制选项 / Audio Control Options ====================
  
  /// 1. 开始音频
  static String get startAudio => isZh ? AppZh.startAudio : AppEn.startAudio;
  
  /// 2. 取消音频
  static String get cancelAudio => isZh ? AppZh.cancelAudio : AppEn.cancelAudio;
  
  /// 3. 开始DNS流
  static String get startDnsStream => isZh ? AppZh.startDnsStream : AppEn.startDnsStream;
  
  /// 4. 暂停DNS流
  static String get pauseDnsStream => isZh ? AppZh.pauseDnsStream : AppEn.pauseDnsStream;
  
  /// 5. 停止DNS流
  static String get stopDnsStream => isZh ? AppZh.stopDnsStream : AppEn.stopDnsStream;
  
  /// 6. 开始普通流
  static String get startNormalStream => isZh ? AppZh.startNormalStream : AppEn.startNormalStream;
  
  /// 7. 暂停普通流
  static String get pauseNormalStream => isZh ? AppZh.pauseNormalStream : AppEn.pauseNormalStream;
  
  /// 8. 停止普通流
  static String get stopNormalStream => isZh ? AppZh.stopNormalStream : AppEn.stopNormalStream;
  
  // ==================== 更多按钮文本 / More Button Text ====================
  
  /// 查询Git哈希版本
  static String get queryGitHashVersion => isZh ? AppZh.queryGitHashVersion : AppEn.queryGitHashVersion;
  
  /// 检查最新版本
  static String get checkLatestVersion => isZh ? AppZh.checkLatestVersion : AppEn.checkLatestVersion;
  
  /// 文件BaseUrl
  static String get fileBaseUrl => isZh ? AppZh.fileBaseUrl : AppEn.fileBaseUrl;
  
  /// SDK最新日志
  static String get sdkLatestLog => isZh ? AppZh.sdkLatestLog : AppEn.sdkLatestLog;
  
  /// 操作类型
  static String get operationType => isZh ? AppZh.operationType : AppEn.operationType;
  
  /// 设备运行状态
  static String get deviceRunningStatus => isZh ? AppZh.deviceRunningStatus : AppEn.deviceRunningStatus;
  
  /// 点击查询或监听自动更新
  static String get clickToQueryOrAutoUpdate => isZh ? AppZh.clickToQueryOrAutoUpdate : AppEn.clickToQueryOrAutoUpdate;
  
  /// 设备状态
  static String get deviceStatus => isZh ? AppZh.deviceStatus : AppEn.deviceStatus;
  
  /// 连接状态
  static String get connectionState => isZh ? AppZh.connectionState : AppEn.connectionState;
  
  /// 设备版本
  static String get deviceVersion => isZh ? AppZh.deviceVersion : AppEn.deviceVersion;
  
  /// 固件版本
  static String get firmwareVersion => isZh ? AppZh.firmwareVersion : AppEn.firmwareVersion;
  
  /// 连接状态==================== 更多选项 / More Options ====================
  
  /// 30 秒
  static String get seconds30 => isZh ? AppZh.seconds30 : AppEn.seconds30;
  
  /// 60 秒
  static String get seconds60 => isZh ? AppZh.seconds60 : AppEn.seconds60;
  
  /// 120 秒
  static String get seconds120 => isZh ? AppZh.seconds120 : AppEn.seconds120;
  
  /// 300 秒
  static String get seconds300 => isZh ? AppZh.seconds300 : AppEn.seconds300;
  
  /// 应用设置
  static String get applySettings => isZh ? AppZh.applySettings : AppEn.applySettings;
  
  /// 开启语音唤醒 (TypeOn)
  static String get enableVoiceWakeupTypeOn => isZh ? AppZh.enableVoiceWakeupTypeOn : AppEn.enableVoiceWakeupTypeOn;
  
  /// 关闭语音唤醒 (TypeOff)
  static String get disableVoiceWakeupTypeOff => isZh ? AppZh.disableVoiceWakeupTypeOff : AppEn.disableVoiceWakeupTypeOff;
  
  /// 开启语音唤醒
  static String get enableVoiceWakeup => isZh ? AppZh.enableVoiceWakeup : AppEn.enableVoiceWakeup;
  
  /// 关闭语音唤醒
  static String get disableVoiceWakeup => isZh ? AppZh.disableVoiceWakeup : AppEn.disableVoiceWakeup;
  
  // ==================== 帧率选项 / Frame Rate Options ====================
  
  /// 15 fps
  static String get fps15 => isZh ? AppZh.fps15 : AppEn.fps15;
  
  /// 24 fps
  static String get fps24 => isZh ? AppZh.fps24 : AppEn.fps24;
  
  /// 30 fps
  static String get fps30 => isZh ? AppZh.fps30 : AppEn.fps30;
  
  /// 60 fps
  static String get fps60 => isZh ? AppZh.fps60 : AppEn.fps60;
  
  /// 已连接设备
  static String get connectedDevice => isZh ? AppZh.connectedDevice : AppEn.connectedDevice;
  
  /// 位置权限被拒绝
  static String get locationPermissionDenied => isZh ? AppZh.locationPermissionDenied : AppEn.locationPermissionDenied;
  
  /// 存储权限被拒绝
  static String get storagePermissionDenied => isZh ? AppZh.storagePermissionDenied : AppEn.storagePermissionDenied;
  
  /// 权限已授予
  static String get permissionGranted => isZh ? AppZh.permissionGranted : AppEn.permissionGranted;
  
  /// 蓝牙已开启
  static String get bluetoothEnabled => isZh ? AppZh.bluetoothEnabled : AppEn.bluetoothEnabled;
  
  /// 蓝牙已关闭
  static String get bluetoothDisabled => isZh ? AppZh.bluetoothDisabled : AppEn.bluetoothDisabled;
  
  /// 检查失败
  static String get checkFailed => isZh ? AppZh.checkFailed : AppEn.checkFailed;
  
  /// 设备已连接
  static String get deviceConnected => isZh ? AppZh.deviceConnected : AppEn.deviceConnected;
  
  /// 设备未连接
  static String get deviceNotConnected => isZh ? AppZh.deviceNotConnected : AppEn.deviceNotConnected;
  
  /// 设备已移除并断开连接
  static String get deviceRemovedAndDisconnected => isZh ? AppZh.deviceRemovedAndDisconnected : AppEn.deviceRemovedAndDisconnected;
  
  /// 断开连接失败
  static String get disconnectFailed => isZh ? AppZh.disconnectFailed : AppEn.disconnectFailed;
  
  /// 移除设备失败
  static String get removeDeviceFailed => isZh ? AppZh.removeDeviceFailed : AppEn.removeDeviceFailed;
  
  /// 时间同步成功
  static String get timeSyncSuccess => isZh ? AppZh.timeSyncSuccess : AppEn.timeSyncSuccess;
  
  /// 时间同步失败
  static String get timeSyncFailed => isZh ? AppZh.timeSyncFailed : AppEn.timeSyncFailed;
  
  /// 版本查询成功
  static String get versionQuerySuccess => isZh ? AppZh.versionQuerySuccess : AppEn.versionQuerySuccess;
  
  /// 版本查询失败
  static String get versionQueryFailed => isZh ? AppZh.versionQueryFailed : AppEn.versionQueryFailed;
  
  /// 语言设置已发送
  static String get languageSettingsSent => isZh ? AppZh.languageSettingsSent : AppEn.languageSettingsSent;
  
  /// 设备重置成功
  static String get deviceResetSuccess => isZh ? AppZh.deviceResetSuccess : AppEn.deviceResetSuccess;
  
  /// 设备重置失败
  static String get deviceResetFailed => isZh ? AppZh.deviceResetFailed : AppEn.deviceResetFailed;
  
  /// 设备关闭成功
  static String get deviceShutdownSuccess => isZh ? AppZh.deviceShutdownSuccess : AppEn.deviceShutdownSuccess;
  
  /// 设备关闭失败
  static String get deviceShutdownFailed => isZh ? AppZh.deviceShutdownFailed : AppEn.deviceShutdownFailed;
  
  /// 音频已停止
  static String get audioStopped => isZh ? AppZh.audioStopped : AppEn.audioStopped;
  
  /// 对讲中
  static String get inIntercom => isZh ? AppZh.inIntercom : AppEn.inIntercom;
  
  /// 未对讲
  static String get notIntercom => isZh ? AppZh.notIntercom : AppEn.notIntercom;
  
  /// 已退出语音
  static String get exitedVoice => isZh ? AppZh.exitedVoice : AppEn.exitedVoice;
  
  /// HTTP GET 模式
  static String get httpGetMode => isZh ? AppZh.httpGetMode : AppEn.httpGetMode;
  
  /// 其他模式
  static String get otherMode => isZh ? AppZh.otherMode : AppEn.otherMode;
  
  /// 删除文件成功
  static String get deleteFileSuccess => isZh ? AppZh.deleteFileSuccess : AppEn.deleteFileSuccess;
  
  /// 删除文件失败
  static String get deleteFileFailed => isZh ? AppZh.deleteFileFailed : AppEn.deleteFileFailed;
  
  /// 录音已开始
  static String get recordingStarted => isZh ? AppZh.recordingStarted : AppEn.recordingStarted;
  
  /// 开始录音失败
  static String get startRecordingFailed => isZh ? AppZh.startRecordingFailed : AppEn.startRecordingFailed;
  
  /// 录音已停止
  static String get recordingStopped => isZh ? AppZh.recordingStopped : AppEn.recordingStopped;
  
  /// 停止录音失败
  static String get stopRecordingFailed => isZh ? AppZh.stopRecordingFailed : AppEn.stopRecordingFailed;
  
  /// 未录音
  static String get notRecording => isZh ? AppZh.notRecording : AppEn.notRecording;
  
  /// 用户信息设置成功
  static String get userInfoSetSuccess => isZh ? AppZh.userInfoSetSuccess : AppEn.userInfoSetSuccess;
  
  /// 用户信息设置失败
  static String get userInfoSetFailed => isZh ? AppZh.userInfoSetFailed : AppEn.userInfoSetFailed;
  
  /// 闹钟设置失败
  static String get alarmSetFailed => isZh ? AppZh.alarmSetFailed : AppEn.alarmSetFailed;
  
  /// 开始录音失败
  static String get startRecordingFailed2 => isZh ? AppZh.startRecordingFailed2 : AppEn.startRecordingFailed2;
  
  /// 停止录音失败
  static String get stopRecordingFailed2 => isZh ? AppZh.stopRecordingFailed2 : AppEn.stopRecordingFailed2;
  
  /// 未定义的指令
  static String get undefinedCommand => isZh ? AppZh.undefinedCommand : AppEn.undefinedCommand;
  
  /// 设备不支持此功能
  static String get deviceNotSupportedFeature => isZh ? AppZh.deviceNotSupportedFeature : AppEn.deviceNotSupportedFeature;
  
  /// 进入直播模式失败
  static String get enterLiveModeFailed => isZh ? AppZh.enterLiveModeFailed : AppEn.enterLiveModeFailed;
  
  /// 已退出直播模式
  static String get exitedLiveMode => isZh ? AppZh.exitedLiveMode : AppEn.exitedLiveMode;
  
  /// 退出直播模式失败
  static String get exitLiveModeFailed => isZh ? AppZh.exitLiveModeFailed : AppEn.exitLiveModeFailed;
  
  /// 已清除配对信息
  static String get clearedPairInfo => isZh ? AppZh.clearedPairInfo : AppEn.clearedPairInfo;
  
  /// 清除配对信息失败
  static String get clearPairInfoFailed => isZh ? AppZh.clearPairInfoFailed : AppEn.clearPairInfoFailed;
  
  /// 已开启
  static String get enabled => isZh ? AppZh.enabled : AppEn.enabled;
  
  /// 已关闭
  static String get disabled => isZh ? AppZh.disabled : AppEn.disabled;
  
  /// 语音唤醒已{0}
  static String voiceWakeupSet(String status) => isZh
    ? AppZh.voiceWakeupSet(status) : AppEn.voiceWakeupSet(status);
  
  /// 语音唤醒状态: {0}
  static String voiceWakeupStatus(String status) => isZh
    ? AppZh.voiceWakeupStatus(status) : AppEn.voiceWakeupStatus(status);
  
  /// 设备不支持此功能
  static String get deviceNotSupportedFeature2 => isZh ? AppZh.deviceNotSupportedFeature2 : AppEn.deviceNotSupportedFeature2;
  
  /// 进入直播模式失败
  static String get enterLiveModeFailed2 => isZh ? AppZh.enterLiveModeFailed2 : AppEn.enterLiveModeFailed2;
  
  /// 退出直播模式失败
  static String get exitLiveModeFailed2 => isZh ? AppZh.exitLiveModeFailed2 : AppEn.exitLiveModeFailed2;
  
  /// 清除配对信息失败
  static String get clearPairInfoFailed2 => isZh ? AppZh.clearPairInfoFailed2 : AppEn.clearPairInfoFailed2;
  
  /// 获取中...
  static String get gettingStatusWithDots => isZh ? AppZh.gettingStatusWithDots : AppEn.gettingStatusWithDots;
  
  /// 秒
  static String get seconds => isZh ? AppZh.seconds : AppEn.seconds;
  
  /// 时长
  static String get duration => isZh ? AppZh.duration : AppEn.duration;
  
  /// 获取录像参数失败
  static String get getVideoParamsFailed => isZh ? AppZh.getVideoParamsFailed : AppEn.getVideoParamsFailed;
  
  /// 录像参数已设置: {0}, 最大{1}
  static String videoParamsSet(String fpsText, int duration) => isZh
    ? AppZh.videoParamsSet(fpsText, duration) : AppEn.videoParamsSet(fpsText, duration);
  
  /// 设置录像参数失败
  static String get setVideoParamsFailed => isZh ? AppZh.setVideoParamsFailed : AppEn.setVideoParamsFailed;
  
  /// 发送语言设置失败
  static String get sendLanguageSettingsFailed => isZh ? AppZh.sendLanguageSettingsFailed : AppEn.sendLanguageSettingsFailed;
  
  /// 设备关闭失败
  static String get deviceShutdownFailed2 => isZh ? AppZh.deviceShutdownFailed2 : AppEn.deviceShutdownFailed2;
  
  /// 设置音频控制失败
  static String get setAudioControlFailed => isZh ? AppZh.setAudioControlFailed : AppEn.setAudioControlFailed;
  
  /// 停止音频失败
  static String get stopAudioFailed => isZh ? AppZh.stopAudioFailed : AppEn.stopAudioFailed;
  
  /// 查询音频状态失败
  static String get queryAudioStateFailed => isZh ? AppZh.queryAudioStateFailed : AppEn.queryAudioStateFailed;
  
  /// 设置 AI 回复状态失败
  static String get setAiReplyStatusFailed => isZh ? AppZh.setAiReplyStatusFailed : AppEn.setAiReplyStatusFailed;
  
  /// 退出语音失败
  static String get exitVoiceFailed => isZh ? AppZh.exitVoiceFailed : AppEn.exitVoiceFailed;
  
  /// 查询文件数量失败
  static String get queryFileCountFailed => isZh ? AppZh.queryFileCountFailed : AppEn.queryFileCountFailed;
  
  /// 查询文件同步方式失败
  static String get queryFileSyncMethodFailed => isZh ? AppZh.queryFileSyncMethodFailed : AppEn.queryFileSyncMethodFailed;
  
  /// 删除媒体文件失败
  static String get deleteMediaFileFailed => isZh ? AppZh.deleteMediaFileFailed : AppEn.deleteMediaFileFailed;
  
  /// 已进入文件同步模式，Wi-Fi 热点已开启
  static String get enteredFileSyncModeWifiOn => isZh ? AppZh.enteredFileSyncModeWifiOn : AppEn.enteredFileSyncModeWifiOn;
  
  /// 已退出文件同步模式，Wi-Fi 热点已关闭
  static String get exitedFileSyncModeWifiOff => isZh ? AppZh.exitedFileSyncModeWifiOff : AppEn.exitedFileSyncModeWifiOff;
  
  // ==================== 音频状态文本 / Audio Status Text ====================
  
  /// 停止音频
  static String get stopAudio => isZh ? AppZh.stopAudio : AppEn.stopAudio;
  
  /// DNS流开始
  static String get dnsStreamStart => isZh ? AppZh.dnsStreamStart : AppEn.dnsStreamStart;
  
  /// DNS流暂停
  static String get dnsStreamPause => isZh ? AppZh.dnsStreamPause : AppEn.dnsStreamPause;
  
  /// DNS流停止
  static String get dnsStreamStop => isZh ? AppZh.dnsStreamStop : AppEn.dnsStreamStop;
  
  /// 普通流开始
  static String get normalStreamStart => isZh ? AppZh.normalStreamStart : AppEn.normalStreamStart;
  
  /// 普通流暂停
  static String get normalStreamPause => isZh ? AppZh.normalStreamPause : AppEn.normalStreamPause;
  
  /// 普通流停止
  static String get normalStreamStop => isZh ? AppZh.normalStreamStop : AppEn.normalStreamStop;
  
  /// 未知错误
  static String get unknownError => isZh ? AppZh.unknownError : AppEn.unknownError;
  
  /// 未知
  static String get unknownState => isZh ? AppZh.unknownState : AppEn.unknownState;
  
  /// 加载缓存的设备: {0} ({1})
  static String loadCachedDevice(String name, String mac) => isZh
    ? AppZh.loadCachedDevice(name, mac) : AppEn.loadCachedDevice(name, mac);
  
  // ==================== 版本信息和日志 / Version Info and Logs ====================
  
  /// 获取固件版本超时
  static String get getJlVersionTimeout => isZh ? AppZh.getJlVersionTimeout : AppEn.getJlVersionTimeout;
  
  /// 获取固件版本失败
  static String get getJlVersionFailed => isZh ? AppZh.getJlVersionFailed : AppEn.getJlVersionFailed;
  
  /// 获取影像系统版本超时
  static String get getQzVersionTimeout => isZh ? AppZh.getQzVersionTimeout : AppEn.getQzVersionTimeout;
  
  /// 获取影像系统版本失败
  static String get getQzVersionFailed => isZh ? AppZh.getQzVersionFailed : AppEn.getQzVersionFailed;
  
  /// 获取Git哈希版本超时
  static String get getGithashVersionTimeout => isZh ? AppZh.getGithashVersionTimeout : AppEn.getGithashVersionTimeout;
  
  /// 获取Git哈希版本失败
  static String get getGithashVersionFailed => isZh ? AppZh.getGithashVersionFailed : AppEn.getGithashVersionFailed;
  
  /// 固件版本: {0}
  static String jlVersion(String version) => isZh
    ? AppZh.jlVersion(version) : AppEn.jlVersion(version);
  
  /// 影像系统版本: {0}
  static String qzVersion(String version) => isZh
    ? AppZh.qzVersion(version) : AppEn.qzVersion(version);
  
  /// Git哈希版本: {0}
  static String githashVersion(String version) => isZh
    ? AppZh.githashVersion(version) : AppEn.githashVersion(version);
  
  /// 请先连接设备以获取 MAC 地址
  static String get connectDeviceForMac => isZh ? AppZh.connectDeviceForMac : AppEn.connectDeviceForMac;
  
  /// 正在检查最新版本...
  static String get checkingLatestVersion => isZh ? AppZh.checkingLatestVersion : AppEn.checkingLatestVersion;
  
  /// 检查结果: {0}
  static String checkResult(String result) => isZh
    ? AppZh.checkResult(result) : AppEn.checkResult(result);
  
  /// 检查版本失败
  static String get checkVersionFailed => isZh ? AppZh.checkVersionFailed : AppEn.checkVersionFailed;
  
  /// 固件版本信息缺失
  static String get jlVersionMissing => isZh ? AppZh.jlVersionMissing : AppEn.jlVersionMissing;
  
  /// 影像系统版本信息缺失
  static String get qzVersionMissing => isZh ? AppZh.qzVersionMissing : AppEn.qzVersionMissing;
  
  /// 发现新版本
  static String get updateAvailable => isZh ? AppZh.updateAvailable : AppEn.updateAvailable;
  
  /// 已是最新版本
  static String get alreadyLatest => isZh ? AppZh.alreadyLatest : AppEn.alreadyLatest;
  
  /// 获取语言设置超时
  static String get getLanguageTimeout => isZh ? AppZh.getLanguageTimeout : AppEn.getLanguageTimeout;
  
  /// 获取语言设置失败
  static String get getLanguageFailed => isZh ? AppZh.getLanguageFailed : AppEn.getLanguageFailed;
  
  /// 语音唤醒可能不支持
  static String get voiceWakeupMayNotSupport => isZh ? AppZh.voiceWakeupMayNotSupport : AppEn.voiceWakeupMayNotSupport;
  
  /// 设置语音唤醒失败
  static String get setVoiceWakeupFailed => isZh ? AppZh.setVoiceWakeupFailed : AppEn.setVoiceWakeupFailed;
  
  /// 运行状态: {0}
  static String runningStatus(String status) => isZh
    ? AppZh.runningStatus(status) : AppEn.runningStatus(status);
  
  /// 运行状态可能不支持
  static String get runningStatusMayNotSupport => isZh ? AppZh.runningStatusMayNotSupport : AppEn.runningStatusMayNotSupport;
  
  /// 已进入直播模式（AP模式）
  static String get enteredLiveModeAp => isZh ? AppZh.enteredLiveModeAp : AppEn.enteredLiveModeAp;
  
  /// 正在获取版本信息...
  static String get gettingVersionInfo => isZh ? AppZh.gettingVersionInfo : AppEn.gettingVersionInfo;
  
  /// 已连接到 {0}
  static String connectedTo(String deviceName) => isZh
    ? AppZh.connectedTo(deviceName) : AppEn.connectedTo(deviceName);
  
  /// SDK 10秒超时未返回
  static String get sdkTimeoutMessage => isZh ? AppZh.sdkTimeoutMessage : AppEn.sdkTimeoutMessage;
  
  // ==================== 补充缺少的属性 / Missing Properties ====================
  
  /// 连接状态
  static String get connectionStatus => isZh ? AppZh.showConnectionStatus : AppEn.showConnectionStatus;
  
  /// SDK日志
  static String get sdkLog => isZh ? AppZh.sdkLog ?? 'SDK日志' : AppEn.sdkLog ?? 'SDK Log';
  
  /// 开始音频状态
  static String get startAudioStatus => isZh ? AppZh.startAudio ?? '开始音频' : AppEn.startAudio ?? 'Start Audio';
  
  /// 开始音频控制状态
  static String get startAudioControlState => isZh ? AppZh.startAudioControlState ?? '开始音频控制' : AppEn.startAudioControlState ?? 'Start Audio Control';
  
  /// 实时状态
  static String get realtimeStatus => isZh ? AppZh.realtimeStatus ?? '实时状态' : AppEn.realtimeStatus ?? 'Realtime Status';
}
