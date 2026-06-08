import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:moyoung_glasses_ble_plugin/moyoung_glasses_ble.dart';
import 'package:moyoung_glasses_ble_plugin/impl/moyoung_glasses_beans.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit/src/player/native/player/real.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../utils/toast_util.dart';

/// 媒体文件管理页面
class MediaFilePage extends StatefulWidget {
  final MoYoungGlassesBle glassesPlugin;

  const MediaFilePage({
    Key? key,
    required this.glassesPlugin,
  }) : super(key: key);

  @override
  State<MediaFilePage> createState() => _MediaFilePageState();
}

class _MediaFilePageState extends State<MediaFilePage> {
  // 状态管理
  bool _isWifiEnabled = false; // Wi-Fi 是否连接成功
  bool _isFileSyncEnabled = false; // 是否进入文件同步模式
  bool _isLiveMode = false; // Wi-Fi 是否为直播模式
  List<MediaFileBean> _files = [];
  Set<String> _selectedFiles = {};
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadPath = '';
  String _activeDownloadDebugSessionId = '';
  List<File> _localDownloadedFiles = [];
  bool _isLocalFilesLoading = false;

  // BLE 文件数量统计（来自 getFileCount）
  int _bleTotal = 0;
  int _blePicture = 0;
  int _bleVideo = 0;
  int _bleAudio = 0;

  // Wi-Fi 连接状态
  String _wifiConnectionStatus = ''; // 使用国际化字符串动态显示
  bool _isWifiConnecting = false; // Wi-Fi 连接 loading 状态
  bool _pendingConnectAfterFileSync = false; // 等待 fileSync=true 后再连接设备Wi-Fi
  String? _targetSsid;
  String? _targetPassword;

  // 流订阅
  StreamSubscription<Map<String, dynamic>>? _actionResultSubscription;
  StreamSubscription<Map<String, dynamic>>? _runningStatusSubscription;
  StreamSubscription<MediaFileBean>? _mediaFileSubscription;
  StreamSubscription<Map<String, dynamic>>? _mediaFileCountSubscription;
  StreamSubscription<String>? _liveUrlSubscription;

  // 直播状态
  bool _isLiveActive = false;
  String _liveUrl = '';
  // media_kit 播放器
  Player? _player;
  VideoController? _videoController;

  @override
  void initState() {
    super.initState();
    print('MediaFilePage initState 被调用');

    // media_kit 播放器初始化（加上 rtsp 协议白名单 + ready 回调设置 RTSP 选项）
    _player = Player(
      configuration: PlayerConfiguration(
        protocolWhitelist: [
          'udp',
          'rtp',
          'tcp',
          'tls',
          'data',
          'file',
          'http',
          'https',
          'crypto',
          'rtsp'
        ],
        ready: () {
          // mpv 初始化完成后才能设置属性
          final native = _player?.platform as NativePlayer?;
          if (native != null) {
            // 强制 RTSP 走 TCP，避免 UDP send failed 导致卡帧
            native.setProperty('rtsp-transport', 'tcp');
            // 极低延迟缓存
            native.setProperty('demuxer-max-bytes', '1048576');
            native.setProperty('demuxer-max-back-bytes', '524288');
            print('media_kit: RTSP 选项已设置（rtsp-transport=tcp）');
          }
        },
      ),
    );
    _videoController = VideoController(_player!);

    _initializePage();
  }

  String _getFileSyncStatusText() {
    return _isFileSyncEnabled ? AppStrings.entered : AppStrings.notEntered;
  }

  Color _getFileSyncStatusColor() {
    return _isFileSyncEnabled ? Colors.blue : Colors.grey;
  }

  String _getWifiConnectionStatusText() {
    if (_isWifiConnecting || _wifiConnectionStatus == 'connecting') {
      return AppStrings.connectingStatus;
    }
    if (_wifiConnectionStatus == 'connected') {
      return AppStrings.connectedSimple;
    }
    return AppStrings.notConnected;
  }

  Color _getWifiConnectionStatusColor() {
    if (_isWifiConnecting || _wifiConnectionStatus == 'connecting') {
      return Colors.orange;
    }
    if (_wifiConnectionStatus == 'connected') {
      return Colors.green;
    }
    return Colors.grey;
  }

