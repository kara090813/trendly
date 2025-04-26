import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 앱 전체에서 사용할 수 있는 스타일리시한 토스트 메시지 위젯
class StylishToast {
  static OverlayEntry? _currentToast;
  static Timer? _toastTimer;

  /// 토스트 메시지 표시
  ///
  /// [context] - 빌드 컨텍스트
  /// [message] - 표시할 메시지
  /// [isError] - 에러 메시지 여부 (빨간색 배경으로 표시)
  /// [duration] - 메시지 표시 시간 (밀리초)
  /// [position] - 화면의 상단에서부터의 위치 비율 (0.0 ~ 1.0)
  static void show(
      BuildContext context, {
        required String message,
        bool isError = false,
        int duration = 2500,
        double position = 0.15,
      }) {
    _dismissCurrent();

    print(MediaQuery.of(context).size.height * position);
    // 애니메이션 컨트롤러 생성
    final animationController = AnimationController(
      vsync: Navigator.of(context).overlay! as TickerProvider,
      duration: Duration(milliseconds: 300),
    );

    final animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    );

    // 오버레이 엔트리 생성
    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        top: 140.h,
        width: MediaQuery.of(context).size.width,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -20 * (1 - animation.value)),
              child: Opacity(
                opacity: animation.value,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isError ? Colors.redAccent.withOpacity(0.95) : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.16),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 아이콘 (성공 또는 에러)
                          Icon(
                            isError ? Icons.error_outline : Icons.check_circle_outline,
                            color: isError ? Colors.white : Color(0xFF19B3F6),
                            size: 22.sp,
                          ),
                          SizedBox(width: 10.w),
                          // 메시지 텍스트
                          Flexible(
                            child: Text(
                              message,
                              style: TextStyle(
                                color: isError ? Colors.white : Colors.black87,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    // 오버레이 표시 및 애니메이션 시작
    Overlay.of(context).insert(_currentToast!);
    animationController.forward();

    // 토스트 자동 제거 타이머 설정
    _toastTimer = Timer(Duration(milliseconds: duration), () {
      // 사라지는 애니메이션
      animationController.reverse().then((_) {
        _dismissCurrent();
        animationController.dispose();
      });
    });
  }

  /// 현재 표시된 토스트 메시지 제거
  static void _dismissCurrent() {
    _toastTimer?.cancel();
    if (_currentToast != null) {
      _currentToast!.remove();
      _currentToast = null;
    }
  }

  /// 성공 메시지 표시 (편의 메서드)
  static void success(BuildContext context, String message, {int duration = 2500, double position = 0.15}) {
    show(context, message: message, isError: false, duration: duration, position: position);
  }

  /// 에러 메시지 표시 (편의 메서드)
  static void error(BuildContext context, String message, {int duration = 2500, double position = 0.15}) {
    show(context, message: message, isError: true, duration: duration, position: position);
  }
}