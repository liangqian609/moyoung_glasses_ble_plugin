/// 中文字符串定义
/// Chinese String Definitions
class AppZh {
  // ==================== 主要界面 / Main UI ====================
  static const String title = 'MoYoung 智能眼镜';
  static const String bluetoothCheck = '检查蓝牙';
  static const String startScan = '开始扫描';
  static const String stopScan = '停止扫描';
  static const String connectDevice = '连接设备';
  static const String disconnectDevice = '断开连接';
  static const String connected = '已连接';
  static const String disconnected = '未连接';
  static const String batteryLevel = '电池电量';
  static const String charging = '充电中';
  static const String queryBattery = '查询电池';
  static const String takePhoto = '拍照';
  static const String startVideo = '开始录像';
  static const String stopVideo = '停止录像';
  static const String enableWifi = '开启Wi-Fi';
  static const String disableWifi = '关闭Wi-Fi';
  static const String otaUpgrade = 'OTA升级';
  static const String jlOtaUpgrade = '杰里OTA升级';
  static const String cancelJlOta = '取消杰里OTA';
  static const String qzOtaUpgrade = '全志OTA升级';
  static const String setVoiceWakeup = '设置语音唤醒';
  static const String exitVoice = '退出语音';
  static const String chinese = '中文';
  static const String english = 'English';
  
  // ==================== 提示信息 / Toast Messages ====================
  static const String pleaseConnectDevice = '请先连接设备';
  static const String operationSuccess = '操作成功';
  static const String operationFailed = '操作失败';
  static const String connectingDevice = '正在连接设备...';
  static const String connectSuccess = '连接成功';
  static String get connectedDevices => '个已连接设备';
  static String get refresh => '刷新';
  static String connectFailed(String error) => '连接失败: $error';
  static const String disconnectedSuccess = '已断开连接';
  static const String cancellingOta = '正在取消OTA升级...';
  static const String otaCancelled = 'OTA升级已取消';
  static const String cancelOtaFailed = '取消OTA升级失败';
  static const String jlOtaStarted = '杰里OTA升级已启动';
  static const String jlOtaStartFailed = '杰里OTA升级启动失败';
  static const String qzOtaNotImplemented = '全志OTA功能暂未实现';
  
  // ==================== 功能模块 / Feature Modules ====================
  static const String basicFunctions = '基础功能';
  static const String glassesFunctions = '眼镜功能';
  static const String audioFunctions = '音频功能';
  static const String fileManagement = '文件管理';
  static const String recordFunctions = '录音功能';
  static const String userInfo = '用户信息';
  static const String liveFunctions = '直播功能';
  static const String deviceManagement = '设备管理';
  static const String otaFunctions = 'OTA升级功能';
  static const String todoFunctions = '待实现功能';
  
  // ==================== 其他常用字符串 / Other Common Strings ====================
  static const String scanDevice = '扫描设备';
  static const String scanAndConnect = '扫描并连接智能眼镜';
  static const String requestPermission = '申请权限';
  static const String disconnect = '断开设备';
  static const String syncTime = '同步时间';
  static const String queryVersion = '查询版本';
  static const String restartDevice = '重启设备';
  static const String shutdownDevice = '关闭设备';
  static const String factoryReset = '恢复出厂设置';
  static const String checkFirmwareUpdate = '检查固件更新';
  static const String selectFirmware = '选择固件文件进行升级';
  static const String onlyJlCancellable = '仅杰里芯片可取消';
  static const String wifiOtaNote = '通过WiFi升级固件（不可取消）';
  static const String selectFirmwareFile = '请选择固件文件...';
  
  // ==================== 状态文本 / Status Text ====================
  static const String requestPermissionStatus = '申请权限';
  static const String disconnectedStatus = '未连接';
  static const String unknownStatus = '未知';
  static const String waitingToReceive = '等待接收...';
  static const String noAudioData = '无音频数据';
  static const String noAiImageData = '无AI识别图片数据';
  static const String noTranslationAudio = '无翻译音频数据';
  static const String noPcmAudio = '无PCM音频数据';
  static const String clickToGet = '点击获取';
  static const String waitingOtaStatus = '等待OTA状态';
  static const String waitingActionResult = '等待操作结果';
  static const String waitingSdkLog = '等待SDK日志';
  static const String notSet = '未设置';
  static const String getting = '获取中...';
  static const String notSupportedOrError = '不支持或错误';
  
