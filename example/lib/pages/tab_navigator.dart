import 'package:flutter/material.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation_example/pages/forum/forum_page.dart';
import 'package:social_foundation_example/pages/settings/settings_page.dart';

import 'chat/message_page.dart';

List<Widget> pages = <Widget>[
  ForumPage(),
  MessagePage(),
  SettingsPage()
];

class TabNavigator extends StatefulWidget {
  TabNavigator({Key key}) : super(key: key);

  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  PageController _pageController;
  int _selectedIndex = 1;

  @override
  void initState(){
    _pageController = PageController(initialPage: _selectedIndex);
    SfLocatorManager.chatState.initData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemBuilder: (ctx, index) => pages[index],
        itemCount: pages.length,
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: '社区'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: '消息'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置'
          )
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}