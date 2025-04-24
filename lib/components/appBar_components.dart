import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        color: Colors.white,
        boxShadow: [
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
            imageUrl: 'assets/img/items/bar_history.png',
            label: '히스토리',
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