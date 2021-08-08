import "package:flutter/material.dart";
import "package:flutter_ctrip/model/common_model.dart";
import "package:flutter_ctrip/ui/widget/webview.dart";

class SubNav extends StatelessWidget {
  final List<CommonModel> subNavList;

  const SubNav({Key key, @required this.subNavList}) : super(key: key);

  /// 这种小部件, 热重载时, 先把调用(new ThisWidget())给关掉;
  /// 否则不会重载;
  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.all(Radius.circular(6)),
      ),
      child: new Padding(
        padding: new EdgeInsets.all(8),

        /// items 就是核心, 自由行, wifi电话卡啥的;
        child: _items(context),
      ),
    );
  }

  Widget _items(BuildContext context) {
    if (subNavList == null) {
      return null;
    }
    List<Widget> items = new List<Widget>();
    subNavList.forEach((model) {
      items.add(_item(context, model));
    });

    /// 四舍五入, 两行除以一半;
    int separate = (subNavList.length / 2 + 0.5).toInt();
    return new Column(
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // 一列切个片;
          children: items.sublist(0, separate),
        ),
        new Padding(
          padding: new EdgeInsets.only(top: 10),
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.sublist(separate, subNavList.length),
        ),
      ],
    );
  }

  Widget _item(BuildContext context, CommonModel model) {
    return new Expanded(
      flex: 1,
      child: new GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (context) =>
              new MyWebView(
                url: model.url,
                statusBarColor: model.statusBarColor,
                hideAppBar: model.hideAppBar,
              ),
            ),
          );
        },
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Image.network(
              model.icon,
              width: 28,
              height: 28,
            ),
            new Text(
              model.title,
              style: new TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
