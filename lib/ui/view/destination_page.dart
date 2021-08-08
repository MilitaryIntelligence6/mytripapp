import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_ctrip/dao/destination_dao.dart";
import "package:flutter_ctrip/model/destination_model.dart";
import "package:flutter_ctrip/ui/view/destination_search_page.dart";
import "package:flutter_ctrip/ui/view/page_type.dart";
import "package:flutter_ctrip/ui/view/speak_page.dart";
import "package:flutter_ctrip/plugin/vertical_tab_view.dart";
import "package:flutter_ctrip/util/navigator_util.dart";
import "package:flutter_ctrip/ui/widget/scalable_box.dart";
import "package:flutter_ctrip/ui/widget/search_bar.dart";
import "package:flutter_ctrip/ui/widget/loading_container.dart";
import "package:flutter_ctrip/ui/widget/webview.dart";

const DEFAULT_TEXT = "目的地 | 主题 | 关键字";

class DestinationPage extends StatefulWidget {
  @override
  _DestinationPageState createState() => new _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage>
    with AutomaticKeepAliveClientMixin {
  DestinationModel destinationModel;
  List<NavigationPopList> navigationList;
  List<Tab> tabs = new List<Tab>();
  List<Widget> tabPages = new List<Widget>();
  bool _isLoading = true;
  bool _isMore = true;
  int pageIndex, buttonIndex;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    if (tabs.length > 0 && tabPages.length > 0) {
      setState(() {
        _isLoading = false;
      });
    }
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      
    }
    return new Scaffold(
      backgroundColor: Colors.white,
      body: new LoadingContainer(
        isLoading: _isLoading,
        child: new Stack(
          children: <Widget>[
            new Container(
              margin: new EdgeInsets.only(
                  top: Theme.of(context).platform == TargetPlatform.iOS
                      ? 92
                      : 86),
              // 热门目的地等等啥的所有框框包括url跳转
              // 说明是封装好了核心功能;
              child: new VerticalTabView(
                tabsWidth: 88,
                tabsElevation: 0,
                indicatorWidth: 0,
                selectedTabBackgroundColor: Colors.white,
                backgroundColor: Colors.white,
                tabTextStyle:
                new TextStyle(height: 60, color: new Color(0xff333333)),
                tabs: tabs,
                contents: tabPages,
              ),
            ),
            // 搜索框布局;
            new Container(
              padding: new EdgeInsets.fromLTRB(8, 6, 6, 10),
              decoration: new BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  new BoxShadow(
                    color: new Color.fromARGB(10, 0, 0, 0),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: new Offset(1, 1),
                  ),
                ],
              ),
              child: new SafeArea(
                child: new SearchBar(
                  searchBarType: SearchBarType.homeLight,
                  defaultText: DEFAULT_TEXT,
                  // 传入方法, 所以没括号;
                  onInputBoxClicked: _jumpToSearch,
                  onSpeakButtonClicked: _jumpToSearch,
                  onRightButtonClicked: _jumpToService,
                  rightIcon: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadData() {
    DestinationDao.fetch().then((DestinationModel model) {
      setState(() {
        destinationModel = model;
        navigationList = destinationModel.navigationPopList;
      });
      _createTab();
      _createTabPage(context);
    }).catchError((e) => print(e));
  }

  void _createTab() {
    if (navigationList == null) {
      return;
    }
    navigationList.forEach((NavigationPopList model) {
      tabs.add(
        new Tab(
          child: new Container(
            height: 50,
            alignment: Alignment.center,
            child: new Text(
              // 左边一栏的tab, 中国日本新加坡那一块;
              // 所以是分类名称;
              model.categoryName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: new TextStyle(
                color: new Color(0xff666666),
                fontSize: 15,
              ),
            ),
          ),
        ),
      );
    });
  }

  void _createTabPage(BuildContext context) {
    if (navigationList == null) {
      return;
    }
    for (int i = 0; i < navigationList.length; i++) {
      List<Widget> tabPage = new List<Widget>();
      for (var j = 0; j < navigationList[i].destAreaList.length; j++) {
        String text = navigationList[i].destAreaList[j].text;
        tabPage.add(
          /// 标题
          new Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
            child: new Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        );
        List<Widget> imageItems = new List<Widget>();
        List<Widget> spanContent = new List<Widget>();
        List<Widget> visibleSpans = new List<Widget>();
        List<Row> visibleRows = new List<Row>();
        List<Widget> unVisibleSpans = new List<Widget>();
        List<Row> unVisibleRows = new List<Row>();
        for (var k = 0;
        k < navigationList[i].destAreaList[j].child.length;
        k++) {
          String imgName = navigationList[i].destAreaList[j].child[k].text;
          String tagName =
          navigationList[i].destAreaList[j].child[k].tagList.length > 0
              ? navigationList[i]
              .destAreaList[j]
              .child[k]
              .tagList[0]
              .tagName
              : "";
          String spanText = navigationList[i].destAreaList[j].child[k].text;
          int tagListL =
              navigationList[i].destAreaList[j].child[k].tagList.length;
          String picUrl = navigationList[i].destAreaList[j].child[k].picUrl;
          String kwd = navigationList[i].destAreaList[j].child[k].kwd;
          int id = navigationList[i].destAreaList[j].child[k].id;

          ///图片
          if (picUrl != null && picUrl != "") {
            imageItems.add(
              createImage(picUrl, tagListL, tagName, imgName, kwd, id),
            );
          } else {
            ///标签
            //当标签数量小于9个时，放到可以显示的容器
            if (k < 9) {
              visibleSpans.add(
                createSpan(spanText, tagListL, tagName, kwd, id),
              );
            } else if (k >= 9) {
              unVisibleSpans.add(
                createSpan(spanText, tagListL, tagName, kwd, id),
              );
            }
          }
        }
        if (visibleSpans.length >= 9) {
          visibleRows.add(new Row(
            children: visibleSpans.sublist(0, 3),
          ));
          visibleRows.add(new Row(
            children: visibleSpans.sublist(3, 6),
          ));
          visibleRows.add(new Row(
            children: visibleSpans.sublist(6, 9),
          ));
        } else if (visibleSpans.length > 0 && visibleSpans.length < 9) {
          if (visibleSpans.length % 3 == 1) {
            visibleSpans.add(new Expanded(child: Container()));
            visibleSpans.add(new Expanded(child: Container()));
          } else if (visibleSpans.length % 3 == 2) {
            visibleSpans.add(new Expanded(child: Container()));
          }
          int vStart = 0;
          for (var k = 0; k < visibleSpans.length; k++) {
            if ((k + 1) % 3 == 0 && k != 0) {
              visibleRows.add(new Row(
                children: visibleSpans.sublist(vStart, (k + 1)),
              ));
              vStart = k + 1;
            }
          }
        }
        int unStart = 0;
        if (unVisibleSpans.length >= 9) {
          if (unVisibleSpans.length % 3 == 1) {
            unVisibleSpans.add(new Expanded(child: Container()));
            unVisibleSpans.add(new Expanded(child: Container()));
          } else if (unVisibleSpans.length % 3 == 2) {
            unVisibleSpans.add(new Expanded(child: Container()));
          }
          for (var k = 0; k < unVisibleSpans.length; k++) {
            if ((k + 1) % 3 == 0 && k != 0) {
              unVisibleRows.add(new Row(
                children: unVisibleSpans.sublist(unStart, (k + 1)),
              ));
              unStart = k + 1;
            }
          }
        }
        // 处理数据 每3条数据放到一个row容器
        List<Widget> rowList = new List<Widget>();
        if (imageItems.length % 3 == 1) {
          imageItems.add(new Expanded(child: Container()));
          imageItems.add(new Expanded(child: Container()));
        } else if (imageItems.length % 3 == 2) {
          imageItems.add(new Expanded(child: Container()));
        }
        int start = 0;
        for (var k = 0; k < imageItems.length; k++) {
          if ((k + 1) % 3 == 0 && k != 0) {
            rowList.add(
              Row(
                children: imageItems.sublist(start, (k + 1)),
              ),
            );
            start = k + 1;
          } else if (imageItems.length - start < 3) {
            rowList.add(
              new Row(
                children: imageItems.sublist(start),
              ),
            );
            break;
          }
        }
        tabPage.add(
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowList,
          ),
        );
        if (visibleRows.length > 0) {
          tabPage.add(
            new ScalableBox(visibleRows, unVisibleRows),
          );
        }
      }
      tabPages.add(new MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: new ListView(
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.fromLTRB(2, 0, 10, 0),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tabPage,
              ),
            ),
          ],
        ),
      ));
    }
  }

