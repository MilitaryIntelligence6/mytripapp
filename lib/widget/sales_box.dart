import 'package:flutter/material.dart';
import 'package:flutter_ctrip/model/common_model.dart';
import 'package:flutter_ctrip/model/sales_box_model.dart';
import 'package:flutter_ctrip/widget/webview.dart';

class SalesBox extends StatelessWidget {
  final SalesBoxModel salesBoxModel;

  const SalesBox({Key key, @required this.salesBoxModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: _items(context),
    );
  }

  Widget _items(BuildContext context) {
    if (salesBoxModel == null) {
      return null;
    }
    List<Widget> items = new List<Widget>();
    items.add(_doubleItem(
        context, salesBoxModel.bigCard1, salesBoxModel.bigCard2, true));
    items.add(_doubleItem(
        context, salesBoxModel.smallCard1, salesBoxModel.smallCard2, false));
    items.add(_doubleItem(
        context, salesBoxModel.smallCard3, salesBoxModel.smallCard4, false));
    return new Column(
      children: <Widget>[
        new Container(
          height: 45,
          decoration: new BoxDecoration(
              color: Colors.white, borderRadius: new BorderRadius.circular(4)),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Image.network(
                salesBoxModel.icon,
                height: 15,
                width: 79,
              ),
              new GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => new WebView(
                        url: salesBoxModel.moreUrl,
                        title: "更多活动",
                      ),
                    ),
                  );
                },
                // 渐变获取更多福利一栏;
                child: new Container(
                  padding: new EdgeInsets.fromLTRB(10, 2, 10, 2),
                  margin: new EdgeInsets.only(right: 10),
                  decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                      colors: [
                        new Color(0xffff4e63),
                        new Color(0xffff6cc9),
                      ],
                    ),
                    borderRadius: new BorderRadius.circular(10),
                  ),
                  child: new Text(
                    "获取更多福利 >>",
                    style: new TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        new Padding(
          padding: new EdgeInsets.only(top: 4),
        ),
        // 排列每一个, 不优雅, 最好是for循环排;
        items[0],
        new Padding(
          padding: new EdgeInsets.only(top: 4),
        ),
        items[1],
        new Padding(
          padding: new EdgeInsets.only(top: 4),
        ),
        items[2],
      ],
    );
  }

  Widget _doubleItem(BuildContext context, CommonModel leftCard,
      CommonModel rightCard, bool big) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _item(context, leftCard, big, true),
        _item(context, rightCard, big, false),
      ],
    );
  }

  Widget _item(BuildContext context, CommonModel model, bool big, bool left) {
    return new Expanded(
      child: new GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (context) => new WebView(
                url: model.url,
                title: model.title ?? "活动",
              ),
            ),
          );
        },
        child: new Container(
          height: big ? 130 : 82,
          margin: left
              ? new EdgeInsets.only(right: 4)
              : EdgeInsets.zero,
          decoration: new BoxDecoration(
            color: Colors.white,
          ),
          child: new Image.network(
            model.icon,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
