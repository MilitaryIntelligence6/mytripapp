import "package:flutter/material.dart";
import "package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart";
import "package:flutter_ctrip/dao/travel_dao.dart";
import "package:flutter_ctrip/model/travel_model.dart";
import "package:flutter_ctrip/util/navigator_util.dart";
import "package:flutter_ctrip/ui/widget/loading_container.dart";
import "package:flutter_ctrip/ui/widget/webview.dart";
import "package:flutter_spinkit/flutter_spinkit.dart";

class TravelTabPage extends StatefulWidget {
  final String travelUrl;
  final Map params;
  final String groupChannelCode;

  const TravelTabPage({
    Key key, this.travelUrl,
    this.params,
    this.groupChannelCode
  }) : super(key: key);

  @override
  _TravelTabPageState createState() => new _TravelTabPageState();
}

class _TravelTabPageState extends State<TravelTabPage>
    with AutomaticKeepAliveClientMixin {

  static const String _TRAVEL_URL =
      "https://m.ctrip.com/restapi/soa2/16189/json/searchTripShootListForHomePageV2?_fxpcqlniredt=09031014111431397988&__gw_appid=99999999&__gw_ver=1.0&__gw_from=10650013707&__gw_platform=H5";

  static const int PAGE_SIZE = 10;

  List<TravelItem> travelItems;
  int pageIndex = 1;
  bool _loading = true;
  bool _loadMore = false;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    _loadData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadData(loadMore: true);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
      body: new LoadingContainer(
        isLoading: _loading,
        child: new RefreshIndicator(
          onRefresh: _handleRefresh,
          child: new MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: new Column(
                children: <Widget>[
                  new Expanded(
                    child: new StaggeredGridView.countBuilder(
                      controller: _scrollController,
                      crossAxisCount: 4,
                      itemCount: travelItems?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) => _TravelItem(
                        index: index,
                        item: travelItems[index],
                      ),
                      staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                      mainAxisSpacing: 2.0,
                      crossAxisSpacing: 2.0,
                    ),
                  ),
                  _loadMoreIndicator(_loadMore),
                ],
              )),
        ),
      ),
    );
  }

  void _loadData({loadMore = false}) {
    if (loadMore) {
      setState(() {
        _loadMore = true;
      });
      pageIndex++;
    } else {
      pageIndex = 1;
    }

    TravelDao.fetch(widget.travelUrl ?? _TRAVEL_URL, widget.params,
            widget.groupChannelCode, pageIndex, PAGE_SIZE)
        .then((TravelItemModel model) {
      _loading = false;
      setState(() {
        List<TravelItem> items = _filterItems(model.resultList);
        if (travelItems != null) {
          travelItems.addAll(items);
          _loadMore = false;
        } else {
          travelItems = items;
        }
      });
    }).catchError((e) {
      _loading = false;
      print(e);
    });
  }

  List<TravelItem> _filterItems(List<TravelItem> resultList) {
    if (resultList == null) {
      return new List<TravelItem>();
    }
    List<TravelItem> filterItems = new List<TravelItem>();
    resultList.forEach((item) {
      if (item.article != null) {
        //移除article为空的模型
        filterItems.add(item);
      }
    });
    return filterItems;
  }

  @override
  bool get wantKeepAlive => true;

  Future<Null> _handleRefresh() async {
    _loadData();
    return null;
  }
}

Widget _loadMoreIndicator(loadMore){
  return loadMore
      ? new Padding(
        padding: const EdgeInsets.all(6),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new SpinKitFadingCircle(color: Colors.blue,size: 24,),
            new Padding(padding: EdgeInsets.only(right: 5),),
            const Text("加载中...",style: TextStyle(fontSize: 14,color: Colors.grey),),
          ],
        ),
      ) : const SizedBox.shrink();
}

class _TravelItem extends StatelessWidget {
  final TravelItem item;
  final int index;

  const _TravelItem({Key key, this.item, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        if (item.article.urls != null && item.article.urls.length > 0) {
          NavigatorUtil.push(
              context, new MyWebView(
            url: item.article.urls[0].h5Url,
            title: "携程旅拍",
          ));
        }
      },
      child: new Card(
        child: new PhysicalModel(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          borderRadius: new BorderRadius.circular(5),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _itemImage(context),
              new Container(
                padding: const EdgeInsets.all(4),
                child: new Text(
                  item.article.articleTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              _infoText()
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemImage(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new Image.network(item.article.images[0]?.dynamicUrl),
        new Positioned(
            bottom: 8,
            left: 8,
            child: new Container(
              padding: const EdgeInsets.fromLTRB(5, 1, 5, 1),
              decoration: new BoxDecoration(
                  color: Colors.black54,
                  borderRadius: new BorderRadius.circular(10)),
              child: new Row(
                children: <Widget>[
                   new Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: new Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 12,
                      )),
                  new LimitedBox(
                    maxWidth: MediaQuery.of(context).size.width / 2 - 66,
                    child: new Text(
                      _poiName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                ],
              ),
            ))
      ],
    );
  }

  String _poiName() {
    return item.article.pois == null || item.article.pois.length == 0
        ? "未知"
        : item.article.pois[0]?.poiName ?? "未知";
  }

  Widget _infoText() {
    return new Container(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 10),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Row(
            children: <Widget>[
              new PhysicalModel(
                color: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                borderRadius: new BorderRadius.circular(12),
                child: new Image.network(
                  item.article.author?.coverImage?.dynamicUrl,
                  width: 24,
                  height: 24,
                ),
              ),
              new Container(
                padding: const EdgeInsets.all(5),
                width: 80,
                child: new Text(
                  item.article.author?.nickName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              )
            ],
          ),
          new Row(
            children: <Widget>[
              new Icon(
                Icons.thumb_up,
                size: 14,
                color: Colors.grey,
              ),
              new Padding(
                padding: const EdgeInsets.only(left: 3),
                child: new Text(
                  item.article.likeCount.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
