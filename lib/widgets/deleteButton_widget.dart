import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_theme.dart';

class DeleteButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final Color? color;
  final bool isVisible;

  const DeleteButtonWidget({
    Key? key,
    required this.onTap,
    this.size = 24,
    this.color,
    this.isVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          color: AppTheme.isDark(context)
              ? Color(0xFF2D2D3A)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            color: AppTheme.isDark(context)
                ? Colors.grey[700]!
                : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.close,
            size: (size * 0.65).w,
            color: color ?? Colors.red[400],
          ),
        ),
      ),
    );
  }
}