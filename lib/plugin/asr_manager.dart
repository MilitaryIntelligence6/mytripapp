
import "package:flutter/services.dart";

class AsrManager {
  
  /// 禁止空构造;
  AsrManager._();
  
  static const MethodChannel _channel = const MethodChannel("asr_plugin");

  ///开始录音
  static Future<String> start({Map<String, String> params}) async {
    return await _channel.invokeMethod("start", params ?? new Map<String, String>());
  }

  ///停止录音
  static Future<String> stop() async {
    return await _channel.invokeMethod("stop");
  }

  ///取消录音
  static Future<String> cancel() async {
    return await _channel.invokeMethod("cancel");
  }
}
