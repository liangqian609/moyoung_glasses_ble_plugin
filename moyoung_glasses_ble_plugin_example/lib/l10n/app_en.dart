/// English String Definitions
class AppEn {
  // ==================== Main UI ====================
  static const String title = 'MoYoung Smart Glasses';
  static const String bluetoothCheck = 'Check Bluetooth';
  static const String startScan = 'Start Scan';
  static const String stopScan = 'Stop Scan';
  static const String connectDevice = 'Connect Device';
  static const String disconnectDevice = 'Disconnect';
  static String get connected => 'Connected';
  static String get connectedDevices => ' connected devices';
  static String get refresh => 'Refresh';
  static const String disconnected = 'Disconnected';
  static const String batteryLevel = 'Battery Level';
  static const String charging = 'Charging';
  static const String queryBattery = 'Query Battery';
  static const String takePhoto = 'Take Photo';
  static const String startVideo = 'Start Video';
  static const String stopVideo = 'Stop Video';
  static const String enableWifi = 'Enable Wi-Fi';
  static const String disableWifi = 'Disable Wi-Fi';
  static const String otaUpgrade = 'OTA Upgrade';
  static const String jlOtaUpgrade = 'JL OTA Upgrade';
  static const String cancelJlOta = 'Cancel JL OTA';
  static const String qzOtaUpgrade = 'QZ OTA Upgrade';
  static const String setVoiceWakeup = 'Set Voice Wakeup';
  static const String exitVoice = 'Exit Voice';
  static const String chinese = '中文';
  static const String english = 'English';
  
  // ==================== Toast Messages ====================
  static const String pleaseConnectDevice = 'Please connect device first';
  static const String operationSuccess = 'Operation successful';
  static const String operationFailed = 'Operation failed';
  static const String connectingDevice = 'Connecting device...';
  static const String connectSuccess = 'Connected successfully';
  static String connectFailed(String error) => 'Connection failed: $error';
  static const String disconnectedSuccess = 'Disconnected successfully';
  static const String cancellingOta = 'Cancelling OTA upgrade...';
  static const String otaCancelled = 'OTA upgrade cancelled';
  static const String cancelOtaFailed = 'Failed to cancel OTA upgrade';
  static const String jlOtaStarted = 'JL OTA upgrade started';
  static const String jlOtaStartFailed = 'Failed to start JL OTA upgrade';
  static const String qzOtaNotImplemented = 'QZ OTA function not yet implemented';
  
  // ==================== Feature Modules ====================
  static const String basicFunctions = 'Basic Functions';
  static const String glassesFunctions = 'Glasses Functions';
  static const String audioFunctions = 'Audio Functions';
  static const String fileManagement = 'File Management';
  static const String recordFunctions = 'Record Functions';
  static const String userInfo = 'User Info';
  static const String liveFunctions = 'Live Functions';
  static const String deviceManagement = 'Device Management';
  static const String otaFunctions = 'OTA Upgrade Functions';
  static const String todoFunctions = 'TODO Functions';
  
  // ==================== Other Common Strings ====================
  static const String scanDevice = 'Scan Device';
  static const String scanAndConnect = 'Scan and connect smart glasses';
  static const String requestPermission = 'Request Permission';
  static const String disconnect = 'Disconnect Device';
  static const String syncTime = 'Sync Time';
  static const String queryVersion = 'Query Version';
  static const String restartDevice = 'Restart Device';
  static const String shutdownDevice = 'Shutdown Device';
  static const String factoryReset = 'Factory Reset';
  static const String checkFirmwareUpdate = 'Check Firmware Update';
  static const String selectFirmware = 'Select firmware file for upgrade';
  static const String onlyJlCancellable = 'Only JL chip can be cancelled';
  static const String wifiOtaNote = 'Upgrade firmware via WiFi (cannot be cancelled)';
  static const String selectFirmwareFile = 'Please select firmware file...';
  
