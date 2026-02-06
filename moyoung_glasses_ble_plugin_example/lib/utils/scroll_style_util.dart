import 'package:flutter/material.dart';

/// 滚动样式工具
/// Scroll Style Utility
class ScrollStyleUtil {
  /// 自定义滚动条样式
  /// Custom scrollbar style
  static ScrollbarThemeData customScrollbarTheme() {
    return ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all(Colors.grey[400]),
      thickness: MaterialStateProperty.all(6.0),
      radius: const Radius.circular(3.0),
      crossAxisMargin: 2.0,
      mainAxisMargin: 2.0,
    );
  }
  
  /// 隐藏滚动条
  /// Hide scrollbar
  static Widget hideScrollbar({required Widget child}) {
    return ScrollConfiguration(
      behavior: const ScrollConfigurationBehavior(),
      child: child,
    );
  }
}

/// 滚动配置行为
/// Scroll Configuration Behavior
class ScrollConfigurationBehavior extends ScrollBehavior {
  const ScrollConfigurationBehavior();
  
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
