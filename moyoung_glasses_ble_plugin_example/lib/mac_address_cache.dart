import 'package:shared_preferences/shared_preferences.dart';

/// MAC 地址缓存管理类
class MacAddressCache {
  static const String _macKey = 'cached_device_mac';
  static const String _nameKey = 'cached_device_name';
  
  /// 保存设备 MAC 地址和名称
  static Future<void> saveDeviceMac(String mac, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_macKey, mac);
    await prefs.setString(_nameKey, name);
    print('MAC地址已缓存: $mac ($name)');
  }
  
  /// 获取缓存的 MAC 地址
  static Future<String?> getCachedMac() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_macKey);
  }
  
  /// 获取缓存的设备名称
  static Future<String?> getCachedDeviceName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }
  
  /// 清除缓存的 MAC 地址
  static Future<void> clearCachedMac() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_macKey);
    await prefs.remove(_nameKey);
    print('MAC地址缓存已清除');
  }
  
  /// 检查是否有缓存的 MAC 地址
  static Future<bool> hasCachedMac() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_macKey);
  }
}
