import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:trendly/widgets/circleButton_widget.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../models/_models.dart';
import '../widgets/sortingToggle_widget.dart';
import '../widgets/_widgets.dart';
import 'discussionHotTab_component.dart';
import 'discussionLiveTab_component.dart';
import 'discussionHistoryTab_component.dart';

class DiscussionHomeComponent extends StatefulWidget {
  const DiscussionHomeComponent({super.key});

  @override
  State<DiscussionHomeComponent> createState() =>
      _DiscussionHomeComponentState();
}

class _DiscussionHomeComponentState extends State<DiscussionHomeComponent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 탭 변경 리스너 추가
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = statusBarHeight + 16.h + 40.h + 16.h; // status bar + top padding + tab bar + bottom padding

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Stack(
        children: [
          // 탭 콘텐츠 영역
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: headerHeight),
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  DiscussionHotTabComponent(),
                  DiscussionLiveTabComponent(),
                  DiscussionHistoryTabComponent(),
                ],
              ),
            ),
          ),
          
          // 고정 헤더 - 위에 떠있도록
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TabHeaderWidget(
              tabLabels: ["HOT", "실시간", "히스토리"],
              selectedTabIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                  _tabController.animateTo(index);
                });
              },
            ),
          ),
        ],
      ),
    );
  }


}