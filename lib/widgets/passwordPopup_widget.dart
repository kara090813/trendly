import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_theme.dart';

class PasswordPopupWidget {
  // 암호 입력 팝업을 표시하는 정적 메서드
  static Future<String?> show(BuildContext context, {
    String title = "댓글 삭제",
    String message = "이 댓글을 삭제하려면 암호를 입력하세요",
    String confirmButtonText = "삭제",
    String cancelButtonText = "취소",
    Color confirmColor = Colors.red,
  }) async {
    final TextEditingController passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // 물리적 뒤로가기 버튼 처리 - true 반환하여 다이얼로그 닫기 허용
            return true;
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: _buildPopupContent(
              context,
              passwordController,
              title,
              message,
              confirmButtonText,
              cancelButtonText,
              confirmColor,
            ),
          ),
        );
      },
    );
  }

  // 팝업 내용 빌드
  static Widget _buildPopupContent(
      BuildContext context,
      TextEditingController controller,
      String title,
      String message,
      String confirmButtonText,
      String cancelButtonText,
      Color confirmColor,
      ) {
    final FocusNode focusNode = FocusNode();

    // 자동으로 포커스 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 400.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppTheme.isDark(context)
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 6.h),
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  color: confirmColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, size: 20.sp),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  splashRadius: 20.r,
                  color: AppTheme.isDark(context)
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            thickness: 1,
            color: AppTheme.isDark(context)
                ? Colors.grey[800]
                : Colors.grey[200],
          ),

          // 메시지
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.isDark(context)
                    ? Colors.grey[300]
                    : Colors.grey[700],
              ),
            ),
          ),

          // 암호 입력 필드
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "암호를 입력하세요",
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.isDark(context)
                      ? Colors.grey[500]
                      : Colors.grey[400],
                ),
                filled: true,
                fillColor: AppTheme.isDark(context)
                    ? Color(0xFF2A2A36)
                    : Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 10.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: AppTheme.isDark(context)
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: confirmColor.withOpacity(0.7),
                    width: 1.5,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.getTextColor(context),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
            ),
          ),

          // 버튼 영역
          Container(
            decoration: BoxDecoration(
              color: AppTheme.isDark(context)
                  ? Color(0xFF232329)
                  : Colors.grey[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 10.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 취소 버튼
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.isDark(context)
                          ? Colors.grey[400]
                          : Colors.grey[700],
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      cancelButtonText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // 확인 버튼
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        Navigator.pop(context, controller.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      confirmButtonText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}