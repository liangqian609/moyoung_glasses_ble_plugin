import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moyoung_glasses_ble_plugin/moyoung_glasses_ble.dart';
import 'package:moyoung_glasses_ble_plugin/impl/moyoung_glasses_beans.dart';
import 'event_manager.dart';
import 'mac_address_cache.dart';
import 'l10n/app_strings.dart';

/// 智能眼镜扫描页面
/// Smart Glasses Scan Page
class GlassesScanPage extends StatefulWidget {
  const GlassesScanPage({Key? key}) : super(key: key);

  @override
  State<GlassesScanPage> createState() => _GlassesScanPageState();
}

class _GlassesScanPageState extends State<GlassesScanPage> {
  final MoYoungGlassesBle _glassesBle = MoYoungGlassesBle();
  List<BleScanBean> _devices = [];
  List<Map<String, dynamic>> _connectedDevices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  StreamSubscription? _scanSub;
  StreamSubscription? _connectionSuccessSub;
  BleScanBean? _connectingDevice;

  @override
  void initState() {
    super.initState();
    _checkBluetooth();
    _loadConnectedDevices();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _connectionSuccessSub?.cancel();
    super.dispose();
  }

  Future<void> _checkBluetooth() async {
    final isEnabled = await _glassesBle.checkBluetoothEnable;
    if (!isEnabled) {
      _showMessage(AppStrings.pleaseEnableBluetooth);
    }
  }

  /// 加载已连接的设备列表
  Future<void> _loadConnectedDevices() async {
    try {
      final connectedDevices = await _glassesBle.getConnectedDevices();
      setState(() {
        _connectedDevices = connectedDevices.map((device) {
          return Map<String, dynamic>.from(device);
        }).toList();
      });
      debugPrint('Loaded ${connectedDevices.length} connected devices');
    } catch (e) {
      debugPrint('Failed to load connected devices: $e');
    }
  }

  /// 检查设备是否已连接
  bool _isDeviceConnected(BleScanBean device) {
    for (var connectedDevice in _connectedDevices) {
      // 安全地比较设备名称和地址
      try {
        String connectedName = connectedDevice['name']?.toString() ?? '';
        String connectedAddress = connectedDevice['address']?.toString() ?? '';
        
        if (connectedName.isNotEmpty && 
            connectedAddress.isNotEmpty &&
            connectedName == device.name && 
            connectedAddress == device.address) {
          return true;
        }
      } catch (e) {
        debugPrint('Error comparing device: $e');
        continue;
      }
    }
    return false;
  }

  /// 刷新已连接设备列表（用于下拉刷新）
  Future<void> _refreshConnectedDevices() async {
    debugPrint('Refreshing connected devices...');
    await _loadConnectedDevices();
    
    // 刷新UI显示
    if (mounted) {
      setState(() {});
    }
    
    debugPrint('Connected devices refreshed');
  }