  // ==================== Status Text ====================
  static const String requestPermissionStatus = 'Request Permission';
  static const String disconnectedStatus = 'Disconnected';
  static const String unknownStatus = 'Unknown';
  static const String waitingToReceive = 'Waiting to receive...';
  static const String noAudioData = 'No audio data';
  static const String noAiImageData = 'No AI recognition image data';
  static const String noTranslationAudio = 'No translation audio data';
  static const String noPcmAudio = 'No PCM audio data';
  static const String clickToGet = 'Click to get';
  static const String waitingOtaStatus = 'Waiting for OTA status';
  static const String waitingActionResult = 'Waiting for action result';
  static const String waitingSdkLog = 'Waiting for SDK log';
  static const String notSet = 'Not set';
  static const String getting = 'Getting...';
  static const String notSupportedOrError = 'Not supported or error';
  
  // ==================== Feature Subtitles ====================
  static const String showConnectionStatus = 'Show current device connection status';
  static const String deviceControl = 'Device Control';
  static const String wearCheck = 'Wear Check';
  static const String queryWearCheckState = 'Query Wear Check State';
  static const String setWearCheckState = 'Set Wear Check State';
  static const String setWearCheckDesc = 'Enable or disable glasses wear detection';
  static const String enableWearCheck = 'Enable Wear Check';
  static const String wearCheckDialogDesc = 'When enabled, glasses will detect if they are being worn';
  static String wearCheckStateToast(String state) => 'Wear check state: $state';
  static const String queryWearCheckFailed = 'Failed to query wear check state';
  static const String setWearCheckSuccess = 'Set wear check state successfully';
  static const String setWearCheckFailed = 'Failed to set wear check state';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String send = 'Send';
  static const String syncDeviceTime = 'Sync device time';
  static const String setGlassesLanguage = 'Set glasses language';
  static const String restartGlasses = 'Restart smart glasses';
  static const String factoryResetGlasses = 'Factory reset smart glasses';
  static const String shutdownGlasses = 'Shutdown smart glasses';
  static const String glassesFeatures = 'Glasses Features';
  static const String controlPhoto = 'Control glasses photo';
  static const String startVideoFunction = 'Start video recording function';
  static const String stopVideoFunction = 'Stop video recording function';
  static const String audioControlFunction = 'Audio Control Function';
  static const String aiConversationListen = 'AI Conversation Listen';
  static const String aiConversationStatus = 'AI Conversation Status';
  static const String aiStatusNotStarted = 'Not Started';
  static const String aiStatusStarted = 'Started';
  static const String aiStatusEnded = 'Ended';
  static const String getRunningStatus = 'Get Running Status';
  static const String aiFunctions = 'AI Functions';
  static String exitVoiceReply = 'Actively exit voice reply status';
  static const String wifiFileSync = 'Wi-Fi Functions (File Sync)';
  static const String enableFileTransfer = 'Enable file transfer service';
  static const String disableFileTransfer = 'Disable file transfer service';
  static const String getDefaultVideoParams = 'Get default video parameters';
  static const String recordFunction = 'Record Function';
  static const String setRecordControl = 'Set record control status';
  static const String stopRecordControl = 'Stop record control';
  static const String userInfoSettings = 'User Info and Settings';
  static const String setUserInfo = 'Set user basic information';
  static const String liveFunction = 'Live Function';
  static const String enterLiveMode = 'Enter live mode';
  static const String exitLiveMode = 'Exit live mode';
  static const String enterFileSyncMode = 'Enter file sync mode';
  static const String exitFileSyncMode = 'Exit file sync mode';
  static const String mediaFileManagement = 'Media File Management';
  static const String openFileManager = 'Open File Manager';
  static const String manageDownloadFiles = 'Manage and download files';
  static const String wifiStatus = 'Wi-Fi Status';
  static const String fileStatistics = 'File Statistics';
  static const String totalFiles = 'Total Files';
  static const String selectedFiles = 'Selected';
  static const String downloadedFiles = 'Downloaded';
  static const String downloadProgress = 'Download Progress';
  static const String noFiles = 'No Files';
  static const String selectAll = 'Select All';
  static const String batchDownload = 'Batch Download';
  static const String batchDelete = 'Batch Delete';
  static const String baseUrl = 'Base URL';
  static const String downloadLocation = 'Download Location';
  static const String downloading = 'Downloading';
  static const String wifiEnabled = 'Wi-Fi Enabled';
  static const String wifiDisabled = 'Wi-Fi Disabled';
  static const String enableWifiFailed = 'Failed to enable Wi-Fi';
  static const String disableWifiFailed = 'Failed to disable Wi-Fi';
  static const String getFileListFailed = 'Failed to get file list';
  static const String deleteSuccess = 'Delete successful';
  static const String deleteFailed = 'Delete failed';
  static const String batchDeleteSuccess = 'Batch delete successful';
  static const String batchDeleteFailed = 'Batch delete failed';
  static const String pathCopied = 'Path copied to clipboard';
  static const String openFolderFeatureComingSoon = 'Open folder feature coming soon';
  static const String confirmDelete = 'Confirm Delete';
  static const String confirmBatchDelete = 'Confirm Batch Delete';
  static const String confirmDeleteFile = 'Confirm delete file';
  static const String confirmDeleteFiles = 'Confirm delete files';
  static const String files = ' files';
  static const String delete = 'Delete';
  static const String batchDownloadComplete = 'Batch download complete';
  static const String filesDownloadedTo = 'Files downloaded to:';
  static const String totalFilesDownloaded = 'Total files downloaded';
  static const String openFolder = 'Open Folder';
  
