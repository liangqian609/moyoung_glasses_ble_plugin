import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:moyoung_glasses_ble_plugin/moyoung_glasses_ble.dart';
import '../l10n/app_strings.dart';
import '../utils/toast_util.dart';

/// 版本信息 & OTA 升级页面
class VersionOtaPage extends StatefulWidget {
  final MoYoungGlassesBle glassesPlugin;
  final bool isConnected;
  final String? cachedMacAddress;

  const VersionOtaPage({
    Key? key,
    required this.glassesPlugin,
    required this.isConnected,
    this.cachedMacAddress,
  }) : super(key: key);

  @override
  State<VersionOtaPage> createState() => _VersionOtaPageState();
}

class _VersionOtaPageState extends State<VersionOtaPage> {
  MoYoungGlassesBle get _glassesPlugin => widget.glassesPlugin;
  bool get _isConnected => widget.isConnected;

  // 版本信息状态
  String _jlVersion = AppStrings.unknown;
  String _qzVersion = AppStrings.unknown;
  String _tpVersion = AppStrings.unknown;
  String _githashVersion = AppStrings.unknown;
  String _actualJlVersion = '';
  String _actualQzVersion = '';

  // 检查版本结果
  String _checkVersionResult = AppStrings.clickToGet;
  String? _latestFirmwareVer;
  String? _latestImageVer;
  String? _latestFirmwareFile;
  String? _latestImageFile;
  int _latestOtaType = 0;
  int _latestFirmwareNum = 0;
  String? _latestFirmwareMd5;
  int _latestFirmwareSize = 0;

  // OTA 升级状态
  String _otaStatus = AppStrings.waitingOtaStatus;

  // 影像升级 loading 状态
  bool _isImageOtaLoading = false;

  // 流订阅
  final List<StreamSubscription> _streamSubscriptions = [];

  @override
  void initState() {
    super.initState();
    _setupEventListeners();
  }

