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
    return Container(
      height: 80.h,
      padding: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.getBottomBarColor(context),
        boxShadow: AppTheme.isDark(context)
            ? [
                BoxShadow(
                  color: Colors.white.withAlpha(10),
                  blurRadius: 3,
                  offset: const Offset(0, -3),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppBarIconWidget(
            imageUrl: 'assets/img/items/bar_home.png',
            label: '홈',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          AppBarIconWidget(
            imageUrl: 'assets/img/items/bar_discussion.png',
            label: '토론방',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          AppBarIconWidget(
            icon: Icons.explore,
            label: '탐험',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          AppBarIconWidget(
            imageUrl: 'assets/img/items/bar_my.png',
            label: '마이페이지',
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}