  // ==================== 功能子标题 / Feature Subtitles ====================
  static const String showConnectionStatus = '显示当前设备连接状态';
  static const String deviceControl = '设备控制';
  static const String wearCheck = '佩戴检查';
  static const String queryWearCheckState = '查询佩戴检查状态';
  static const String setWearCheckState = '设置佩戴检查状态';
  static const String setWearCheckDesc = '开启或关闭眼镜佩戴检测功能';
  static const String enableWearCheck = '启用佩戴检查';
  static const String wearCheckDialogDesc = '开启后，眼镜会检测是否被佩戴';
  static String wearCheckStateToast(String state) => '佩戴检查状态: $state';
  static const String queryWearCheckFailed = '查询佩戴检查状态失败';
  static const String setWearCheckSuccess = '设置佩戴检查状态成功';
  static const String setWearCheckFailed = '设置佩戴检查状态失败';
  static const String cancel = '取消';
  static const String confirm = '确认';
  static const String send = '发送';
  static const String syncDeviceTime = '同步设备时间';
  static const String setGlassesLanguage = '设置眼镜语言';
  static const String restartGlasses = '重启智能眼镜';
  static const String factoryResetGlasses = '恢复出厂设置';
  static const String shutdownGlasses = '关闭智能眼镜';
  static const String glassesFeatures = '眼镜功能';
  static const String controlPhoto = '控制眼镜拍照';
  static const String startVideoFunction = '开始录像功能';
  static const String stopVideoFunction = '停止录像功能';
  static const String audioControlFunction = '音频控制功能';
  static const String aiConversationListen = 'AI对话监听';
  static const String aiConversationStatus = 'AI对话状态';
  static const String aiStatusNotStarted = '未开始';
  static const String aiStatusStarted = '开始';
  static const String aiStatusEnded = '结束';
  static const String aiFunctions = 'AI功能';
  static const String exitVoiceReply = '主动退出语音回复状态';
  static const String wifiFileSync = 'Wi-Fi功能（文件同步）';
  static const String enableFileTransfer = '开启文件传输服务';
  static const String disableFileTransfer = '关闭文件传输服务';
  static const String getDefaultVideoParams = '获取录像默认参数';
  static const String recordFunction = '录音功能';
  static const String setRecordControl = '设置录音控制状态';
  static const String stopRecordControl = '停止录音控制';
  static const String userInfoSettings = '用户信息和设置';
  static const String setUserInfo = '设置用户基本信息';
  static const String liveFunction = '直播功能';
  static const String enterLiveMode = '进入直播模式';
  static const String exitLiveMode = '退出直播模式';
  static const String enterFileSyncMode = '进入文件同步模式';
  static const String exitFileSyncMode = '退出文件同步模式';
  static const String mediaFileManagement = '媒体文件管理';
  static const String openFileManager = '打开文件管理';
  static const String manageDownloadFiles = '管理和下载文件';
  static const String wifiStatus = 'Wi-Fi状态';
  static const String fileStatistics = '文件统计';
  static const String totalFiles = '总文件数';
  static const String selectedFiles = '已选择';
  static const String downloadedFiles = '已下载';
  static const String downloadProgress = '下载进度';
  static const String noFiles = '暂无文件';
  static const String selectAll = '全选';
  static const String batchDownload = '批量下载';
  static const String batchDelete = '批量删除';
  static const String baseUrl = '基础URL';
  static const String downloadLocation = '下载位置';
  static const String downloading = '下载中';
  static const String wifiEnabled = 'Wi-Fi已开启';
  static const String wifiDisabled = 'Wi-Fi已关闭';
  static const String enableWifiFailed = '开启Wi-Fi失败';
  static const String disableWifiFailed = '关闭Wi-Fi失败';
  static const String getFileListFailed = '获取文件列表失败';
  static const String deleteSuccess = '删除成功';
  static const String deleteFailed = '删除失败';
  static const String batchDeleteSuccess = '批量删除成功';
  static const String batchDeleteFailed = '批量删除失败';
  static const String pathCopied = '路径已复制到剪贴板';
  static const String openFolderFeatureComingSoon = '打开文件夹功能即将上线';
  static const String confirmDelete = '确认删除';
  static const String confirmBatchDelete = '确认批量删除';
  static const String confirmDeleteFile = '确认删除文件';
  static const String confirmDeleteFiles = '确认删除文件';
  static const String files = '个文件';
  static const String delete = '删除';
  static const String batchDownloadComplete = '批量下载完成';
  static const String filesDownloadedTo = '文件已下载到：';
  static const String totalFilesDownloaded = '共下载文件';
  static const String openFolder = '打开文件夹';
  