  // ==================== Dynamic Messages ====================
  static String receivedFileBaseUrl(String url) => 'Received file BaseUrl: $url';
  static String receivedAudioData(int frame, int size) => 'Received audio data: size ${size} bytes';
  static String errorMessage(String code, String message) => 'Error: $code - $message';
  static String batteryDisplay(String level, bool charging) => 'Battery: $level${charging ? ' (charging)' : ''}';
  
  // ==================== More Status Text ====================
  static const String audioIdle = 'Audio idle';
  static const String recording = 'Recording';
  static const String audioPaused = 'Audio paused';
  static const String unknownAudioStatus = 'Unknown audio status';
  
  static String receivedImageData(int bytes) => 'Received image data: ${bytes} bytes';
  static String receivingImageData(int bytes) => 'Receiving image data: ${bytes} bytes';
  static const String otaUpgradeStatus = 'OTA Upgrade Status';
  static String logMessage(String log) => 'Log: $log';
  
  static const String connectedStatus = 'Connected';
  static const String connectingStatus = 'Connecting';
  static const String disconnectedDone = 'Disconnected';
  static const String disconnecting = 'Disconnecting';
  static const String unknownConnectionState = 'Unknown state';
  static const String bluetoothResetting = 'Bluetooth resetting';
  static const String bluetoothUnavailable = 'Bluetooth unavailable';
  static const String bluetoothUnauthorized = 'Bluetooth unauthorized';
  static const String bluetoothAvailable = 'Bluetooth available';
  static const String bluetoothLimiting = 'Bluetooth limiting';
  static const String bluetoothTurningOn = 'Bluetooth turning on';
  static const String bluetoothOn = 'Bluetooth on';
  static const String bluetoothTurningOff = 'Bluetooth turning off';
  static const String bluetoothOff = 'Bluetooth off';
  static const String pressAgainToExit = 'Press again to exit app';
  static const String bluetoothStatus = 'Bluetooth Status';
  static const String showConnectionStatusTitle = 'Show Connection Status';
  
  // Scan page related
  static const String smartGlassesTest = 'Smart Glasses Test';
  static const String pleaseEnableBluetooth = 'Please enable Bluetooth first';
  static const String scanning = 'Scanning';
  static const String scanningWithCount = 'Scanning... ({0} devices)';
  static const String devicesFound = 'Found {0} devices';
  static const String searchingForDevices = 'Searching for devices...';
  static const String clickToScan = 'Click scan button to search devices';
  static const String stop = 'Stop';
  static const String scan = 'Scan';
  static const String connectingToDevice = 'Connecting to {0}';
  static const String connectionFailed = 'Connection failed: {0}';
  static const String scanFailed = 'Scan failed: {0}';
  static const String unknownDevice = 'Unknown Device';
  static const String connect = 'Connect';
  static const String signalStrength = 'Signal Strength';
  static const String jieLi = 'JieLi';
  static const String quanZhi = 'QuanZhi';
  static const String unknown = 'Unknown';
  static const String disconnectAndRemove = 'Disconnect and Remove Device';
  static const String removeAndDisconnect = 'Remove and Disconnect';
  static const String reconnectDevice = 'Reconnect Device';
  static const String reconnectLastDevice = 'Reconnect to last device';
  static const String reconnecting = 'Reconnecting...';
  static const String reconnectCommandSent = 'Reconnect command sent';
  static const String reconnectFailed = 'Reconnect failed';
  static const String sendLanguageSettings = 'Send Language Settings';
  
