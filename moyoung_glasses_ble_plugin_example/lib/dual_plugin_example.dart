import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moyoung_ble_plugin/moyoung_ble.dart' as watch;
import 'package:moyoung_glasses_ble_plugin/moyoung_glasses_ble.dart' as glasses;
import 'package:permission_handler/permission_handler.dart';

/// 双插件验证页：
/// - 眼镜：只展示状态（连接动作仍在主页面）
/// - 手表：参考官方手表示例，提供权限、扫描、设备列表与连接
class DualPluginExample extends StatefulWidget {
  const DualPluginExample({super.key});

  @override
  State<DualPluginExample> createState() => _DualPluginExampleState();
}

class _DualPluginExampleState extends State<DualPluginExample> {
  static const EventChannel _watchScanEventChannel =
      EventChannel('event_scan_device');
  static const EventChannel _watchConnStateEventChannel =
      EventChannel('event_connection_state');
  static const EventChannel _watchBatteryEventChannel =
      EventChannel('event_device_battery');
  static const MethodChannel _watchConnMethodChannel =
      MethodChannel('method_connection');

  final glasses.MoYoungGlassesBle _glassesPlugin = glasses.MoYoungGlassesBle();
  final watch.MoYoungBle _watchPlugin = watch.MoYoungBle();
  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  final List<watch.BleScanBean> _watchDevices = <watch.BleScanBean>[];

  String _watchConnectionStatus = '未连接';
  bool _watchBluetoothEnabled = false;
  String _watchBatteryOverview = '未查询';
  String _watchVersionOverview = '未查询';
  Completer<String>? _pendingWatchBatteryQuery;
  String _scanButtonText = 'startScan(10*1000)';
  String _cancelScanText = 'cancelScan()';

  String _mapConnectionState(int state) {
    switch (state) {
      case 0:
        return '未连接';
      case 1:
        return '连接中';
      case 2:
        return '已连接';
      case 3:
        return '断开中';
      default:
        return '未知($state)';
    }
  }

  String? _parseWatchBatteryText(dynamic rawEvent) {
    final Map<dynamic, dynamic>? map = _normalizeEventMap(rawEvent, eventName: '手表电量事件');
    if (map == null) {
      return null;
    }

    final Object? battery = map['battery'] ?? map['level'];
    final Object? charging = map['charging'];
    if (battery == null) {
      return null;
    }

    String text = '$battery%';
    if (charging != null) {
      text = '$text (${charging == true ? '充电中' : '未充电'})';
    }
    return text;
  }

  Future<void> _queryWatchBattery() async {
    try {
      _pendingWatchBatteryQuery = Completer<String>();
      final dynamic result = await _watchConnMethodChannel.invokeMethod<dynamic>('queryBattery');
      debugPrint('[dual] 手表 queryBattery 返回: $result (${result.runtimeType})');

      String batteryText = '查询指令已发送，等待设备上报';
      if (result is Map) {
        final Object? battery = result['battery'] ?? result['level'];
        final Object? charging = result['charging'];
        if (battery != null) {
          batteryText = '$battery%';
        }
        if (charging != null) {
          batteryText = '$batteryText (${charging == true ? '充电中' : '未充电'})';
        }
      } else if (result is num) {
        batteryText = '${result.toInt()}%';
      } else if (result is String && result.trim().isNotEmpty) {
        batteryText = result.trim();
      } else if (result == null) {
        debugPrint('[dual] 手表 queryBattery 同步返回 null，改为等待 event_device_battery 回传');
      }

      if (!mounted) return;
      setState(() {
        _watchBatteryOverview = batteryText;
      });

      if (result == null || result == true) {
        try {
          final String eventBatteryText = await _pendingWatchBatteryQuery!.future.timeout(
            const Duration(seconds: 3),
          );
          if (!mounted) return;
          setState(() {
            _watchBatteryOverview = eventBatteryText;
          });
        } on TimeoutException {
          debugPrint('[dual][warn] 手表电量查询等待事件超时，保持当前展示: $_watchBatteryOverview');
        }
      }
    } catch (e) {
      debugPrint('[dual][error] 查询手表电量失败: $e');
      if (!mounted) return;
      setState(() {
        _watchBatteryOverview = '查询失败';
      });
      Fluttertoast.showToast(msg: '查询手表电量失败: $e');
    } finally {
      _pendingWatchBatteryQuery = null;
    }
  }

