import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_theme.dart';
import '../widgets/appBarIcon_widget.dart';

class AppBarComponent extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBarComponent({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 시스템 네비게이션 바 높이 가져오기
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 90.h + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 하단바 배경
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 90.h + bottomPadding,
              decoration: BoxDecoration(
                color: AppTheme.getBottomBarColor(context),
                boxShadow: AppTheme.isDark(context)
                    ? [
                        BoxShadow(
                          color: Colors.white.withAlpha(8),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 12,
                          offset: const Offset(0, -4),
                        ),
                      ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 탐험
                    Expanded(
                      child: AppBarIconWidget(
                        icon: Icons.explore_outlined,
                        label: '탐험',
                        isSelected: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                    ),

                    // 중앙 공간 확보 (홈 버튼 자리)
                    SizedBox(width: 92.w),

                    // 설정
                    Expanded(
                      child: AppBarIconWidget(
                        icon: Icons.settings_outlined,
                        label: '설정',
                        isSelected: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 플로팅 홈 버튼 (바 위에 떠있음)
          Positioned(
            left: 0,
            right: 0,
            top: -5.h, // 바 위로 튀어나오게
            child: Center(
              child: AppBarIconWidget(
                imageUrl: 'assets/img/items/bar_home.png',
                label: '홈',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
                isCenter: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
