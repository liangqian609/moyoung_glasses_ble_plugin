import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:moyoung_glasses_ble_plugin/moyoung_glasses_ble.dart';
import 'package:moyoung_glasses_ble_plugin/impl/moyoung_glasses_beans.dart';
import 'package:moyoung_glasses_ble_plugin/impl/channel_names.dart';
import 'package:moyoung_glasses_ble_plugin/models/ai_image_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'utils/toast_util.dart';
import 'event_manager.dart';
import 'glasses_scan_page.dart';
import 'mac_address_cache.dart';
import 'package:permission_handler/permission_handler.dart';
import 'l10n/app_strings.dart';
import 'utils/locale_manager.dart';
import 'pages/media_file_page.dart';

//region 数据类定义

// 翻译音频数据Bean（临时定义，实际应该在插件中定义）
class TranslateAudioDataBean {
  final int frameIndex;
  final Uint8List data;
  
  TranslateAudioDataBean({
    required this.frameIndex,
    required this.data,
  });
}

//endregion

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MoYoungGlassesBle _glassesPlugin = MoYoungGlassesBle();
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  
  //region 属性变量
  
  // 语言管理
  Locale _locale = const Locale('zh', 'CN');
  
  String _permissionTxt = AppStrings.requestPermission;
  String _connectionStatus = AppStrings.disconnected;
  String _batteryLevel = AppStrings.unknown;
  bool _isCharging = false;
  String _wearCheckState = AppStrings.unknown;
  String _deviceVersion = AppStrings.unknown;
  String _jlVersion = AppStrings.unknown;
  String _qzVersion = AppStrings.unknown;
  String _tpVersion = AppStrings.unknown;
  String _githashVersion = AppStrings.unknown;
  
  // 存储实际值，用于语言切换时重新格式化
  int _actualBatteryLevel = 0;
  String _actualDeviceVersion = '';
  String _actualJlVersion = '';
  String _actualQzVersion = '';
  String _actualRunningStatus = '';
  String _actualLanguageStatus = '';
  String _actualDeviceUUIDStatus = '';
  String _actualVoiceWakeupStatus = '';
  String _actualAudioTalkState = '';
  String _actualBluetoothState = '';
  String _fileBaseUrl = AppStrings.waitingToReceive;
  bool isQuit = false;
  bool _isConnected = false;
  String _audioDataStatus = AppStrings.noAudioData;
  String _aiImageDataStatus = AppStrings.noAiImageData;
  String _aiConversationStatus = AppStrings.aiStatusNotStarted; // AI对话状态
  String _simultaneousInterpretationStatus = AppStrings.simultaneousInterpretationNotStarted; // 同声传译状态
  int _selectedSimultaneousInterpretationAction = 3; // 选择的同声传译动作：3=开始，4=暂停，5=停止
  String _translateAudioStatus = AppStrings.noTranslationAudio;
  int _translateTotalBytes = 0; // 翻译音频数据累计字节数
  
  // 拍照模式选择
  int _selectedPhotoMode = 0;
  
  // 图片数据相关
  bool _isImageReceiving = false; // 是否正在接收图片数据
  Uint8List? _displayedImage; // 当前显示的图片数据
  String _pcmAudioStatus = AppStrings.noPcmAudioData;
  int _pcmTotalBytes = 0;
  String _audioRecordStatus = AppStrings.clickToGet;  // 录音状态
  String _languageStatus = AppStrings.clickToGet;     // 语言设置状态
  String _deviceUUIDStatus = AppStrings.clickToGet;     // 设备UUID状态
  String _voiceWakeupStatus = AppStrings.clickToGet;   // 语音唤醒状态
  String _runningStatus = AppStrings.clickToGet;       // 运行状态
  String _otaStatus = AppStrings.waitingOtaStatus;        // OTA升级状态
  String _actionResultStatus = AppStrings.waitingActionResult;  // Wifi操作结果状态
  String _sdkLogStatus = AppStrings.waitingSdkLog;      // SDK日志状态
  String _checkVersionResult = AppStrings.clickToGet;  // 检查版本结果状态
  String? _cachedMacAddress;               // 缓存的 MAC 地址
  String? _cachedDeviceName;               // 缓存的设备名称
  
  //endregion
  BuildContext? _materialContext;          // MaterialApp 内部的 context
  String _audioTalkState = AppStrings.notSet;        // 音频控制状态
  int _selectedAudioAction = 1;            // 选择的音频动作类型
  String _bluetoothState = AppStrings.unknown;         // 蓝牙状态
  int _selectedAIStatus = 0;               // 选择的AI回复状态类型
  int _selectedFrameRate = 0;             // 选择的录像帧率
  int _selectedMaxDuration = 60;          // 选择的录像最大时长
  int _selectedVoiceWakeupAction = 0;     // 选择的语音唤醒操作：0=开启(TypeOn)，1=关闭(TypeOff)

  //endregion
  
  //region 生命周期
  
  @override
  void initState() {
    super.initState();
    
    try {
      // 检测当前运行平台
      if (kIsWeb) {
        debugPrint('当前运行平台: Web');
      } else if (Platform.isIOS) {
        debugPrint('当前运行平台: iOS');
      } else if (Platform.isAndroid) {
        debugPrint('当前运行平台: Android');
      } else {
        debugPrint('当前运行平台: 其他平台');
      }
      
      _loadLocale();
      _loadCachedMacAddress();
      _subscribeToStreams();
      _checkInitialBluetoothState();
      
      // 延迟检查初始连接状态，确保事件流监听已启动
      Future.delayed(Duration(milliseconds: 1000), () {
        _checkInitialConnectionState();
      });
      
      debugPrint('=== MyApp 初始化完成 ===');
    } catch (e, stackTrace) {
      debugPrint('=== MyApp 初始化失败 ===');
      debugPrint('错误: $e');
      debugPrint('堆栈: $stackTrace');
    }
  }
  
  /// 更新状态文本（语言切换时调用，只更新显示文本，不改变数据源）
  void _updateStatusTexts() {
    setState(() {
      _permissionTxt = AppStrings.requestPermissionStatus;
      
      // 只更新连接状态的显示文本，数据源 _isConnected 保持不变
      _connectionStatus = _isConnected ? AppStrings.connected : AppStrings.disconnected;
      
      // 只根据实际数据源重新格式化显示文本，不改变数据源
      _batteryLevel = _actualBatteryLevel > 0 
          ? AppStrings.batteryDisplay("$_actualBatteryLevel", _isCharging)
          : AppStrings.unknownStatus;
      
      _deviceVersion = _actualJlVersion.isNotEmpty 
          ? "${AppStrings.firmwareVersion}: $_actualJlVersion"
          : AppStrings.unknownStatus;
      
      _jlVersion = _actualJlVersion.isNotEmpty 
          ? AppStrings.jlVersion(_actualJlVersion)
          : AppStrings.unknownStatus;
      
      _qzVersion = _actualQzVersion.isNotEmpty 
          ? AppStrings.qzVersion(_actualQzVersion)
          : AppStrings.unknownStatus;
      
      // 根据实际状态重新设置显示文本
      _runningStatus = _actualRunningStatus.isNotEmpty 
          ? _actualRunningStatus 
          : AppStrings.clickToGet;
      
      _languageStatus = _actualLanguageStatus.isNotEmpty 
          ? _actualLanguageStatus 
          : AppStrings.clickToGet;
      
      _deviceUUIDStatus = _actualDeviceUUIDStatus.isNotEmpty 
          ? _actualDeviceUUIDStatus 
          : AppStrings.clickToGet;
      
      _voiceWakeupStatus = _actualVoiceWakeupStatus.isNotEmpty 
          ? _actualVoiceWakeupStatus 
          : AppStrings.clickToGet;
      
      _audioTalkState = _actualAudioTalkState.isNotEmpty 
          ? _actualAudioTalkState 
          : AppStrings.notSet;
      
      _bluetoothState = _actualBluetoothState.isNotEmpty 
          ? _actualBluetoothState 
          : AppStrings.unknownStatus;
      
      // 这些状态文本根据当前语言重新设置
      _githashVersion = AppStrings.unknownStatus;
      _fileBaseUrl = AppStrings.waitingToReceive;
      _audioDataStatus = AppStrings.noAudioData;
      _aiImageDataStatus = AppStrings.noAiImageData;
      _aiConversationStatus = AppStrings.aiStatusNotStarted;
      _translateAudioStatus = AppStrings.noTranslationAudio;
      _pcmAudioStatus = AppStrings.noPcmAudio;
      _audioRecordStatus = AppStrings.clickToGet;
      _otaStatus = AppStrings.waitingOtaStatus;
      _actionResultStatus = AppStrings.waitingActionResult;
      _sdkLogStatus = AppStrings.waitingSdkLog;
      
      // 重置图片数据相关变量
      _isImageReceiving = false;
      _displayedImage = null;
    });
  }
  
  /// 加载语言设置
  Future<void> _loadLocale() async {
    final savedLocale = LocaleManager.getSavedLocale();
    setState(() {
      _locale = savedLocale;
      AppStrings.setLocale(savedLocale);
    });
    
    // 语言加载完成后，初始化显示文本
    _initializeStatusTexts();
  }
  
  /// 初始化状态文本（只在语言加载后调用一次）
  void _initializeStatusTexts() {
    setState(() {
      // 设置初始显示文本，这些会在数据更新时被替换
      _permissionTxt = AppStrings.requestPermissionStatus;
      _connectionStatus = AppStrings.disconnected;
      _batteryLevel = AppStrings.unknownStatus;
      _deviceVersion = AppStrings.unknownStatus;
      _jlVersion = AppStrings.unknownStatus;
      _qzVersion = AppStrings.unknownStatus;
      _githashVersion = AppStrings.unknownStatus;
      _fileBaseUrl = AppStrings.waitingToReceive;
      _audioDataStatus = AppStrings.noAudioData;
      _aiImageDataStatus = AppStrings.noAiImageData;
      _aiConversationStatus = AppStrings.aiStatusNotStarted;
      _translateAudioStatus = AppStrings.noTranslationAudio;
      _pcmAudioStatus = AppStrings.noPcmAudio;
      _audioRecordStatus = AppStrings.clickToGet;
      _languageStatus = AppStrings.clickToGet;
      _deviceUUIDStatus = AppStrings.clickToGet;
      _voiceWakeupStatus = AppStrings.clickToGet;
      _runningStatus = AppStrings.clickToGet;
      _otaStatus = AppStrings.waitingOtaStatus;
      _actionResultStatus = AppStrings.waitingActionResult;
      _sdkLogStatus = AppStrings.waitingSdkLog;
      _audioTalkState = AppStrings.notSet;
      _bluetoothState = AppStrings.unknownStatus;
      
      // 重置累计字节数
      _translateTotalBytes = 0;
      _pcmTotalBytes = 0;
    });
  }
  
  /// 切换语言
  Future<void> _changeLanguage(Locale locale) async {
    await LocaleManager.saveLocale(locale);
    setState(() {
      _locale = locale;
      AppStrings.setLocale(locale);
    });
    // 更新所有状态文本
    _updateStatusTexts();
  }
  
  /// 加载缓存的 MAC 地址
  Future<void> _loadCachedMacAddress() async {
    final mac = await MacAddressCache.getCachedMac();
    final name = await MacAddressCache.getCachedDeviceName();
    setState(() {
      _cachedMacAddress = mac;
      _cachedDeviceName = name;
    });
    if (mac != null && name != null) {
      print(AppStrings.loadCachedDevice(name!, mac!));
    }
  }
  
  void _subscribeToStreams() {
    // 监听连接状态
    _streamSubscriptions.add(
      _glassesPlugin.connStateEveStm.listen((ConnectStateBean event) {
        setState(() {
          // connectState: 0=断开, 1=连接中, 2=已连接, 3=断开中
          _isConnected = event.connectState == 2;
          _connectionStatus = _getConnectionStateText(event.connectState);
        });
        
        // 连接成功时发送通知并更新信息
        if (event.connectState == 2) {
          EventManager().emit(EventNames.connectionSuccess, {
            'isConnected': true,
          });

          // 连接成功后更新基本信息
          // 延迟一下，避免与初始连接检查冲突
          Timer(const Duration(milliseconds: 100), () async {
            if (_isConnected) {
              await _loadCachedMacAddress();
              // 查询设备信息
              _queryBattery();
              _queryDeviceVersion();
            }
          });
        }
        // 断开连接时清除状态
        else if (event.connectState == 0) {
          setState(() {
            _cachedMacAddress = null;
            _cachedDeviceName = null;
          });
        }
      }),
    );
    
    // 监听Wi-Fi状态文件BaseUrl
    _streamSubscriptions.add(
      _glassesPlugin.fileBaseUrlEveStm.listen((String baseUrl) {
        setState(() {
          _fileBaseUrl = baseUrl;
        });
      }),
    );
    
    // 监听蓝牙状态
    _streamSubscriptions.add(
      _glassesPlugin.bluetoothStateEveStm.listen((int state) {
        String stateText = AppStrings.unknownState;
        switch (state) {
          case 0:
            stateText = AppStrings.unknownConnectionState;
            break;
          case 1:
            stateText = AppStrings.bluetoothResetting;
            break;
          case 2:
            stateText = AppStrings.bluetoothUnavailable;
            break;
          case 3:
            stateText = AppStrings.bluetoothUnauthorized;
            break;
          case 4:
            stateText = AppStrings.bluetoothAvailable;
            break;
          case 5:
            stateText = AppStrings.bluetoothLimiting;
            break;
          case 6:
            stateText = AppStrings.bluetoothTurningOn;
            break;
          case 7:
            stateText = AppStrings.bluetoothOn;
            break;
          case 8:
            stateText = AppStrings.bluetoothTurningOff;
            break;
          case 9:
            stateText = AppStrings.bluetoothOff;
            break;
        }
        setState(() {
          _bluetoothState = stateText;
        });
      }),
    );
    
    // 监听音频数据
    _streamSubscriptions.add(
      _glassesPlugin.audioDataEveStm.listen((Map<String, dynamic> data) {
        int frameIndex = data['frameIndex'] ?? 0;
        int size = data['size'] ?? 0;
        
        setState(() {
          if (size > 0) {
            _audioDataStatus = AppStrings.receivedAudioData(frameIndex, size);
          } else {
            _audioDataStatus = AppStrings.noAudioData;
          }
        });
      }),
    );
    
    // 监听ACK错误
    _streamSubscriptions.add(
      _glassesPlugin.ackErrorEveStm.listen((Map<String, dynamic> error) {
        int code = error['code'] ?? -1;
        String message = error['message'] ?? AppStrings.unknownError;
        
        bool shouldShowToast = true;
        
        // 如果是语音唤醒相关的错误，更新状态显示
        if (_voiceWakeupStatus == AppStrings.gettingStatusWithDots) {
          setState(() {
            _actualVoiceWakeupStatus = AppStrings.notSupportedOrErrorStatus;
            _voiceWakeupStatus = AppStrings.notSupportedOrErrorStatus;
          });
          // 语音唤醒错误不显示Toast，避免重复提示
          shouldShowToast = false;
        }
        
        // 如果是运行状态相关的错误，更新状态显示
        if (_runningStatus == AppStrings.gettingStatusWithDots) {
          setState(() {
            _actualRunningStatus = AppStrings.notSupportedOrErrorStatus;
            _runningStatus = AppStrings.notSupportedOrErrorStatus;
          });
          // 运行状态错误不显示Toast，避免重复提示
          shouldShowToast = false;
        }
        
        // 只在非功能查询错误时显示Toast
        if (shouldShowToast) {
          _showToast(AppStrings.errorMessage(code.toString(), message));
        }
      }),
    );
    
    // 监听音频控制状态（SDK的receiveAudioState回调）
    _streamSubscriptions.add(
      _glassesPlugin.audioTalkStateEveStm.listen((int state) {
        String stateText = AppStrings.unknownState;
        String aiStatus = AppStrings.aiStatusNotStarted;
        String siStatus = _simultaneousInterpretationStatus; // 保持当前同声传译状态
        
        switch (state) {
          case 0:
            stateText = AppStrings.stopAudio;
            aiStatus = AppStrings.aiStatusEnded; // 结束
            break;
          case 1:
            stateText = AppStrings.startAudio;
            aiStatus = AppStrings.aiStatusStarted; // 开始
            break;
          case 2:
            stateText = AppStrings.cancelAudio;
            aiStatus = AppStrings.aiStatusEnded; // 结束
            break;
          case 3:
            stateText = AppStrings.dnsStreamStart;
            siStatus = AppStrings.simultaneousInterpretationStarted; // 同声传译开始
            break;
          case 4:
            stateText = AppStrings.dnsStreamPause;
            siStatus = AppStrings.simultaneousInterpretationPaused; // 同声传译暂停
            break;
          case 5:
            stateText = AppStrings.dnsStreamStop;
            siStatus = AppStrings.simultaneousInterpretationStopped; // 同声传译停止
            break;
          case 6:
            stateText = AppStrings.normalStreamStart;
            break;
          case 7:
            stateText = AppStrings.normalStreamPause;
            break;
          case 8:
            stateText = AppStrings.normalStreamStop;
            break;
          default:
            stateText = AppStrings.unknownState;
        }
        
        setState(() {
          _audioTalkState = stateText;
          _actualAudioTalkState = stateText;
          _aiConversationStatus = aiStatus;
          _simultaneousInterpretationStatus = siStatus;
        });
        
        debugPrint('Audio control state: $stateText (value: $state)');
      }),
    );
    
    // 监听音频状态
    _streamSubscriptions.add(
      _glassesPlugin.audioStateEveStm.listen((AudioStateBean event) {
        debugPrint('Received audio state: state=${event.state}, frameIndex=${event.frameIndex}, dataSize=${event.dataSize}');
        
        setState(() {
          if (event.hasData == true && event.dataSize != null) {
            // 收到音频数据
            debugPrint('Received audio data: frame=${event.frameIndex}, size=${event.dataSize} bytes');
            _audioDataStatus = AppStrings.receivedAudioData(event.frameIndex ?? 0, event.dataSize ?? 0);
          } else {
            // 只是状态变化
            switch (event.state) {
              case 0:
                _audioDataStatus = AppStrings.audioIdle;
                break;
              case 1:
                _audioDataStatus = AppStrings.recording;
                break;
              case 2:
                _audioDataStatus = AppStrings.audioPaused;
                break;
              default:
                _audioDataStatus = AppStrings.unknownAudioStatus;
            }
          }
        });
      }),
    );
    
    // 监听AI识别图片数据
    _streamSubscriptions.add(
      _glassesPlugin.aiImageDataEveStm.listen((AIImageData imageData) async {
        debugPrint('Received AI image data: source=${imageData.source}, size=${imageData.size} bytes');
        
        // 获取图片数据
        final imageBytes = await imageData.getDisplayableData();
        
        // 直接显示图片，无需累加
        setState(() {
          _displayedImage = imageBytes;
          _aiImageDataStatus = AppStrings.receivedImageData(imageBytes.length);
          _isImageReceiving = false; // 图片已接收完成
        });
        
        debugPrint('Image displayed, size: ${imageBytes.length} bytes');
      }),
    );
    
    // 监听翻译音频数据
    _streamSubscriptions.add(
      _glassesPlugin.translateAudioEveStm.listen((Uint8List data) {
        // data 现在是直接的二进制数据 (Uint8List)
        debugPrint('收到翻译音频数据: ${data.length} bytes');
        setState(() {
          _translateTotalBytes += data.length;
          _translateAudioStatus = AppStrings.receivedAudioData(0, _translateTotalBytes);
        });
      }),
    );
    
    // 监听PCM音频数据 - 支持iOS和Android平台
    _streamSubscriptions.add(
      _glassesPlugin.pcmAudioEveStm.listen((Uint8List data) {
        // data 现在是直接的二进制数据 (Uint8List)
        debugPrint('Received PCM audio data: size=${data.length} bytes');
        setState(() {
          _pcmTotalBytes += data.length;
          _pcmAudioStatus = AppStrings.receivedAudioData(0, _pcmTotalBytes);
        });
      }),
    );
    
    // 监听OTA升级状态
    _streamSubscriptions.add(
      _glassesPlugin.otaStateEveStm.listen((Map<String, dynamic> data) {
        debugPrint('Received OTA upgrade event: $data');
        int type = data['type'] ?? 0;
        int progress = data['progress'] ?? 0;
        String typeText = type == 0 ? 'Preparing' : type == 1 ? 'Upgrading' : type == 2 ? 'Complete' : 'Failed';
        
        setState(() {
          _otaStatus = "$typeText (${progress}%)";
        });
        
        // 只在重要状态变化时显示Toast
        if (type == 2 || type == 3) {
          _showToast(typeText);
        }
      }),
    );
    
    // 监听Wifi操作结果
    _streamSubscriptions.add(
      _glassesPlugin.actionResultEveStm.listen((Map<String, dynamic> data) {
        debugPrint('Received action result: $data');
        int code = data['code'] ?? -1;
        String msg = data['msg'] ?? '';
        
        String statusText = '';
        // 根据官方Demo，只确认 code=0 表示成功
        if (code == 0) {
          statusText = msg.isEmpty ? 'Connected' : 'Success: $msg';
        } else {
          // 其他状态码显示原始信息
          statusText = msg.isEmpty ? 'Operation result(code: $code)' : 'Result: $msg (code: $code)';
        }
        
        setState(() {
          _actionResultStatus = statusText;
        });
        
        _showToast(statusText);
      }),
    );
    
    // 监听SDK日志
    debugPrint('开始监听 SDK 日志事件流...');
    _streamSubscriptions.add(
      _glassesPlugin.sdkLogEveStm.listen(
        (String log) {
          debugPrint('Received log message: $log');
          
          // 更新状态显示，只显示最新的日志
          setState(() {
            // 截取日志，避免太长
            String displayLog = log.length > 50 ? '${log.substring(0, 47)}...' : log;
            _sdkLogStatus = displayLog;
          });
          
          // 重要日志仍然显示Toast
          if (log.contains('ERROR') || log.contains('WARN')) {
            _showToast(AppStrings.logMessage(log));
          }
        },
        onError: (error) {
          debugPrint('SDK 日志事件流错误: $error');
        },
        onDone: () {
          debugPrint('SDK 日志事件流关闭');
        },
      ),
    );
    
    // 监听运行状态
    _streamSubscriptions.add(
      _glassesPlugin.runningStatusEveStm.listen((Map<String, dynamic> status) {
        debugPrint('Received running status event: $status');
        String actualStatus = status['status'] ?? 'Unknown status';
        setState(() {
          _actualRunningStatus = actualStatus;
          _runningStatus = actualStatus;
        });
      }),
    );
    
    // 监听电池信息
    _streamSubscriptions.add(
      _glassesPlugin.batteryEveStm.listen((Map<String, dynamic> batteryInfo) {
        debugPrint('Received battery info event: $batteryInfo');
        
        if (batteryInfo['error'] != null) {
          debugPrint('Battery info error: ${batteryInfo['error']}');
          return;
        }
        
        int batteryLevel = 0;
        bool isCharging = false;
        
        // 解析电池数据
        if (batteryInfo['battery'] != null) {
          batteryLevel = int.tryParse(batteryInfo['battery'].toString()) ?? 0;
        }
        if (batteryInfo['charging'] != null) {
          isCharging = batteryInfo['charging'].toString().toLowerCase() == 'true';
        }
        
        // 只在电量变化时更新UI（避免频繁刷新）
        if (_actualBatteryLevel != batteryLevel || _isCharging != isCharging) {
          setState(() {
            _actualBatteryLevel = batteryLevel;
            _batteryLevel = AppStrings.batteryDisplay("$batteryLevel", isCharging);
            _isCharging = isCharging;
          });
          debugPrint('Battery info updated: level=$batteryLevel%, charging=$isCharging');
        }
      }),
    );
  }
  
  String _getConnectionStateText(int state) {
    switch (state) {
      case 2:
        return AppStrings.connected;
      case 1:
        return AppStrings.connectingStatus;
      case 0:
        return AppStrings.disconnected;
      case 3:
        return AppStrings.disconnecting;
      default:
        return AppStrings.unknownConnectionState;
    }
  }
  
  //endregion
  
  @override
  void dispose() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
  
  //endregion

  //region 初始化和设置方法

  /// 退出app并且断开连接
  Future<bool> exitAppWithDisconnect() {
    if (!isQuit) {
      _showToast(AppStrings.pressAgainToExit);
      isQuit = true;
      return Future.value(false);
    }

    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }

  //region UI布局 - build方法
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      home: Builder(
        builder: (context) {
          _materialContext = context;
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: Text(AppStrings.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              actions: [
                PopupMenuButton<Locale>(
                  icon: const Icon(Icons.language),
                  onSelected: _changeLanguage,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: const Locale('zh', 'CN'),
                      child: Text(AppStrings.chinese),
                    ),
                    PopupMenuItem(
                      value: const Locale('en', 'US'),
                      child: Text(AppStrings.english),
                    ),
                  ],
                ),
              ],
            ),
            body: WillPopScope(
              onWillPop: () => exitAppWithDisconnect(),
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 状态卡片
                    _buildStatusCard(),
                    const SizedBox(height: 20),
                    
                    // 基础功能
                    _buildBasicFunctionSection(),
                    const SizedBox(height: 20),

                    // 佩戴检查
                    _buildWearCheckSection(),

                    // 眼镜功能
                    _buildGlassesSection(),
                    const SizedBox(height: 20),

                    // AI 对话监听
                    _buildAIConversationListenSection(),
                    const SizedBox(height: 20),

                    // 同声传译
                    _buildSimultaneousInterpretationSection(),
                    const SizedBox(height: 20),

                    // 媒体文件管理
                    _buildMediaFileSection(),
                    const SizedBox(height: 20),

                    // AI 功能
                    _buildAISection(),
                    const SizedBox(height: 20),

                    // Wi-Fi 功能（文件同步）
                    _buildWifiSection(),
                    const SizedBox(height: 20),

                    // 录音功能
                    _buildRecordSection(),
                    const SizedBox(height: 20),

                    // 用户信息和设置 - 已屏蔽
                    // _buildUserInfoSection(),
                    // const SizedBox(height: 20),

                    // 直播功能 - 已屏蔽
                    // _buildLiveSection(),
                    // const SizedBox(height: 20),

                    // 版本信息
                    _buildVersionInfoSection(),
                    const SizedBox(height: 20),

                    // OTA 升级功能
                    _buildOTASection(),
                    const SizedBox(height: 20),

                    // 文件管理功能
                    _buildFileManagementSection(),
                    const SizedBox(height: 20),

                    // SDK 日志显示
                    _buildSDKLogSection(),
                    const SizedBox(height: 20),

                    // 设备管理功能
                    _buildDeviceManagementSection(),
                    const SizedBox(height: 20),

                    // 实时运行状态显示
                    _buildRealtimeStatusSection(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  //endregion

  //region UI构建方法 - 各功能模块

  Widget _buildBasicFunctionSection() {
    return _buildSectionCard(
      title: AppStrings.basicFunctions,
      icon: Icons.settings,
      children: [
        _buildApiButton(
          AppStrings.bluetoothCheck,
          Icons.security,
          requestPermissions,
          subtitle: _permissionTxt,
        ),
        Builder(
          builder: (context) => _buildApiButton(
            AppStrings.scanDevice,
            Icons.bluetooth_searching,
            () => _navigateToScanPage(context),
            subtitle: AppStrings.scanAndConnect,
          ),
        ),
        _buildApiButton(
          AppStrings.bluetoothStatus,
          Icons.bluetooth,
          () {},
          subtitle: _bluetoothState,
          enabled: false,
        ),
        _buildApiButton(
          AppStrings.connectionStatus,
          Icons.link,
          _updateConnectionState,
          subtitle: _connectionStatus,
        ),
        _buildApiButton(
          AppStrings.getDeviceUUID,
          Icons.numbers,
          _getDeviceUUID,
          subtitle: _deviceUUIDStatus,
        ),
        _buildApiButton(
          AppStrings.batteryLevel,
          Icons.battery_full,
          _queryBattery,
          subtitle: _batteryLevel,
        ),
        _buildApiButton(
          AppStrings.firmwareVersion,
          Icons.info,
          _queryDeviceVersion,
          subtitle: _deviceVersion,
        ),
        _buildApiButton(
          AppStrings.getRunningStatus,
          Icons.speed,
          _getRunningStatus,
          subtitle: _runningStatus,
        ),
        _buildApiButton(
          AppStrings.sdkLog,
          Icons.description,
          () {},
          subtitle: _sdkLogStatus,
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildWearCheckSection() {
    return _buildSectionCard(
      title: AppStrings.wearCheck,
      icon: Icons.watch,
      children: [
        _buildApiButton(
          AppStrings.queryWearCheckState,
          Icons.visibility,
          _queryWearCheckState,
          subtitle: _wearCheckState,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.setWearCheckState,
          Icons.settings,
          _showWearCheckDialog,
          subtitle: AppStrings.setWearCheckDesc,
          enabled: _isConnected,
        ),
      ],
    );
  }

  Widget _buildGlassesSection() {
    return _buildSectionCard(
      title: AppStrings.glassesFeatures,
      icon: Icons.camera,
      children: [
        // 拍照模式选择
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.photo_camera, color: Colors.green[600], size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.photoMode + ':',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<int>(
                  value: _selectedPhotoMode,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 0, child: Text(AppStrings.normalPhoto)),
                    DropdownMenuItem(value: 1, child: Text(AppStrings.aiRecognitionPhoto)),
                    DropdownMenuItem(value: 2, child: Text(AppStrings.continuousPhoto)),
                  ],
                  onChanged: (int? value) {
                    if (value != null) {
                      setState(() {
                        _selectedPhotoMode = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildApiButton(
          AppStrings.takePhoto,
          Icons.camera_alt,
          () => _takePhoto(photoMode: _selectedPhotoMode),
          subtitle: AppStrings.controlPhoto,
          enabled: _isConnected,
        ),
        // 视频功能暂时禁用
        /*
        _buildApiButton(
          AppStrings.startVideo,
          Icons.videocam,
          _startVideo,
          subtitle: AppStrings.startVideoFunction,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.stopVideo,
          Icons.videocam_off,
          _stopVideo,
          subtitle: AppStrings.stopVideoFunction,
          enabled: _isConnected,
        ),
        */
      ],
    );
  }

  Widget _buildAIConversationListenSection() {
    return _buildSectionCard(
      title: AppStrings.aiConversationListen,
      icon: Icons.hearing,
      children: [
        // AI对话状态显示
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.psychology, color: Colors.purple[600], size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.aiConversationStatus,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Text(
                  _aiConversationStatus,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.purple[700],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // PCM 音频数据状态显示
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.mic, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.pcmAudioStatus,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _pcmAudioStatus,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // AI识别图片数据状态显示
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.image, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.aiImageDataStatus,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _aiImageDataStatus,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              // 显示接收到的图片
              if (_displayedImage != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.image, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'AI识别图片',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _displayedImage = null;
                                _aiImageDataStatus = AppStrings.noAiImageData;
                              });
                            },
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.memory(
                          _displayedImage!,
                          fit: BoxFit.contain,
                          height: 200,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, color: Colors.grey[400], size: 40),
                                    const SizedBox(height: 8),
                                    Text(
                                      '图片显示失败',
                                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '图片大小: ${_displayedImage!.length} bytes',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimultaneousInterpretationSection() {
    return _buildSectionCard(
      title: AppStrings.simultaneousInterpretation,
      icon: Icons.record_voice_over,
      children: [
        // 同声传译状态显示（参照AI对话状态样式）
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.record_voice_over, color: Colors.teal[600], size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.simultaneousInterpretationStatus,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Text(
                  _simultaneousInterpretationStatus,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.teal[700],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 同声传译控制（参照AI回复的UI处理方式）
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.tune, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.simultaneousInterpretation + ':',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<int>(
                  value: _selectedSimultaneousInterpretationAction,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 3, child: Text(AppStrings.startSimultaneousInterpretation)),
                    DropdownMenuItem(value: 4, child: Text(AppStrings.pauseSimultaneousInterpretation)),
                    DropdownMenuItem(value: 5, child: Text(AppStrings.stopSimultaneousInterpretation)),
                  ],
                  onChanged: _isConnected ? (value) {
                    setState(() {
                      _selectedSimultaneousInterpretationAction = value!;
                    });
                  } : null,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isConnected ? _setSimultaneousInterpretation : null,
                child: Text(AppStrings.send),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 翻译音频数据状态显示
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.translate, color: Colors.green[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.translationAudioData,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _translateAudioStatus,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAISection() {
    return _buildSectionCard(
      title: AppStrings.aiFunctions,
      icon: Icons.psychology,
      children: [
        // 翻译音频数据状态显示
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.translate, color: Colors.green[600], size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.stopAudioStatus,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Text(
                  _translateAudioStatus,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.chat, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<int>(
                  value: _selectedAIStatus,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 0, child: Text(AppStrings.startAiReply)),
                    DropdownMenuItem(value: 1, child: Text(AppStrings.completeAiReply)),
                    DropdownMenuItem(value: 2, child: Text(AppStrings.interruptAiReply)),
                  ],
                  onChanged: _isConnected ? (value) {
                    setState(() {
                      _selectedAIStatus = value!;
                    });
                  } : null,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isConnected ? _setAIReplyStatus : null,
                child: Text(AppStrings.send),
              ),
            ],
          ),
        ),
        _buildApiButton(
          AppStrings.exitVoice,
          Icons.stop_circle,
          _exitAIReply,
          subtitle: AppStrings.exitVoiceReplyState,
          enabled: _isConnected,
        ),
      ],
    );
  }

  //endregion

  //region 媒体文件管理

  Widget _buildMediaFileSection() {
    return _buildSectionCard(
      title: AppStrings.mediaFileManagement,
      icon: Icons.folder,
      children: [
        Builder(
          builder: (context) => _buildApiButton(
            AppStrings.openFileManager,
            Icons.folder_open,
            () => _navigateToMediaFilePage(context),
            subtitle: AppStrings.manageDownloadFiles,
            enabled: _isConnected,
          ),
        ),
      ],
    );
  }

  /// 导航到媒体文件管理页面
  void _navigateToMediaFilePage(BuildContext context) {
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaFilePage(
          glassesPlugin: _glassesPlugin,
        ),
      ),
    );
  }

  //endregion

  Widget _buildWifiSection() {
    return _buildSectionCard(
      title: AppStrings.wifiFileSync,
      icon: Icons.wifi,
      children: [
        _buildApiButton(
          AppStrings.enterFileSyncMode,
          Icons.sync,
          _setFileSyncModeEnter,
          subtitle: AppStrings.enableFileTransfer,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.exitFileSyncMode,
          Icons.sync_disabled,
          _setFileSyncModeExit,
          subtitle: AppStrings.disableFileTransfer,
          enabled: _isConnected,
        ),
        // 视频配置功能暂时禁用
        /*
        _buildApiButton(
          AppStrings.getDefaultVideoParams,
          Icons.settings,
          _queryVideoConfig,
          subtitle: AppStrings.getVideoDefaultParams,
          enabled: _isConnected,
        ),
        */
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.setVideoDefaultParams,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.frameRate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        DropdownButton<int>(
                          value: _selectedFrameRate,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(value: 0, child: Text(AppStrings.notSet)),
                            DropdownMenuItem(value: 15, child: Text(AppStrings.fps15)),
                            DropdownMenuItem(value: 24, child: Text(AppStrings.fps24)),
                            DropdownMenuItem(value: 30, child: Text(AppStrings.fps30)),
                            DropdownMenuItem(value: 60, child: Text(AppStrings.fps60)),
                          ],
                          onChanged: _isConnected ? (value) {
                            setState(() {
                              _selectedFrameRate = value!;
                            });
                          } : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.maxDuration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        DropdownButton<int>(
                          value: _selectedMaxDuration,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(value: 30, child: Text(AppStrings.seconds30)),
                            DropdownMenuItem(value: 60, child: Text(AppStrings.seconds60)),
                            DropdownMenuItem(value: 120, child: Text(AppStrings.seconds120)),
                            DropdownMenuItem(value: 300, child: Text(AppStrings.seconds300)),
                          ],
                          onChanged: _isConnected ? (value) {
                            setState(() {
                              _selectedMaxDuration = value!;
                            });
                          } : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // 视频配置功能暂时禁用
                  onPressed: () => _showToast("视频配置功能暂时禁用"),
                  child: Text(AppStrings.applySettings),
                ),
              ),
            ],
          ),
        ),
        // 操作结果显示
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.wifi_outlined, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppStrings.wifiOperationResult,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.codeZeroSuccess,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _actionResultStatus,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordSection() {
    return _buildSectionCard(
      title: AppStrings.recordFunction,
      icon: Icons.mic,
      children: [
        _buildApiButton(
          AppStrings.setRecordControl,
          Icons.fiber_manual_record,
          _startAudioRecord,
          subtitle: AppStrings.setRecordControl,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.stopRecordControl,
          Icons.stop,
          _stopAudioRecord,
          subtitle: AppStrings.stopRecordControl,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.getRecordStatus,
          Icons.info,
          _queryAudioRecordState,
          subtitle: _audioRecordStatus,
          enabled: _isConnected,
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return _buildSectionCard(
      title: AppStrings.userInfoSettings,
      icon: Icons.person_outline,
      children: [
        // 设置用户信息功能已移除
        /*
        _buildApiButton(
          AppStrings.setUserInfo,
          Icons.person,
          _setUserInfo,
          subtitle: AppStrings.setUserInfoFunction,
          enabled: _isConnected,
        ),
        */
        // 语言设置功能已移至设备基础功能模块，避免重复
      ],
    );
  }

  Widget _buildLiveSection() {
    return _buildSectionCard(
      title: AppStrings.liveFunction,
      icon: Icons.live_tv,
      children: [
        // 直播功能已移除
        /*
        _buildApiButton(
          AppStrings.enterLiveMode,
          Icons.live_tv,
          _enterLiveStream,
          subtitle: AppStrings.enterLiveModeFunction,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.exitLiveMode,
          Icons.live_tv_off,
          _exitLiveStream,
          subtitle: AppStrings.exitLiveModeFunction,
          enabled: _isConnected,
        ),
        */
      ],
    );
  }

  Widget _buildVersionInfoSection() {
    return _buildSectionCard(
      title: AppStrings.versionInfo,
      icon: Icons.info,
      children: [
        _buildApiButton(
          AppStrings.queryJLVersion,
          Icons.memory,
          _getJLVersion,
          subtitle: _jlVersion,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.queryAllwinnerVersion,
          Icons.developer_board,
          _getQZVersion,
          subtitle: _qzVersion,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.queryTPVersion,
          Icons.touch_app,
          _getTPVersion,
          subtitle: _tpVersion,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.queryGitHashVersion,
          Icons.code,
          _getGithashVersion,
          subtitle: _githashVersion,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.checkLatestVersion,
          Icons.system_update_alt,
          _checkLatestVersion,
          subtitle: _checkVersionResult,
          enabled: _isConnected,
        ),
      ],
    );
  }

  Widget _buildOTASection() {
    return _buildSectionCard(
      title: AppStrings.otaUpgradeFunction,
      icon: Icons.system_update,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.system_update, size: 20, color: Colors.orange[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.otaUpgradeStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _otaStatus,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 分隔线
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(height: 1, color: Colors.grey[300]),
        ),
        // OTA升级子标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.system_update_alt, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                AppStrings.selectFirmware,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        // 分隔线
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(height: 1, color: Colors.grey[300]),
        ),
        // OTA升级子标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.system_update, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'OTA升级功能',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildApiButton(
          AppStrings.jlOtaUpgrade,
          Icons.memory,
          _startJLOTA,
          subtitle: AppStrings.selectFirmwareFile,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.cancelJlOta,
          Icons.cancel,
          _cancelOTA,
          subtitle: AppStrings.onlyJlCancellable,
          enabled: _isConnected,
        ),
        // 分隔线
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(height: 1, color: Colors.grey[300]),
        ),
        _buildApiButton(
          AppStrings.qzOtaUpgrade,
          Icons.developer_board,
          _startQZOTA,
          subtitle: AppStrings.wifiOtaNote,
          enabled: _isConnected,
        ),
      ],
    );
  }

  Widget _buildFileManagementSection() {
    return _buildSectionCard(
      title: AppStrings.fileManagementFunction,
      icon: Icons.folder,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.link, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.fileBaseUrl,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Text(
                  _fileBaseUrl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        _buildApiButton(
          AppStrings.queryFileCount,
          Icons.numbers,
          _queryFileCount,
          subtitle: AppStrings.queryFileCount,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.queryFileSyncMethod,
          Icons.sync_alt,
          _queryFileSyncType,
          subtitle: AppStrings.queryFileSyncMethod,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.deleteMediaFile,
          Icons.delete,
          _deleteMediaFile,
          subtitle: AppStrings.deleteMediaFile,
          enabled: _isConnected,
        ),
      ],
    );
  }

  Widget _buildSDKLogSection() {
    return _buildSectionCard(
      title: AppStrings.sdkLog,
      icon: Icons.bug_report,
      children: [
        // SDK日志显示
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.bug_report, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.sdkLatestLog,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _sdkLogStatus,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceManagementSection() {
    return _buildSectionCard(
      title: AppStrings.deviceManagementFunction,
      icon: Icons.settings_applications,
      children: [
        _buildApiButton(
          AppStrings.disconnectDevice,
          Icons.bluetooth_disabled,
          _disconnectDevice,
          subtitle: AppStrings.disconnectDevice,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.clearPairInfo,
          Icons.link_off,
          _clearPairInfo,
          subtitle: AppStrings.clearPairInfo,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.getDeviceUUID,
          Icons.fingerprint,
          _getDeviceUUID,
          subtitle: _deviceUUIDStatus,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.getVoiceWakeupStatus,
          Icons.voice_over_off,
          _getVoiceWakeupState,
          subtitle: _voiceWakeupStatus,
          enabled: _isConnected,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.setVoiceWakeup,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.operationType,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        DropdownButton<int>(
                          value: _selectedVoiceWakeupAction,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(value: 0, child: Text(AppStrings.enableVoiceWakeupTypeOn)),
                            DropdownMenuItem(value: 1, child: Text(AppStrings.disableVoiceWakeupTypeOff)),
                          ],
                          onChanged: _isConnected ? (value) {
                            setState(() {
                              _selectedVoiceWakeupAction = value!;
                            });
                          } : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isConnected ? _setVoiceWakeup : null,
                  child: Text(_selectedVoiceWakeupAction == 0 ? AppStrings.enableVoiceWakeup : AppStrings.disableVoiceWakeup),
                ),
              ),
            ],
          ),
        ),
        _buildApiButton(
          AppStrings.getRunningStatus,
          Icons.info_outline,
          _getRunningStatus,
          subtitle: _runningStatus,
          enabled: _isConnected,
        ),
      ],
    );
  }

  Widget _buildRealtimeStatusSection() {
    return _buildSectionCard(
      title: AppStrings.realtimeStatus,
      icon: Icons.speed,
      children: [
        // 实时运行状态显示
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.play_circle_outline, size: 20, color: Colors.green[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.deviceRunningStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _runningStatus == AppStrings.clickToGet ? AppStrings.clickToQueryOrAutoUpdate : _runningStatus,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  //region UI构建辅助方法

  // ==================== UI 构建方法 ====================
  
  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  AppStrings.deviceStatus,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusRow(AppStrings.connectionState, _connectionStatus, 
                _isConnected ? Colors.green : Colors.red),
            _buildStatusRow(AppStrings.batteryLevel, _batteryLevel, Colors.orange),
            _buildStatusRow(AppStrings.firmwareVersion, _deviceVersion, Colors.blue),
            // 显示设备名称和 MAC 地址
            if (_cachedDeviceName != null && _cachedMacAddress != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.devices, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.connectedDevice,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _cachedDeviceName!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _cachedMacAddress!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildApiButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
    {
    String? subtitle,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: enabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: enabled ? Colors.blue[600] : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: enabled ? Colors.black87 : Colors.grey,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: enabled ? Colors.grey[600] : Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: enabled ? Colors.grey[400] : Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  //endregion

  //region API调用方法 - 设备连接和控制

  // ==================== API 调用方法 ====================
  
  void requestPermissions() {
    [
      Permission.location,
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise
    ].request().then((value) => {
          setState(() {
            Map<Permission, PermissionStatus> statuses = value;
            if (statuses[Permission.location] == PermissionStatus.denied) {
              _permissionTxt = AppStrings.locationPermissionDenied;
              return;
            }
            if (statuses[Permission.storage] == PermissionStatus.denied) {
              _permissionTxt = AppStrings.storagePermissionDenied;
              return;
            }
            _permissionTxt = AppStrings.permissionGranted;
          })
        });
  }
  
  void _navigateToScanPage(BuildContext context) async {
    if (!mounted) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GlassesScanPage(),
      ),
    );
    
    // 处理连接结果
    if (result != null && result is Map<String, dynamic>) {
      if (result['connected'] == true) {
        final device = result['device'] as BleScanBean;
        _showToast(AppStrings.connectedTo(device.name.isEmpty ? device.address : device.name));
        
        // 连接成功后更新基本信息
        // 注意：不要手动设置 _isConnected，让事件流来更新状态
        _updateConnectionState();
      }
    }
  }
  
  /// 检查初始蓝牙状态
  void _checkInitialBluetoothState() async {
    try {
      bool isEnabled = await _glassesPlugin.checkBluetoothEnable;
      // 根据返回值设置初始状态
      setState(() {
        _bluetoothState = isEnabled ? AppStrings.bluetoothEnabled : AppStrings.bluetoothDisabled;
      });
      debugPrint('Initial Bluetooth state: $_bluetoothState');
    } catch (e) {
      debugPrint('Failed to check initial Bluetooth state: $e');
      setState(() {
        _bluetoothState = AppStrings.checkFailed;
      });
    }
  }
  
  // 标记是否已经完成初始连接检查
  bool _hasCheckedInitialConnection = false;
  
  /// 检查初始连接状态，解决时序问题
  void _checkInitialConnectionState() async {
    // 如果已经检查过且状态已同步，则跳过
    if (_hasCheckedInitialConnection && _isConnected) {
      debugPrint('Initial connection already checked and synced');
      return;
    }
    
    try {
      debugPrint('Checking initial connection state...');
      
      // 检查是否有缓存的设备信息
      if (_cachedMacAddress != null && _cachedMacAddress!.isNotEmpty) {
        debugPrint('Found cached device, checking connection status...');
        
        // 如果有缓存的设备信息，尝试查询电池来判断是否真的连接
        try {
          await _glassesPlugin.queryBattery();
          debugPrint('Battery query successful, device is connected');
          if (!_isConnected) {
            setState(() {
              _isConnected = true;
              _connectionStatus = AppStrings.connected;
            });
            debugPrint('Updated UI state to connected');
            _hasCheckedInitialConnection = true;
            
            // 触发连接成功后的操作（静默，不显示Toast）
            await _loadCachedMacAddress();
            // 重新查询电量用于刷新UI显示（上面的查询仅用于判断连接状态）
            _queryBattery();
            _queryDeviceVersion();
          }
        } catch (e) {
          debugPrint('Battery query failed, device may not be connected: $e');
          // 只有在第一次检查失败时才更新状态
          if (!_hasCheckedInitialConnection) {
            setState(() {
              _isConnected = false;
              _connectionStatus = AppStrings.disconnected;
            });
          }
        }
      } else {
        debugPrint('No cached device found');
        _hasCheckedInitialConnection = true;
      }
    } catch (e) {
      debugPrint('Failed to check initial connection state: $e');
    }
  }
  
  void _updateConnectionState() async {
    // 更新 UI 状态显示，基于当前的连接状态
    _showToast(_isConnected ? AppStrings.deviceConnected : AppStrings.deviceNotConnected);
    
    // 如果已连接，加载缓存的设备信息并查询一些基本信息
    if (_isConnected) {
      // 重新加载缓存的设备信息（可能在扫描页面更新了）
      await _loadCachedMacAddress();
      
      _queryBattery();
      _queryDeviceVersion();
    }
  }
  
  void _reconnectDevice() async {
    try {
      debugPrint('Attempting to reconnect device...');
      _showToast(AppStrings.reconnecting);
      
      await _glassesPlugin.reconnect();
      
      _showToast(AppStrings.reconnectCommandSent);
      debugPrint('Reconnect command sent');
    } catch (e) {
      debugPrint('Reconnect failed: $e');
      _showToast(AppStrings.reconnectFailed + ": $e");
    }
  }
  
  void _disconnectDevice() async {
    try {
      await _glassesPlugin.disconnect();
      _showToast(AppStrings.disconnectedSuccess);
    } catch (e) {
      _showToast(AppStrings.disconnectFailed + ": $e");
    }
  }
  
  void _removeDevice() async {
    try {
      await _glassesPlugin.disconnect();
      setState(() {
        _isConnected = false;
        _batteryLevel = AppStrings.unknown;
        _isCharging = false;
        _deviceVersion = AppStrings.unknown;
        _cachedMacAddress = null;  // 清除缓存的 MAC 地址
        _cachedDeviceName = null; // 清除缓存的设备名称
      });
      
      // 清除 MAC 地址缓存
      await MacAddressCache.clearCachedMac();
      
      _showToast(AppStrings.deviceRemovedAndDisconnected);
    } catch (e) {
      _showToast(AppStrings.removeDeviceFailed + ": $e");
    }
  }
  
  void _syncTime() async {
    try {
      await _glassesPlugin.syncTime();
      _showToast(AppStrings.timeSyncSuccess);
    } catch (e) {
      _showToast(AppStrings.timeSyncFailed + ": $e");
    }
  }
  
  void _queryDeviceVersion() async {
    try {
      String version = await _glassesPlugin.queryDeviceVersion(versionType: 1);
      setState(() {
        _actualJlVersion = version;
        _deviceVersion = "${AppStrings.firmwareVersion}: $version";
        _jlVersion = AppStrings.jlVersion(version);
      });
      _showToast(AppStrings.versionQuerySuccess + ": $version");
    } catch (e) {
      _showToast(AppStrings.versionQueryFailed + ": $e");
    }
  }
  
  void _queryBattery() async {
    try {
      Map<String, dynamic> batteryInfo = await _glassesPlugin.queryBattery();
      debugPrint('Battery query returned data: $batteryInfo');
      
      int batteryLevel = 0;
      bool isCharging = false;
      
      // 处理返回的数据
      if (batteryInfo['battery'] != null) {
        batteryLevel = int.tryParse(batteryInfo['battery'].toString()) ?? 0;
      }
      if (batteryInfo['charging'] != null) {
        isCharging = batteryInfo['charging'].toString().toLowerCase() == 'true';
      }
      
      setState(() {
        _actualBatteryLevel = batteryLevel;
        _batteryLevel = AppStrings.batteryDisplay("$batteryLevel", isCharging);
        _isCharging = isCharging;
      });
      
      _showToast(AppStrings.batteryLevelToast("${batteryLevel}%", isCharging));
      
    } catch (e) {
      debugPrint('Battery query exception: $e');
      _showToast(AppStrings.batteryQueryFailed + ": $e");
    }
  }
  
  void _restartDevice() async {
    try {
      bool success = await _glassesPlugin.restart();
      _showToast(success ? AppStrings.deviceRestartSuccess : AppStrings.deviceRestartFailed);
    } catch (e) {
      _showToast(AppStrings.deviceRestartFailed + ": $e");
    }
  }
  
  void _takePhoto({int photoMode = 0}) async {
    try {
      await _glassesPlugin.takePhoto(photoMode: photoMode);
      _showToast(AppStrings.photoCommandSent);
    } catch (e) {
      debugPrint('takePhoto failed: $e');
      _showToast(AppStrings.photoFailed + ": $e");
    }
  }

  // 暂时禁用
  // void _startVideo() async {
  //   try {
  //     await _glassesPlugin.startVideo(fps: 30, maxDuration: 10);
  //   } catch (e) {
  //     _showToast(AppStrings.videoStartFailed + ": $e");
  //   }
  // }

  // 暂时禁用
  // void _stopVideo() async {
  //   try {
  //     await _glassesPlugin.stopVideo();
  //   } catch (e) {
  //     _showToast(AppStrings.videoStopFailed + ": $e");
  //   }
  // }
  
  // 暂时禁用
  // void _queryVideoConfig() async {
  //   try {
  //     Map<String, dynamic> config = await _glassesPlugin.queryVideoConfig();
  //     debugPrint('Retrieved config: $config');
  //
  //     // 安全地获取参数值
  //     final frameRate = config['frameRate'] ?? '未知';
  //     final maxDuration = config['maxDuration'] ?? '未知';
  //
  //     String configStr = AppStrings.videoConfigParams(frameRate, maxDuration);
  //     _showToast(AppStrings.videoParams(configStr));
  //   } catch (e) {
  //     debugPrint('Error getting video parameters: $e');
  //     _showToast(AppStrings.getVideoParamsFailed + ": $e");
  //   }
  // }
  
  void _setVideoConfig() async {
    try {
      // 使用用户选择的录像参数
      Map<String, dynamic> config = {
        "frameRate": _selectedFrameRate,
        "duration": _selectedMaxDuration,  // 注意：iOS端使用 duration 而不是 maxDuration
      };
      // await _glassesPlugin.sendVideoConfig(config); // 暂时禁用
      _showToast("视频配置功能暂时禁用");
      
      String fpsText = _selectedFrameRate == 0 ? AppStrings.notSet : '$_selectedFrameRate fps';
      _showToast(AppStrings.videoParamsSet(fpsText, _selectedMaxDuration));
    } catch (e) {
      _showToast(AppStrings.setVideoParamsFailed + ": $e");
    }
  }
  
  void _sendLanguage() async {
    try {
      await _glassesPlugin.sendLanguage(1); // 1 = 中文
      _showToast(AppStrings.languageSettingsSent);
    } catch (e) {
      _showToast(AppStrings.sendLanguageSettingsFailed + ": $e");
    }
  }
  
  void _resetDevice() async {
    try {
      bool success = await _glassesPlugin.reset();
      _showToast(success ? AppStrings.deviceResetSuccess : AppStrings.deviceResetFailed);
    } catch (e) {
      _showToast(AppStrings.alarmSetFailed + ": $e");
    }
  }
  
  void _shutdownDevice() async {
    try {
      bool success = await _glassesPlugin.shutdown();
      _showToast(success ? AppStrings.deviceShutdownSuccess : AppStrings.deviceShutdownFailed);
    } catch (e) {
      _showToast(AppStrings.deviceShutdownFailed2 + ": $e");
    }
  }
  
  /// 查询佩戴检查状态
  void _queryWearCheckState() async {
    debugPrint('Querying wear check state...');
    try {
      bool state = await _glassesPlugin.getWearCheckState();
      debugPrint('Wear check state: $state');
      setState(() {
        _wearCheckState = state ? AppStrings.enabled : AppStrings.disabled;
      });
      _showToast(AppStrings.wearCheckStateToast(state ? AppStrings.enabled : AppStrings.disabled));
    } catch (e) {
      debugPrint('Query wear check failed: $e');
      _showToast(AppStrings.queryWearCheckFailed + ": $e");
    }
  }
  
  /// 显示佩戴检查设置对话框
  void _showWearCheckDialog() {
    final dialogContext = _materialContext ?? context;
    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        bool enableWearCheck = false;
        return AlertDialog(
          title: Text(AppStrings.setWearCheckState),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppStrings.wearCheckDialogDesc),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return SwitchListTile(
                    title: Text(AppStrings.enableWearCheck),
                    value: enableWearCheck,
                    onChanged: (bool value) {
                      setState(() {
                        enableWearCheck = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  debugPrint('Setting wear check state to: $enableWearCheck');
                  bool success = await _glassesPlugin.setWearCheckState(enable: enableWearCheck);
                  if (success) {
                    _showToast(AppStrings.setWearCheckSuccess);
                    // 重新查询状态
                    _queryWearCheckState();
                  } else {
                    _showToast(AppStrings.setWearCheckFailed);
                  }
                } catch (e) {
                  debugPrint('Set wear check failed: $e');
                  _showToast(AppStrings.setWearCheckFailed + ": $e");
                }
              },
              child: Text(AppStrings.confirm),
            ),
          ],
        );
      },
    );
  }
  
  //endregion

  //region 音频控制方法

  // ==================== 音频控制方法 ====================
  
  /// 设置音频控制状态
  /// 调用 SDK 的 setAudioCtrl 方法，传入用户选择的音频动作类型
  void _startAudio() async {
    try {
      await _glassesPlugin.setAudioControl(actionType: _selectedAudioAction);
      
      String actionText = '';
      switch (_selectedAudioAction) {
        case 1:
          actionText = AppStrings.startAudio;
          break;
        case 2:
          actionText = AppStrings.cancelAudio;
          break;
        case 3:
          actionText = AppStrings.dnsStreamStart;
          break;
        case 4:
          actionText = AppStrings.dnsStreamPause;
          break;
        case 5:
          actionText = AppStrings.dnsStreamStop;
          break;
        case 6:
          actionText = AppStrings.normalStreamStart;
          break;
        case 7:
          actionText = AppStrings.normalStreamPause;
          break;
        case 8:
          actionText = AppStrings.normalStreamStop;
          break;
      }
      
      _showToast(AppStrings.audioControlSet(actionText));
    } catch (e) {
      _showToast(AppStrings.setAudioControlFailed + ": $e");
    }
  }
  
  /// 停止音频
  /// 调用 SDK 的 setAudioCtrl 方法，传入 audioStop
  void _stopAudio() async {
    try {
      await _glassesPlugin.setAudioControl(actionType: 0); // 0 = audioStop
      _showToast(AppStrings.audioStopped);
    } catch (e) {
      _showToast(AppStrings.stopAudioFailed + ": $e");
    }
  }
  
  /// 查询音频状态
  /// 调用 SDK 的 queryAudioState 方法
  void _queryAudioState() async {
    try {
      int state = await _glassesPlugin.queryAudioState();
      String stateText = state == 1 ? AppStrings.inIntercom : AppStrings.notIntercom;
      _showToast(AppStrings.audioStatus(stateText));
    } catch (e) {
      _showToast(AppStrings.queryAudioStateFailed + ": $e");
    }
  }
  
  //endregion

  //region AI功能方法

  // ==================== AI 功能方法 ====================
  
  /// 设置 AI 回复状态
  /// 调用 SDK 的 setAIReplyStatus 方法
  void _setAIReplyStatus() async {
    try {
      await _glassesPlugin.setAIReplyStatus(status: _selectedAIStatus);
      
      String statusText = '';
      switch (_selectedAIStatus) {
        case 0:
          statusText = AppStrings.startAiReply;
          break;
        case 1:
          statusText = AppStrings.completeAiReply;
          break;
        case 2:
          statusText = AppStrings.interruptAiReply;
          break;
      }
      
      _showToast(AppStrings.aiReplyStatusSet(statusText));
    } catch (e) {
      _showToast(AppStrings.setAiReplyStatusFailed + ": $e");
    }
  }
  
  /// 退出语音
  void _exitAIReply() async {
    try {
      await _glassesPlugin.exitAIReply();
      _showToast(AppStrings.exitedVoice);
    } catch (e) {
      _showToast(AppStrings.exitVoiceFailed + ": $e");
    }
  }
  
  // ==================== 文件管理功能方法 ====================
  
  /// 查询文件数量
  /// 调用 SDK 的 getFileCount 方法
  void _queryFileCount() async {
    try {
      int count = await _glassesPlugin.getFileCount();
      _showToast(AppStrings.deviceFileCount(count));
    } catch (e) {
      _showToast(AppStrings.queryFileCountFailed + ": $e");
    }
  }
  
  /// 查询文件同步方式
  /// 调用 SDK 的 getFileSyncType 方法
  void _queryFileSyncType() async {
    try {
      int type = await _glassesPlugin.getFileSyncType();
      String typeStr = type == 0 ? AppStrings.httpGetMode : AppStrings.otherMode;
      _showToast(AppStrings.currentFileSyncMethod(typeStr));
    } catch (e) {
      _showToast(AppStrings.queryFileSyncMethodFailed + ": $e");
    }
  }
  
  /// 删除文件
  /// 调用 SDK 的 deleteFile 方法
  void _deleteMediaFile() async {
    try {
      // 示例：删除一个图片文件
      // 实际使用时应该从文件列表中选择
      bool success = await _glassesPlugin.deleteFile(
        fileType: 1, // 0-删除所有文件, 1-按名称删除, 2-按类型删除
        fileName: "example.jpg",
      );
      if (success) {
        _showToast(AppStrings.deleteFileSuccess);
      } else {
        _showToast(AppStrings.deleteFileFailed);
      }
    } catch (e) {
      _showToast(AppStrings.deleteMediaFileFailed + ": $e");
    }
  }
  
  /// 进入文件同步模式（开启 Wi-Fi）
  /// 调用 SDK 的 setFileSyncModeEnter 方法
  void _setFileSyncModeEnter() async {
    try {
      // 先检查电池电量，低电量时无法进入文件同步模式
      if (_batteryLevel != AppStrings.unknown) {
        // 从电池字符串中提取电量值（格式如 "50" 或 "50%"）
        int batteryValue = int.tryParse(_batteryLevel.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        if (batteryValue < 20) {
          _showToast(AppStrings.lowBatteryWarning(_batteryLevel));
          return;
        }
      }
      
      await _glassesPlugin.enableWifi(wifiType: 0);
      _showToast(AppStrings.enteredFileSyncModeWifiOn);
    } catch (e) {
      _showToast(AppStrings.enterFileSyncModeFailed + ": $e");
    }
  }
  
  /// 退出文件同步模式（关闭 Wi-Fi）
  /// 调用 SDK 的 setFileSyncModeExit 方法
  void _setFileSyncModeExit() async {
    try {
      await _glassesPlugin.disableWifi();
      _showToast(AppStrings.exitedFileSyncModeWifiOff);
    } catch (e) {
      _showToast(AppStrings.exitFileSyncModeFailed + ": $e");
    }
  }
  
  //endregion

  //region 同声传译方法

  // ==================== 同声传译方法 ====================
  
  /// 设置同声传译状态
  /// 调用 SDK 的 setAudioCtrl 方法，传入用户选择的同声传译动作类型
  void _setSimultaneousInterpretation() async {
    try {
      await _glassesPlugin.setAudioControl(actionType: _selectedSimultaneousInterpretationAction);
      
      String actionText = '';
      switch (_selectedSimultaneousInterpretationAction) {
        case 3:
          actionText = AppStrings.startSimultaneousInterpretation;
          setState(() {
            _simultaneousInterpretationStatus = AppStrings.simultaneousInterpretationStarted;
            _translateTotalBytes = 0; // 重置翻译音频累计字节数
            _translateAudioStatus = AppStrings.noTranslationAudio; // 重置状态显示
          });
          break;
        case 4:
          actionText = AppStrings.pauseSimultaneousInterpretation;
          setState(() {
            _simultaneousInterpretationStatus = AppStrings.simultaneousInterpretationPaused;
          });
          break;
        case 5:
          actionText = AppStrings.stopSimultaneousInterpretation;
          setState(() {
            _simultaneousInterpretationStatus = AppStrings.simultaneousInterpretationStopped;
          });
          break;
      }
      
      _showToast(AppStrings.simultaneousInterpretationStatusSet(actionText));
    } catch (e) {
      debugPrint('Set simultaneous interpretation failed: $e');
      _showToast(AppStrings.setSimultaneousInterpretationFailed + ": $e");
    }
  }
  
  //endregion

  //region 音频录音功能方法

  // ==================== 音频录音功能方法 ====================
  
  /// 设置录音控制（开始录音）
  /// 调用 SDK 的 setAudioRecord 方法，传入 Start
  void _startAudioRecord() async {
    try {
      bool success = await _glassesPlugin.setAudioRecord(type: 0); // totalTime 在内部固定为 0
      if (success) {
        _showToast(AppStrings.recordingStarted);
      } else {
        _showToast(AppStrings.startRecordingFailed2);
      }
    } catch (e) {
      _showToast(AppStrings.startRecordingFailed + ": $e");
    }
  }
  
  /// 设置录音控制（停止录音）
  /// 调用 SDK 的 setAudioRecord 方法，传入 Stop
  void _stopAudioRecord() async {
    try {
      bool success = await _glassesPlugin.setAudioRecord(type: 1); // totalTime 在内部固定为 0
      if (success) {
        _showToast(AppStrings.recordingStopped);
      } else {
        _showToast(AppStrings.stopRecordingFailed2);
      }
    } catch (e) {
      _showToast(AppStrings.stopRecordingFailed + ": $e");
    }
  }
  
  /// 获取录音状态
  /// 调用 SDK 的 getAudioRecordState 方法
  void _queryAudioRecordState() async {
    // 设置初始状态为获取中
    setState(() {
      _audioRecordStatus = AppStrings.gettingStatusWithDots;
    });
    
    try {
      // 使用 timeout 设置10秒超时
      Map<String, int> state = await _glassesPlugin.getAudioRecordState()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(AppStrings.sdkTimeoutMessage, const Duration(seconds: 10));
      });
      
      int type = state['type'] ?? 0;
      int totalTime = state['totalTime'] ?? 0;

      String stateText = type == 1 ? AppStrings.recording : AppStrings.notRecording;
      setState(() {
        _audioRecordStatus = "$stateText, ${AppStrings.duration}: ${totalTime}${AppStrings.seconds}";
      });
      _showToast(AppStrings.recordingStatus(stateText, totalTime));
    } on TimeoutException catch (e) {
      setState(() {
        _audioRecordStatus = AppStrings.sdkNotReturned;
      });
      _showToast(AppStrings.queryRecordStatusTimeout + ": $e");
    } catch (e) {
      // 显示SDK返回的错误信息
      String errorMsg = e.toString();
      // 检查多种错误模式
      if (errorMsg.contains(AppStrings.undefinedCommand) || 
          errorMsg.contains("Unknown") ||
          errorMsg.contains("CRPACKError") ||
          errorMsg.contains("rawValue: 1")) {
        setState(() {
          _audioRecordStatus = AppStrings.deviceNotSupported;
        });
      } else {
        setState(() {
          _audioRecordStatus = AppStrings.getFailed;
        });
      }
      _showToast(AppStrings.getRecordStatusFailed + ": $e");
    }
  }
  
  //endregion

  //region 用户信息和设置方法

  // ==================== 用户信息和设置方法 ====================
  
  /// 设置用户信息
  /// 调用 SDK 的 setUserInfo 方法
  void _setUserInfo() async {
    try {
      // 示例用户信息
      Map<String, dynamic> userInfo = {
        'gender': false,      // 性别：false-男，true-女
        'age': 25,            // 年龄
        'height': 175,        // 身高(cm)
        'weight': 70,         // 体重(kg)
      };
      
      // bool success = await _glassesPlugin.setUserInfo(userInfo); // 已移除
      _showToast("设置用户信息功能已移除");
      /*
      if (success) {
        _showToast(AppStrings.userInfoSetSuccess);
      } else {
        _showToast(AppStrings.userInfoSetFailed);
      }
      */
    } catch (e) {
      _showToast(AppStrings.setUserInfoFailed + ": $e");
    }
  }
  
  /// 设置闹钟
  /// 调用 SDK 的 setAlarm 方法
  void _setAlarm() async {
    try {
      // 示例闹钟设置：早上7:30，重复
      Map<String, dynamic> alarmInfo = {
        'enable': true,       // 启用闹钟
        'hour': 7,           // 小时
        'minute': 30,        // 分钟
        'repeat': 1,         // 重复：0-单次，1-每天
      };
      
      // bool success = await _glassesPlugin.setAlarm(alarmInfo); // 已移除
      _showToast("设置闹钟功能已移除");
      /*
      if (success) {
        _showToast(AppStrings.alarmSetSuccess);
      } else {
        _showToast(AppStrings.alarmSetFailed);
      }
      */
    } catch (e) {
      _showToast(AppStrings.setAlarmFailed + ": $e");
    }
  }
  
  /// 获取语言设置
  /// 调用 SDK 的 getLanguage 方法
  void _getLanguage() async {
    // 设置初始状态为获取中
    setState(() {
      _actualLanguageStatus = AppStrings.gettingStatusWithDots;
      _languageStatus = AppStrings.gettingStatusWithDots;
    });
    
    try {
      // 使用 timeout 设置10秒超时
      // String language = await _glassesPlugin.getLanguage() // 已移除
      //     .timeout(const Duration(seconds: 10), onTimeout: () {
      //   throw TimeoutException(AppStrings.sdkTimeoutMessage, const Duration(seconds: 10));
      // });
      
      _showToast("获取语言功能已移除");
      return;
      
      /*
      setState(() {
        _actualLanguageStatus = language;
        _languageStatus = language;
      });
      _showToast(AppStrings.currentLanguage(language));
      */
    } on TimeoutException catch (e) {
      setState(() {
        _actualLanguageStatus = AppStrings.sdkNotReturned;
        _languageStatus = AppStrings.sdkNotReturned;
      });
      _showToast(AppStrings.getLanguageTimeout + ": $e");
    } catch (e) {
      // 显示SDK返回的错误信息
      String errorMsg = e.toString();
      if (errorMsg.contains('device not support')) {
        setState(() {
          _actualLanguageStatus = AppStrings.deviceNotSupportedFeature;
          _languageStatus = AppStrings.deviceNotSupportedFeature;
        });
        _showToast(AppStrings.getFailed + ": $e");
      } else {
        setState(() {
          _actualLanguageStatus = AppStrings.getFailed;
          _languageStatus = AppStrings.getFailed;
        });
        _showToast(AppStrings.getLanguageFailed + ": $e");
      }
    }
  }
  
  //endregion

  //region 直播功能方法

  // ==================== 直播功能方法 ====================
  
  /// 进入直播模式
  /// 调用 SDK 的 setLiveStreamEnter 方法
  void _enterLiveStream() async {
    try {
      // 默认使用 AP 模式（0）
      // bool success = await _glassesPlugin.enterLiveStream(wifiType: 0); // 已移除
      _showToast("直播功能已移除");
      /*
      if (success) {
        _showToast(AppStrings.enteredLiveModeAp);
      } else {
        _showToast(AppStrings.enterLiveModeFailed2);
      }
      */
    } catch (e) {
      _showToast(AppStrings.enterLiveModeFailed + ": $e");
    }
  }
  
  /// 退出直播模式
  /// 调用 SDK 的 setLiveStreamExit 方法
  void _exitLiveStream() async {
    try {
      // bool success = await _glassesPlugin.exitLiveStream(); // 已移除
      _showToast("直播功能已移除");
      /*
      if (success) {
        _showToast(AppStrings.exitedLiveMode);
      } else {
        _showToast(AppStrings.exitLiveModeFailed2);
      }
      */
    } catch (e) {
      _showToast(AppStrings.exitLiveModeFailed + ": $e");
    }
  }
  
  //endregion

  //region 设备管理功能方法

  // ==================== 设备管理功能方法 ====================
  
  /// 清除配对信息
  /// 调用 SDK 的 clearPairInfo 方法
  void _clearPairInfo() async {
    try {
      bool success = await _glassesPlugin.clearPairInfo();
      if (success) {
        // 清除 MAC 地址缓存
        setState(() {
          _cachedMacAddress = null;
          _cachedDeviceName = null;
        });
        await MacAddressCache.clearCachedMac();
        
        _showToast(AppStrings.clearedPairInfo);
      } else {
        _showToast(AppStrings.clearPairInfoFailed2);
      }
    } catch (e) {
      _showToast(AppStrings.clearPairInfoFailed + ": $e");
    }
  }
  
  /// 获取设备UUID
  /// 调用 SDK 的 getDeviceUUID 方法
  void _getDeviceUUID() async {
    // 设置初始状态为获取中
    setState(() {
      _actualDeviceUUIDStatus = AppStrings.gettingStatus;
      _deviceUUIDStatus = AppStrings.gettingStatus;
    });
    
    try {
      // 使用 timeout 设置10秒超时
      String uuid = await _glassesPlugin.getDeviceUUID()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(AppStrings.sdkTimeoutMessage, const Duration(seconds: 10));
      });
      
      setState(() {
        _actualDeviceUUIDStatus = uuid;
        _deviceUUIDStatus = uuid;
      });
      _showToast(AppStrings.deviceUuid(uuid));
    } on TimeoutException catch (e) {
      setState(() {
        _actualDeviceUUIDStatus = AppStrings.sdkNotReturned;
        _deviceUUIDStatus = AppStrings.sdkNotReturned;
      });
      _showToast(AppStrings.getDeviceUuidTimeout + ": $e");
    } catch (e) {
      // 显示SDK返回的错误信息
      String errorMsg = e.toString();
      if (errorMsg.contains('device not support')) {
        setState(() {
          _actualDeviceUUIDStatus = AppStrings.deviceNotSupported;
          _deviceUUIDStatus = AppStrings.deviceNotSupported;
        });
        _showToast(AppStrings.getFailed + ": $e");
      } else {
        setState(() {
          _actualDeviceUUIDStatus = AppStrings.getFailed;
          _deviceUUIDStatus = AppStrings.getFailed;
        });
        _showToast(AppStrings.getDeviceUuidFailed + ": $e");
      }
    }
  }
  
  /// 获取语音唤醒状态
  /// 调用 SDK 的 readVoiceWakeupState 方法
  void _getVoiceWakeupState() async {
    // 设置初始状态为获取中
    setState(() {
      _actualVoiceWakeupStatus = AppStrings.gettingStatusWithDots;
      _voiceWakeupStatus = AppStrings.gettingStatusWithDots;
    });
    
    try {
      // 使用 timeout 设置10秒超时
      bool isEnabled = await _glassesPlugin.getVoiceWakeupState()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(AppStrings.sdkTimeoutMessage, const Duration(seconds: 10));
      });
      
      String statusText = isEnabled ? AppStrings.enabled : AppStrings.disabled;
      setState(() {
        _actualVoiceWakeupStatus = statusText;
        _voiceWakeupStatus = statusText;
      });
      
      _showToast(AppStrings.voiceWakeupStatus(isEnabled ? AppStrings.enabled : AppStrings.disabled));
    } catch (e) {
      debugPrint('Voice wakeup state exception: $e');
      // 显示SDK返回的错误信息
      String errorMsg = e.toString();
      // 检查多种错误模式
      if (errorMsg.contains(AppStrings.undefinedCommand) || 
          errorMsg.contains("Unknown") ||
          errorMsg.contains("CRPACKError")) {
        setState(() {
          _voiceWakeupStatus = AppStrings.deviceNotSupportedFeature;
        });
      } else {
        setState(() {
          _voiceWakeupStatus = AppStrings.notSupportedOrError;
        });
      }
      _showToast(AppStrings.voiceWakeupMayNotSupport + ": $e");
    }
  }
  
  /// 设置语音唤醒
  /// 调用 SDK 的 setVoiceWakeup 方法
  void _setVoiceWakeup() async {
    try {
      // SDK 定义：0=TypeOn(开启)，1=TypeOff(关闭)
      bool enable = _selectedVoiceWakeupAction == 0;
      
      await _glassesPlugin.setVoiceWakeup(enable: enable);
      _showToast(AppStrings.voiceWakeupSet(enable ? AppStrings.enabled : AppStrings.disabled));
      
      // 设置完成后重新获取状态
      _getVoiceWakeupState();
    } catch (e) {
      _showToast(AppStrings.setVoiceWakeupFailed + ": $e");
    }
  }
  
  /// 获取运行状态
  /// 调用 SDK 的 readRunningStatus 方法
  void _getRunningStatus() async {
    // 设置初始状态为获取中
    setState(() {
      _actualRunningStatus = AppStrings.gettingStatusWithDots;
      _runningStatus = AppStrings.gettingStatusWithDots;
    });
    
    try {
      // 使用 timeout 设置10秒超时
      String status = await _glassesPlugin.getRunningStatus()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(AppStrings.sdkTimeoutMessage, const Duration(seconds: 10));
      });
      
      setState(() {
        _actualRunningStatus = status;
        _runningStatus = status;
      });
      
      _showToast(AppStrings.runningStatus(status));
    } catch (e) {
      debugPrint('Running status exception: $e');
      setState(() {
        _actualRunningStatus = AppStrings.deviceNotSupportedFeature2;
        _runningStatus = AppStrings.deviceNotSupportedFeature2;
      });
      _showToast(AppStrings.getFailed + ": $e");
    }
  }
  
  //endregion

  //region 版本查询方法

  /// 获取杰里版本号
  Future<void> _getJLVersion() async {
    setState(() {
      _jlVersion = AppStrings.gettingStatusWithDots;
    });
    
    try {
      String version = await _glassesPlugin.getJLVersion()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(AppStrings.sdkTimeoutMessage, const Duration(seconds: 10));
      });
      
      setState(() {
        _actualJlVersion = version;
        _jlVersion = AppStrings.jlVersion(version);
      });
      _showToast(AppStrings.jlVersion(version));
    } on TimeoutException catch (e) {
      setState(() {
        _jlVersion = AppStrings.sdkNotReturned;
      });
      _showToast(AppStrings.getJlVersionTimeout + ": $e");
    } catch (e) {
      setState(() {
        _jlVersion = AppStrings.getFailed;
      });
      _showToast(AppStrings.getJlVersionFailed + ": $e");
    }
  }
  
  /// 获取影像系统版本号
  Future<void> _getQZVersion() async {
    debugPrint('_getQZVersion: 开始获取影像系统版本');
    setState(() {
      _qzVersion = AppStrings.gettingStatusWithDots;
    });
    
    try {
      debugPrint('_getQZVersion: 调用 getQZVersion 方法');
      String version = await _glassesPlugin.getQZVersion()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint('_getQZVersion: 超时');
        throw TimeoutException(AppStrings.sdkTimeoutMessage, const Duration(seconds: 10));
      });
      
      debugPrint('_getQZVersion: 获取到版本: $version');
      
      // 检查版本是否为空
      if (version.isEmpty || version == 'null' || version == 'N/A') {
        debugPrint('_getQZVersion: 版本为空或无效');
        setState(() {
          _actualQzVersion = version;
          _qzVersion = AppStrings.deviceNotSupportedFeature2; // 显示"设备不支持"
        });
        _showToast(AppStrings.deviceNotSupportedFeature2);
      } else {
        setState(() {
          _actualQzVersion = version;
          _qzVersion = AppStrings.qzVersion(version);
        });
        _showToast(AppStrings.qzVersion(version));
      }
    } on TimeoutException catch (e) {
      debugPrint('_getQZVersion: TimeoutException: $e');
      setState(() {
        _qzVersion = AppStrings.sdkNotReturned;
      });
      _showToast(AppStrings.getQzVersionTimeout + ": $e");
    } catch (e) {
      debugPrint('_getQZVersion: Exception: $e');
      setState(() {
        _qzVersion = AppStrings.getFailed;
      });
      _showToast(AppStrings.getQzVersionFailed + ": $e");
    }
  }
  
  /// 获取TP版本号
  Future<void> _getTPVersion() async {
    debugPrint('_getTPVersion: 开始获取TP版本');
    setState(() {
      _tpVersion = AppStrings.gettingStatusWithDots;
    });
    
    try {
      debugPrint('_getTPVersion: 调用 getTPVersion 方法');
      String version = await _glassesPlugin.getTPVersion()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint('_getTPVersion: 超时');
        throw TimeoutException(AppStrings.sdkTimeoutMessage, const Duration(seconds: 10));
      });
      
      debugPrint('_getTPVersion: 获取到版本: $version');
      
      // 检查版本是否为空
      if (version.isEmpty || version == 'null' || version == 'N/A') {
        debugPrint('_getTPVersion: 版本为空或无效');
        setState(() {
          _tpVersion = AppStrings.deviceNotSupportedFeature2; // 显示"设备不支持"
        });
        _showToast(AppStrings.deviceNotSupportedFeature2);
      } else {
        setState(() {
          _tpVersion = 'TP版本: $version';
        });
        _showToast('TP版本: $version');
      }
    } on TimeoutException catch (e) {
      debugPrint('_getTPVersion: TimeoutException: $e');
      setState(() {
        _tpVersion = AppStrings.sdkNotReturned;
      });
      _showToast('获取TP版本超时: $e');
    } catch (e) {
      debugPrint('_getTPVersion: Exception: $e');
      setState(() {
        _tpVersion = AppStrings.getFailed;
      });
      _showToast('获取TP版本失败: $e');
    }
  }
  
  /// 获取Git哈希版本号
  Future<void> _getGithashVersion() async {
    setState(() {
      _githashVersion = AppStrings.gettingStatusWithDots;
    });
    
    try {
      String version = await _glassesPlugin.getGithashVersion()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(AppStrings.sdkTimeoutMessage, const Duration(seconds: 10));
      });
      
      setState(() {
        _githashVersion = version;
      });
      _showToast(AppStrings.githashVersion(version));
    } on TimeoutException catch (e) {
      setState(() {
        _githashVersion = AppStrings.sdkNotReturned;
      });
      _showToast(AppStrings.getGithashVersionTimeout + ": $e");
    } catch (e) {
      setState(() {
        _githashVersion = AppStrings.getFailed;
      });
      _showToast(AppStrings.getGithashVersionFailed + ": $e");
    }
  }
  //endregion

  //region 辅助方法

  void _showToast(String message) {
    ToastUtil.showToast(message);
  }

  // ==================== OTA 升级功能方法 ====================
  
  /// 检查最新版本
  void _checkLatestVersion() async {
    setState(() {
      _checkVersionResult = AppStrings.checkingLatestVersion;
    });
    
    try {
      // 先获取当前版本信息
      await _getJLVersion();
      await _getQZVersion();
      
      // 检查固件版本
      if (_jlVersion == AppStrings.unknown || _jlVersion.isEmpty) {
        setState(() {
          _checkVersionResult = AppStrings.jlVersionMissing;
        });
        _showToast(AppStrings.jlVersionMissing);
        return;
      }
      
      // 检查影像系统版本
      if (_qzVersion == AppStrings.unknown || _qzVersion.isEmpty) {
        setState(() {
          _checkVersionResult = AppStrings.qzVersionMissing;
        });
        _showToast(AppStrings.qzVersionMissing);
        return;
      }
      
      // 检查MAC地址
      String mac = _cachedMacAddress ?? "00:00:00:00:00:00";
      if (mac == "00:00:00:00:00:00" || mac.isEmpty) {
        setState(() {
          _checkVersionResult = AppStrings.connectDeviceForMac;
        });
        _showToast(AppStrings.connectDeviceForMac);
        return;
      }
      
      // _showToast(AppStrings.checkingLatestVersion);
      
      Map<String, dynamic> result = await _glassesPlugin.checkLatestVersion(
        fw1Ver: _jlVersion,
        fw2Ver: _qzVersion,
        mac: mac,
      );
      
      // 处理结构化的返回结果
      String status = result['status'] ?? 'unknown';
      String messageKey = result['message'] ?? 'unknown';
      bool hasUpdate = result['hasUpdate'] ?? false;
      
      // 根据消息键获取国际化文本
      String localizedMessage = _getLocalizedMessage(messageKey);
      _showToast(localizedMessage);
      
      // 更新检查结果状态
      setState(() {
        _checkVersionResult = localizedMessage;
      });
      
      // 如果有更新，显示更多详细信息
      if (hasUpdate && result['latestVersion'] != null) {
        Map<String, dynamic> latestVersion = result['latestVersion'];
        String firmwareVer = latestVersion['firmwareVer'] ?? '';
        String firmwareFile = latestVersion['firmwareFile'] ?? '';
        int firmwareSize = latestVersion['firmwareSize'] ?? 0;
        String firmwareMd5 = latestVersion['firmwareMd5'] ?? '';
        
        debugPrint('发现新版本: $firmwareVer');
        debugPrint('固件文件: $firmwareFile');
        debugPrint('固件大小: ${(firmwareSize / 1024 / 1024).toStringAsFixed(2)} MB');
        debugPrint('MD5校验: $firmwareMd5');
        
        // 可以在这里添加更新提示对话框
        _showUpdateDialog(latestVersion);
      } else if (status == 'error' && result['error'] != null) {
        Map<String, dynamic> error = result['error'];
        debugPrint('检查版本错误: ${error['message']}');
      }
    } catch (e) {
      setState(() {
        _checkVersionResult = AppStrings.checkVersionFailed;
      });
      _showToast(AppStrings.checkVersionFailed + ": $e");
    }
  }
  
  /// 根据消息键获取国际化文本
  String _getLocalizedMessage(String messageKey) {
    switch (messageKey) {
      case 'update_available':
        return AppStrings.updateAvailable;
      case 'already_latest':
        return AppStrings.alreadyLatest;
      case 'check_failed':
        return AppStrings.checkFailed;
      default:
        return AppStrings.checkVersionFailed; // 默认错误消息
    }
  }

  /// 显示更新提示对话框
  void _showUpdateDialog(Map<String, dynamic> latestVersion) {
    String firmwareVer = latestVersion['firmwareVer'] ?? '';
    String firmwareFile = latestVersion['firmwareFile'] ?? '';
    int type = latestVersion['type'] ?? 0;
    int firmwareNum = latestVersion['firmwareNum'] ?? 0;
    String firmwareMd5 = latestVersion['firmwareMd5'] ?? '';
    int firmwareSize = latestVersion['firmwareSize'] ?? 0;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('发现新版本 $firmwareVer'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('固件版本: $firmwareVer', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                if (firmwareFile.isNotEmpty) ...[
                  Text('固件文件: $firmwareFile'),
                  SizedBox(height: 8),
                ],
                Text('固件类型: $type'),
                SizedBox(height: 8),
                Text('固件编号: $firmwareNum'),
                SizedBox(height: 8),
                if (firmwareSize > 0) ...[
                  Text('固件大小: ${(firmwareSize / 1024 / 1024).toStringAsFixed(2)} MB'),
                  SizedBox(height: 8),
                ],
                if (firmwareMd5.isNotEmpty) ...[
                  Text('MD5校验:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  SelectableText(firmwareMd5, style: TextStyle(fontSize: 12, color: Colors.blue)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('稍后更新'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: 启动OTA升级流程
                _showToast('OTA升级功能开发中...');
              },
              child: Text('立即更新'),
            ),
          ],
        );
      },
    );
  }

  /// 启动杰里OTA升级
  void _startJLOTA() async {
    _showToast(AppStrings.selectFirmwareFile);
    
    // TODO: 实现文件选择功能
    // 这里暂时使用模拟路径
    String firmwarePath = "/path/to/firmware.bin";
    
    try {
      bool success = await _glassesPlugin.startJLOTA(path: firmwarePath);
      if (success) {
        _showToast(AppStrings.jlOtaStarted);
        // TODO: 显示升级进度
      } else {
        _showToast(AppStrings.jlOtaStartFailed);
      }
    } catch (e) {
      _showToast("${AppStrings.jlOtaStartFailed}: $e");
    }
  }
  
  /// 启动全志OTA升级
  void _startQZOTA() async {
    _showToast(AppStrings.qzOtaNotImplemented);
  }
  
  /// 取消杰里OTA升级（仅适用于杰里芯片）
  /// 注意：全志OTA升级无法取消
  void _cancelOTA() async {
    try {
      _showToast(AppStrings.cancellingOta);
      bool success = await _glassesPlugin.cancelJLOTA();
      if (success) {
        _showToast(AppStrings.otaCancelled);
      } else {
        _showToast(AppStrings.cancelOtaFailed);
      }
    } catch (e) {
      _showToast("${AppStrings.cancelOtaFailed}: $e");
    }
  }
  
  //endregion
}
