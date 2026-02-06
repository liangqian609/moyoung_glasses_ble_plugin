import 'package:flutter/material.dart';

/// 屏幕适配工具
/// Screen Adaptation Utility
extension ScreenSizeFit on double {
  /// 根据屏幕宽度适配
  /// Adapt according to screen width
  double get w {
    return this * (MediaData.mediaQueryData.size.width / 375.0);
  }
  
  /// 根据屏幕高度适配
  /// Adapt according to screen height
  double get h {
    return this * (MediaData.mediaQueryData.size.height / 667.0);
  }
  
  /// 根据屏幕较小边适配
  /// Adapt according to smaller screen side
  double get sp {
    return this * (MediaData.mediaQueryData.size.shortestSide / 375.0);
  }
}

/// 媒体数据
/// Media Data
class MediaData {
  static MediaQueryData mediaQueryData = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
}