  Future<void> _queryWatchVersion() async {
    try {
      dynamic result = await _watchConnMethodChannel.invokeMethod<dynamic>(
        'queryDeviceVersion',
        <String, dynamic>{'versionType': 1},
      );
      // 部分 watch 版本不接收参数，改为无参重试一次。
      result ??= await _watchConnMethodChannel.invokeMethod<dynamic>('queryDeviceVersion');
      // 再兜底兼容旧方法名，避免因 SDK 版本差异导致无返回。
      result ??= await _watchConnMethodChannel.invokeMethod<dynamic>('queryFirmwareVersion');
      debugPrint('[dual] 手表 queryDeviceVersion 返回: $result (${result.runtimeType})');

      String versionText = '查询指令已发送，等待设备回传';
      if (result is String && result.trim().isNotEmpty) {
        versionText = result.trim();
      } else if (result is Map) {
        versionText = (result['version'] ?? result['firmware'] ?? result.toString()).toString();
      }

      if (!mounted) return;
      setState(() {
        _watchVersionOverview = versionText;
      });
    } catch (e) {
      debugPrint('[dual][error] 查询手表版本号失败: $e');
      if (!mounted) return;
      setState(() {
        _watchVersionOverview = '查询失败';
      });
      Fluttertoast.showToast(msg: '查询手表版本号失败: $e');
    }
  }

  Map<dynamic, dynamic>? _normalizeEventMap(dynamic rawEvent, {required String eventName}) {
    if (rawEvent is Map) {
      return rawEvent;
    }

    if (rawEvent is String) {
      final String payload = rawEvent.trim();
      if (payload.isEmpty) {
        debugPrint('[dual][warn] $eventName 是空字符串，已忽略');
        return null;
      }

      try {
        final dynamic decoded = jsonDecode(payload);
        if (decoded is Map) {
          return decoded;
        }
        debugPrint('[dual][warn] $eventName 字符串解析后不是 Map，已忽略: ${decoded.runtimeType}');
        return null;
      } catch (e) {
        debugPrint('[dual][warn] $eventName 不是合法 JSON 字符串，已忽略: $e');
        return null;
      }
    }

    debugPrint('[dual][warn] $eventName 类型未知，已忽略: ${rawEvent.runtimeType}');
    return null;
  }

  watch.ConnectStateBean? _parseWatchConnStateEvent(dynamic rawEvent) {
    try {
      if (rawEvent is Map) {
        final Map<dynamic, dynamic> map = rawEvent;
        return watch.ConnectStateBean(
          autoConnect: map['autoConnect'] == true,
          connectState: (map['connectState'] as num?)?.toInt() ?? 0,
        );
      }

      if (rawEvent is String) {
        return watch.connectStateBeanFromJson(rawEvent);
      }

      debugPrint('[dual][warn] 连接状态事件类型未知，已忽略: ${rawEvent.runtimeType}');
      return null;
    } catch (e) {
      debugPrint('[dual][error] 解析手表连接状态事件失败: $e, raw=$rawEvent');
      return null;
    }
  }

  String _formatWatchDeviceLabel(watch.BleScanBean device) {
    final String name = device.name.trim();
    final String address = device.address.trim();

    if (name.isEmpty && address.isEmpty) {
      debugPrint('[dual][warn] 设备名称和地址都为空，使用兜底文案');
      return '未知设备';
    }
    if (name.isEmpty) {
      return address;
    }
    if (address.isEmpty) {
      return name;
    }
    return '$name, $address';
  }

