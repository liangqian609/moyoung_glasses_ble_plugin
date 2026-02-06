import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地化管理器
/// Locale Manager
class LocaleManager {
  static const String _localeKey = 'locale_key';
  
  /// 保存本地设置
  /// Save locale settings
  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
  
  /// 获取保存的本地设置
  /// Get saved locale settings
  static Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);
    
    if (languageCode != null) {
      return Locale(languageCode);
    }
    
    // 默认返回中文
    // Return Chinese by default
    return const Locale('zh');
  }
  
  /// 获取已保存的本地设置（同步方法）
  /// Get saved locale settings (synchronous method)
  static Locale getSavedLocale() {
    // 由于SharedPreferences是异步的，这里返回默认值
    // In practice, you should call getLocale() instead
    return const Locale('zh');
  }
  
  /// 清除本地设置
  /// Clear locale settings
  static Future<void> clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
  }
}
