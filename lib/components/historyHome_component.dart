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
          Container(
            decoration: BoxDecoration(
              color: AppTheme.getContainerColor(context),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15.r),
                bottomRight: Radius.circular(15.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.35)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // 헤더 타이틀
                  Padding(
                    padding: EdgeInsets.only(top: 16.h, bottom: 18.h),
                    child: Center(
                      child: Text(
                        "트렌드 히스토리",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                    ),
                  ),
                  // 뉴모픽 스타일 탭바
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: _buildNeumorphicTabBar(),
                  ),
                ],
              ),
            ),
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

  // 뉴모픽 스타일 탭바 위젯
  // 뉴모픽 스타일 탭바 위젯
  Widget _buildNeumorphicTabBar() {
    final isDark = AppTheme.isDark(context);
    final double totalWidth = MediaQuery.of(context).size.width - 48.w;
    final double tabWidth = totalWidth / 3;
    final List<String> tabLabels = ["타임머신", "키워드 히스토리", "랜덤 키워드"];

    return Container(
      height: 40.h,
      child: Stack(
        children: [
          // 배경 컨테이너 (음각 효과)
          Neumorphic(
            style: NeumorphicStyle(
              depth: isDark ? -2.5 : -2.5,
              intensity: isDark ? 0.6 : 0.8,
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10.r)),
              color: isDark ? Color(0xFF16161D) : Color(0xFFF4F4F4),
              lightSource: LightSource.topLeft,
              shadowDarkColor: isDark ? Colors.black : Colors.grey.shade400,
              shadowLightColor: isDark ? Colors.grey.shade800 : Colors.white,
            ),
            child: SizedBox(
              width: totalWidth,
              height: 40.h,
            ),
          ),

          // 선택된 탭 인디케이터 (양각 효과) - 텍스트 제거
          AnimatedPositioned(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            left: _selectedTabIndex * tabWidth,
            top: 0,
            child: Neumorphic(
              style: NeumorphicStyle(
                depth: 4,
                intensity: 0.7,
                shape: NeumorphicShape.flat,
                lightSource: LightSource.topLeft,
                color: Color(0xFF19B3F6),
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8.r)),
                shadowDarkColor: isDark ? Colors.black : Colors.grey.shade400,
                shadowLightColor: isDark ? Colors.grey.shade700 : Colors.white,
              ),
              child: Container(
                width: tabWidth,
                height: 40.h,
              ), // 텍스트 제거
            ),
          ),

          // 탭 버튼 영역 - 모든 탭에 텍스트 표시
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: totalWidth,
              height: 40.h,
              child: Row(
                children: List.generate(
                  3,
                      (index) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = index;
                          _tabController.animateTo(index);
                        });
                      },
                      child: Container(
                        height: 40.h,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(
                          tabLabels[index],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: index == _selectedTabIndex ? FontWeight.w600 : FontWeight.w400,
                            fontFamily: 'asgm',
                            color: index == _selectedTabIndex
                                ? Colors.white
                                : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}