  @override
  void initState() {
    super.initState();
    _subscribeStreams();
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> s in _streamSubscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  watch.BleScanBean? _parseWatchScanEvent(dynamic rawEvent) {
    try {
      final Map<dynamic, dynamic>? map = _normalizeEventMap(rawEvent, eventName: '扫描事件');
      if (map == null) {
        return null;
      }

      final List<int> scanRecord = (map['mScanRecord'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => (e as num).toInt())
          .toList();

      return watch.BleScanBean(
        isCompleted: map['isCompleted'] == true,
        address: (map['address'] ?? '').toString(),
        mRssi: (map['mRssi'] as num?)?.toInt() ?? 0,
        mScanRecord: scanRecord,
        name: (map['name'] ?? '').toString(),
        platform: (map['platform'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      debugPrint('[dual][error] 解析手表扫描事件失败: $e, raw=$rawEvent');
      return null;
    }
  }

  void _subscribeStreams() {
    _streamSubscriptions.add(
      _glassesPlugin.connStateEveStm.listen((glasses.ConnectStateBean event) {
        debugPrint('[dual] 眼镜连接状态变化: ${_mapConnectionState(event.connectState)}');
      }, onError: (Object e) {
        debugPrint('[dual][error] 眼镜连接状态监听失败: $e');
      }),
    );

    _streamSubscriptions.add(
      _glassesPlugin.batteryEveStm.listen((Map<String, dynamic> battery) {
        final Object? level = battery['level'];
        debugPrint('[dual] 眼镜电量变化: ${level == null ? '未知' : '$level%'}');
      }, onError: (Object e) {
        debugPrint('[dual][error] 眼镜电量监听失败: $e');
      }),
    );

    _streamSubscriptions.add(
      _watchScanEventChannel.receiveBroadcastStream().listen((dynamic rawEvent) {
        final watch.BleScanBean? event = _parseWatchScanEvent(rawEvent);
        if (event == null) {
          return;
        }
        if (!mounted) return;
        if (event.isCompleted) {
          setState(() {
            _scanButtonText = 'startScan(10*1000)';
          });
          return;
        }

        final String name = event.name;
        final String address = event.address;
        if (address.isEmpty) {
          debugPrint('[dual][warn] 扫描到地址为空的设备，已忽略');
          return;
        }

        final bool exists =
            _watchDevices.any((watch.BleScanBean d) => d.address == address);
        if (!exists) {
          setState(() {
            _watchDevices.add(event);
          });
          debugPrint('[dual] 扫描到手表设备: $name, $address');
        }
      }, onError: (Object e) {
        debugPrint('[dual][error] 手表扫描监听失败: $e');
      }),
    );

    _streamSubscriptions.add(
      _watchConnStateEventChannel.receiveBroadcastStream().listen((dynamic rawEvent) {
        final watch.ConnectStateBean? event = _parseWatchConnStateEvent(rawEvent);
        if (event == null) {
          return;
        }
        if (!mounted) return;
        setState(() {
          _watchConnectionStatus = 'state=${event.connectState}, auto=${event.autoConnect}';
        });
      }, onError: (Object e) {
        debugPrint('[dual][error] 手表连接状态监听失败: $e');
      }),
    );

    _streamSubscriptions.add(
      _watchBatteryEventChannel.receiveBroadcastStream().listen((dynamic rawEvent) {
        final String? batteryText = _parseWatchBatteryText(rawEvent);
        if (batteryText == null || !mounted) {
          return;
        }
        setState(() {
          _watchBatteryOverview = batteryText;
        });
        if (_pendingWatchBatteryQuery != null && !_pendingWatchBatteryQuery!.isCompleted) {
          _pendingWatchBatteryQuery!.complete(batteryText);
        }
        debugPrint('[dual] 手表电量事件更新: $batteryText');
      }, onError: (Object e) {
        debugPrint('[dual][error] 手表电量监听失败: $e');
      }),
    );
  }

  Future<void> _requestPermissions() async {
    try {
      final List<Permission> permissions = <Permission>[
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        if (Platform.isAndroid) Permission.location,
        if (Platform.isIOS) Permission.locationWhenInUse,
      ];

      final Map<Permission, PermissionStatus> result = await permissions.request();
      final bool allGranted = result.values.every(
        (PermissionStatus status) => status == PermissionStatus.granted,
      );
      if (!allGranted) {
        debugPrint('[dual][warn] 部分权限未授权: $result');
        Fluttertoast.showToast(msg: '有权限未通过，可能影响扫描或连接');
        return;
      }
      Fluttertoast.showToast(msg: '权限已授权');
    } catch (e) {
      debugPrint('[dual][error] 权限请求失败: $e');
      Fluttertoast.showToast(msg: '权限请求失败: $e');
    }
  }

  Future<void> _checkWatchBluetooth() async {
    try {
      final bool enabled = await _watchPlugin.checkBluetoothEnable;
      if (!mounted) return;
      setState(() {
        _watchBluetoothEnabled = enabled;
      });
      if (!enabled) {
        Fluttertoast.showToast(msg: '蓝牙未开启，请先打开蓝牙');
      }
    } catch (e) {
      debugPrint('[dual][error] 检查手表蓝牙状态失败: $e');
      Fluttertoast.showToast(msg: '检查蓝牙状态失败: $e');
    }
  }

  Future<void> _startWatchScan() async {
    try {
      setState(() {
        _watchDevices.clear();
      });
      final bool started = await _watchPlugin.startScan(10 * 1000);
      if (!mounted) return;
      setState(() {
        _scanButtonText = started ? 'Scanning...' : 'Scan failed';
      });
      if (!started) {
        Fluttertoast.showToast(msg: '开始扫描失败');
      }
    } catch (e) {
      debugPrint('[dual][error] 开始扫描手表失败: $e');
      Fluttertoast.showToast(msg: '扫描失败: $e');
    }
  }

  Future<void> _cancelWatchScan() async {
    try {
      await _watchPlugin.cancelScan;
      if (!mounted) return;
      setState(() {
        _cancelScanText = 'cancelScan()';
        _scanButtonText = 'startScan(10*1000)';
      });
    } catch (e) {
      debugPrint('[dual][error] 取消扫描失败: $e');
      Fluttertoast.showToast(msg: '取消扫描失败: $e');
    }
  }

  Future<void> _connectWatch(watch.BleScanBean device) async {
    if (device.address.isEmpty) {
      Fluttertoast.showToast(msg: '设备地址为空，无法连接');
      return;
    }
    try {
      await _watchPlugin.connect(
        watch.ConnectBean(autoConnect: false, address: device.address, uuid: ''),
      );
      Fluttertoast.showToast(msg: '正在连接手表: ${device.name}');
      debugPrint('[dual] 手表连接请求已发出: ${device.name}, ${device.address}');
    } catch (e) {
      debugPrint('[dual][error] 手表连接失败: $e');
      Fluttertoast.showToast(msg: '连接手表失败: $e');
    }
  }

  Future<void> _disconnectWatch() async {
    try {
      await _watchPlugin.disconnect;
      Fluttertoast.showToast(msg: '手表已断开');
    } catch (e) {
      debugPrint('[dual][error] 断开手表失败: $e');
      Fluttertoast.showToast(msg: '断开手表失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('双插件验证页'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('手表状态（顶部总览）',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('连接状态: $_watchConnectionStatus'),
                    Text('蓝牙开关: ${_watchBluetoothEnabled ? '已开启' : '未开启'}'),
                    Text('扫描设备数: ${_watchDevices.length}'),
                    Text('电量: $_watchBatteryOverview'),
                    Text('版本号: $_watchVersionOverview'),
                    const SizedBox(height: 6),
                    const Text('说明：这里展示手表连接与扫描数据，便于快速确认联调状态。'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: <Widget>[
                ElevatedButton(onPressed: _requestPermissions, child: const Text('requestPermissions()')),
                ElevatedButton(
                  onPressed: _checkWatchBluetooth,
                  child: Text('checkBluetoothPermission: $_watchBluetoothEnabled'),
                ),
                ElevatedButton(onPressed: _startWatchScan, child: Text(_scanButtonText)),
                ElevatedButton(onPressed: _cancelWatchScan, child: Text(_cancelScanText)),
                ElevatedButton(onPressed: _disconnectWatch, child: const Text('disconnectWatch()')),
                ElevatedButton(onPressed: _queryWatchBattery, child: const Text('queryWatchBattery()')),
                ElevatedButton(onPressed: _queryWatchVersion, child: const Text('queryWatchVersion()')),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('手表连接状态: $_watchConnectionStatus'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _watchDevices.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.blue),
                itemBuilder: (BuildContext context, int index) {
                  final watch.BleScanBean d = _watchDevices[index];
                  return ListTile(
                    title: Text(_formatWatchDeviceLabel(d)),
                    subtitle: const Text('点击发起连接'),
                    onTap: () => _connectWatch(d),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