  // ==================== Toast Messages ====================
  static String lowBatteryWarning(String battery) => 'Battery too low ($battery), cannot enter file sync mode\nPlease charge to above 20% first';
  static const String enteredFileSyncMode = 'Entered file sync mode (Wi-Fi enabled)';
  static const String enterFileSyncModeFailed = 'Failed to enter file sync mode';
  static const String exitedFileSyncMode = 'Exited file sync mode (Wi-Fi disabled)';
  static const String exitFileSyncModeFailed = 'Failed to exit file sync mode';
  static const String photoCommandSent = 'Photo command sent';
  static const String photoFailed = 'Photo failed';
  static const String photoMode = 'Photo Mode';
  static const String normalPhoto = 'Normal';
  static const String aiRecognitionPhoto = 'AI Recognition';
  static const String continuousPhoto = 'Continuous';
  static const String simultaneousInterpretation = 'Simultaneous Interpretation';
  static const String simultaneousInterpretationStatus = 'Simultaneous Interpretation Status';
  static const String startSimultaneousInterpretation = 'Start Simultaneous Interpretation';
  static const String pauseSimultaneousInterpretation = 'Pause Simultaneous Interpretation';
  static const String stopSimultaneousInterpretation = 'Stop Simultaneous Interpretation';
  static const String simultaneousInterpretationNotStarted = 'Not Started';
  static const String simultaneousInterpretationStarted = 'In Progress';
  static const String simultaneousInterpretationPaused = 'Paused';
  static const String simultaneousInterpretationStopped = 'Stopped';
  static const String commandSent = ' command sent';
  static const String failed = ' failed';
  static const String videoStartSuccess = 'Video recording started successfully';
  static const String videoStartFailed = 'Failed to start video recording';
  static const String videoStopCommandSent = 'Video stop command sent';
  static const String videoStopFailed = 'Failed to stop video recording';
  static const String deviceRestartSuccess = 'Device restarted successfully';
  static const String deviceRestartFailed = 'Device restart failed';
  static String batteryLevelToast(String level, bool charging) => 'Battery level: $level${charging ? ', charging' : ''}';
  static const String batteryQueryFailed = 'Battery query failed';
  
  // ==================== More Function Buttons ====================
  static const String getRecordStatus = 'Get Record Status';
  static const String getDeviceLanguage = 'Get Device Language';
  static const String getDeviceUUID = 'Get Device UUID';
  static const String getVoiceWakeupStatus = 'Get Voice Wakeup Status';
  static const String getOtaStatus = 'Get OTA Status';
  static const String getActionResult = 'Get Action Result';
  static const String getSdkLog = 'Get SDK Log';
  static const String otaUpgradeFunction = 'OTA Upgrade Function';
  static const String currentVersionInfo = 'Current Version Info';
  static const String versionInfo = 'Version Info';
  static const String queryDeviceVersion = 'Query Device Version';
  static const String queryJLVersion = 'Query Firmware Version';
  static const String queryAllwinnerVersion = 'Query Imaging System Version';
  static const String queryTPVersion = 'Query TP Version';
  static const String queryGitHashVersion = 'Query Git Hash Version';
  static const String fileManagementFunction = 'File Management Function';
  static const String deviceManagementFunction = 'Device Management Function';
  
  // ==================== Status Labels ====================
  static const String audioDataStatus = 'Audio Data Status';
  static const String stopAudioStatus = 'Stop Audio Status';
  static const String audioControlStatus = 'Audio Control Status';
  static const String aiImageDataStatus = 'AI Recognition Image Data';
  static const String translationAudioData = 'Translation Audio Data';
  static const String setVideoDefaultParams = 'Set Video Default Parameters';
  static const String pcmAudioStatus = 'PCM Audio Data';
  
