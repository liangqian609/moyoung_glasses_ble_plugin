import 'dart:async';
import 'package:moyoung_glasses_ble_plugin/moyoung_glasses_ble.dart';

/// Re-export from the main library
class EventManager {
  static final EventManager _instance = EventManager._internal();
  factory EventManager() => _instance;
  EventManager._internal();
  
  final Map<String, StreamController> _controllers = {};
  
  void emit(String eventName, dynamic data) {
    if (!_controllers.containsKey(eventName)) {
      _controllers[eventName] = StreamController.broadcast();
    }
    _controllers[eventName]?.add(data);
  }
  
  Stream<T> on<T>(String eventName) {
    if (!_controllers.containsKey(eventName)) {
      _controllers[eventName] = StreamController.broadcast();
    }
    return _controllers[eventName]?.stream.cast<T>() ?? Stream.empty();
  }
  
  void off(String eventName) {
    _controllers[eventName]?.close();
    _controllers.remove(eventName);
  }
}

/// Event names for communication between native and Flutter
class EventNames {
  // Bluetooth events
  static const String bleScan = "bleScan";
  static const String connState = "connState";
  static const String bluetoothState = "bluetoothState";
  static const String connectionSuccess = "connectionSuccess";
  
  // Device events
  static const String battery = "battery";
  static const String runningStatus = "runningStatus";
  static const String sdkLog = "sdkLog";
  
  // Audio events
  static const String audioState = "audioState";
  static const String audioData = "audioData";
  static const String audioTalkState = "audioTalkState";
  static const String pcmAudio = "pcmAudio";
  static const String translateAudio = "translateAudio";
  
  // AI events
  static const String aiImageData = "aiImageData";
  static const String aiDialogue = "aiDialogue";
  
  // File events
  static const String fileBaseUrl = "fileBaseUrl";
  static const String actionResult = "actionResult";
  static const String mediaFile = "mediaFile";
  
  // OTA events
  static const String otaState = "otaState";
  static const String ackError = "ackError";
  
  // Translation events
  static const String translation = "translation";
}