  // ==================== 动态消息 / Dynamic Messages ====================
  static String receivedFileBaseUrl(String url) => '收到文件BaseUrl: $url';
  static String receivedAudioData(int frame, int size) => '收到音频数据: 大小${size}字节';
  static String errorMessage(String code, String message) => '错误: $code - $message';
  static String batteryDisplay(String level, bool charging) => '电量: $level${charging ? ' (充电中)' : ''}';
  
  // ==================== 更多状态文本 / More Status Text ====================
  static const String audioIdle = '音频空闲';
  static const String recording = '录音中';
  static const String audioPaused = '音频暂停';
  static const String unknownAudioStatus = '未知音频状态';
  
  static String receivedImageData(int bytes) => '收到图片数据: ${bytes}字节';
  static String receivingImageData(int bytes) => '接收图片数据中: ${bytes}字节';
  static const String otaUpgradeStatus = 'OTA升级状态';
  static String logMessage(String log) => '日志: $log';
  
  static const String connectedStatus = '已连接';
  static const String connectingStatus = '连接中';
  static const String disconnectedDone = '已断开';
  static const String disconnecting = '断开中';
  static const String unknownConnectionState = '未知状态';
  static const String bluetoothResetting = '蓝牙重置中';
  static const String bluetoothUnavailable = '蓝牙不可用';
  static const String bluetoothUnauthorized = '蓝牙未授权';
  static const String bluetoothAvailable = '蓝牙可用';
  static const String bluetoothLimiting = '蓝牙受限';
  static const String bluetoothTurningOn = '蓝牙开启中';
  static const String bluetoothOn = '蓝牙已开启';
  static const String bluetoothTurningOff = '蓝牙关闭中';
  static const String bluetoothOff = '蓝牙已关闭';
  static const String pressAgainToExit = '再按一次退出app';
  static const String bluetoothStatus = '蓝牙状态';
  static const String showConnectionStatusTitle = '显示连接状态';
  
  // 扫描页面相关
  static const String smartGlassesTest = '智能眼镜测试';
  static const String pleaseEnableBluetooth = '请先开启蓝牙';
  static const String scanning = '正在扫描';
  static const String scanningWithCount = '正在扫描... ({0} 个设备)';
  static const String devicesFound = '已发现 {0} 个设备';
  static const String searchingForDevices = '正在搜索设备...';
  static const String clickToScan = '点击扫描按钮搜索设备';
  static const String stop = '停止';
  static const String scan = '扫描';
  static const String connectingToDevice = '正在连接 {0}';
  static const String connectionFailed = '连接失败: {0}';
  static const String scanFailed = '扫描失败: {0}';
  static const String unknownDevice = '未知设备';
  static const String connect = '连接';
  static const String signalStrength = '信号强度';
  static const String jieLi = '杰理';
  static const String quanZhi = '全志';
  static const String unknown = '未知';
  static const String disconnectAndRemove = '断开并移除设备';
  static const String removeAndDisconnect = '移除断开连接';
  static const String reconnectDevice = '重新连接设备';
  static const String reconnectLastDevice = '重新连接上次设备';
  static const String reconnecting = '重新连接中...';
  static const String reconnectCommandSent = '重新连接命令已发送';
  static const String reconnectFailed = '重新连接失败';
  static const String sendLanguageSettings = '发送语言设置';
  
