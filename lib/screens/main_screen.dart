import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../components/_components.dart';
import '_screens.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    KeywordHomeComponent(),
    DiscussionHomeComponent(),
    HistoryHomeComponent(),
    MypageHomeComponent(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // 화면이 완전히 빌드된 후 가이드 표시
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Column(
        children: [
          // 메인 컨텐츠 영역
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _widgetOptions,
            ),
          ),

          // 하단 앱바
          Container(
            color: AppTheme.getBottomBarColor(context),
            child: SafeArea(
              top: false,
              child: AppBarComponent(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
            ),
          )


        ],
      ),
    );
  }
}