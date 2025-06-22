import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/_providers.dart';
import '../widgets/_widgets.dart';
import 'timeMachineTab_component.dart';
import 'keywordHistoryTab_component.dart';
import 'keywordRandomTab_component.dart';

class HistoryHomeComponent extends StatefulWidget {
  const HistoryHomeComponent({super.key});

  @override
  State<HistoryHomeComponent> createState() => _HistoryHomeComponentState();
}

class _HistoryHomeComponentState extends State<HistoryHomeComponent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0; // 현재 선택된 탭 인덱스 추가

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

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Column(  // CustomScrollView 대신 Column 사용
        children: [
          // 고정 헤더
          TabHeaderWidget(
            tabLabels: ["타임머신", "키워드 히스토리", "랜덤 키워드"],
            selectedTabIndex: _selectedTabIndex,
            onTabSelected: (index) {
              setState(() {
                _selectedTabIndex = index;
                _tabController.animateTo(index);
              });
            },
          ),

          // 탭 콘텐츠 영역 - Expanded로 남은 공간 모두 사용
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(), // 좌우 스와이프 비활성화
              children: [
                TimeMachineTabComponent(),
                KeywordHistoryTabComponent(),
                RandomKeywordTabComponent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

}