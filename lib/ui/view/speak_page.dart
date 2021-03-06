/**
 * 《Flutter从入门到进阶-实战携程网App》
 * 课程地址：
 * https://coding.imooc.com/class/321.html
 * 课程代码、文档：
 * https://git.imooc.com/coding-321/
 * 课程辅导答疑区：
 * http://coding.imooc.com/learn/qa/321.html
 */
import "package:flutter/material.dart";
import "package:flutter_ctrip/ui/view/destination_search_page.dart";
import "package:flutter_ctrip/ui/view/page_type.dart";
import "package:flutter_ctrip/ui/view/search_page.dart";
import "package:flutter_ctrip/ui/view/travel_search_page.dart";
import "package:flutter_ctrip/plugin/asr_manager.dart";
import "package:flutter_ctrip/util/navigator_util.dart";

///语音识别
class SpeakPage extends StatefulWidget {
  final PageType pageType;

  SpeakPage({this.pageType = PageType.home});

  @override
  _SpeakPageState createState() => _SpeakPageState();
}

class _SpeakPageState extends State<SpeakPage>
    with SingleTickerProviderStateMixin, TickerProviderStateMixin {

  static const uniteTextStyle26 = const TextStyle(
      fontSize: 14,
      color: Colors.black26,
      letterSpacing: 1.2
  );

  static const uniteTextStyle38 = const TextStyle(
      fontSize: 14,
      color: Colors.black38,
      letterSpacing: 1.2
  );

  String speakTips = "长按说话";
  String speakResult = "";
  bool isUnResult = true;
  bool isStart = false;
  Animation<double> animation;
  AnimationController controller;
  bool isVTop = true;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    animation = CurvedAnimation(parent: controller, curve: Curves.easeInCubic)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reset();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 30, 30, 10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              isVTop
                  ? _topItem()
                  : isStart
                  ? _startTip()
                  : !isUnResult
                  ? _topTip()
                  : const SizedBox.shrink(),
              _bottomItem()
            ],
          ),
        ),
      ),
    );
  }

  void _speakStart() {
    controller.forward();
    setState(() {
      speakTips = "松开完成";
      isStart = true;
      isVTop = false;
    });
    AsrManager.start().then((text) {
      if (text != null && text.length > 0) {
        setState(() {
          speakResult = text;
          if (speakResult.endsWith("，")) {
            speakResult = speakResult.substring(0, speakResult.length - 1);
          }
          if (speakResult.endsWith("。")) {
            speakResult = speakResult.substring(0, speakResult.length - 1);
          }
          if (speakResult.endsWith("?")) {
            speakResult = speakResult.substring(0, speakResult.length - 1);
          }
          if (speakResult.endsWith("？")) {
            speakResult = speakResult.substring(0, speakResult.length - 1);
          }
        });
        Navigator.pop(context);
        switch (widget.pageType) {
          case PageType.home:
            NavigatorUtil.push(
                context,
                new SearchPage(
                  keyword: speakResult,
                  hideLeft: false,
                ));
            break;
          case PageType.travel:
            NavigatorUtil.push(
                context,
                new TravelSearchPage(
                  keyword: speakResult,
                  hideLeft: false,
                ));
            break;
          case PageType.destination:
            NavigatorUtil.push(
                context,
                DestinationSearchPage(
                  keyword: speakResult,
                  hideLeft: false,
                ));
            break;
        }
      } else {
        setState(() {
          isUnResult = false;
        });
      }
    }).catchError((e) {
      setState(() {
        isUnResult = false;
      });
      print("----------" + e.toString());
    });
  }

  void _speakStop() {
    setState(() {
      speakTips = "长按说话";
      isStart = false;
    });
    controller.reset();
    controller.stop();
    AsrManager.stop();
  }

  Widget _startTip() {
    return new Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Image.network(
          "https://images3.c-ctrip.com/marketing/2015/07/coupon_new_h5/dlp_awk.png",
          height: 80,
          width: 80,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        const Text("正在听您说...",
            style: const TextStyle(
                fontSize: 16,
                color: Colors.black38,
                letterSpacing: 1.2
            ),
        ),
      ],
    );
  }

  Widget _topTip() {
    return new Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        new Image.network(
          "https://ui.pages.c-ctrip.com/you/livestream/lvpai_you_img2.png",
          height: 80,
          width: 80,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        const Text("你好像没有说话",
            style: TextStyle(
                fontSize: 16,
                color: Colors.black38,
                letterSpacing: 1.2)),
        const Padding(
          padding: EdgeInsets.only(top: 8),
        ),
        const Text("请按住话筒重新开始",
            style: TextStyle(
                fontSize: 14,
                color: Colors.black26,
                letterSpacing: 1.2)
        ),
      ],
    );
  }

  Widget _topItem() {
    return new Column(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 26),
          child: new Text(
            "你可以这样说",
            style: new TextStyle(
              fontSize: 16,
              color: Colors.black38,
            ),
          ),
        ),
        _textItem("东方明珠"),
        _textItem("三亚自由行"),
        _textItem("迪士尼乐园"),
        _textItem("日本跟团游"),
        new Padding(
          padding: const EdgeInsets.all(20),
          child: new Text(
            speakResult,
            style: const TextStyle(color: Colors.blue),
          ),
        )
      ],
    );
  }

  Widget _textItem(String text) {
    return new Container(
      padding: const EdgeInsets.only(bottom: 6),
      child: new Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
          )),
    );
  }

  Widget _bottomItem() {
    return new Stack(
      children: <Widget>[
        new GestureDetector(
          onTapDown: (e) {
            _speakStart();
          },
          onTapUp: (e) {
            _speakStop();
          },
          onTapCancel: () {
            _speakStop();
          },
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Column(
                children: <Widget>[
                  new Text(
                    speakTips,
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                  new AnimatedWear(
                    animation: animation,
                    isStart: isStart,
                  ),
                ],
              ),
            ],
          ),
        ),
        new Positioned(
          right: 0,
          bottom: 26,
          child: new GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: new Icon(
              Icons.close,
              size: 26,
              color: Colors.grey,
            ),
          ),
        )
      ],
    );
  }
}

class AnimatedWear extends AnimatedWidget {
  final bool isStart;
  static final _opacityTween = new Tween<double>(begin: 0.5, end: 0);
  static final _sizeTween = new Tween<double>(begin: 90, end: 260);

  AnimatedWear({Key key, this.isStart, Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return new Container(
      height: 90,
      width: 90,
      child: new Stack(
        overflow: Overflow.visible,
        alignment: Alignment.center,
        children: <Widget>[
          isStart
              ? new Container(
                  decoration: new BoxDecoration(
                    color: Colors.black.withAlpha(30),
                    borderRadius: new BorderRadius.circular(45),
                  ),
                )
              : const SizedBox.shrink(),
          new Container(
            height: 70,
            width: 70,
            decoration: new BoxDecoration(
              color: Colors.blue,
              borderRadius: new BorderRadius.circular(35),
            ),
            child: new Icon(
              Icons.mic,
              color: Colors.white,
              size: 30,
            ),
          ),
          new Positioned(
            left: -((_sizeTween.evaluate(animation) - 90) / 2), //45
            top: -((_sizeTween.evaluate(animation) - 90) / 2), //45,
            child: new Opacity(
              opacity: _opacityTween.evaluate(animation),
              child: new Container(
                width: isStart ? _sizeTween.evaluate(animation) : 0,
                height: _sizeTween.evaluate(animation),
                decoration: new BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: new BorderRadius.circular(
                        _sizeTween.evaluate(animation) / 2),
                    border: new Border.all(
                      color: const Color(0xa8000000),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