  // ==================== Toast 消息 / Toast Messages ====================
  static String lowBatteryWarning(String battery) => '电量过低（$battery），无法进入文件同步模式\n请先充电至 20% 以上';
  static const String enteredFileSyncMode = '已进入文件同步模式（Wi-Fi 已开启）';
  static const String enterFileSyncModeFailed = '进入文件同步模式失败';
  static const String exitedFileSyncMode = '已退出文件同步模式（Wi-Fi 已关闭）';
  static const String exitFileSyncModeFailed = '退出文件同步模式失败';
  static const String photoCommandSent = '拍照指令已发送';
  static const String photoFailed = '拍照失败';
  static const String photoMode = '拍照模式';
  static const String normalPhoto = '普通拍照';
  static const String aiRecognitionPhoto = 'AI识别拍照';
  static const String continuousPhoto = '连拍';
  static const String simultaneousInterpretation = '同声传译';
  static const String simultaneousInterpretationStatus = '同声传译状态';
  static const String startSimultaneousInterpretation = '开始同声传译';
  static const String pauseSimultaneousInterpretation = '暂停同声传译';
  static const String stopSimultaneousInterpretation = '停止同声传译';
  static const String simultaneousInterpretationNotStarted = '未开始';
  static const String simultaneousInterpretationStarted = '进行中';
  static const String simultaneousInterpretationPaused = '已暂停';
  static const String simultaneousInterpretationStopped = '已停止';
  static const String commandSent = '指令已发送';
  static const String failed = '失败';
  static const String videoStartSuccess = '录像开始成功';
  static const String videoStartFailed = '开始录像失败';
  static const String videoStopCommandSent = '录像停止指令已发送';
  static const String videoStopFailed = '停止录像失败';
  static const String deviceRestartSuccess = '设备重启成功';
  static const String deviceRestartFailed = '设备重启失败';
  static String batteryLevelToast(String level, bool charging) => '电池电量: $level${charging ? '，充电中' : ''}';
  static const String batteryQueryFailed = '电池查询失败';
  
  // ==================== 更多功能按钮 / More Function Buttons ====================
  static const String getRecordStatus = '获取录音状态';
  static const String getDeviceLanguage = '获取设备语言';
  static const String getDeviceUUID = '获取设备UUID';
  static const String getVoiceWakeupStatus = '获取语音唤醒状态';
  static const String getRunningStatus = '获取运行状态';
  static const String getOtaStatus = '获取OTA状态';
  static const String getActionResult = '获取操作结果';
  static const String getSdkLog = '获取SDK日志';
  static const String otaUpgradeFunction = 'OTA升级功能';
  static const String currentVersionInfo = '当前版本信息';
  static const String versionInfo = '版本信息';
  static const String queryDeviceVersion = '查询设备版本';
  static const String queryJLVersion = '查询固件版本';
  static const String queryAllwinnerVersion = '查询影像系统版本';
  static const String queryTPVersion = '查询TP版本';
  static const String queryGitHashVersion = '查询Git哈希版本';
  static const String fileManagementFunction = '文件管理功能';
  static const String deviceManagementFunction = '设备管理功能';
  
  // ==================== 状态标签 / Status Labels ====================
  static const String audioDataStatus = '音频数据状态';
  static const String stopAudioStatus = '停止音频状态';
  static const String audioControlStatus = '音频控制状态';
  static const String aiImageDataStatus = 'AI识别图片数据';
  static const String translationAudioData = '翻译音频数据';
  static const String setVideoDefaultParams = '设置录像默认参数';
  static const String pcmAudioStatus = 'PCM音频数据';
  
