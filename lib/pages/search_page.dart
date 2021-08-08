import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_ctrip/dao/search_dao.dart";
import "package:flutter_ctrip/model/seach_model.dart";
import "package:flutter_ctrip/pages/speak_page.dart";
import "package:flutter_ctrip/util/navigator_util.dart";
import "package:flutter_ctrip/widget/search_bar.dart";
import "package:flutter_ctrip/widget/webview.dart";

class SearchPage extends StatefulWidget {

  static const String URL =
      "http://m.ctrip.com/restapi/h5api/globalsearch/search?source=mobileweb&action=mobileweb&keyword=";

  final bool hideLeft;
  final String searchUrl;
  final String keyword;
  final String hint;

  SearchPage(
      {this.hideLeft = true,
      this.searchUrl = URL,
      this.keyword,
      this.hint = "目的地 | 酒店 | 景点 | 航班号"});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  static const List<String> TYPES = [
    "channelgroup",
    "gs",
    "plane",
    "train",
    "cruise",
    "district",
    "food",
    "hotel",
    "huodong",
    "shop",
    "sight",
    "ticket",
    "travelgroup"
  ];

  SearchModel searchModel;
  String keyword;

  @override
  void initState() {
    if (widget.keyword != null) {
      _onTextChange(widget.keyword);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return new Scaffold(
      body: new Column(
        children: <Widget>[
          _appBar(),
          new MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: new Expanded(
              flex: 1,
              child: new ListView.builder(
                  itemCount: searchModel?.data?.length ?? 0,
                  itemBuilder: (BuildContext context, int position) {
                    return _item(position);
                  }),
            ),
          )
        ],
      ),
    );
  }

  Widget _item(int position) {
    if (searchModel == null || searchModel.data == null) return null;
    SearchItem item = searchModel.data[position];
    return new GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) => new MyWebView(
              url: item.url,
              title: "详情",
            ),
          ),
        );
      },
      child: new Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
            border: const Border(bottom: const BorderSide(width: 0.3, color: Colors.grey))),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.all(1),
              child: new Image(
                  height: 26,
                  width: 26,
                  image: new AssetImage(_typeImage(item.type))),
            ),
            new Column(
              children: <Widget>[
                new Container(
                  width: 300,
                  child: _title(item),
                ),
                _isSubTitle(item),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return new Column(
      children: <Widget>[
        new Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: [new Color(0x66000000), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: new Container(
              padding: EdgeInsets.only(top: 30),
              height: 100,
              decoration: new BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  new BoxShadow(
                    color: Colors.black12,
                    offset: new Offset(2, 3),
                    blurRadius: 6,
                    spreadRadius: 0.6,
                  ),
                ],
              ),
              child: new SearchBar(
                hideLeft: widget.hideLeft,
                defaultText: widget.keyword,
                hint: widget.hint,
                leftButtonClick: () {
                  Navigator.pop(context);
                },
                onChanged: _onTextChange,
                speakClick: _jumpToSpeak,
              )),
        )
      ],
    );
  }

  void _jumpToSpeak() {
    NavigatorUtil.push(context, new SpeakPage());
  }

  void _onTextChange(String text) {
    keyword = text;
    if (text.length == 0) {
      setState(() {
        searchModel = null;
      });
      return;
    }
    String url = widget.searchUrl + text;
    SearchDao.fetch(url, text).then((SearchModel model) {
      if (model.keyword == keyword) {
        setState(() {
          searchModel = model;
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  String _typeImage(String type) {
    if (type == null) return "images/type_travelgroup.png";
    String path = "travelgroup";
    for (final val in TYPES) {
      if (type.contains(val)) {
        path = val;
        break;
      }
    }
    return "images/type_$path.png";
  }

  Widget _title(SearchItem item) {
    if (item == null) {
      return null;
    }
    List<TextSpan> spans = new List<TextSpan>();
    spans.addAll(_keywordTextSpans(item.word, searchModel.keyword));
    spans.add(TextSpan(
        text: " " + (item.districtname ?? "") + " " + (item.zonename ?? ""),
        style: const TextStyle(fontSize: 16, color: Colors.grey)));
    return new RichText(text: new TextSpan(children: spans));
  }

  Widget _subTitle(SearchItem item) {
    return new RichText(
      text: new TextSpan(children: <TextSpan>[
        new TextSpan(
          text: item.price ?? "",
          style: const TextStyle(fontSize: 16, color: Colors.orange),
        ),
        new TextSpan(
          text: " " + (item.star ?? ""),
          style: TextStyle(fontSize: 12, color: Colors.grey),
        )
      ]),
    );
  }

  List<TextSpan> _keywordTextSpans(String word, String keyword) {
    List<TextSpan> spans = new List<TextSpan>();
    if (word == null || word.length == 0) return spans;
    String wordL = word.toLowerCase(), keywordL = keyword.toLowerCase();
    List<String> arr = wordL.split(keywordL);
    TextStyle normalStyle = TextStyle(fontSize: 16, color: Colors.black87);
    TextStyle keywordStyle = TextStyle(fontSize: 16, color: Colors.orange);
    int preIndex = 0;
    for (int i = 0; i < arr.length; i++) {
      if (i != 0) {
        preIndex = wordL.indexOf(keywordL, preIndex);
        spans.add(new TextSpan(
            text: word.substring(preIndex, preIndex + keyword.length),
            style: keywordStyle));
      }
      String val = arr[i];
      if (val != null && val.length > 0) {
        spans.add(new TextSpan(text: val, style: normalStyle));
      }
    }
    return spans;
  }

  Widget _isSubTitle(SearchItem item) {
    return item.price != null
        ? new Container(
            width: 300,
            margin: const EdgeInsets.only(top: 5),
            child: _subTitle(item),
          )
        : const SizedBox.shrink();
  }
}
