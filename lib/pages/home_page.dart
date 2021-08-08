import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_ctrip/dao/home_dao.dart";
import "package:flutter_ctrip/model/common_model.dart";
import "package:flutter_ctrip/model/grid_nav_model.dart";
import "package:flutter_ctrip/model/home_model.dart";
import "package:flutter_ctrip/model/sales_box_model.dart";
import "package:flutter_ctrip/pages/search_page.dart";
import "package:flutter_ctrip/pages/speak_page.dart";
import "package:flutter_ctrip/plugin/square_swiper_pagination.dart";
import "package:flutter_ctrip/util/navigator_util.dart";
import "package:flutter_ctrip/widget/grid_nav.dart";
import "package:flutter_ctrip/widget/grid_nav_new.dart";
import "package:flutter_ctrip/widget/local_nav.dart";
import "package:flutter_ctrip/widget/sales_box.dart";
import "package:flutter_ctrip/widget/search_bar.dart";
import "package:flutter_ctrip/widget/sub_nav.dart";
import "package:flutter_ctrip/widget/webview.dart";
import "package:flutter_swiper/flutter_swiper.dart";
import "package:flutter_ctrip/widget/loading_container.dart";

const APPBAR_SCROLL_OFFSET = 100;
const SEARCH_BAR_DEFAULT_TEXT = "目的地 | 酒店 | 景点 | 航班号";

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double appBarAlpha = 0;
  List<CommonModel> localNavList = new List<CommonModel>();
  GridNavModel gridNavModel;
  List<CommonModel> subNavList = new List<CommonModel>();
  SalesBoxModel salesBoxModel;
  bool _isLoading = true;
  List<CommonModel> bannerList = new List<CommonModel>();

  @override
  void initState() {
    super.initState();
    _handleRefresh();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: new Color(0xfffafafc),
      body: new LoadingContainer(
        child: new Stack(
          children: <Widget>[
            new MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: new NotificationListener(
                onNotification: (ScrollNotification scrollNotification) {
                  if (scrollNotification is ScrollUpdateNotification &&
                      scrollNotification.depth == 0) {
                    _onScroll(scrollNotification.metrics.pixels);
                  }
                  return true;
                },
                child: new RefreshIndicator(
                  // ?? 没有方法括号;
                  onRefresh: _handleRefresh,
                  child: new ListView(
                    children: <Widget>[
                      new Container(
                        height: 262,
                        child: new Stack(
                          children: <Widget>[
                            new Container(
                              height: 210,
                              child: new Swiper(
                                // swiper 是轮播图组件;
                                itemCount: bannerList.length,
                                autoplay: true,
                                // 分页小圆点, 没有的话不出现分页;
                                pagination: new SwiperPagination(
                                  builder: new SquareSwiperPagination(
                                    size: 6,
                                    activeSize: 6,
                                    color: Colors.white.withAlpha(80),
                                    activeColor: Colors.white,
                                  ),
                                  alignment: Alignment.bottomCenter,
                                  margin: new EdgeInsets.fromLTRB(0, 0, 14, 28),
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return new GestureDetector(
                                    onTap: () {
                                      CommonModel model = bannerList[index];
                                      Navigator.push(
                                        context,
                                        // push 是方法, 必须把路由也传进去;
                                        new MaterialPageRoute(
                                          builder: (context) => new MyWebView(
                                            // 点击图片跳转的url, 如果没有, 点的动, 但会一直转圈
                                            // 不会有回应, 一直loading;
                                            url: model.url,
                                          ),
                                        ),
                                      );
                                    },
                                    // 轮播图片icon;
                                    child: new Image.network(
                                      bannerList[index].icon,
                                      fit: BoxFit.fill,
                                    ),
                                  );
                                },
                              ),
                            ),
                            // 攻略景点 门票玩乐那一坨;
                            new Positioned(
                              top: 188,
                              child: new Container(
                                width: MediaQuery.of(context).size.width,
                                padding: new EdgeInsets.fromLTRB(14, 0, 14, 0),
                                child: new LocalNav(localNavList: localNavList),
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Container(
                        // padding left right 14
                        padding: new EdgeInsets.fromLTRB(14, 0, 14, 0),
                        // 上面padding;
                        margin: new EdgeInsets.only(top: 10),
                        child: new Column(
                          // padding 就是给了内容然后隔离, 就是分隔;
                          children: <Widget>[
                            // 酒店机票旅游那一列;
                            new GridNavNew(),
                            new Padding(padding: EdgeInsets.only(top: 10)),
                            // 自由行 wifi电话 那一坨;
                            new SubNav(subNavList: subNavList),
                            new Padding(padding: EdgeInsets.only(top: 10)),
                            // 下拉框中的热门活动一栏;
                            new SalesBox(salesBoxModel: salesBoxModel),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 搜索框;
            _appBar
          ],
        ),
        isLoading: _isLoading,
      ),
    );
  }

  Widget get _appBar {
    return new Column(
      children: <Widget>[
        new Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: <Color>[new Color(0x66000000), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          // 最顶层container 的child
          child: new Container(
            padding: new EdgeInsets.fromLTRB(14, 20, 0, 0),
            height: 86,
            decoration: new BoxDecoration(
              color: new Color.fromARGB(
                  (appBarAlpha * 255).toInt(), 255, 255, 255),
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color:
                      appBarAlpha == 1.0 ? Colors.black12 : Colors.transparent,
                  offset: new Offset(2, 3),
                  blurRadius: 6,
                  spreadRadius: 0.6,
                ),
              ],
            ),
            // 最顶层container 的child container的child
            // new search bar 出现 searchbar 目的地|酒店|那一坨
            // 若缺少某些东西可能会掉;
            child: new SearchBar(
              // 不可缺少;
              defaultText: SEARCH_BAR_DEFAULT_TEXT,
              searchBarType: appBarAlpha > 0.2
                  ? SearchBarType.homeLight
                  : SearchBarType.home,
              inputBoxClick: _jumpToSearch,
              leftButtonClick: () {},
              // 语音点击;
              speakClick: _jumpToSpeak,
              rightButtonClick: _jumpToUser,
            ),
          ),
        ),
        // 出现搜索下拉全靠他;
        new Container(
          height: appBarAlpha > 0.2 ? 0.5 : 0,
          decoration: new BoxDecoration(
            boxShadow: <BoxShadow>[
              new BoxShadow(
                color: Colors.black12,
                blurRadius: 0.5,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _jumpToSpeak() {
    NavigatorUtil.push(context, new SpeakPage());
  }

  /// 下拉的阴影;
  void _onScroll(double offset) {
    double alpha = offset / APPBAR_SCROLL_OFFSET;
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
    setState(() {
      appBarAlpha = alpha;
    });
    print(alpha);
  }

  /// 异步请求?;
  Future<Null> _handleRefresh() async {
    try {
      HomeModel homeModel = await HomeDao.fetch();
      setState(() {
        localNavList = homeModel.localNavList;
        gridNavModel = homeModel.gridNav;
        subNavList = homeModel.subNavList;
        salesBoxModel = homeModel.salesBox;
        bannerList = homeModel.bannerList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        print(e);
        setState(() {
          _isLoading = false;
        });
      });
      return null;
    }
  }

  void _jumpToSearch() {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new SearchPage(
          hint: SEARCH_BAR_DEFAULT_TEXT,
          hideLeft: false,
        ),
      ),
    );
  }

  void _jumpToUser() {
    NavigatorUtil.push(
        context,
        new MyWebView(
          url:
              "https://m.ctrip.com/webapp/servicechatv2/messagelist/?from=%2Fwebapp%2Fmyctrip%2Findex",
          hideHead: false,
          hideAppBar: false,
          title: "我的消息",
        ), callBack: () {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    });
  }
}
