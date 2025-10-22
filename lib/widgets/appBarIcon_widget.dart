import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';
import '../utils/device_utils.dart';

class AppBarIconWidget extends StatelessWidget {
  final String? imageUrl;
  final IconData? icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double? iconSize;
  final bool isCenter;

  const AppBarIconWidget({
    Key? key,
    this.imageUrl,
    this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.iconSize,
    this.isCenter = false,
  }) : assert(imageUrl != null || icon != null, 'Either imageUrl or icon must be provided'),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 중앙 홈 버튼 - 플로팅 디자인 (텍스트 라벨 없음)
    if (isCenter) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          customBorder: CircleBorder(),
          child: Container(
            width: 76.w,
            height: 76.w,
            padding: EdgeInsets.all(2.w),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? LinearGradient(
                        colors: [Color(0xFF19B3F6), Color(0xFF0EA5E9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark ? Colors.grey[800] : Colors.grey[200]),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Color(0xFF19B3F6).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 3,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Color(0xFF0EA5E9).withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
              ),
              child: Center(
                child: imageUrl != null
                    ? Image.asset(
                        imageUrl!,
                        width: 36.w,
                        height: 36.w,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      )
                    : Icon(
                        icon!,
                        size: 36.sp,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
              ),
            ),
          ),
        ),
      );
    }

    // 일반 버튼 (탐험, 설정) - 터치 영역을 텍스트까지 확장
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 2.h),
              // 아이콘
              Icon(
                icon!,
                size: iconSize ?? (DeviceUtils.isTablet(context) ? 18.sp : 22.sp),
                color: isSelected ? AppTheme.primaryBlue : Colors.grey[500],
              ),
              SizedBox(height: 3.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: DeviceUtils.isTablet(context) ? 8.sp : 10.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryBlue : Colors.grey[600],
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}