  void _jumpToSearch() {
    NavigatorUtil.push(
      context,
      new DestinationSearchPage(
        hint: DEFAULT_TEXT,
        hideLeft: false,
      ),
    );
  }

  void _jumpToSpeak() {
    NavigatorUtil.push(
        context,
        new SpeakPage(
          pageType: PageType.destination,
        ));
  }

  void _jumpToService() {
    NavigatorUtil.push(
        context,
        new MyWebView(
          url:
          "https://m.ctrip.com/webapp/servicechatv2/?bizType=1105&channel=VAC&orderInfo=&isPreSale=1&pageCode=220008&thirdPartytoken=F2BCB02915C58496DD7DEA00278B68AF&sceneCode=0&isFreeLogin=",
          hideAppBar: false,
          title: "客服",
        ));
  }

  void _buttonMore(int i, int j) {
    pageIndex = i;
    buttonIndex = j;
    _isMore = !_isMore;
  }

  Widget createSpan(String text, int tagListL, String tagText, String kwd,
      int id) {
    return new Expanded(
      child: new GestureDetector(
        onTap: () {
          _openWebView(kwd, id);
        },
        child: Stack(
          children: <Widget>[
            new Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
              decoration: new BoxDecoration(
                  color: const Color(0xfff8f8f8),
                  borderRadius: new BorderRadius.circular(4),
                  boxShadow: [
                    new BoxShadow(
                        color: Colors.black.withAlpha(30),
                        offset: const Offset(1, 1),
                        spreadRadius: 1,
                        blurRadius: 3),
                  ]),
              height: 36,
              child: new Text(
                text,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: new TextStyle(
                    color: Color(0xff333333).withAlpha(220), fontSize: 13),
              ),
            ),
            tagListL > 0
                ? new Positioned(
              top: -8,
              right: 4,
              child: new Container(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                height: 18,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: const Color(0xffff7600),
                  borderRadius: const BorderRadius.only(
                    topRight: const Radius.circular(6),
                    topLeft: const Radius.circular(8),
                    bottomLeft: const Radius.circular(0),
                    bottomRight: const Radius.circular(6),
                  ),
                ),
                child: new Text(
                  tagText,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            )
                : Container(),
          ],
          overflow: Overflow.visible,
        ),
      ),
    );
  }

