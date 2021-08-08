import "package:flutter/material.dart";
import "package:flutter_ctrip/dao/trave_search_dao.dart";
import "package:flutter_ctrip/dao/trave_search_hot_dao.dart";
import "package:flutter_ctrip/model/travel_search_hot_model.dart";
import "package:flutter_ctrip/model/travel_search_model.dart";
import "package:flutter_ctrip/pages/page_type.dart";
import "package:flutter_ctrip/pages/speak_page.dart";
import "package:flutter_ctrip/util/navigator_util.dart";
import "package:flutter_ctrip/widget/search_bar.dart";
import "package:flutter_ctrip/widget/webview.dart";

const List<String> TYPES = ["topic", "place", "user", "hotword", "district"];
const String URL =
    "https://m.ctrip.com/restapi/soa2/16189/json/appSuggest?_fxpcqlniredt=09031043410934928682&__gw_appid=99999999&__gw_ver=1.0&__gw_from=10650016495&__gw_platform=H5";

class TravelSearchPage extends StatefulWidget {
  final bool hideLeft;
  final String searchUrl;
  final String keyword;
  final String hint;

  TravelSearchPage(
      {this.hideLeft = true,
      this.searchUrl = URL,
      this.keyword,
      this.hint = "试试搜\“花式过五一\”"});

  @override
  _TravelSearchPageState createState() => _TravelSearchPageState();
}

class _TravelSearchPageState extends State<TravelSearchPage> {
  TravelSearchModel travelSearchModel;
  String keyword;
  TravelSearchHotModel travelSearchHotModel;
  List<ResourceItems> resourceItems;
  String hotTitle = "";
  int listNum;
  List<Items> itemsList = new List<Items>();
  bool _isHidden = false;

