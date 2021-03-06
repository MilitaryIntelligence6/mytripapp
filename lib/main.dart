
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_color_plugin/flutter_color_plugin.dart";
import 'package:flutter_ctrip/ui/navigator/tab_navigater.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(fontSize: 20);
    SystemUiOverlayStyle style = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        ///这是设置状态栏的图标和字体的颜色
        ///Brightness.light  一般都是显示为白色
        ///Brightness.dark 一般都是显示为黑色
        statusBarIconBrightness: Brightness.dark
    );
    SystemChrome.setSystemUIOverlayStyle(style);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MISectionTrip",
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "PingFang",
      ),
      home: new TabNavigator(),
    );
  }
}