  // ==================== 更多Toast消息 / More Toast Messages ====================
  static const String getRecordStatusFailed = '获取录音状态失败';
  static const String getDeviceUuidTimeout = '获取设备UUID超时';
  static const String getDeviceUuidFailed = '获取设备UUID失败';
  
  // ==================== 子标题和描述 / Subtitles and Descriptions ====================
  static const String stopAudioControlState = '停止音频控制状态';
  static const String exitVoiceReplyState = '主动退出语音回复状态';
  static const String getVideoDefaultParams = '获取录像默认参数';
  static const String checkForNewVersion = '检查是否有新版本';
  static const String queryFileCount = '查询设备中的文件数量';
  static const String queryFileSyncMethod = '查询当前文件同步方式';
  static const String deleteMediaFile = '删除指定的媒体文件';
  static const String clearPairInfo = '清除设备配对信息';
  
  // ==================== 更多状态文本 / More Status Text ====================
  static const String gettingStatus = '获取中...';
  static const String notSupportedOrErrorStatus = '不支持或错误';
  static const String deviceNotSupported = '设备不支持此功能';
  static const String getFailed = '获取失败';
  static const String sdkNotReturned = 'SDK未返回';
  
  static String deviceUuid(String uuid) => '设备UUID: $uuid';
  
  static const String startAiReply = '开始AI回复';
  static const String completeAiReply = '完成AI回复';
  static const String interruptAiReply = '中断AI回复';
  
  // ==================== 初始状态文本 / Initial Status Text ====================
  
  // ==================== 下拉选项文本 / Dropdown Options ====================
  static const String frameRate = '帧率 (fps)';
  static const String maxDuration = '最大时长';
  static const String wifiOperationResult = 'WiFi操作结果';
  static const String codeZeroSuccess = '(code=0成功)';
  
  // ==================== 音频控制选项 / Audio Control Options ====================
  static const String startAudio = '1. 开始音频';
  static const String cancelAudio = '2. 取消音频';
  static const String startDnsStream = '3. 开始DNS流';
  static const String pauseDnsStream = '4. 暂停DNS流';
  static const String stopDnsStream = '5. 停止DNS流';
  static const String startNormalStream = '6. 开始普通流';
  static const String pauseNormalStream = '7. 暂停普通流';
  static const String stopNormalStream = '8. 停止普通流';
  
  // ==================== 更多按钮文本 / More Button Text ====================
  static const String checkLatestVersion = '检查最新版本';
  static const String fileBaseUrl = '文件BaseUrl';
  static const String sdkLatestLog = 'SDK最新日志';
  static const String operationType = '操作类型';
  static const String deviceRunningStatus = '设备运行状态';
  static const String clickToQueryOrAutoUpdate = '点击查询或监听自动更新';
  static const String deviceStatus = '设备状态';
  static const String connectionState = '连接状态';
  static const String deviceVersion = '设备版本';
  static const String firmwareVersion = '固件版本';
  
  // ==================== 更多选项 / More Options ====================
  static const String seconds30 = '30 秒';
  static const String seconds60 = '60 秒';
  static const String seconds120 = '120 秒';
  static const String seconds300 = '300 秒';
  static const String applySettings = '应用设置';
  static const String enableVoiceWakeupTypeOn = '开启语音唤醒 (TypeOn)';
  static const String disableVoiceWakeupTypeOff = '关闭语音唤醒 (TypeOff)';
  static const String enableVoiceWakeup = '开启语音唤醒';
  static const String disableVoiceWakeup = '关闭语音唤醒';
  
