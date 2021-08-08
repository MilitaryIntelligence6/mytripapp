import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_ctrip/dao/travel_dao.dart";
import "package:flutter_ctrip/ui/widget/webview.dart";

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => new _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return new Scaffold(
      body: new MyWebView(
        url: "https://m.ctrip.com/webapp/myctrip/",
        hideAppBar: true,
        backForbid: true,
        hideHead: true,
      ),
    );
  }
}
