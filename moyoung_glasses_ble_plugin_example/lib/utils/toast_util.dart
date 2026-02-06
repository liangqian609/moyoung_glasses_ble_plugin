import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Toast工具类
/// Toast Utility Class
class ToastUtil {
  /// 显示Toast消息
  /// Show toast message
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  
  /// 显示长Toast消息
  /// Show long toast message
  static void showLongToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  
  /// 取消Toast
  /// Cancel toast
  static void cancelToast() {
    Fluttertoast.cancel();
  }
}