  // ==================== More Toast Messages ====================
  static const String getRecordStatusFailed = 'Failed to get record status';
  static const String getDeviceUuidTimeout = 'Get device UUID timeout';
  static const String getDeviceUuidFailed = 'Failed to get device UUID';
  
  // ==================== Subtitles and Descriptions ====================
  static const String stopAudioControlState = 'Stop audio control state';
  static const String exitVoiceReplyState = 'Actively exit voice reply state';
  static const String getVideoDefaultParams = 'Get video default parameters';
  static const String checkForNewVersion = 'Check for new version';
  static const String queryFileCount = 'Query file count in device';
  static const String queryFileSyncMethod = 'Query current file sync method';
  static const String deleteMediaFile = 'Delete specified media file';
  static const String clearPairInfo = 'Clear device pairing info';
  
  // ==================== More Status Text ====================
  static const String gettingStatus = 'Getting...';
  static const String notSupportedOrErrorStatus = 'Not supported or error';
  static const String deviceNotSupported = 'Device does not support this feature';
  static const String getFailed = 'Get failed';
  static const String sdkNotReturned = 'SDK not returned';
  
  static String deviceUuid(String uuid) => 'Device UUID: $uuid';
  
  static const String startAiReply = 'Start AI Reply';
  static const String completeAiReply = 'Complete AI Reply';
  static const String interruptAiReply = 'Interrupt AI Reply';
  
  // ==================== Initial Status Text ====================
  
  // ==================== Dropdown Options ====================
  static const String frameRate = 'Frame Rate (fps)';
  static const String maxDuration = 'Max Duration';
  static const String wifiOperationResult = 'WiFi Operation Result';
  static const String codeZeroSuccess = '(code=0 success)';
  
  // ==================== Audio Control Options ====================
  static const String startAudio = '1. Start Audio';
  static const String cancelAudio = '2. Cancel Audio';
  static const String startDnsStream = '3. Start DNS Stream';
  static const String pauseDnsStream = '4. Pause DNS Stream';
  static const String stopDnsStream = '5. Stop DNS Stream';
  static const String startNormalStream = '6. Start Normal Stream';
  static const String pauseNormalStream = '7. Pause Normal Stream';
  static const String stopNormalStream = '8. Stop Normal Stream';
  
  // ==================== More Button Text ====================
  static const String checkLatestVersion = 'Check Latest Version';
  static const String fileBaseUrl = 'File BaseUrl';
  static const String sdkLatestLog = 'SDK Latest Log';
  static const String operationType = 'Operation Type';
  static const String deviceRunningStatus = 'Device Running Status';
  static const String clickToQueryOrAutoUpdate = 'Click to query or auto-update';
  static const String deviceStatus = 'Device Status';
  static const String connectionState = 'Connection State';
  static const String deviceVersion = 'Device Version';
  static const String firmwareVersion = 'Firmware Version';
  
  // ==================== More Options ====================
  static const String seconds30 = '30 seconds';
  static const String seconds60 = '60 seconds';
  static const String seconds120 = '120 seconds';
  static const String seconds300 = '300 seconds';
  static const String applySettings = 'Apply Settings';
  static const String enableVoiceWakeupTypeOn = 'Enable Voice Wakeup (TypeOn)';
  static const String disableVoiceWakeupTypeOff = 'Disable Voice Wakeup (TypeOff)';
  static const String enableVoiceWakeup = 'Enable Voice Wakeup';
  static const String disableVoiceWakeup = 'Disable Voice Wakeup';
  
