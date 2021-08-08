import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_ctrip/dao/trave_hot_keyword_dao.dart";
import "package:flutter_ctrip/dao/travel_params_dao.dart";
import "package:flutter_ctrip/dao/travel_tab_dao.dart";
import "package:flutter_ctrip/model/travel_hot_keyword_model.dart";
import "package:flutter_ctrip/model/travel_params_model.dart";
import "package:flutter_ctrip/model/travel_tab_model.dart";
import "package:flutter_ctrip/pages/page_type.dart";
import "package:flutter_ctrip/pages/speak_page.dart";
import "package:flutter_ctrip/pages/travel_search_page.dart";
import "package:flutter_ctrip/pages/travel_tab_page.dart";
import "package:flutter_ctrip/util/navigator_util.dart";
import "package:flutter_ctrip/widget/search_bar.dart";
import "package:flutter_ctrip/widget/webview.dart";

class TravelPage extends StatefulWidget {
  @override
  _TravelPageState createState() => new _TravelPageState();
}

class _TravelPageState extends State<TravelPage> with TickerProviderStateMixin {
  TabController _controller;

  // ignore: deprecated_member_use
  List<Groups> tabs = new List<Groups>();
  TravelTabModel travelTabModel;
  TravelParamsModel travelParamsModel;
  TravelHotKeywordModel travelHotKeywordModel;
  List<HotKeyword> hotKeyWords;
  String defaultText = "试试搜\“花式过五一\”";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 6, 0),
            decoration: new BoxDecoration(
              color: Colors.white,
            ),
            child: new SafeArea(
              child: new SearchBar(
                searchBarType: SearchBarType.homeLight,
                defaultText: defaultText,
                hintList: hotKeyWords,
                isUserIcon: true,
                inputBoxClick: _jumpToSearch,
                speakClick: _jumpToSpeak,
                rightButtonClick: _jumpToUser,
              ),
            ),
          ),
          new Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 2),
            child: new TabBar(
              controller: _controller,
              isScrollable: true,
              labelColor: Colors.black,
              labelPadding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              indicatorColor: const Color(0xff2FCFBB),
              indicatorPadding: const EdgeInsets.all(6),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2.2,
              labelStyle: const TextStyle(fontSize: 18),
              unselectedLabelStyle: const TextStyle(fontSize: 15),
              tabs: tabs.map<Tab>((Groups tab) {
                return new Tab(
                  text: tab.name,
                );
              }).toList(),
            ),
          ),
          new Flexible(
            child: new Container(
              padding: new EdgeInsets.fromLTRB(6, 3, 6, 0),
              child: new TabBarView(
                controller: _controller,
                children: tabs.map((Groups tab) {
                  return new TravelTabPage(
                    travelUrl: travelParamsModel?.url,
                    params: travelParamsModel?.params,
                    groupChannelCode: tab?.code,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _controller = TabController(length: 0, vsync: this);
    _loadParams();
    _loadHotKeyword();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _jumpToSpeak() {
    NavigatorUtil.push(
        context,
        new SpeakPage(
          pageType: PageType.travel,
        ));
  }

  void _jumpToSearch() {
    NavigatorUtil.push(
      context,
      new TravelSearchPage(
        hint: defaultText,
        hideLeft: false,
      ),
    );
  }

  void _jumpToUser() {
    NavigatorUtil.push(
      context,
      new WebView(
        url:
            "https://m.ctrip.com/webapp/you/tripshoot/user/home?seo=0&isHideHeader=true&isHideNavBar=YES&navBarStyle=white",
        hideHead: false,
        hideAppBar: false,
        title: "我的旅拍",
      ),
    );
  }

  void _loadParams() {
    TravelParamsDao.fetch().then((TravelParamsModel model) {
      setState(() {
        travelParamsModel = model;
      });
      _loadTab();
    }).catchError((e) {
      print(e);
    });
  }

  void _loadTab() {
    TravelTabDao.fetch().then((TravelTabModel model) {
      _controller = TabController(
          length: model.district.groups.length,
          vsync: this); //fix tab label 空白问题
      setState(() {
        tabs = model.district.groups;
        travelTabModel = model;
      });
    }).catchError((e) {
      print(e);
    });
  }

  void _loadHotKeyword() {
    TravelHotKeywordDao.fetch().then((TravelHotKeywordModel model) {
      setState(() {
        travelHotKeywordModel = model;
        hotKeyWords = travelHotKeywordModel.hotKeyword;
      });
    }).catchError((e) => print(e));
  }
}