  Widget _buildStatusTag({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _closeWifiBeforeDispose();
    _actionResultSubscription?.cancel();
    _runningStatusSubscription?.cancel();
    _mediaFileSubscription?.cancel();
    _mediaFileCountSubscription?.cancel();
    _liveUrlSubscription?.cancel();
    _disposePlayer();
    _player?.dispose();
    super.dispose();
  }

  /// 页面销毁前尝试关闭 Wi-Fi，避免页面退出后设备热点仍保持开启
  void _closeWifiBeforeDispose() {
    _pendingConnectAfterFileSync = false;

    final shouldCloseWifi = _isWifiEnabled ||
        _isFileSyncEnabled ||
        _isLiveMode ||
        _wifiConnectionStatus != 'disconnected';
    if (!shouldCloseWifi) return;

    // 如果是直播模式，先停止直播再关闭 Wi-Fi
    if (_isLiveMode) {
      _disposePlayer();
      widget.glassesPlugin.stopLive().catchError((e) {
        print('MediaFilePage dispose: 停止直播失败: $e');
      });
    }

    widget.glassesPlugin.disableWifi().then((_) {
      print('MediaFilePage dispose: 已触发关闭 Wi-Fi');
    }).catchError((error) {
      print('MediaFilePage dispose: 关闭 Wi-Fi 失败: $error');
    });
  }

  /// 初始化页面
  Future<void> _initializePage() async {
    // 先订阅事件，避免初始化耗时阶段错过原生早期事件
    _subscribeToEvents();
    _subscribeMediaFileChange();

    // 预防性调用：如果设备之前处于直播模式且由于App异常退出未正常停止，调用 stopLive 进行状态重置
    widget.glassesPlugin.stopLive().catchError((e) {
      print('MediaFilePage initState: 预防性停止直播失败: $e');
    });

    // 加载用户自定义的 Wi-Fi 设置
    final prefs = await SharedPreferences.getInstance();
    _targetSsid = prefs.getString('custom_wifi_ssid') ?? 'Glass-01';
    _targetPassword = prefs.getString('custom_wifi_password') ?? '12345678';

    await _checkPermissions();
    await _getDownloadDirectory();
    await _loadLocalDownloadedFiles();
    print('等待运行状态事件更新...');
    _queryBleFileCount(reason: 'page_init');

    // 初始化 Wi-Fi 连接状态
    setState(() {
      _wifiConnectionStatus = 'disconnected';
    });
  }

  /// 下载全部文件
  Future<void> _downloadFiles() async {
    final int estimatedFileCount = _bleTotal > 0 ? _bleTotal : _files.length;
    if (estimatedFileCount <= 0) {
      print('下载被阻止：当前可下载文件数为 0');
      ToastUtil.showToast(AppStrings.noDownloadableFiles);
      return;
    }

    if (!_isWifiEnabled) {
      print('下载被阻止：设备 Wi-Fi 尚未连接成功');
      ToastUtil.showToast(AppStrings.connectWifiBeforeDownload);
      return;
    }

    if (_downloadPath.isEmpty) {
      ToastUtil.showToast(AppStrings.unableToGetDownloadDir);
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _activeDownloadDebugSessionId =
          'ui-${DateTime.now().millisecondsSinceEpoch}';
    });

    try {
      print(
          '开始调用SDK下载: uiSession=$_activeDownloadDebugSessionId, 预估文件数=$estimatedFileCount, '
          '导入前计数 total=$_bleTotal, picture=$_blePicture, video=$_bleVideo, audio=$_bleAudio, '
          'wifi=$_isWifiEnabled, fileSync=$_isFileSyncEnabled, path=$_downloadPath');
      final result = await widget.glassesPlugin
          .downloadMediaFilesToDir(targetDir: _downloadPath)
          .timeout(const Duration(seconds: 90), onTimeout: () {
        print('下载调用超时：90秒未完成，自动结束本次下载状态');
        return {
          'success': false,
          'message': AppStrings.downloadTimeoutRetry,
          'successCount': 0,
          'failCount': estimatedFileCount,
        };
      });

      final successCount =
          result['successCount'] is int ? result['successCount'] as int : 0;
      final failCount = result['failCount'] is int
          ? result['failCount'] as int
          : (estimatedFileCount - successCount);
      final message = (result['message'] ?? '').toString();
      final nativeSessionId = (result['debugSessionId'] ?? '').toString();

      if (!mounted) return;
      setState(() {
        _downloadProgress = 1.0;
        _selectedFiles.clear();
      });

      print(
          '下载结果返回: uiSession=$_activeDownloadDebugSessionId, nativeSession=$nativeSessionId, '
          'successCount=$successCount, failCount=$failCount, message=$message, rawResult=$result');

      await _loadLocalDownloadedFiles();
      // 下载后延迟查询，给 SDK 内部删除设备端文件留出时间
      await Future.delayed(const Duration(seconds: 2));
      await _queryBleFileCount(reason: 'post_download_delay');

      if (failCount == 0) {
        ToastUtil.showToast(AppStrings.downloadCompletedCount(successCount));
      } else {
        print(
            '下载有失败项: successCount=$successCount, failCount=$failCount, message=$message');
        ToastUtil.showToast(AppStrings.downloadCompletedWithFailure(
            successCount, failCount, message));
      }

      // 下载完成后重置 Wi-Fi 和文件同步状态
      setState(() {
        _isWifiEnabled = false;
        _isFileSyncEnabled = false;
      });
      print('下载完成，已重置 Wi-Fi 和文件同步状态');
    } catch (e) {
      print('下载失败: uiSession=$_activeDownloadDebugSessionId, error=$e');
      ToastUtil.showToast(AppStrings.downloadFailedWithError('$e'));
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _activeDownloadDebugSessionId = '';
        });
      }
    }
  }

  /// 检查权限
  Future<void> _checkPermissions() async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    } catch (e) {
      print('权限检查失败，已跳过: $e');
    }
  }

  /// 获取下载目录
  Future<void> _getDownloadDirectory() async {
    try {
      final appSupportDir = await getApplicationSupportDirectory();
      final downloadDir =
          Directory(path.join(appSupportDir.path, 'moyoung_media_downloads'));
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      setState(() {
        _downloadPath = downloadDir.path;
      });
    } catch (e) {
      print('获取下载目录失败，使用默认路径: $e');
      // 设置一个默认路径，避免阻塞初始化
      setState(() {
        _downloadPath = '/tmp/MoYoungGlasses';
      });
    }
  }

  /// 订阅事件
  void _subscribeToEvents() {
    // 防止重复进入页面或重复初始化导致多次订阅
    _actionResultSubscription?.cancel();
    _runningStatusSubscription?.cancel();
    _mediaFileSubscription?.cancel();
    _liveUrlSubscription?.cancel();

    // 监听直播 URL（只保存，不自动播放，由用户点击开始直播触发）
    _liveUrlSubscription = widget.glassesPlugin.liveUrlEveStm.listen((url) {
      print('收到直播 URL: $url');
      if (url.isNotEmpty) {
        setState(() {
          _liveUrl = url;
        });
      }
    });

    // 监听操作结果
    _actionResultSubscription =
        widget.glassesPlugin.actionResultEveStm.listen((data) async {
      int code = data['code'] ?? -1;
      String msg = data['msg'] ?? '';
      String? action = data['action'];

      // 处理 Wi-Fi 连接结果
      if (action == 'wifi_connection') {
        final status = (data['status'] ?? '').toString();
        final message = (data['message'] ?? msg).toString();

        if (status.isEmpty) {
          print('⚠️ 收到 wifi_connection 事件但缺少 status，忽略: $data');
          return;
        }

        if (status == 'prompt') {
          if (_isWifiEnabled || _wifiConnectionStatus == 'connected') {
            print('ℹ️ 已连接成功，忽略后续 prompt 事件');
            return;
          }
          // 系统弹出提示
          print('📱 系统已弹出 Wi-Fi 连接提示');
          setState(() {
            _wifiConnectionStatus = 'connecting';
          });
          ToastUtil.showToast(
              message.isNotEmpty ? message : AppStrings.wifiJoinPrompt);
        } else if (status == 'configured') {
          if (_isWifiEnabled || _wifiConnectionStatus == 'connected') {
            print('ℹ️ 已连接成功，忽略后续 configured 事件');
          } else {
            // 注意：此状态目前只有 iOS 会发送（NEHotspotConfiguration 配置成功后）
            // Android 不会发送此状态
            print('⚙️ Wi-Fi 配置已应用');
            setState(() {
              _wifiConnectionStatus = 'connecting';
            });
            ToastUtil.showToast(message.isNotEmpty
                ? message
                : AppStrings.wifiConfigAppliedPrompt);
          }
        } else if (status == 'success') {
          print('✅ 设备 Wi-Fi 连接成功');
          setState(() {
            _wifiConnectionStatus = 'connected';
            _isWifiEnabled = true;
            _isWifiConnecting = false; // 取消 loading
          });

          _queryBleFileCount(reason: 'wifi_connection_success');

          ToastUtil.showToast(
              message.isNotEmpty ? message : AppStrings.deviceWifiConnected);
        } else if (status == 'error' ||
            status == 'failed' ||
            status == 'disconnected') {
          print('❌ 设备 Wi-Fi 连接失败: $message');
          setState(() {
            _wifiConnectionStatus = 'disconnected';
            _isWifiEnabled = false;
            _isWifiConnecting = false; // 取消 loading
          });
          ToastUtil.showToast(AppStrings.deviceWifiConnectFailed(message));
        } else {
          print('ℹ️ 未处理的 wifi_connection 状态: $status');
        }
        return;
      }

      // 处理下载进度事件
      if (action == 'media_download_progress') {
        final int current = (data['current'] as num?)?.toInt() ?? 0;
        final int total = (data['total'] as num?)?.toInt() ?? 0;
        final String stage = (data['stage'] ?? '').toString();
        final String nativeSessionId =
            (data['debugSessionId'] ?? '').toString();

        if (mounted && total > 0) {
          setState(() {
            _downloadProgress = (current / total).clamp(0.0, 1.0);
          });
        }

        print(
            '下载进度事件: uiSession=$_activeDownloadDebugSessionId, nativeSession=$nativeSessionId, '
            'stage=$stage, current=$current, total=$total');

        if (stage == 'completed') {
          print(
              '媒体下载任务完成: uiSession=$_activeDownloadDebugSessionId, nativeSession=$nativeSessionId, '
              'current=$current, total=$total');
          if (mounted) {
            setState(() {
              _downloadProgress = 1.0;
            });
          }
        }
        return;
      }

      // 处理其他操作结果
      if (code == 0) {
        ToastUtil.showToast(AppStrings.wifiEnabled);
        print('Wi-Fi 开启成功，请继续连接设备热点');
      } else {
        ToastUtil.showToast('${AppStrings.operationFailed}: $msg');
      }
    });

    // 监听运行状态（包含Wi-Fi状态）
    _runningStatusSubscription =
        widget.glassesPlugin.runningStatusEveStm.listen((status) async {
      print('MediaFilePage 收到运行状态事件: $status');

      // 检查直播模式状态
      if (status.containsKey('livingMode')) {
        bool livingMode = status['livingMode'] ?? false;
        if (livingMode && _isLiveMode && _pendingConnectAfterFileSync) {
          print('livingMode 已就绪，开始自动连接设备 Wi-Fi');
          _pendingConnectAfterFileSync = false;
          try {
            print('等待 5 秒后再连接设备 Wi-Fi');
            await Future.delayed(const Duration(seconds: 5));
            if (!mounted || !_isLiveMode) {
              print('页面已销毁或已退出直播模式，跳过自动连接');
              return;
            }
            if (_targetSsid != null && _targetPassword != null) {
              await widget.glassesPlugin.connectToDeviceWifiWithCredentials(_targetSsid!, _targetPassword!);
            } else {
              await widget.glassesPlugin.connectToDeviceWifi();
            }
          } catch (e) {
            print('自动连接设备 Wi-Fi 失败: $e');
            if (!mounted) return;
            setState(() {
              _wifiConnectionStatus = 'disconnected';
              _isWifiConnecting = false;
            });
            ToastUtil.showToast(AppStrings.connectDeviceWifiFailed('$e'));
          }
        } else if (!livingMode && _isLiveMode) {
          print('livingMode 变为 false，直播模式已退出');
          setState(() {
            _isLiveMode = false;
          });
          _pendingConnectAfterFileSync = false;
        }
      }

      // 检查文件同步状态
      if (status.containsKey('fileSync')) {
        bool fileSync = status['fileSync'] ?? false;
        print(
            'MediaFilePage fileSync 状态: $fileSync, 当前 _isFileSyncEnabled: $_isFileSyncEnabled');
        if (fileSync && !_isFileSyncEnabled) {
          print('MediaFilePage 更新 _isFileSyncEnabled 为 true');
          setState(() {
            _isFileSyncEnabled = true;
          });
          // ToastUtil.showToast(AppStrings.wifiEnabled);
        }

        if (fileSync && _pendingConnectAfterFileSync && !_isLiveMode) {
          print('fileSync 已就绪，开始自动连接设备 Wi-Fi');
          _pendingConnectAfterFileSync = false;
          try {
            print('等待 5 秒后再连接设备 Wi-Fi');
            await Future.delayed(const Duration(seconds: 5));
            if (!mounted || !_isFileSyncEnabled) {
              print('页面已销毁或已退出文件同步，跳过自动连接');
              return;
            }
            if (_targetSsid != null && _targetPassword != null) {
              await widget.glassesPlugin.connectToDeviceWifiWithCredentials(_targetSsid!, _targetPassword!);
            } else {
              await widget.glassesPlugin.connectToDeviceWifi();
            }
          } catch (e) {
            print('自动连接设备 Wi-Fi 失败: $e');
            if (!mounted) return;
            setState(() {
              _wifiConnectionStatus = 'disconnected';
              _isWifiConnecting = false;
            });
            ToastUtil.showToast(AppStrings.connectDeviceWifiFailed('$e'));
          }
        } else if (!fileSync && _isFileSyncEnabled) {
          print('MediaFilePage 更新 _isFileSyncEnabled 为 false');
          setState(() {
            _isFileSyncEnabled = false;
            _files.clear();
          });
          _pendingConnectAfterFileSync = false;
        }
      }
    });

    // 监听媒体文件事件
    _mediaFileSubscription =
        widget.glassesPlugin.mediaFileEveStm.listen((mediaFile) {
      if (mediaFile.fileName == '__count_changed__') return;
      setState(() {
        _files.removeWhere((item) => item.fileName == mediaFile.fileName);
        _files.add(mediaFile);
      });
    });
  }

  /// 订阅媒体文件变化事件：收到新文件时 Toast 提示并刷新 BLE 文件数量
  void _subscribeMediaFileChange() {
    // 防止重复初始化导致多次监听同一事件流
    _mediaFileCountSubscription?.cancel();
    print('mediaFileCountEveStm: 开始监听');

    _mediaFileCountSubscription =
        widget.glassesPlugin.mediaFileCountEveStm.listen((countMap) {
      if (!mounted) return;

      print('mediaFileCountEveStm: 收到事件原始数据=$countMap');
      final reason = (countMap['reason'] ?? '').toString();
      final sessionId = (countMap['debugSessionId'] ?? '').toString();
      print(
          'mediaFileCountEveStm: 会话关联 uiSession=$_activeDownloadDebugSessionId, nativeSession=$sessionId, '
          'isDownloading=$_isDownloading, isFileSyncEnabled=$_isFileSyncEnabled');
      _applyBleFileCount(countMap,
          source: reason.isNotEmpty ? 'event:$reason' : 'event');

      if (reason == 'change' && _isFileSyncEnabled) {
        ToastUtil.showToast(AppStrings.deviceHasNewFiles);
      }
    }, onDone: () {
      print('mediaFileCountEveStm: 监听结束');
    }, onError: (error) {
      print('媒体数量事件监听失败，降级走主动查询: $error');
    });
  }

  void _applyBleFileCount(Map<String, dynamic> countMap,
      {required String source}) {
    if (!mounted) return;
    setState(() {
      _bleTotal = (countMap['total'] as num?)?.toInt() ?? 0;
      _blePicture = (countMap['picture'] as num?)?.toInt() ?? 0;
      _bleVideo = (countMap['video'] as num?)?.toInt() ?? 0;
      _bleAudio = (countMap['audio'] as num?)?.toInt() ?? 0;
    });
    print(
        'BLE文件数量($source): total=$_bleTotal, picture=$_blePicture, video=$_bleVideo, audio=$_bleAudio');
  }

  /// 通过 BLE 查询设备文件数量（total/picture/video/audio）
  Future<void> _queryBleFileCount({String reason = 'manual'}) async {
    try {
      print(
          '查询BLE文件数量: reason=$reason, uiSession=$_activeDownloadDebugSessionId, '
          '当前计数 total=$_bleTotal, picture=$_blePicture, video=$_bleVideo, audio=$_bleAudio, '
          'isDownloading=$_isDownloading, isFileSyncEnabled=$_isFileSyncEnabled');
      await widget.glassesPlugin.getFileCount();
    } catch (e) {
      print(
          '查询BLE文件数量失败: reason=$reason, uiSession=$_activeDownloadDebugSessionId, error=$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.mediaFileManagement),
      ),
      body: ListView(
        children: [
          _buildWifiStatusCard(),
          _buildFileStatsCard(),
          _buildDownloadProgressSlot(),
          _buildDownloadLocationCard(),
          _buildLiveViewCard(),
          SizedBox(
            height: 420,
            child: _files.isEmpty
                ? Center(child: Text(AppStrings.noFiles))
                : _buildFileList(),
          ),
        ],
      ),
    );
  }

  /// 构建Wi-Fi状态卡片
  Widget _buildWifiStatusCard() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isWifiEnabled ? Icons.wifi : Icons.wifi_off,
                  color: _isWifiEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.wifiStatus,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusTag(
                    label: AppStrings.fileSync,
                    value: _getFileSyncStatusText(),
                    color: _getFileSyncStatusColor(),
                    icon: Icons.sync,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusTag(
                    label: AppStrings.wifiConnection,
                    value: _getWifiConnectionStatusText(),
                    color: _getWifiConnectionStatusColor(),
                    icon: Icons.wifi,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _isWifiConnecting
                      ? ElevatedButton.icon(
                          onPressed: null,
                          icon: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          label: Text(AppStrings.connectingStatus),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _enableWifi,
                          icon: Icon(Icons.wifi),
                          label: Text(AppStrings.enableWifi),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _disableWifi,
                    icon: Icon(Icons.wifi_off),
                    label: Text(AppStrings.disableWifi),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showWifiSettingsDialog,
                icon: const Icon(Icons.settings, size: 18),
                label: Text('配置设备 Wi-Fi 名称和密码'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建文件统计卡片
  Widget _buildFileStatsCard() {
    final bool canDownload = !_isDownloading && _bleTotal > 0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_open, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.fileStatistics,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _getMediaFileList,
                            icon: Icon(Icons.refresh, size: 14),
                            label: Text(AppStrings.refreshFiles),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton.icon(
                            onPressed: canDownload ? _downloadFiles : null,
                            icon: Icon(Icons.download, size: 14),
                            label: Text(AppStrings.downloadFiles),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  canDownload ? Colors.green : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_bleTotal > 0) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                        AppStrings.image, '$_blePicture', Icons.image,
                        color: Colors.green[700]!),
                  ),
                  Expanded(
                    child: _buildStatItem(
                        AppStrings.video, '$_bleVideo', Icons.videocam,
                        color: Colors.orange[700]!),
                  ),
                  Expanded(
                    child: _buildStatItem(
                        AppStrings.audio, '$_bleAudio', Icons.audiotrack,
                        color: Colors.purple[700]!),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(AppStrings.image, '0', Icons.image,
                        color: Colors.green[700]!),
                  ),
                  Expanded(
                    child: _buildStatItem(AppStrings.video, '0', Icons.videocam,
                        color: Colors.orange[700]!),
                  ),
                  Expanded(
                    child: _buildStatItem(
                        AppStrings.audio, '0', Icons.audiotrack,
                        color: Colors.purple[700]!),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, IconData icon,
      {Color? color}) {
    final iconColor = color ?? Colors.grey[600]!;
    final valueColor = color ?? Colors.blue[700]!;
    return Column(
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 构建直播视图卡片
  Widget _buildLiveViewCard() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                Icon(Icons.videocam,
                    color: _isLiveActive ? Colors.red : Colors.grey),
                SizedBox(width: 8),
                Text(
                  AppStrings.liveView,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                // 直播状态标签
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _isLiveActive
                        ? Colors.red.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isLiveActive
                        ? AppStrings.liveActive
                        : AppStrings.liveInactive,
                    style: TextStyle(
                      fontSize: 12,
                      color: _isLiveActive ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (_isLiveActive || !_isWifiEnabled) ? null : _startLive,
                    icon: Icon(Icons.play_circle),
                    label: Text(AppStrings.startLive),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLiveActive ? _stopLive : null,
                    icon: Icon(Icons.stop_circle),
                    label: Text(AppStrings.stopLive),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // 测试播放按钮（用公开 RTSP 流验证播放器）
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testPlayRtsp,
                icon: Icon(Icons.science),
                label: Text('测试播放 RTSP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  foregroundColor: Colors.purple,
                ),
              ),
            ),
            SizedBox(height: 12),
            // RTSP URL 显示
            if (_liveUrl.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.liveUrl,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _liveUrl,
                      style: TextStyle(fontSize: 13, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              )
            else if (_isLiveActive)
              Text(
                AppStrings.waitingForLiveUrl,
                style: TextStyle(fontSize: 13, color: Colors.orange),
              ),
            // 视频播放器（media_kit）
            if (_isLiveActive && _player != null) ...[
              SizedBox(height: 12),
              Text(
                AppStrings.liveVideo,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Video(
                    controller: _videoController!,
                    width: double.infinity,
                    height: 220,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建下载位置卡片
  Widget _buildDownloadLocationCard() {
    final totalSizeBytes = _localDownloadedFiles.fold<int>(
      0,
      (sum, file) {
        try {
          return sum + file.statSync().size;
        } catch (_) {
          return sum;
        }
      },
    );

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.downloadCenter,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _localDownloadedFiles.isEmpty
                      ? null
                      : _deleteAllLocalFiles,
                  icon: const Icon(Icons.delete_sweep, size: 16),
                  label: Text(AppStrings.deleteAll),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.localFiles,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 2),
                        Text(
                          '${_localDownloadedFiles.length} ${AppStrings.files}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.totalDirectorySize,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 2),
                        Text(
                          _formatFileSize(totalSizeBytes),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLocalFilesLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              ))
            else if (_localDownloadedFiles.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  AppStrings.noDownloadedFilesInDirectory,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _localDownloadedFiles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final file = _localDownloadedFiles[index];
                    final stat = file.statSync();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(_localFileIcon(file.path),
                                color: Colors.blueGrey, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  path.basename(file.path),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_formatFileSize(stat.size)} · ${_formatDateTime(stat.modified)}',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          TextButton(
                            onPressed: () => _openLocalFile(file.path),
                            child: Text(AppStrings.view),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建文件列表
  Widget _buildFileList() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _files.length,
      itemBuilder: (context, index) => _buildFileGridItem(_files[index]),
    );
  }

  /// 构建文件网格项
  Widget _buildFileGridItem(MediaFileBean file) {
    bool isSelected = _selectedFiles.contains(file.fileName);

    return Card(
      child: InkWell(
        onTap: () => _toggleFileSelection(file.fileName),
        child: Column(
          children: [
            // 缩略图区域
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: _buildFileIcon(file.fileType),
                  ),
                  // 选择框
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) => _toggleFileSelection(file.fileName),
                    ),
                  ),
                ],
              ),
            ),
            // 文件信息
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.fileName,
                      style: TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Text(
                      _formatFileSize(file.fileSize),
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建文件图标
  Widget _buildFileIcon(int fileType) {
    IconData icon;
    Color color;

    switch (fileType) {
      case 0: // 图片
        icon = Icons.image;
        color = Colors.blue;
        break;
      case 1: // 视频
        icon = Icons.videocam;
        color = Colors.red;
        break;
      case 2: // 音频
        icon = Icons.audiotrack;
        color = Colors.green;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 24);
  }

  /// 构建下载进度条
  Widget _buildDownloadProgressSlot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: _isDownloading
            ? _buildDownloadProgress()
            : Container(
                key: const ValueKey('download-progress-idle'),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  AppStrings.downloadProgressWaitingStart,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
      ),
    );
  }

  /// 构建下载进度条
  Widget _buildDownloadProgress() {
    return Container(
      key: const ValueKey('download-progress-active'),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: _downloadProgress),
          const SizedBox(height: 8),
          Text(
              '${AppStrings.downloading}: ${(_downloadProgress * 100).toInt()}%'),
        ],
      ),
    );
  }

  /// 开启Wi-Fi（选择模式：文件同步 or 直播）
  Future<void> _enableWifi() async {
    final wifiType = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(AppStrings.enableWifi),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 1),
            child: Row(
              children: [
                Icon(Icons.folder, color: Colors.blue),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.wifiFileSync,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(AppStrings.enableFileTransfer,
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 3),
            child: Row(
              children: [
                Icon(Icons.videocam, color: Colors.red),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.liveView,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(AppStrings.startLive,
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (wifiType == null) return; // 用户取消

    try {
      setState(() {
        _isWifiConnecting = true;
        _wifiConnectionStatus = 'connecting';
        _isLiveMode = wifiType == 3;
      });
      _pendingConnectAfterFileSync = true;

      await widget.glassesPlugin.enableWifi(
        wifiType: wifiType,
        ssid: _targetSsid,
        password: _targetPassword,
      );
      ToastUtil.showToast(AppStrings.wifiEnabledWaitingAutoConnect);
      print('Wi-Fi 开启成功(wifiType=$wifiType, ssid=${_targetSsid ?? "默认"}, password=${_targetPassword != null ? "***" : "默认"})，等待连接设备 Wi-Fi');
    } catch (e) {
      print('开启 Wi-Fi 失败: $e');
      ToastUtil.showToast('${AppStrings.enableWifiFailed}: $e');
      _pendingConnectAfterFileSync = false;
      setState(() {
        _wifiConnectionStatus = 'disconnected';
        _isWifiConnecting = false;
      });
    }
  }

  /// 关闭Wi-Fi
  Future<void> _disableWifi() async {
    try {
      await widget.glassesPlugin.disableWifi();
      _pendingConnectAfterFileSync = false;
      setState(() {
        _isWifiEnabled = false;
        _isFileSyncEnabled = false;
        _isLiveMode = false;
        _wifiConnectionStatus = 'disconnected';
        _files.clear();
      });
      ToastUtil.showToast(AppStrings.wifiDisabled);
    } catch (e) {
      ToastUtil.showToast('${AppStrings.disableWifiFailed}: $e');
    }
  }

  /// 设置 Wi-Fi 热点名称和密码
  Future<void> _showWifiSettingsDialog() async {
    final ssidController = TextEditingController(text: _targetSsid);
    final passwordController = TextEditingController(text: _targetPassword);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppStrings.wifiName), // or custom title
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: ssidController,
                  decoration: InputDecoration(
                    labelText: AppStrings.wifiName,
                    hintText: AppStrings.wifiNameHint,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'SSID 不能为空';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: AppStrings.wifiPassword,
                    hintText: AppStrings.wifiPasswordHint,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().length < 8) {
                      return '密码长度不能少于 8 位';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final newSsid = ssidController.text.trim();
                  final newPassword = passwordController.text.trim();
                  
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('custom_wifi_ssid', newSsid);
                  await prefs.setString('custom_wifi_password', newPassword);

                  setState(() {
                    _targetSsid = newSsid;
                    _targetPassword = newPassword;
                  });
                  
                  Navigator.pop(ctx);
                  ToastUtil.showToast('Wi-Fi 设置已保存');
                }
              },
              child: Text(AppStrings.confirm),
            ),
          ],
        );
      },
    );
  }

  /// 开启直播（Wi-Fi 已连接后由用户主动触发）
  Future<void> _startLive() async {
    if (!_isWifiEnabled) {
      ToastUtil.showToast(AppStrings.enableWifi);
      return;
    }
    if (_liveUrl.isEmpty) {
      ToastUtil.showToast(AppStrings.waitingForLiveUrl);
      return;
    }
    setState(() {
      _isLiveActive = true;
    });
    final isReady = await _waitForRtspEndpointReady(_liveUrl);
    if (!mounted || !_isLiveActive) return;
    if (!isReady) {
      ToastUtil.showToast('直播地址暂时不可连接，请稍后重试');
      return;
    }
    await _initAndPlayMedia(_liveUrl);
  }

  /// 初始化 media_kit 播放器并播放指定 URL
  Future<void> _initAndPlayMedia(String url) async {
    if (!mounted || !_isLiveActive || _player == null) return;
    // media_kit 的 Player 在 initState 时已创建，直接打开媒体
    await _player!.open(Media(url));
    print('media_kit 播放已启动: $url');
    setState(() {});
  }

  Future<bool> _waitForRtspEndpointReady(String url) async {
    final uri = Uri.tryParse(url);
    final host = uri?.host ?? '';
    final port = uri?.hasPort == true ? uri!.port : 554;
    if (host.isEmpty) {
      print('RTSP 地址解析失败: $url');
      return false;
    }
    for (var attempt = 1; attempt <= 12; attempt++) {
      Socket? socket;
      try {
        print('检查 RTSP 端点连通性: $host:$port，第 $attempt 次');
        socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(milliseconds: 800),
        );
        await socket.close();
        print('RTSP 端点已可连接: $host:$port');
        return true;
      } catch (e) {
        print('RTSP 端点暂不可连接: $host:$port，第 $attempt 次，$e');
        await socket?.close();
        if (attempt < 12) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }
    print('RTSP 端点检查失败，放弃启动播放器: $host:$port');
    return false;
  }

  /// 释放 media_kit 播放器（同步，Player 在 dispose 时统一释放）
  void _disposePlayer() {
    _player?.stop();
  }

  /// 测试播放公开 RTSP 流，验证 media_kit 播放器是否正常
  void _testPlayRtsp() {
    const testUrl = 'rtsp://stream.strba.sk:1935/strba/VYHLAD_JAZERO.stream';
    print('测试播放 RTSP 流: $testUrl');
    setState(() {
      _liveUrl = testUrl;
      _isLiveActive = true;
    });
    _initAndPlayMedia(testUrl);
  }

  /// 停止直播
  Future<void> _stopLive() async {
    try {
      await widget.glassesPlugin.stopLive();
      _disposePlayer();
      setState(() {
        _isLiveActive = false;
        _liveUrl = '';
      });
      ToastUtil.showToast(AppStrings.liveStopped);
    } catch (e) {
      ToastUtil.showToast('${AppStrings.stopLiveFailed}: $e');
    }
  }

  /// 获取媒体文件列表
  Future<void> _getMediaFileList() async {
    print('=== 刷新文件统计 ===');
    await _queryBleFileCount(reason: 'manual_refresh');
  }

  /// 切换文件选择
  void _toggleFileSelection(String fileName) {
    setState(() {
      if (_selectedFiles.contains(fileName)) {
        _selectedFiles.remove(fileName);
      } else {
        _selectedFiles.add(fileName);
      }
    });
  }

  Future<void> _loadLocalDownloadedFiles() async {
    if (_downloadPath.isEmpty) return;

    setState(() {
      _isLocalFilesLoading = true;
    });

    try {
      final directory = Directory(_downloadPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final files = directory.listSync().whereType<File>().toList()
        ..sort((a, b) {
          try {
            return b.statSync().modified.compareTo(a.statSync().modified);
          } catch (_) {
            return 0;
          }
        });

      if (!mounted) return;
      setState(() {
        _localDownloadedFiles = files;
      });
    } catch (e) {
      print('加载本地下载文件失败: $e');
      ToastUtil.showToast(AppStrings.loadLocalFilesFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isLocalFilesLoading = false;
        });
      }
    }
  }

  Future<void> _openLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        ToastUtil.showToast(AppStrings.localFileNotExistRefreshed);
        await _loadLocalDownloadedFiles();
        return;
      }

      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        ToastUtil.showToast(AppStrings.fileOpenNotSupported);
      }
    } catch (e) {
      print('打开本地文件失败: $e');
      ToastUtil.showToast(AppStrings.openFileFailedWithError('$e'));
    }
  }

  Future<void> _deleteAllLocalFiles() async {
    final confirmed = await _showDeleteAllLocalFilesConfirmDialog();
    if (!confirmed) return;

    try {
      if (_downloadPath.isEmpty) {
        print('删除全部本地文件失败: 下载目录为空');
        ToastUtil.showToast(AppStrings.deleteFailedEmptyDownloadDir);
        return;
      }

      final directory = Directory(_downloadPath);
      if (!await directory.exists()) {
        print('删除全部本地文件: 目录不存在，path=$_downloadPath');
        await _loadLocalDownloadedFiles();
        ToastUtil.showToast(AppStrings.deleteSkippedDirNotExist);
        return;
      }

      final entities =
          await directory.list(recursive: false, followLinks: false).toList();
      int deletedCount = 0;
      for (final entity in entities) {
        if (entity is File) {
          if (await entity.exists()) {
            await entity.delete();
            deletedCount++;
          }
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
          deletedCount++;
        }
      }
      await _loadLocalDownloadedFiles();
      ToastUtil.showToast(AppStrings.clearedDownloadDirCount(deletedCount));
    } catch (e) {
      print('删除全部本地文件失败: $e');
      ToastUtil.showToast(AppStrings.deleteAllFailedWithError('$e'));
    }
  }

  Future<bool> _showDeleteAllLocalFilesConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.confirmDeleteAll),
        content: Text(AppStrings.confirmDeleteAllContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.deleteAll),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  IconData _localFileIcon(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.webp', '.gif'].contains(ext)) {
      return Icons.image;
    }
    if (['.mp4', '.mov', '.avi', '.mkv'].contains(ext)) {
      return Icons.videocam;
    }
    if (['.mp3', '.wav', '.aac', '.m4a'].contains(ext)) {
      return Icons.audiotrack;
    }
    return Icons.insert_drive_file;
  }

  String _formatDateTime(DateTime dateTime) {
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${dateTime.year}-${two(dateTime.month)}-${two(dateTime.day)} ${two(dateTime.hour)}:${two(dateTime.minute)}';
  }
}