  // ==================== Frame Rate Options ====================
  static const String fps15 = '15 fps';
  static const String fps24 = '24 fps';
  static const String fps30 = '30 fps';
  static const String fps60 = '60 fps';
  static const String connectedDevice = 'Connected Device';
  static const String locationPermissionDenied = 'Location permission denied';
  static const String storagePermissionDenied = 'Storage permission denied';
  static const String permissionGranted = 'Permission granted';
  static const String bluetoothEnabled = 'Bluetooth enabled';
  static const String bluetoothDisabled = 'Bluetooth disabled';
  static const String checkFailed = 'Check failed';
  static const String deviceConnected = 'Device connected';
  static const String deviceNotConnected = 'Device not connected';
  static const String deviceRemovedAndDisconnected = 'Device removed and disconnected';
  static const String disconnectFailed = 'Disconnect failed';
  static const String removeDeviceFailed = 'Remove device failed';
  static const String timeSyncSuccess = 'Time sync success';
  static const String timeSyncFailed = 'Time sync failed';
  static const String versionQuerySuccess = 'Version query success';
  static const String versionQueryFailed = 'Version query failed';
  static const String languageSettingsSent = 'Language settings sent';
  static const String deviceResetSuccess = 'Device reset success';
  static const String deviceResetFailed = 'Device reset failed';
  static const String deviceShutdownSuccess = 'Device shutdown success';
  static const String deviceShutdownFailed = 'Device shutdown failed';
  static const String audioStopped = 'Audio stopped';
  static const String inIntercom = 'In intercom';
  static const String notIntercom = 'Not intercom';
  static const String exitedVoice = 'Exited voice';
  static const String httpGetMode = 'HTTP GET mode';
  static const String otherMode = 'Other mode';
  static const String deleteFileSuccess = 'Delete file success';
  static const String deleteFileFailed = 'Delete file failed';
  static const String recordingStarted = 'Recording started';
  static const String startRecordingFailed = 'Start recording failed';
  static const String recordingStopped = 'Recording stopped';
  static const String stopRecordingFailed = 'Stop recording failed';
  static const String notRecording = 'Not recording';
  static const String userInfoSetSuccess = 'User info set success';
  static const String userInfoSetFailed = 'User info set failed';
  static const String alarmSetFailed = 'Alarm set failed';
  static const String startRecordingFailed2 = 'Start recording failed';
  static const String stopRecordingFailed2 = 'Stop recording failed';
  static const String undefinedCommand = 'Undefined command';
  static const String deviceNotSupportedFeature = 'Device does not support this feature';
  static const String enterLiveModeFailed = 'Enter live mode failed';
  static const String exitedLiveMode = 'Exited live mode';
  static const String exitLiveModeFailed = 'Exit live mode failed';
  static const String clearedPairInfo = 'Cleared pair info';
  static const String clearPairInfoFailed = 'Clear pair info failed';
  static const String enabled = 'Enabled';
  static const String disabled = 'Disabled';
  
  static String voiceWakeupSet(String status) => 'Voice wakeup $status';
  static String voiceWakeupStatus(String status) => 'Voice wakeup status: $status';
  static const String deviceNotSupportedFeature2 = 'Device does not support this feature';
  static const String enterLiveModeFailed2 = 'Enter live mode failed';
  static const String exitLiveModeFailed2 = 'Exit live mode failed';
  static const String clearPairInfoFailed2 = 'Clear pair info failed';
  static const String gettingStatusWithDots = 'Getting...';
  static const String seconds = 'seconds';
  static const String duration = 'duration';
  static const String getVideoParamsFailed = 'Get video params failed';
  static String videoParamsSet(String fpsText, int duration) => 'Video params set: $fpsText, max $duration seconds';
  static const String setVideoParamsFailed = 'Set video params failed';
  static const String sendLanguageSettingsFailed = 'Send language settings failed';
  static const String deviceShutdownFailed2 = 'Device shutdown failed';
  static const String setAudioControlFailed = 'Set audio control failed';
  static const String stopAudioFailed = 'Stop audio failed';
  static const String queryAudioStateFailed = 'Query audio state failed';
  static const String setAiReplyStatusFailed = 'Set AI reply status failed';
  static const String setSimultaneousInterpretationFailed = 'Set simultaneous interpretation failed';
  static const String exitVoiceFailed = 'Exit voice failed';
  static const String queryFileCountFailed = 'Query file count failed';
  static const String queryFileSyncMethodFailed = 'Query file sync method failed';
  static const String deleteMediaFileFailed = 'Delete media file failed';
  static const String enteredFileSyncModeWifiOn = 'Entered file sync mode, Wi-Fi hotspot enabled';
  static const String exitedFileSyncModeWifiOff = 'Exited file sync mode, Wi-Fi hotspot disabled';
  static String videoParams(String configStr) => 'Video params: $configStr';
  static String recordingStatus(String stateText, int totalTime) => 'Recording status: $stateText, duration: ${totalTime}s';
  static const String queryRecordStatusTimeout = 'Query record status timeout';
  static String audioControlSet(String actionText) => 'Audio control set: $actionText';
  static String audioStatus(String stateText) => 'Audio status: $stateText';
  static String aiReplyStatusSet(String statusText) => 'AI reply status set: $statusText';
  static String simultaneousInterpretationStatusSet(String action) => 'Simultaneous interpretation status set: $action';
  static String deviceFileCount(int count) => 'Device has $count files';
  static String currentFileSyncMethod(String typeStr) => 'Current file sync method: $typeStr';
  static const String setUserInfoFailed = 'Set user info failed';
  static const String alarmSetSuccess = 'Alarm set success (7:30)';
  static const String setAlarmFailed = 'Set alarm failed';
  static String currentLanguage(String language) => 'Current language: $language';
  static String videoConfigParams(int frameRate, int maxDuration) => 'Frame rate: ${frameRate}fps, max duration: ${maxDuration}s';
  