  @override
  void initState() {
    if (widget.keyword != null) {
      _onTextChange(widget.keyword);
    }
    _loadSearchHotData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: new Column(
        children: <Widget>[
          new MediaQuery.removePadding(
            context: context,
            removeLeft: true,
            removeRight: true,
            child: _appBar(),
          ),
          _searItems(),
        ],
      ),
    );
  }

  Widget _appBar() {
    return new Column(
      children: <Widget>[
        new Container(
          decoration: const BoxDecoration(
            gradient: const LinearGradient(
              colors: [const Color(0x66000000), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: new Container(
              padding: const EdgeInsets.only(top: 30),
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: new SearchBar(
                hideLeft: widget.hideLeft,
                hint: widget.hint,
                defaultText: widget.keyword,
                leftButtonClick: () {
                  Navigator.pop(context);
                },
                onChanged: _onTextChange,
                speakClick: _jumpToSpeak,
              )),
        ),
        new Row(
          children: <Widget>[
            new Expanded(
              flex: 1,
              child: new Offstage(
                offstage: _isHidden,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.only(left: 12),
                      child: new Text(
                        hotTitle,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: new Wrap(
                        spacing: 6,
                        runSpacing: 0,
                        children: _hotChip(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _searItems() {
    return _isHidden
        ? new MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: new Expanded(
              flex: 1,
              child: new ListView.builder(
                  itemCount: itemsList?.length ?? 0,
                  itemBuilder: (BuildContext context, int position) {
                    return _item(position);
                  }),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _item(int position) {
    if (itemsList == null) {
      return null;
    }
    if (itemsList[position].resourceType == "topic") {
      return new GestureDetector(
        onTap: () {
          NavigatorUtil.push(
              context,
              new MyWebView(
                title: itemsList[position].name,
                url: itemsList[position].h5Url,
              ));
        },
        child: new Container(
          padding: const  EdgeInsets.all(10),
          decoration: const BoxDecoration(
              border:
                  const Border(bottom: const BorderSide(width: 0.3, color: Colors.grey))),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Image.asset(
                    "images/lvpai_search_tag.png",
                    width: 16,
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 6),
                  ),
                  new Text(
                    "#",
                    style: TextStyle(fontSize: 16),
                  ),
                  _title(itemsList[position].name),
                ],
              ),
              new Text(
                itemsList[position].articleCount.toString() + "篇旅拍",
                style: const TextStyle(
                  fontFamily: "",
                  fontWeight: FontWeight.w300,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (itemsList[position].resourceType == "sight") {
      return new GestureDetector(
        onTap: () {
          NavigatorUtil.push(
              context,
              new MyWebView(
                title: itemsList[position].name,
                url: itemsList[position].h5Url,
              ));
        },
        child: new Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              border:
                  const Border(bottom: const BorderSide(width: 0.3, color: Colors.grey))),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Image.asset(
                    "images/lvpai_issue_sight.png",
                    width: 16,
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 6),
                  ),
                  _title(itemsList[position].name),
                ],
              ),
              new Text(
                itemsList[position].articleCount.toString() + "篇旅拍",
                style: const TextStyle(
                  fontFamily: "",
                  fontWeight: FontWeight.w300,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (itemsList[position].resourceType == "user") {
      return new GestureDetector(
        onTap: () {
          NavigatorUtil.push(
              context,
              new MyWebView(
                title: itemsList[position].title,
                url: "https://m.ctrip.com/webapp/you/tripshoot/user/home?seo=0&clientAuth=" +
                    itemsList[position].clientAuth +
                    "&autoawaken=close&popup=close&isHideHeader=true&isHideNavBar=YES&navBarStyle=white",
              ));
        },
        child: new Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              border:
                  const Border(bottom: const  BorderSide(width: 0.3, color: Colors.grey))),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new CircleAvatar(
                backgroundImage: new NetworkImage(itemsList[position].imageUrl),
              ),
              const SizedBox(
                width: 8,
              ),
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(itemsList[position].title),
                  new Row(
                    children: <Widget>[
                      new Text(
                        itemsList[position].articleCount.toString() + "篇旅拍",
                        style: const TextStyle(
                            fontFamily: "",
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      new Text(
                        itemsList[position].followCount.toString() + "粉丝",
                        style: const TextStyle(
                            fontFamily: "",
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (itemsList[position].resourceType == "hotword") {
      return new GestureDetector(
        onTap: () {
          NavigatorUtil.push(
              context,
              new MyWebView(
                title: itemsList[position].name,
                url: "https://m.ctrip.com/webapp/you/livestream/paipai/searchResult?districtId=0&userLat=-180&userLng=-180&keyword=" +
                    itemsList[position].name +
                    "&isHideHeader=true&isHideNavBar=YES&navBarStyle=white&from=https%3A%2F%2Fm.ctrip.com%2Fwebapp%2Fyou%2Flivestream%2Fpaipai%2FsearchPage.html%3FdistrictId%3D-1%26locatedDistrictId%3D0%26userLat%3D-180%26userLng%3D-180%26isHideHeader%3Dtrue%26isHideNavBar%3DYES%26autoawaken%3Dclose%26popup%3Dclose%26navBarStyle%3Dwhite&navBarStyle=white",
              ));
        },
        child: new Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              border:
                  const Border(bottom: const BorderSide(width: 0.3, color: Colors.grey))),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Image.asset(
                    "images/lvpai_search_list.png",
                    width: 16,
                  ),
                  new Padding(
                    padding: EdgeInsets.only(left: 6),
                  ),
                  new Text(
                    itemsList[position].name,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (itemsList[position].resourceType == "district") {
      return new GestureDetector(
        onTap: () {
          NavigatorUtil.push(
              context,
              new MyWebView(
                title: itemsList[position].name,
                url: itemsList[position].h5Url,
              ));
        },
        child: new Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              border:
                  const Border(bottom: const BorderSide(width: 0.3, color: Colors.grey))),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Image.asset(
                    "images/lvpai_issue_position.png",
                    width: 16,
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 6),
                  ),
                  new Text(
                    itemsList[position].name,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  List<Widget> _hotChip(BuildContext context) {
    if (resourceItems == null) {
      return new List<Widget>();
    }
    List<Widget> _chip = new List<Widget>();
    resourceItems.forEach((resourceItem) {
      _chip.add(_hotItem(context, resourceItem));
    });
    return _chip;
  }

  Widget _hotItem(BuildContext context, ResourceItems resourceItem) {
    if (resourceItem.iconUrl != "") {
      return new GestureDetector(
        onTap: () {
          NavigatorUtil.push(
              context,
              new MyWebView(
                url: resourceItem.h5Url,
                title: "携程旅拍",
              ));
        },
        child: new Chip(
          backgroundColor: const Color(0xffF4F4F4),
          avatar: new Image.network(
            resourceItem?.iconUrl,
            height: 18,
            width: 18,
          ),
          label: new Text(
            resourceItem?.title,
            style: const TextStyle(fontFamily: "", fontWeight: FontWeight.w400),
          ),
        ),
      );
    } else {
      return new GestureDetector(
        onTap: () {
          NavigatorUtil.push(
              context,
              new MyWebView(
                url: resourceItem.h5Url,
                title: "携程旅拍",
              ));
        },
        child: new Chip(
          backgroundColor: Color(0xffF4F4F4),
          label: new Text(
            resourceItem?.title,
            style: const TextStyle(fontFamily: "", fontWeight: FontWeight.w400),
          ),
        ),
      );
    }
  }

  void _jumpToSpeak() {
    NavigatorUtil.push(
        context,
        new SpeakPage(
          pageType: PageType.travel,
        ));
  }

  void _onTextChange(String text) {
    keyword = text;
    if (text.length == 0) {
      setState(() {
        travelSearchModel = null;
        _isHidden = false;
        itemsList.clear();
      });
      return;
    }
    TravelSearchDao.fetch(widget.searchUrl, text)
        .then((TravelSearchModel model) {
      setState(() {
        travelSearchModel = model;
      });
      _createItems();
    }).catchError((e) {
      print(e);
    });
    _isHidden = true;
  }

  List<Items> _createItems() {
    if (itemsList.length > 0) {
      itemsList.clear();
    }
    if (travelSearchModel == null || travelSearchModel.result == null) {
      return null;
    }
    travelSearchModel.result.forEach((result) {
      result.items.forEach((item) {
        itemsList.add(item);
      });
    });
    return itemsList;
  }

  void _loadSearchHotData() {
    TravelSearchHotDao.fetch().then((TravelSearchHotModel model) {
      setState(() {
        travelSearchHotModel = model;
        hotTitle = travelSearchHotModel.hotResult[0].title;
        resourceItems = travelSearchHotModel.hotResult[0].resourceItems;
      });
    }).catchError((e) {
      print(e);
    });
  }

  Widget _title(String name) {
    if (name == null) {
      return null;
    }
    List<TextSpan> spans = new List<TextSpan>();
    spans.addAll(_keywordTextSpans(name, travelSearchModel.keyword));
    return new RichText(text: new TextSpan(children: spans));
  }

  List<TextSpan> _keywordTextSpans(String word, String keyword) {
    List<TextSpan> spans = new List<TextSpan>();
    if (word == null || word.length == 0) return spans;
    String wordL = word.toLowerCase(), keywordL = keyword.toLowerCase();
    List<String> arr = wordL.split(keywordL);
    TextStyle normalStyle = TextStyle(fontSize: 16, color: Colors.black);
    TextStyle keywordStyle =
        TextStyle(fontSize: 16, color: Colors.lightBlueAccent);
    int preIndex = 0;
    for (int i = 0; i < arr.length; i++) {
      if (i != 0) {
        preIndex = wordL.indexOf(keywordL, preIndex);
        spans.add(TextSpan(
            text: word.substring(preIndex, preIndex + keyword.length),
            style: keywordStyle));
      }
      String val = arr[i];
      if (val != null && val.length > 0) {
        spans.add(TextSpan(text: val, style: normalStyle));
      }
    }
    return spans;
  }
}
