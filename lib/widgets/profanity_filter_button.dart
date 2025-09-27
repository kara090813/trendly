import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_preference_provider.dart';
import '../app_theme.dart';

/// 욕설 필터링 토글 버튼 (새로고침 버튼과 유사한 스타일)
class ProfanityFilterButton extends StatefulWidget {
  const ProfanityFilterButton({Key? key}) : super(key: key);

  @override
  State<ProfanityFilterButton> createState() => _ProfanityFilterButtonState();
}

class _ProfanityFilterButtonState extends State<ProfanityFilterButton> {
  bool _isProcessing = false;

  void _showSnackBar(BuildContext context, bool isEnabled) {
    // 이전 스낵바 즉시 제거
    ScaffoldMessenger.of(context).clearSnackBars();

    // 새로운 스낵바 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEnabled
              ? '댓글 클린봇이 활성화되었습니다'
              : '댓글 클린봇이 비활성화되었습니다',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isEnabled ? Colors.green : Colors.orange,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferenceProvider>(
      builder: (context, provider, child) {
        final isEnabled = provider.isProfanityFilterEnabled;

        return GestureDetector(
          onTap: () async {
            // 이미 처리 중이면 무시
            if (_isProcessing) return;

            setState(() {
              _isProcessing = true;
            });

            await provider.toggleProfanityFilter();
            _showSnackBar(context, provider.isProfanityFilterEnabled);

            // 짧은 지연 후 다시 클릭 가능하게 설정
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted) {
                setState(() {
                  _isProcessing = false;
                });
              }
            });
          },
          child: Opacity(
            opacity: _isProcessing ? 0.6 : 1.0,
            child: Container(
              width: 36.w,
              height: 36.w,
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
                child: Icon(
                  Icons.security,
                  color: isEnabled ? Color(0xFF19B3F6) : (AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600]),
                  size: 22.sp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}