  // ==================== Audio Status Text ====================
  static const String stopAudio = 'Stop Audio';
  static const String dnsStreamStart = 'DNS Stream Start';
  static const String dnsStreamPause = 'DNS Stream Pause';
  static const String dnsStreamStop = 'DNS Stream Stop';
  static const String normalStreamStart = 'Normal Stream Start';
  static const String normalStreamPause = 'Normal Stream Pause';
  static const String normalStreamStop = 'Normal Stream Stop';
  static const String unknownError = 'Unknown Error';
  static const String unknownState = 'Unknown';
  static String loadCachedDevice(String name, String mac) => 'Loaded cached device: $name ($mac)';
  
  // ==================== Version Info and Logs ====================
  static const String getJlVersionTimeout = 'Get Firmware Version Timeout';
  static const String getJlVersionFailed = 'Get Firmware Version Failed';
  static const String getQzVersionTimeout = 'Get Imaging System Version Timeout';
  static const String getQzVersionFailed = 'Get Imaging System Version Failed';
  static const String getGithashVersionTimeout = 'Get Git hash version timeout';
  static const String getGithashVersionFailed = 'Get Git hash version failed';
  static String jlVersion(String version) => 'Firmware Version: $version';
  static String qzVersion(String version) => 'Imaging System Version: $version';
  static String githashVersion(String version) => 'Git hash version: $version';
  static const String connectDeviceForMac = 'Please connect device first to get MAC address';
  static const String checkingLatestVersion = 'Checking latest version...';
  static String checkResult(String result) => 'Check result: $result';
  static const String checkVersionFailed = 'Check version failed';
  static const String jlVersionMissing = 'Firmware version info missing, please get version info first';
  static const String qzVersionMissing = 'Imaging System version info missing, please get version info first';
  static const String updateAvailable = 'New version available';
  static const String alreadyLatest = 'Already latest version';
  static const String getLanguageTimeout = 'Get language settings timeout';
  static const String getLanguageFailed = 'Get language settings failed';
  static const String voiceWakeupMayNotSupport = 'Voice wakeup may not be supported';
  static const String setVoiceWakeupFailed = 'Set voice wakeup failed';
  static String runningStatus(String status) => 'Running status: $status';
  static const String runningStatusMayNotSupport = 'Running status may not be supported';
  static const String enteredLiveModeAp = 'Entered live mode (AP mode)';
  static const String gettingVersionInfo = 'Getting version info...';
  static String connectedTo(String deviceName) => 'Connected to $deviceName';
  static const String sdkTimeoutMessage = 'SDK 10 seconds timeout, no response';
  
  // ==================== Missing Strings ====================
  
  static const String sdkLog = 'SDK Log';
  static const String startAudioControlState = 'Start Audio Control';
  static const String realtimeStatus = 'Realtime Status';
}
