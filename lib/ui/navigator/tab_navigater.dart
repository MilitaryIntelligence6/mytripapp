import "package:flutter/material.dart";
import "package:flutter_ctrip/ui/view/destination_page.dart";
import "package:flutter_ctrip/ui/view/home_page.dart";
import "package:flutter_ctrip/ui/view/my_page.dart";
import "package:flutter_ctrip/ui/view/travel_page.dart";

class TabNavigator extends StatefulWidget {
  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final _defaultColor = Color(0xff8a8a8a);
  final _activeColor = Color(0xff50b4ed);
  int _currentIndex = 0;
  PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        children: <Widget>[
          new HomePage(),
          new DestinationPage(),
          new TravelPage(),
          new MyPage(),
        ],
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            _controller.animateToPage(
                index,
                curve: Curves.easeIn, duration: Duration(milliseconds: 260)
            );
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                "images/xiecheng.png",
                width: 22,
                height: 22,
              ),
              activeIcon: Image.asset(
                "images/xiecheng_active.png",
                width: 22,
                height: 22,
              ),
              title: Text(
                "??????",
                style: TextStyle(
                  color: _currentIndex != 0 ? _defaultColor : _activeColor,
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "images/mude.png",
                width: 24,
                height: 24,
              ),
              activeIcon: Image.asset(
                "images/mude_active.png",
                width: 24,
                height: 24,
              ),
              title: Text(
                "?????????",
                style: TextStyle(
                  color: _currentIndex != 1 ? _defaultColor : _activeColor,
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "images/lvpai.png",
                width: 23,
                height: 23,
              ),
              activeIcon: Image.asset(
                "images/lvpai_active.png",
                width: 23,
                height: 23,
              ),
              title: Text(
                "??????",
                style: TextStyle(
                  color: _currentIndex != 2 ? _defaultColor : _activeColor,
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "images/wode.png",
                width: 23,
                height: 23,
              ),
              activeIcon: Image.asset(
                "images/wode_active.png",
                width: 23,
                height: 23,
              ),
              title: Text(
                "??????",
                style: TextStyle(
                  color: _currentIndex != 3 ? _defaultColor : _activeColor,
                ),
              ),
            ),
          ]),
    );
  }

  Color _requireShouldBeColor(int pageIndex) {
    return _currentIndex == pageIndex
        ? _activeColor
        : _defaultColor;
  }
}