  Future<void> _startScan() async {
    // 开始扫描前先刷新已连接设备列表
    await _loadConnectedDevices();
    
    setState(() {
      _devices = [];
      _isScanning = true;
    });

    // 监听扫描结果
    _scanSub?.cancel();
    debugPrint('Starting to listen to scan event stream...');
    _scanSub = _glassesBle.bleScanEveStm.listen((device) {
      if (device == null) return;
      // 类型转换
      final scanDevice = device as BleScanBean;
      debugPrint('Received scan event: ${scanDevice.name} (${scanDevice.address})');
      if (scanDevice.isCompleted) {
        debugPrint('Scan completed');
        setState(() {
          _isScanning = false;
        });
      } else if (scanDevice.address?.isNotEmpty == true) {
        debugPrint('Adding device: ${scanDevice.name}');
        setState(() {
          if (!_devices.any((d) => d.address == scanDevice.address)) {
            _devices.add(scanDevice);
            // 按信号强度排序
            _devices.sort((a, b) => b.mRssi.compareTo(a.mRssi));
            debugPrint('Device added, current device count: ${_devices.length}');
          } else {
            debugPrint('Device already exists, skipping addition');
          }
        });
      }
    },
      onError: (e) {
        debugPrint('Scan event stream error: $e');
      },
      onDone: () {
        debugPrint('Scan event stream ended');
      }
    );

    // 开始扫描（10秒）
    try {
      await _glassesBle.startScan(10000);
    } catch (e) {
      _showMessage(AppStrings.scanFailed(e.toString()));
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _stopScan() async {
    _glassesBle.cancelScan();
    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _connectDevice(BleScanBean device) async {
    _stopScan();
    
    setState(() {
      _isConnecting = true;
      _connectingDevice = device;
    });
    
    _showMessage(AppStrings.connectingToDevice(device.name.isEmpty ? device.address : device.name));
    
    // 监听连接成功通知
    _connectionSuccessSub?.cancel();
    _connectionSuccessSub = EventManager().on<Map<String, dynamic>>(EventNames.connectionSuccess).listen((data) {
      debugPrint('Scan page received connection success notification');
      setState(() {
        _isConnecting = false;
      });
      
      // 保存 MAC 地址到缓存
      if (_connectingDevice != null) {
        String deviceName = _connectingDevice!.name.isEmpty ? _connectingDevice!.address : _connectingDevice!.name;
        MacAddressCache.saveDeviceMac(_connectingDevice!.address, deviceName);
      }
      
      // 连接成功，返回 main.dart
      Navigator.pop(context, {
        'connected': true,
        'device': _connectingDevice,
      });
    });
    
    try {
      await _glassesBle.connect(ConnectBean(
        autoConnect: false,
        address: device.address,
      ));
      debugPrint('Connection request sent');
    } catch (e) {
      setState(() {
        _isConnecting = false;
      });
      _showMessage(AppStrings.connectionFailed(e.toString()));
      _connectionSuccessSub?.cancel();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.smartGlassesTest),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 已连接设备信息栏
          if (_connectedDevices.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  Icon(
                    Icons.bluetooth_connected,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_connectedDevices.length} ${AppStrings.connectedDevices}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _refreshConnectedDevices,
                    child: Text(
                      AppStrings.refresh,
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // 扫描控制区
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isScanning 
                        ? AppStrings.scanningWithCount(_devices.length)
                        : AppStrings.devicesFound(_devices.length),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isScanning ? _stopScan : _startScan,
                  icon: Icon(_isScanning ? Icons.stop : Icons.bluetooth_searching),
                  label: Text(_isScanning ? AppStrings.stop : AppStrings.scan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isScanning ? Colors.red : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // 设备列表
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth_searching,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isScanning ? AppStrings.searchingForDevices : AppStrings.clickToScan,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshConnectedDevices,
                    child: ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        return _buildDeviceItem(device);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(BleScanBean device) {
    // 信号强度指示
    int signalLevel = 0;
    if (device.mRssi >= -50) {
      signalLevel = 4;
    } else if (device.mRssi >= -60) {
      signalLevel = 3;
    } else if (device.mRssi >= -70) {
      signalLevel = 2;
    } else if (device.mRssi >= -80) {
      signalLevel = 1;
    }
    bool isConnected = _isDeviceConnected(device);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isConnected ? Colors.green.shade50 : null,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isConnected ? Colors.green.shade100 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(24),
            border: isConnected ? Border.all(color: Colors.green, width: 2) : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.visibility,  // 眼镜图标
                  color: isConnected ? Colors.green.shade700 : Colors.blue.shade700,
                  size: 28,
                ),
              ),
              if (isConnected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                device.name.isEmpty ? AppStrings.unknownDevice : device.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isConnected ? Colors.green.shade700 : null,
                ),
              ),
            ),
            if (isConnected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppStrings.connected,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(device.address),
            Row(
              children: [
                _buildSignalIndicator(signalLevel),
                const SizedBox(width: 8),
                Text(
                  '${device.mRssi} dBm',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: isConnected ? null : (_isConnecting ? null : () => _connectDevice(device)),
          style: ElevatedButton.styleFrom(
            backgroundColor: isConnected ? Colors.grey : null,
          ),
          child: _isConnecting 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  isConnected ? AppStrings.connected : AppStrings.connect,
                  style: TextStyle(
                    color: isConnected ? Colors.grey.shade600 : null,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSignalIndicator(int level) {
    return Row(
      children: List.generate(4, (index) {
        return Container(
          width: 4,
          height: 6 + index * 3.0,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: index < level ? Colors.green : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
