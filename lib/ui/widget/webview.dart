import "dart:async";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:flutter_ctrip/ui/widget/loading_container.dart";
import "package:flutter_webview_plugin/flutter_webview_plugin.dart";

class MyWebView extends StatefulWidget {
  final String url;
  final String statusBarColor;
  final String title;
  final bool hideAppBar;
  final bool backForbid;
  final bool hideHead;

  MyWebView(
      {this.url,
      this.statusBarColor,
      this.title,
      this.hideAppBar,
      this.backForbid = false,
      this.hideHead = false});

  @override
  _MyWebViewState createState() => new _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {

  static const List<String> CATCH_URLS = [
    "m.ctrip.com/",
    "m.ctrip.com/html5/",
    "m.ctrip.com/html5",
    "m.ctrip.com/html5/you/",
    "m.ctrip.com/webapp/you/foods/",
    "m.ctrip.com/webapp/vacations/tour/list"
  ];

  final FlutterWebviewPlugin webViewPluginRef = new FlutterWebviewPlugin();
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  StreamSubscription<WebViewHttpError> _onHttpError;
  bool exiting = false;


  @override
  void initState() {
    webViewPluginRef.close();
    print(widget.url);
    _onUrlChanged = webViewPluginRef.onUrlChanged.listen((String url) {});
    _onStateChanged =
        webViewPluginRef.onStateChanged.listen((WebViewStateChanged state) {
      switch (state.type) {
        case WebViewState.startLoad:
          if (_isToMain(state.url) && !exiting) {
            if (widget.backForbid) {
              webViewPluginRef.launch(widget.url);
            } else {
              Navigator.pop(context);
              exiting = true;
            }
          }
          break;
        default:
          break;
      }
    });
    _onHttpError = webViewPluginRef.onHttpError.listen((event) {});
    super.initState();
  }

  @override
  void dispose() {
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    webViewPluginRef.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String statusBarColorStr = widget.statusBarColor ?? "ffffff";
    Color backButtonColor;
    switch (statusBarColorStr) {
      case "ffffff":
        backButtonColor = Colors.black;
        break;
      default:
        backButtonColor = Colors.white;
        break;
    }
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return new Scaffold(
      body: new MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: new Column(
          children: <Widget>[
            _appBar(new Color(int.parse("0xff$statusBarColorStr")),
                backButtonColor),
            new Expanded(
              child: new WebviewScaffold(
                url: widget.url,
                withZoom: true,
                withLocalStorage: true,
                hidden: true,
                initialChild: new Container(
                  color: Colors.white,
                  child: new Center(
                    // 加载时的转圈;
                    child: new CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToMain(String url) {
    for (final value in CATCH_URLS) {
      if (url?.endsWith(value) ?? false) {
        return true;
      }
    }
    return false;
  }

  Widget _appBar(Color backgroundColor, Color backButtonColor) {
    if (widget.hideAppBar ?? false) {
      return widget.hideHead
          ? new Container()
          : new Container(
              color: backgroundColor,
              height:
                  Theme.of(context).platform == TargetPlatform.iOS ? 34 : 29,
              width: double.infinity,
            );
    }
    return new Container(
      color: backgroundColor,
      padding: new EdgeInsets.fromLTRB(0, 38, 0, 10),
      child: new FractionallySizedBox(
        widthFactor: 1,
        child: new Stack(
          children: <Widget>[
            new GestureDetector(
              onTap: () => Navigator.pop(context),
              child: new Container(
                margin: new EdgeInsets.only(left: 10),
                child: new Icon(
                  Icons.close,
                  color: backButtonColor,
                  size: 24,
                ),
              ),
            ),
            new Positioned(
              left: 0,
              right: 0,
              child: new Center(
                child: new Text(
                  widget.title ?? "",
                  style: new TextStyle(
                    color: backButtonColor,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