  // ==================== 帧率选项 / Frame Rate Options ====================
  static const String fps15 = '15 fps';
  static const String fps24 = '24 fps';
  static const String fps30 = '30 fps';
  static const String fps60 = '60 fps';
  static const String connectedDevice = '已连接设备';
  static const String locationPermissionDenied = '位置权限被拒绝';
  static const String storagePermissionDenied = '存储权限被拒绝';
  static const String permissionGranted = '权限已授予';
  static const String bluetoothEnabled = '蓝牙已开启';
  static const String bluetoothDisabled = '蓝牙已关闭';
  static const String checkFailed = '检查失败';
  static const String deviceConnected = '设备已连接';
  static const String deviceNotConnected = '设备未连接';
  static const String deviceRemovedAndDisconnected = '设备已移除并断开连接';
  static const String disconnectFailed = '断开连接失败';
  static const String removeDeviceFailed = '移除设备失败';
  static const String timeSyncSuccess = '时间同步成功';
  static const String timeSyncFailed = '时间同步失败';
  static const String versionQuerySuccess = '版本查询成功';
  static const String versionQueryFailed = '版本查询失败';
  static const String languageSettingsSent = '语言设置已发送';
  static const String deviceResetSuccess = '设备重置成功';
  static const String deviceResetFailed = '设备重置失败';
  static const String deviceShutdownSuccess = '设备关闭成功';
  static const String deviceShutdownFailed = '设备关闭失败';
  static const String audioStopped = '音频已停止';
  static const String inIntercom = '对讲中';
  static const String notIntercom = '未对讲';
  static const String exitedVoice = '已退出语音';
  static const String httpGetMode = 'HTTP GET 模式';
  static const String otherMode = '其他模式';
  static const String deleteFileSuccess = '删除文件成功';
  static const String deleteFileFailed = '删除文件失败';
  static const String recordingStarted = '录音已开始';
  static const String startRecordingFailed = '开始录音失败';
  static const String recordingStopped = '录音已停止';
  static const String stopRecordingFailed = '停止录音失败';
  static const String notRecording = '未录音';
  static const String userInfoSetSuccess = '用户信息设置成功';
  static const String userInfoSetFailed = '用户信息设置失败';
  static const String alarmSetFailed = '闹钟设置失败';
  static const String startRecordingFailed2 = '开始录音失败';
  static const String stopRecordingFailed2 = '停止录音失败';
  static const String undefinedCommand = '未定义的指令';
  static const String deviceNotSupportedFeature = '设备不支持此功能';
  static const String enterLiveModeFailed = '进入直播模式失败';
  static const String exitedLiveMode = '已退出直播模式';
  static const String exitLiveModeFailed = '退出直播模式失败';
  static const String clearedPairInfo = '已清除配对信息';
  static const String clearPairInfoFailed = '清除配对信息失败';
  static const String enabled = '已开启';
  static const String disabled = '已关闭';
  
  static String voiceWakeupSet(String status) => '语音唤醒已$status';
  static String voiceWakeupStatus(String status) => '语音唤醒状态: $status';
  static const String deviceNotSupportedFeature2 = '设备不支持此功能';
  static const String enterLiveModeFailed2 = '进入直播模式失败';
  static const String exitLiveModeFailed2 = '退出直播模式失败';
  static const String clearPairInfoFailed2 = '清除配对信息失败';
  static const String gettingStatusWithDots = '获取中...';
  static const String seconds = '秒';
  static const String duration = '时长';
  static const String getVideoParamsFailed = '获取录像参数失败';
  static String videoParamsSet(String fpsText, int duration) => '录像参数已设置: $fpsText, 最大$duration秒';
  static const String setVideoParamsFailed = '设置录像参数失败';
  static const String sendLanguageSettingsFailed = '发送语言设置失败';
  static const String deviceShutdownFailed2 = '设备关闭失败';
  static const String setAudioControlFailed = '设置音频控制失败';
  static const String stopAudioFailed = '停止音频失败';
  static const String queryAudioStateFailed = '查询音频状态失败';
  static const String setAiReplyStatusFailed = '设置 AI 回复状态失败';
  static const String setSimultaneousInterpretationFailed = '设置同声传译失败';
  static const String exitVoiceFailed = '退出语音失败';
  static const String queryFileCountFailed = '查询文件数量失败';
  static const String queryFileSyncMethodFailed = '查询文件同步方式失败';
  static const String deleteMediaFileFailed = '删除媒体文件失败';
  static const String enteredFileSyncModeWifiOn = '已进入文件同步模式，Wi-Fi 热点已开启';
  static const String exitedFileSyncModeWifiOff = '已退出文件同步模式，Wi-Fi 热点已关闭';
  static String videoParams(String configStr) => '录像参数: $configStr';
  static String recordingStatus(String stateText, int totalTime) => '录音状态: $stateText, 时长: ${totalTime}秒';
  static const String queryRecordStatusTimeout = '查询录音状态超时';
  static String audioControlSet(String actionText) => '音频控制已设置: $actionText';
  static String audioStatus(String stateText) => '音频状态: $stateText';
  static String aiReplyStatusSet(String statusText) => 'AI回复状态已设置: $statusText';
  static String simultaneousInterpretationStatusSet(String action) => '同声传译状态已设置: $action';
  static String deviceFileCount(int count) => '设备中共有 $count 个文件';
  static String currentFileSyncMethod(String typeStr) => '当前文件同步方式: $typeStr';
  static const String setUserInfoFailed = '设置用户信息失败';
  static const String alarmSetSuccess = '闹钟设置成功（7:30）';
  static const String setAlarmFailed = '设置闹钟失败';
  static String currentLanguage(String language) => '当前语言: $language';
  static String videoConfigParams(int frameRate, int maxDuration) => '帧率: ${frameRate}fps, 最大时长: ${maxDuration}秒';
  