  @override
  void dispose() {
    for (var sub in _streamSubscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  void _setupEventListeners() {
    // OTA 升级状态
    _streamSubscriptions.add(
      _glassesPlugin.otaStateEveStm.listen((Map<String, dynamic> data) {
        debugPrint('OTA event: $data');
        int type = data['type'] ?? 0;
        int progress = data['progress'] ?? 0;
        String typeText = type == 0 ? 'Preparing' : type == 1 ? 'Upgrading' : type == 2 ? 'Complete' : 'Failed';

        setState(() {
          _otaStatus = "$typeText (${progress}%)";
        });

        if (type == 2 || type == 3) {
          _showToast(typeText);
        }
      }),
    );
  }

  void _showToast(String message) {
    ToastUtil.showToast(message);
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.versionInfo),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildVersionInfoSection(),
          const SizedBox(height: 20),
          _buildOTASection(),
        ],
      ),
    );
  }

  Widget _buildVersionInfoSection() {
    // 固件版本 subtitle
    String jlSubtitle = _jlVersion;
    if (_latestFirmwareVer != null && _latestFirmwareVer != _actualJlVersion) {
      jlSubtitle = '$_jlVersion  →  $_latestFirmwareVer (可更新)';
    } else if (_checkVersionResult == AppStrings.alreadyLatest && _actualJlVersion.isNotEmpty) {
      jlSubtitle = '$_jlVersion  ✓ 已是最新';
    }

    // 影像版本 subtitle
    String qzSubtitle = _qzVersion;
    if (_latestImageVer != null && _latestImageVer != _actualQzVersion) {
      qzSubtitle = '$_qzVersion  →  $_latestImageVer (可更新)';
    } else if (_checkVersionResult == AppStrings.alreadyLatest && _actualQzVersion.isNotEmpty) {
      qzSubtitle = '$_qzVersion  ✓ 已是最新';
    }

    return _buildSectionCard(
      title: AppStrings.versionInfo,
      icon: Icons.info,
      children: [
        _buildApiButton(
          AppStrings.queryJLVersion,
          Icons.memory,
          _getJLVersion,
          subtitle: jlSubtitle,
          enabled: _isConnected,
        ),
        _buildApiButton(
          AppStrings.queryAllwinnerVersion,
          Icons.developer_board,
          _getQZVersion,
          subtitle: qzSubtitle,
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
        // OTA 升级状态
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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
        // 固件升级子标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.memory, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                AppStrings.jlOtaUpgrade,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        _buildApiButton(
          '固件网络升级',
          Icons.cloud_download,
          _startFirmwareNetworkOTA,
          subtitle: '需先检查新版本',
          enabled: _isConnected,
        ),
        _buildApiButton(
          '固件本地升级',
          Icons.folder_open,
          _startFirmwareLocalOTA,
          subtitle: '选择本地固件文件',
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
        // 影像版本升级子标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.developer_board, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                AppStrings.qzOtaUpgrade,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        _buildApiButton(
          '影像网络升级',
          Icons.cloud_download,
          _startImageNetworkOTA,
          subtitle: '需先检查新版本',
          enabled: _isConnected && !_isImageOtaLoading,
        ),
        _buildApiButton(
          '影像本地升级',
          Icons.folder_open,
          _startImageLocalOTA,
          subtitle: '选择本地影像文件',
          enabled: _isConnected && !_isImageOtaLoading,
        ),
        if (_isImageOtaLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _otaStatus,
                    style: TextStyle(fontSize: 14, color: Colors.orange[700]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ==================== 通用 UI 组件 ====================

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
    VoidCallback onPressed, {
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

  // ==================== 版本查询方法 ====================

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

  Future<void> _getQZVersion() async {
    setState(() {
      _qzVersion = AppStrings.gettingStatusWithDots;
    });

    try {
      String version = await _glassesPlugin.getQZVersion()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(AppStrings.sdkTimeoutMessage, const Duration(seconds: 10));
      });

      if (version.isEmpty || version == 'null' || version == 'N/A') {
        setState(() {
          _actualQzVersion = version;
          _qzVersion = AppStrings.deviceNotSupportedFeature2;
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
      setState(() {
        _qzVersion = AppStrings.sdkNotReturned;
      });
      _showToast(AppStrings.getQzVersionTimeout + ": $e");
    } catch (e) {
      setState(() {
        _qzVersion = AppStrings.getFailed;
      });
      _showToast(AppStrings.getQzVersionFailed + ": $e");
    }
  }

  Future<void> _getTPVersion() async {
    setState(() {
      _tpVersion = AppStrings.gettingStatusWithDots;
    });

    try {
      String version = await _glassesPlugin.getTPVersion()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(AppStrings.sdkTimeoutMessage, const Duration(seconds: 10));
      });

      if (version.isEmpty || version == 'null' || version == 'N/A') {
        setState(() {
          _tpVersion = AppStrings.deviceNotSupportedFeature2;
        });
        _showToast(AppStrings.deviceNotSupportedFeature2);
      } else {
        setState(() {
          _tpVersion = 'TP版本: $version';
        });
        _showToast('TP版本: $version');
      }
    } on TimeoutException catch (e) {
      setState(() {
        _tpVersion = AppStrings.sdkNotReturned;
      });
      _showToast('获取TP版本超时: $e');
    } catch (e) {
      setState(() {
        _tpVersion = AppStrings.getFailed;
      });
      _showToast('获取TP版本失败: $e');
    }
  }

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

  // ==================== 检查版本 & OTA 方法 ====================

  void _checkLatestVersion() async {
    setState(() {
      _checkVersionResult = AppStrings.checkingLatestVersion;
    });

    try {
      await _getJLVersion();
      await _getQZVersion();

      if (_actualJlVersion.isEmpty || _actualJlVersion == 'null' || _actualJlVersion == 'N/A') {
        setState(() {
          _checkVersionResult = AppStrings.jlVersionMissing;
        });
        _showToast(AppStrings.jlVersionMissing);
        return;
      }

      if (_actualQzVersion.isEmpty || _actualQzVersion == 'null' || _actualQzVersion == 'N/A') {
        setState(() {
          _checkVersionResult = AppStrings.qzVersionMissing;
        });
        _showToast(AppStrings.qzVersionMissing);
        return;
      }

      String mac = widget.cachedMacAddress ?? "00:00:00:00:00:00";
      if (mac == "00:00:00:00:00:00" || mac.isEmpty) {
        setState(() {
          _checkVersionResult = AppStrings.connectDeviceForMac;
        });
        _showToast(AppStrings.connectDeviceForMac);
        return;
      }

      Map<String, dynamic> result = await _glassesPlugin.checkLatestVersion(
        fw1Ver: _actualJlVersion,
        fw2Ver: _actualQzVersion,
        mac: mac,
      );

      String status = result['status'] ?? 'unknown';
      String messageKey = result['message'] ?? 'unknown';
      bool hasUpdate = result['hasUpdate'] ?? false;
      String localizedMessage = _getLocalizedMessage(messageKey);

      if (hasUpdate && result['latestVersion'] != null) {
        Map<String, dynamic> latestVersion = Map<String, dynamic>.from(result['latestVersion']);
        String firmwareVer = latestVersion['firmwareVer'] ?? '';
        String firmwareFile = latestVersion['firmwareFile'] ?? '';
        int firmwareNum = latestVersion['firmwareNum'] ?? 0;
        String firmwareMd5 = latestVersion['firmwareMd5'] ?? '';
        int firmwareSize = latestVersion['firmwareSize'] ?? 0;
        int otaType = latestVersion['type'] ?? 0;

        String updateTypeLabel = firmwareNum == 1 ? '固件版本' : '影像版本';
        String currentVer = firmwareNum == 1 ? _actualJlVersion : _actualQzVersion;

        setState(() {
          _checkVersionResult = localizedMessage;
          _latestOtaType = otaType;
          _latestFirmwareNum = firmwareNum;
          _latestFirmwareMd5 = firmwareMd5;
          _latestFirmwareSize = firmwareSize;
          if (firmwareNum == 1) {
            _latestFirmwareVer = firmwareVer;
            _latestFirmwareFile = firmwareFile;
          } else if (firmwareNum == 2) {
            _latestImageVer = firmwareVer;
            _latestImageFile = firmwareFile;
          }
        });

        _showToast(localizedMessage);
        _showUpdateDialog(updateTypeLabel, currentVer, firmwareVer);
      } else {
        setState(() {
          _checkVersionResult = localizedMessage;
          _latestFirmwareVer = null;
          _latestImageVer = null;
          _latestFirmwareFile = null;
          _latestImageFile = null;
        });
        _showToast(localizedMessage);
      }
    } catch (e) {
      debugPrint('checkLatestVersion 异常: $e');
      setState(() {
        _checkVersionResult = AppStrings.checkVersionFailed;
      });
      _showToast(AppStrings.checkVersionFailed + ": $e");
    }
  }

  String _getLocalizedMessage(String messageKey) {
    switch (messageKey) {
      case 'update_available':
        return AppStrings.updateAvailable;
      case 'already_latest':
        return AppStrings.alreadyLatest;
      case 'check_failed':
        return AppStrings.checkFailed;
      default:
        return AppStrings.checkVersionFailed;
    }
  }

  void _showUpdateDialog(String updateTypeLabel, String currentVer, String newVer) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.system_update, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(child: Text('发现${updateTypeLabel}更新')),
            ],
          ),
          content: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('当前版本:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(currentVer, style: TextStyle(fontSize: 14)),
                SizedBox(height: 8),
                Text('最新版本:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(newVer, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('知道了'),
            ),
          ],
        );
      },
    );
  }

  /// 将 assets 中的固件文件拷贝到沙盒目录
  Future<String?> _copyAssetToSandbox(String assetPath, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final targetPath = '${dir.path}/$fileName';
      final targetFile = File(targetPath);

      if (await targetFile.exists()) {
        debugPrint('沙盒中已存在: $targetPath');
        return targetPath;
      }

      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      await targetFile.writeAsBytes(bytes);
      debugPrint('已拷贝到沙盒: $targetPath (${bytes.length} bytes)');
      return targetPath;
    } catch (e) {
      debugPrint('拷贝 asset 到沙盒失败: $e');
      return null;
    }
  }

  /// 固件网络升级
  void _startFirmwareNetworkOTA() async {
    if (_latestFirmwareFile == null || _latestFirmwareFile!.isEmpty) {
      _showToast('请先检查新版本，确认有固件更新');
      return;
    }
    if (_latestFirmwareNum != 1) {
      _showToast('当前检查到的更新不是固件版本，请重新检查');
      return;
    }

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('固件网络升级'),
        content: Text('将从服务器下载固件文件并升级，升级过程中请勿断开设备。\n\n新版本: $_latestFirmwareVer\n\n是否继续？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(AppStrings.cancel)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(AppStrings.confirm)),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() { _otaStatus = '正在下载固件文件...'; });

    try {
      String localPath = await _glassesPlugin.downloadFirmware(url: _latestFirmwareFile!);
      debugPrint('固件下载完成: $localPath');

      setState(() { _otaStatus = '固件下载完成，开始升级...'; });
      bool success = await _glassesPlugin.startJLOTA(path: localPath);
      if (success) {
        _showToast(AppStrings.jlOtaStarted);
        setState(() { _otaStatus = '固件升级中...'; });
      } else {
        _showToast(AppStrings.jlOtaStartFailed);
        setState(() { _otaStatus = AppStrings.waitingOtaStatus; });
      }
    } catch (e) {
      debugPrint('固件网络升级失败: $e');
      _showToast('固件网络升级失败: $e');
      setState(() { _otaStatus = AppStrings.waitingOtaStatus; });
    }
  }

  /// 固件本地升级
  void _startFirmwareLocalOTA() async {
    const assetPath = 'assets/firmware/20260423184115_MOY-A033-0.0.3-BIN-89E60A0C-ENCRYPTED.ufw';
    const fileName = '20260423184115_MOY-A033-0.0.3-BIN-89E60A0C-ENCRYPTED.ufw';

    _showToast('正在准备固件文件...');

    final localPath = await _copyAssetToSandbox(assetPath, fileName);
    if (localPath == null) {
      _showToast('固件文件准备失败');
      return;
    }

    try {
      bool success = await _glassesPlugin.startJLOTA(path: localPath);
      if (success) {
        _showToast(AppStrings.jlOtaStarted);
        setState(() { _otaStatus = '固件升级中...'; });
      } else {
        _showToast(AppStrings.jlOtaStartFailed);
      }
    } catch (e) {
      _showToast('${AppStrings.jlOtaStartFailed}: $e');
    }
  }

  /// 影像版本网络升级
  void _startImageNetworkOTA() async {
    if (_latestImageFile == null || _latestImageFile!.isEmpty) {
      _showToast('请先检查新版本，确认有影像版本更新');
      return;
    }
    if (_latestFirmwareNum != 2) {
      _showToast('当前检查到的更新不是影像版本，请重新检查');
      return;
    }

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('影像版本网络升级'),
        content: Text('将从服务器下载影像文件并通过 Wi-Fi 升级，升级过程中请勿断开设备。\n\n新版本: $_latestImageVer\n\n是否继续？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(AppStrings.cancel)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(AppStrings.confirm)),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _isImageOtaLoading = true;
      _otaStatus = '正在下载影像文件...';
    });

    try {
      String localPath = await _glassesPlugin.downloadFirmware(url: _latestImageFile!);
      debugPrint('影像文件下载完成: $localPath');

      setState(() { _otaStatus = '影像文件下载完成，正在自动连接设备 Wi-Fi 并升级...'; });

      // startImageOTA 内部自动：开启设备 Wi-Fi → 等待就绪 → 连接 Wi-Fi → 启动升级
      bool success = await _glassesPlugin.startImageOTA(path: localPath);
      if (success) {
        _showToast('影像版本升级已启动');
        setState(() { _otaStatus = '影像版本升级中...'; });
      } else {
        _showToast('影像升级启动失败（可能超时）');
        setState(() { _otaStatus = AppStrings.waitingOtaStatus; });
      }
    } catch (e) {
      debugPrint('影像版本网络升级失败: $e');
      _showToast('影像版本网络升级失败: $e');
      setState(() { _otaStatus = AppStrings.waitingOtaStatus; });
    } finally {
      setState(() { _isImageOtaLoading = false; });
    }
  }

  /// 影像版本本地升级
  void _startImageLocalOTA() async {
    const assetPath = 'assets/firmware/openwrt_v821_aiglass-ai-v1.0.0.1.3.2508201758.swu';
    const fileName = 'openwrt_v821_aiglass-ai-v1.0.0.1.3.2508201758.swu';

    setState(() { _isImageOtaLoading = true; });
    _showToast('正在准备影像文件...');

    final localPath = await _copyAssetToSandbox(assetPath, fileName);
    if (localPath == null) {
      _showToast('影像文件准备失败');
      setState(() { _isImageOtaLoading = false; });
      return;
    }

    try {
      setState(() { _otaStatus = '正在自动连接设备 Wi-Fi 并升级...'; });

      // startImageOTA 内部自动：开启设备 Wi-Fi → 等待就绪 → 连接 Wi-Fi → 启动升级
      bool success = await _glassesPlugin.startImageOTA(path: localPath);
      if (success) {
        _showToast('影像版本本地升级已启动');
        setState(() { _otaStatus = '影像版本升级中...'; });
      } else {
        _showToast('影像升级启动失败（可能超时）');
        setState(() { _otaStatus = AppStrings.waitingOtaStatus; });
      }
    } catch (e) {
      _showToast('影像版本本地升级失败: $e');
      setState(() { _otaStatus = AppStrings.waitingOtaStatus; });
    } finally {
      setState(() { _isImageOtaLoading = false; });
    }
  }

  /// 取消固件升级
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
}