  Widget createImage(String picUrl, int tagListL, String tagName,
      String imgName, String kwd, int id) {
    return new Expanded(
      child: new GestureDetector(
        onTap: () {
          _openWebView(kwd, id);
        },
        child: new Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 0, 0),
          child: new Column(
            children: <Widget>[
              new PhysicalModel(
                borderRadius: new BorderRadius.circular(6),
                clipBehavior: Clip.antiAlias,
                color: Colors.transparent,
                elevation: 5,
                child: new Stack(
                  children: <Widget>[
                    new Container(
                      child: new Image.network(
                        picUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    tagListL > 0
                        ? new Positioned(
                      top: 0,
                      left: 0,
                      child: new Container(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        height: 18,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: const Color(0xffff7600),
                            borderRadius: const BorderRadius.only(
                                bottomRight: const Radius.circular(8))),
                        child: new Text(
                          tagName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              new Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: new Text(
                  imgName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: new TextStyle(color: new Color(0xff333333).withAlpha(220)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void _openWebView(String keyword, int id) {
    NavigatorUtil.push(
        context,
        new MyWebView(
          url:
          "https://m.ctrip.com/webapp/vacations/tour/list?identifier=choice&kwd=${keyword}&poid=${id
              .toString()}&poitype=D&salecity=2&scity=2&searchtype=all&tab=126",
          hideAppBar: true,
        ));
  }
}