  // ==================== 音频状态文本 / Audio Status Text ====================
  static const String stopAudio = '停止音频';
  static const String dnsStreamStart = 'DNS流开始';
  static const String dnsStreamPause = 'DNS流暂停';
  static const String dnsStreamStop = 'DNS流停止';
  static const String normalStreamStart = '普通流开始';
  static const String normalStreamPause = '普通流暂停';
  static const String normalStreamStop = '普通流停止';
  static const String unknownError = '未知错误';
  static const String unknownState = '未知';
  static String loadCachedDevice(String name, String mac) => '加载缓存的设备: $name ($mac)';
  
  // ==================== 版本信息和日志 / Version Info and Logs ====================
  static const String getJlVersionTimeout = '获取固件版本超时';
  static const String getJlVersionFailed = '获取固件版本失败';
  static const String getQzVersionTimeout = '获取影像系统版本超时';
  static const String getQzVersionFailed = '获取影像系统版本失败';
  static const String getGithashVersionTimeout = '获取Git哈希版本超时';
  static const String getGithashVersionFailed = '获取Git哈希版本失败';
  static String jlVersion(String version) => '固件版本: $version';
  static String qzVersion(String version) => '影像系统版本: $version';
  static String githashVersion(String version) => 'Git哈希版本: $version';
  static const String connectDeviceForMac = '请先连接设备以获取 MAC 地址';
  static const String checkingLatestVersion = '正在检查最新版本...';
  static String checkResult(String result) => '检查结果: $result';
  static const String checkVersionFailed = '检查版本失败';
  static const String jlVersionMissing = '固件版本信息缺失，请先获取版本信息';
  static const String qzVersionMissing = '影像系统版本信息缺失，请先获取版本信息';
  static const String updateAvailable = '发现新版本';
  static const String alreadyLatest = '已是最新版本';
  static const String getLanguageTimeout = '获取语言设置超时';
  static const String getLanguageFailed = '获取语言设置失败';
  static const String voiceWakeupMayNotSupport = '语音唤醒可能不支持';
  static const String setVoiceWakeupFailed = '设置语音唤醒失败';
  static String runningStatus(String status) => '运行状态: $status';
  static const String runningStatusMayNotSupport = '运行状态可能不支持';
  static const String enteredLiveModeAp = '已进入直播模式（AP模式）';
  static const String gettingVersionInfo = '正在获取版本信息...';
  static String connectedTo(String deviceName) => '已连接到 $deviceName';
  static const String sdkTimeoutMessage = 'SDK 10秒超时未返回';
  
  // ==================== 补充缺少的字符串 / Missing Strings ====================
  
  static const String sdkLog = 'SDK日志';
  static const String startAudioControlState = '开始音频控制';
  static const String realtimeStatus = '实时状态';
}
