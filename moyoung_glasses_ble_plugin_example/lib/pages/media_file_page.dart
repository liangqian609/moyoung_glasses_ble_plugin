import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:moyoung_glasses_ble_plugin/moyoung_glasses_ble.dart';
import 'package:moyoung_glasses_ble_plugin/impl/moyoung_glasses_beans.dart';
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
  bool _isWifiEnabled = false;
  String _baseUrl = '';
  List<MediaFileBean> _files = [];
  Set<String> _selectedFiles = {};
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  Map<String, double> _fileDownloadProgress = {};
  String _downloadPath = '';
  bool _isLoading = false;
  bool _isGridView = true;
  int _downloadedCount = 0;
  int _totalFiles = 0;
  
  // Wi-Fi 配置
  String _wifiSSID = 'Glass-01';
  String _wifiPassword = '12345678';
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Wi-Fi 连接状态
  String _wifiConnectionStatus = ''; // 使用国际化字符串动态显示
  
  // 流订阅
  StreamSubscription<String>? _fileBaseUrlSubscription;
  StreamSubscription<Map<String, dynamic>>? _actionResultSubscription;
  StreamSubscription<Map<String, dynamic>>? _runningStatusSubscription;
  StreamSubscription<MediaFileBean>? _mediaFileSubscription;

  @override
  void initState() {
    super.initState();
    print('MediaFilePage initState 被调用');
    
    // 初始化 Wi-Fi 配置控制器
    _ssidController.text = _wifiSSID;
    _passwordController.text = _wifiPassword;
    
    _initializePage();
  }

  @override
  void dispose() {
    _fileBaseUrlSubscription?.cancel();
    _actionResultSubscription?.cancel();
    _runningStatusSubscription?.cancel();
    _mediaFileSubscription?.cancel();
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 初始化页面
  Future<void> _initializePage() async {
    await _checkPermissions();
    await _getDownloadDirectory();
    _subscribeToEvents();
    _checkWifiStatus();
    
    // 初始化 Wi-Fi 连接状态
    setState(() {
      _wifiConnectionStatus = 'disconnected';
    });
  }

  /// 检查权限
  Future<void> _checkPermissions() async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    } catch (e) {
      // print('权限检查失败，跳过: $e');
    }
  }

  /// 获取下载目录
  Future<void> _getDownloadDirectory() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          final downloadDir = Directory(path.join(directory.path, 'Download', 'MoYoungGlasses'));
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          setState(() {
            _downloadPath = downloadDir.path;
          });
        }
      } else {
        // iOS
        directory = await getApplicationDocumentsDirectory();
        final downloadDir = Directory(path.join(directory.path, 'MoYoungGlasses'));
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        setState(() {
          _downloadPath = downloadDir.path;
        });
      }
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
    // 监听运行状态（包含Wi-Fi状态）
    _runningStatusSubscription = widget.glassesPlugin.runningStatusEveStm.listen((status) {
      // 检查文件同步状态
      if (status.containsKey('fileSync')) {
        bool fileSync = status['fileSync'] ?? false;
        if (fileSync && !_isWifiEnabled) {
          setState(() {
            _isWifiEnabled = true;
          });
          print('Wi-Fi已开启，等待BaseUrl获取文件列表...');
          // ToastUtil.showToast(AppStrings.wifiEnabled);
        } else if (!fileSync && _isWifiEnabled) {
          setState(() {
            _isWifiEnabled = false;
            _baseUrl = '';
            _files.clear();
            _totalFiles = 0;
            _downloadedCount = 0;
          });
          print('Wi-Fi已关闭，清空文件列表');
          // ToastUtil.showToast(AppStrings.wifiDisabled);
        }
      }
    });
    
    // 监听文件BaseUrl
    _fileBaseUrlSubscription = widget.glassesPlugin.fileBaseUrlEveStm.listen((baseUrl) {
      print('收到 BaseUrl 事件: $baseUrl');
      setState(() {
        _baseUrl = baseUrl;
        _isWifiEnabled = true;
      });
      if (baseUrl.isNotEmpty) {
        print('BaseUrl 不为空，开始获取文件列表...');
        _getMediaFileList();
      } else {
        print('BaseUrl 为空，无法获取文件列表');
      }
    });

    // 监听操作结果（iOS）
    _actionResultSubscription = widget.glassesPlugin.actionResultEveStm.listen((data) {
      int code = data['code'] ?? -1;
      String msg = data['msg'] ?? '';
      String? action = data['action'];
      
      print('收到操作结果事件: code=$code, msg=$msg, action=$action');
      
      // 处理 Wi-Fi 连接结果
      if (action == 'wifi_connection') {
        String? status = data['status'];
        
        if (status == 'prompt') {
          // 系统弹出提示
          print('📱 系统已弹出 Wi-Fi 连接提示');
          setState(() {
            _wifiConnectionStatus = 'connecting';
          });
          ToastUtil.showToast('请查看系统弹窗，点击"加入"连接 Wi-Fi');
        } else if (status == 'configured') {
          // 配置已应用，等待用户点击加入
          print('⚙️ Wi-Fi 配置已应用');
          setState(() {
            _wifiConnectionStatus = 'connecting';
          });
          ToastUtil.showToast('配置已应用，请点击系统弹窗中的"加入"');
        } else if (code == 0) {
          print('✅ 设备 Wi-Fi 连接成功');
          setState(() {
            _wifiConnectionStatus = 'connected';
          });
          ToastUtil.showToast('设备 Wi-Fi 连接成功，等待 BaseUrl...');
        } else {
          print('❌ 设备 Wi-Fi 连接失败: $msg');
          setState(() {
            _wifiConnectionStatus = 'disconnected';
          });
          String detailedMessage = '''
设备 Wi-Fi 连接失败: $msg

请检查：
1. 智能眼镜是否已开启 Wi-Fi 热点
2. 设备热点名称是否为 "$_wifiSSID"
3. 设备热点密码是否为 "$_wifiPassword"

如果热点名称或密码不同，请手动连接设备 Wi-Fi，然后点击刷新文件按钮。
          ''';
          
          _showWifiConnectionDialog(detailedMessage);
        }
        return;
      }
      
      // 处理其他操作结果
      if (code == 0) {
        ToastUtil.showToast(AppStrings.wifiEnabled);
        // 底层已自动处理延时连接，Flutter 端无需额外处理
        print('Wi-Fi 开启成功，底层将自动连接设备热点');
      } else {
        ToastUtil.showToast('${AppStrings.operationFailed}: $msg');
      }
    });
    
    // 监听运行状态（包含Wi-Fi状态）
    _runningStatusSubscription = widget.glassesPlugin.runningStatusEveStm.listen((status) {
      print('MediaFilePage 收到运行状态事件: $status');
      // 检查文件同步状态
      if (status.containsKey('fileSync')) {
        bool fileSync = status['fileSync'] ?? false;
        print('MediaFilePage fileSync 状态: $fileSync, 当前 _isWifiEnabled: $_isWifiEnabled');
        if (fileSync && !_isWifiEnabled) {
          print('MediaFilePage 更新 _isWifiEnabled 为 true');
          setState(() {
            _isWifiEnabled = true;
          });
          // ToastUtil.showToast(AppStrings.wifiEnabled);
        } else if (!fileSync && _isWifiEnabled) {
          print('MediaFilePage 更新 _isWifiEnabled 为 false');
          setState(() {
            _isWifiEnabled = false;
            _baseUrl = '';
            _files.clear();
          });
          // ToastUtil.showToast(AppStrings.wifiDisabled);
        }
      }
    });

    // 监听媒体文件事件
    _mediaFileSubscription = widget.glassesPlugin.mediaFileEveStm.listen((file) {
      if (file == null) return;
      // 类型转换
      final mediaFile = file as MediaFileBean;
      setState(() {
        _files.add(mediaFile);
      });
    });
  }

  /// 检查Wi-Fi状态
  void _checkWifiStatus() async {
    // 不再主动查询，依赖事件流接收状态
    // 如果需要主动查询，可以尝试其他方法
    print('等待运行状态事件更新...');
  }
  
  /// 手动刷新状态
  Future<void> _refreshStatus() async {
    try {
      // 尝试获取运行状态（可能会失败）
      await widget.glassesPlugin.getRunningStatus();
    } catch (e) {
      print('刷新状态失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.mediaFileManagement),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshFileList,
          ),
        ],
      ),
      body: Column(
        children: [
          // Wi-Fi状态卡片
          _buildWifiStatusCard(),
          _buildFileStatsCard(),
          // 下载位置卡片
          _buildDownloadLocationCard(),
          // 操作栏
          _buildActionBar(),
          // 文件列表
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _files.isEmpty
                    ? Center(child: Text(AppStrings.noFiles))
                    : _buildFileList(),
          ),
          // 下载进度条
          if (_isDownloading) _buildDownloadProgress(),
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
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getWifiStatusColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getWifiStatusIcon(),
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getWifiStatusText(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Wi-Fi 配置区域
            Container(
              padding: EdgeInsets.all(12),
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
                      Icon(Icons.settings, color: Colors.blue[600], size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Wi-Fi 配置',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[600],
                        ),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: _showWifiConfigDialog,
                        child: Text('修改', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '热点名称: $_wifiSSID',
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '密码: ${_wifiPassword.length > 0 ? '*' * _wifiPassword.length : '未设置'}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            if (_isWifiEnabled && _baseUrl.isNotEmpty) ...[
              Text(
                '${AppStrings.baseUrl}: $_baseUrl',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
            ],
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
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
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _checkWifiConnection,
                  icon: Icon(Icons.refresh),
                  label: Text('检查连接'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建文件统计卡片
  Widget _buildFileStatsCard() {
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
                Text(
                  '文件统计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                // 刷新文件按钮
                ElevatedButton.icon(
                  onPressed: _isWifiEnabled ? _getMediaFileList : null,
                  icon: Icon(Icons.refresh, size: 16),
                  label: Text('刷新文件'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isWifiEnabled ? Colors.blue : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('总文件数', '${_files.length}', Icons.insert_drive_file),
                ),
                Expanded(
                  child: _buildStatItem('已选择', '${_selectedFiles.length}', Icons.check_circle),
                ),
                Expanded(
                  child: _buildStatItem('已下载', '${_downloadedCount}', Icons.download_done),
                ),
              ],
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: _downloadProgress),
              const SizedBox(height: 8),
              Text(
                '下载进度: ${(_downloadProgress * 100).toInt()}%',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
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

  /// 构建下载位置卡片
  Widget _buildDownloadLocationCard() {
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
                Text(
                  AppStrings.downloadLocation,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.copy, size: 20),
                  onPressed: () => _copyPathToClipboard(_downloadPath),
                ),
                IconButton(
                  icon: Icon(Icons.folder_open, size: 20),
                  onPressed: () => _openFileLocation(_downloadPath),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _downloadPath,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建操作栏
  Widget _buildActionBar() {
    if (_files.isEmpty) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: _selectedFiles.length == _files.length,
            onChanged: (value) => _selectAllFiles(value ?? false),
          ),
          Text(AppStrings.selectAll),
          Spacer(),
          if (_selectedFiles.isNotEmpty) ...[
            TextButton.icon(
              onPressed: _batchDownload,
              icon: Icon(Icons.download),
              label: Text(AppStrings.batchDownload),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _batchDelete,
              icon: Icon(Icons.delete),
              label: Text(AppStrings.batchDelete),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建文件列表
  Widget _buildFileList() {
    if (_isGridView) {
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
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _files.length,
        itemBuilder: (context, index) => _buildFileListItem(_files[index]),
      );
    }
  }

  /// 构建文件网格项
  Widget _buildFileGridItem(MediaFileBean file) {
    bool isSelected = _selectedFiles.contains(file.fileName);
    bool isDownloading = _fileDownloadProgress.containsKey(file.fileName);
    
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
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
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
                  // 下载进度
                  if (isDownloading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: _fileDownloadProgress[file.fileName],
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.download, size: 20),
                          onPressed: () => _downloadSingleFile(file),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 20),
                          onPressed: () => _deleteFile(file),
                        ),
                      ],
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

  /// 构建文件列表项
  Widget _buildFileListItem(MediaFileBean file) {
    bool isSelected = _selectedFiles.contains(file.fileName);
    bool isDownloading = _fileDownloadProgress.containsKey(file.fileName);
    
    return Card(
      child: ListTile(
        leading: Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildFileIcon(file.fileType),
            ),
            if (isDownloading)
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: _fileDownloadProgress[file.fileName],
                ),
              ),
          ],
        ),
        title: Text(file.fileName),
        subtitle: Text(_formatFileSize(file.fileSize)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) => _toggleFileSelection(file.fileName),
            ),
            IconButton(
              icon: Icon(Icons.download),
              onPressed: () => _downloadSingleFile(file),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteFile(file),
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
  Widget _buildDownloadProgress() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          LinearProgressIndicator(value: _downloadProgress),
          const SizedBox(height: 8),
          Text('${AppStrings.downloading}: ${(_downloadProgress * 100).toInt()}%'),
        ],
      ),
    );
  }

  /// 开启Wi-Fi
  Future<void> _enableWifi() async {
    try {
      await widget.glassesPlugin.enableWifi(
        wifiType: 1, // 1-文件同步模式
        ssid: _wifiSSID,
        password: _wifiPassword,
      );
      setState(() {
        _isWifiEnabled = true;
      });
      ToastUtil.showToast(AppStrings.wifiEnabled);
      // 底层已自动处理延时连接，Flutter 端无需额外处理
      print('Wi-Fi 开启成功，底层将自动连接设备热点');
    } catch (e) {
      print('开启 Wi-Fi 失败: $e');
      ToastUtil.showToast('${AppStrings.enableWifiFailed}: $e');
    }
  }

  /// 关闭Wi-Fi
  Future<void> _disableWifi() async {
    try {
      await widget.glassesPlugin.disableWifi();
      setState(() {
        _isWifiEnabled = false;
        _wifiConnectionStatus = 'disconnected';
        _baseUrl = '';
        _files.clear();
      });
      ToastUtil.showToast(AppStrings.wifiDisabled);
    } catch (e) {
      ToastUtil.showToast('${AppStrings.disableWifiFailed}: $e');
    }
  }

  /// 获取 Wi-Fi 连接状态显示文本
  String _getWifiStatusText() {
    // 根据内部状态返回对应的国际化文本
    if (_wifiConnectionStatus == 'connected') {
      return AppStrings.connectedStatus;
    } else if (_wifiConnectionStatus == 'connecting') {
      return AppStrings.connectingStatus;
    } else {
      return AppStrings.disconnectedStatus;
    }
  }

  /// 获取 Wi-Fi 连接状态颜色
  Color _getWifiStatusColor() {
    switch (_wifiConnectionStatus) {
      case 'disconnected':
        return Colors.grey;
      case 'connecting':
        return Colors.orange;
      case 'connected':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// 获取 Wi-Fi 连接状态图标
  IconData _getWifiStatusIcon() {
    switch (_wifiConnectionStatus) {
      case 'disconnected':
        return Icons.wifi_off;
      case 'connecting':
        return Icons.hourglass_empty;
      case 'connected':
        return Icons.wifi;
      default:
        return Icons.wifi_off;
    }
  }

  /// 显示 Wi-Fi 配置对话框
  void _showWifiConfigDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wi-Fi 配置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('请输入设备 Wi-Fi 热点的名称和密码'),
              const SizedBox(height: 8),
              Text(
                '热点名称：1-32字符，只能包含字母、数字、-和_',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '密码：8-63字符，不能包含空格',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ssidController,
                decoration: InputDecoration(
                  labelText: '热点名称 (SSID)',
                  hintText: '例如: Glass-01',
                  border: OutlineInputBorder(),
                ),
                maxLength: 32,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: '例如: 12345678',
                  border: OutlineInputBorder(),
                ),
                obscureText: false, // 显示明文，方便用户输入
                maxLength: 63,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                _saveWifiConfig();
                Navigator.of(context).pop();
              },
              child: Text('保存'),
            ),
          ],
        );
      },
    );
  }

  /// 保存 Wi-Fi 配置
  void _saveWifiConfig() {
    String newSSID = _ssidController.text.trim();
    String newPassword = _passwordController.text.trim();
    
    if (newSSID.isEmpty) {
      ToastUtil.showToast('热点名称不能为空');
      return;
    }
    
    if (newPassword.isEmpty) {
      ToastUtil.showToast('密码不能为空');
      return;
    }
    
    // SSID 验证：长度 1-32 字符，只允许字母、数字、连字符和下划线
    if (newSSID.length > 32) {
      ToastUtil.showToast('热点名称过长，最多 32 个字符');
      return;
    }
    
    // SSID 不能包含特殊字符（除了连字符和下划线）
    final ssidPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!ssidPattern.hasMatch(newSSID)) {
      ToastUtil.showToast('热点名称只能包含字母、数字、连字符(-)和下划线(_)');
      return;
    }
    
    // 密码验证：长度 8-63 字符
    if (newPassword.length < 8) {
      ToastUtil.showToast('密码过短，至少需要 8 个字符');
      return;
    }
    
    if (newPassword.length > 63) {
      ToastUtil.showToast('密码过长，最多 63 个字符');
      return;
    }
    
    // 密码不能包含空格
    if (newPassword.contains(' ')) {
      ToastUtil.showToast('密码不能包含空格');
      return;
    }
    
    setState(() {
      _wifiSSID = newSSID;
      _wifiPassword = newPassword;
    });
    
    ToastUtil.showToast('Wi-Fi 配置已保存');
    print('Wi-Fi 配置已更新: SSID=$_wifiSSID, Password=$_wifiPassword');
  }

  /// 显示 Wi-Fi 连接失败对话框
  void _showWifiConnectionDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('自动连接失败'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('由于 iOS 系统限制，自动连接可能失败。'),
              SizedBox(height: 12),
              Text('请手动连接：'),
              SizedBox(height: 8),
              Text('1. 打开 设置 → Wi-Fi'),
              Text('2. 找到热点: $_wifiSSID'),
              Text('3. 输入密码: $_wifiPassword'),
              Text('4. 连接成功后返回应用'),
              SizedBox(height: 12),
              Text('然后点击界面上的"检查连接"按钮验证。'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('知道了'),
            ),
          ],
        );
      },
    );
  }

  /// 连接设备 Wi-Fi（参考官方Demo实现）
  Future<void> _connectToDeviceWifi() async {
    try {
      print('开始连接设备 Wi-Fi...');
      print('使用配置: SSID=$_wifiSSID, Password=$_wifiPassword');
      
      // 更新状态为连接中
      setState(() {
        _wifiConnectionStatus = 'connecting';
      });
      
      // 调用 Flutter SDK 中的连接设备 Wi-Fi 方法，传入配置的凭据
      await widget.glassesPlugin.connectToDeviceWifiWithCredentials(_wifiSSID, _wifiPassword);
      
      print('已发送连接设备 Wi-Fi 请求，等待连接结果...');
      ToastUtil.showToast('正在连接设备 Wi-Fi: $_wifiSSID...');
      
    } catch (e) {
      print('连接设备 Wi-Fi 失败: $e');
      ToastUtil.showToast('连接 Wi-Fi 失败: $e');
      // 连接失败，恢复状态为未连接
      setState(() {
        _wifiConnectionStatus = 'disconnected';
      });
    }
  }

  /// 检查 Wi-Fi 连接状态
  Future<void> _checkWifiConnection() async {
    try {
      print('检查 Wi-Fi 连接状态: $_wifiSSID');
      ToastUtil.showToast('正在检查 Wi-Fi 连接状态...');
      
      await widget.glassesPlugin.checkWifiConnection(_wifiSSID);
      
    } catch (e) {
      print('检查 Wi-Fi 连接状态失败: $e');
      ToastUtil.showToast('检查连接状态失败: $e');
    }
  }

  /// 获取媒体文件列表
  Future<void> _getMediaFileList() async {
    print('=== 开始获取文件列表 ===');
    print('_isWifiEnabled: $_isWifiEnabled');
    print('_baseUrl: $_baseUrl');
    
    if (!_isWifiEnabled) {
      print('Wi-Fi未启用，无法获取文件列表');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先开启Wi-Fi')),
      );
      return;
    }

    if (_baseUrl.isEmpty) {
      print('BaseUrl为空，尝试使用默认地址或等待BaseUrl事件');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('正在等待BaseUrl，请稍后重试')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 参考官方Demo实现：请求 media.config 获取文件列表
      final configUrl = '$_baseUrl/media.config';
      print('正在获取文件列表: $configUrl');

      // 使用HTTP请求获取配置
      final uri = Uri.parse(configUrl);
      final request = await HttpClient().getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final data = await response.transform(utf8.decoder).join();
        print('获取到配置数据: $data');

        // 解析文件列表（按行分割）
        final fileNames = data.split('\n').where((line) => line.isNotEmpty).toList();
        
        setState(() {
          _totalFiles = fileNames.length;
          _files = fileNames.map((fileName) {
            // 根据文件扩展名确定文件类型
            int fileType = 0; // 默认图片类型
            if (fileName.toLowerCase().endsWith('.jpg') || 
                fileName.toLowerCase().endsWith('.jpeg') ||
                fileName.toLowerCase().endsWith('.png')) {
              fileType = 0; // 图片
            } else if (fileName.toLowerCase().endsWith('.mp4') ||
                       fileName.toLowerCase().endsWith('.mov')) {
              fileType = 1; // 视频
            } else if (fileName.toLowerCase().endsWith('.mp3') ||
                       fileName.toLowerCase().endsWith('.wav')) {
              fileType = 2; // 音频
            }

            return MediaFileBean(
              fileName: fileName,
              fileType: fileType,
              fileSize: 0, // 官方Demo中没有文件大小信息
              createTime: DateTime.now().millisecondsSinceEpoch,
            );
          }).toList();
          _isLoading = false;
        });

        print('成功解析 ${_files.length} 个文件');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功获取 ${_files.length} 个文件'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('HTTP ${response.statusCode}: 无法获取文件列表');
      }
    } catch (e) {
      print('获取文件列表失败: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('获取文件列表失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 刷新文件列表
  Future<void> _refreshFileList() async {
    if (_isWifiEnabled) {
      await _getMediaFileList();
    }
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

  /// 全选/取消全选
  void _selectAllFiles(bool selectAll) {
    setState(() {
      if (selectAll) {
        _selectedFiles = Set.from(_files.map((f) => f.fileName));
      } else {
        _selectedFiles.clear();
      }
    });
  }

  /// 下载单个文件
  Future<void> _downloadSingleFile(MediaFileBean file) async {
    if (_downloadPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('下载路径未设置')),
      );
      return;
    }

    try {
      print('开始下载文件: ${file.fileName}');
      
      // 构建下载URL
      final downloadUrl = '$_baseUrl${file.fileName}';
      
      // 构建本地保存路径
      final fileName = file.fileName;
      final localPath = path.join(_downloadPath, fileName);
      final localFile = File(localPath);

      // 确保目录存在
      final directory = localFile.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 使用HTTP下载文件（参考官方Demo使用Alamofire，这里使用HttpClient）
      final uri = Uri.parse(downloadUrl);
      final request = await HttpClient().getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        // 保存文件
        final bytes = await response.fold<List<int>>(
          [],
          (previous, element) => previous..addAll(element),
        );
        
        await localFile.writeAsBytes(bytes);
        
        setState(() {
          _downloadedCount++;
        });

        print('文件下载完成: $localPath');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('文件下载完成: ${file.fileName}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('HTTP ${response.statusCode}: 下载失败');
      }
    } catch (e) {
      print('下载文件失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('下载失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 批量下载
  Future<void> _batchDownload() async {
    final selectedFiles = _files.where((f) => _selectedFiles.contains(f.fileName));
    
    if (selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先选择要下载的文件')),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      print('开始批量下载 ${selectedFiles.length} 个文件');
      
      for (int i = 0; i < selectedFiles.length; i++) {
        final file = selectedFiles.elementAt(i);
        
        // 更新进度
        setState(() {
          _downloadProgress = (i + 1) / selectedFiles.length;
        });

        await _downloadSingleFile(file);
        
        // 官方Demo中下载完一个文件后继续下一个
        print('已下载 ${i + 1}/${selectedFiles.length} 个文件');
      }

      setState(() {
        _isDownloading = false;
        _downloadProgress = 1.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('批量下载完成！'),
          backgroundColor: Colors.green,
        ),
      );

      // 官方Demo：下载完成后关闭Wi-Fi
      if (_downloadedCount >= _totalFiles) {
        print('所有文件下载完成，关闭Wi-Fi');
        await _disableWifi();
      }
    } catch (e) {
      print('批量下载失败: $e');
      setState(() {
        _isDownloading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('批量下载失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 删除文件
  Future<void> _deleteFile(MediaFileBean file) async {
    final confirmed = await _showDeleteConfirmDialog(file.fileName);
    if (!confirmed) return;
    
    try {
      final success = await widget.glassesPlugin.deleteFile(
        fileType: 3,
        fileName: file.fileName,
      );
      
      if (success) {
        setState(() {
          _files.removeWhere((f) => f.fileName == file.fileName);
          _selectedFiles.remove(file.fileName);
        });
        ToastUtil.showToast(AppStrings.deleteSuccess);
      } else {
        ToastUtil.showToast(AppStrings.deleteFailed);
      }
    } catch (e) {
      ToastUtil.showToast('${AppStrings.deleteFailed}: $e');
    }
  }

  /// 批量删除
  Future<void> _batchDelete() async {
    final confirmed = await _showBatchDeleteConfirmDialog();
    if (!confirmed) return;
    
    try {
      for (String fileName in _selectedFiles) {
        await widget.glassesPlugin.deleteFile(
          fileType: 3,
          fileName: fileName,
        );
      }
      
      setState(() {
        _files.removeWhere((f) => _selectedFiles.contains(f.fileName));
        _selectedFiles.clear();
      });
      
      ToastUtil.showToast(AppStrings.batchDeleteSuccess);
    } catch (e) {
      ToastUtil.showToast('${AppStrings.batchDeleteFailed}: $e');
    }
  }

  /// 复制路径到剪贴板
  Future<void> _copyPathToClipboard(String path) async {
    await Clipboard.setData(ClipboardData(text: path));
    ToastUtil.showToast(AppStrings.pathCopied);
  }

  /// 打开文件位置
  Future<void> _openFileLocation(String path) async {
    // TODO: 实现打开文件夹功能
    ToastUtil.showToast(AppStrings.openFolderFeatureComingSoon);
  }

  /// 显示删除确认对话框
  Future<bool> _showDeleteConfirmDialog(String fileName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.confirmDelete),
        content: Text('${AppStrings.confirmDeleteFile}: $fileName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示批量删除确认对话框
  Future<bool> _showBatchDeleteConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.confirmBatchDelete),
        content: Text('${AppStrings.confirmDeleteFiles}: ${_selectedFiles.length} ${AppStrings.files}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示批量下载完成对话框
  void _showBatchDownloadCompleteDialog(List<String> filePaths) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.batchDownloadComplete),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.filesDownloadedTo),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _downloadPath,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, size: 20),
                    onPressed: () => _copyPathToClipboard(_downloadPath),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${AppStrings.totalFiles}: ${filePaths.length}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _openFileLocation(_downloadPath),
            child: Text(AppStrings.openFolder),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );
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
}
