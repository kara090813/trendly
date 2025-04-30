import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_theme.dart';

Widget CircleButtonWidget({
  required BuildContext context,
  required VoidCallback onTap,
  IconData? icon,
  String? assetImagePath,
  required Color color,
  required double iconSize,
  EdgeInsets? imagePadding,
  double? containerSize, // 버튼 전체 크기 조절 옵션
}) {
  // 컨테이너 크기의 기본값은 36.w
  final double effectiveContainerSize = containerSize ?? 36.w;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: effectiveContainerSize,
      height: effectiveContainerSize,
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? Color(0xFF2A2A36)
            : Colors.white,
        shape: BoxShape.circle,
        boxShadow: AppTheme.isDark(context)
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            spreadRadius: 1,
            offset: Offset(0, 1),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.35),
            blurRadius: 3,
            spreadRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        // 에셋 이미지 경로가 제공된 경우 이미지 사용, 그렇지 않으면 아이콘 사용
        child: assetImagePath != null
            ? Padding(
          padding: imagePadding ?? EdgeInsets.all(8.w),
          child: Image.asset(
            assetImagePath,
            width: iconSize,
            height: iconSize,
            color: color,
          ),
        )
            : Icon(
          icon ?? Icons.circle,
          color: color,
          size: iconSize,
        ),
      ),
    ),
  );
}