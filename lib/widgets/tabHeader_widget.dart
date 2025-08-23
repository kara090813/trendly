import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../app_theme.dart';

class TabHeaderWidget extends StatelessWidget {
  final List<String> tabLabels;
  final int selectedTabIndex;
  final Function(int) onTabSelected;

  const TabHeaderWidget({
    super.key,
    required this.tabLabels,
    required this.selectedTabIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final topPadding = statusBarHeight + 16.h; // Status bar + additional padding

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.12),
            blurRadius: 16,
            spreadRadius: 3,
            offset: Offset(0, 6),
          ),
          // 추가 그림자 레이어
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: topPadding,
          bottom: 16.h,
          left: 24.w,
          right: 24.w,
        ),
        child: _buildNeumorphicTabBar(context),
      ),
    );
  }

  Widget _buildNeumorphicTabBar(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final double totalWidth = MediaQuery.of(context).size.width - 48.w;
    final double tabWidth = totalWidth / tabLabels.length;

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

          // 선택된 탭 인디케이터 (양각 효과)
          AnimatedPositioned(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            left: selectedTabIndex * tabWidth,
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
              ),
            ),
          ),

          // 탭 버튼 영역
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: totalWidth,
              height: 40.h,
              child: Row(
                children: List.generate(
                  tabLabels.length,
                  (index) => Expanded(
                    child: GestureDetector(
                      onTap: () => onTabSelected(index),
                      child: Container(
                        height: 40.h,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(
                          tabLabels[index],
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: index == selectedTabIndex ? FontWeight.w600 : FontWeight.w400,
                            fontFamily: 'asgm',
                            color: index == selectedTabIndex
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