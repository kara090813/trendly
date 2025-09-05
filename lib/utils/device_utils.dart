import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'dart:math';

class DeviceUtils {
  // 태블릿 판별 기준 - 폰에서 태블릿 레이아웃이 보이는 것을 절대 방지
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    final longestSide = size.longestSide;
    final aspectRatio = longestSide / shortestSide;
    
    // 1단계: 화면 비율로 확실한 폰 필터링 (가장 중요)
    // iPhone, Galaxy S 시리즈 등 모든 폰은 2.0 이상의 비율
    if (aspectRatio > 1.85) {
      return false; // 세로로 긴 화면은 무조건 폰
    }
    
    // 2단계: 플랫폼별 세부 판별
    if (Platform.isIOS) {
      // iOS에서는 iPad만 태블릿으로 인정
      // iPad의 shortestSide는 최소 768dp 이상
      // iPhone 16 Pro Max는 약 430dp
      return shortestSide >= 768 && aspectRatio <= 1.78;
    } else {
      // Android에서는 매우 보수적으로 판별
      // 7인치 태블릿: 약 800dp+
      // 폴더블 폰도 고려하여 더 높은 기준 적용
      return shortestSide >= 900 && aspectRatio <= 1.6;
    }
  }
  
  // 태블릿 여부에 따른 패딩 계산
  static double getTabletPadding(BuildContext context, {double phone = 16, double tablet = 32}) {
    return isTablet(context) ? tablet.w : phone.w;
  }
  
  // 태블릿 여부에 따른 폰트 크기 계산
  static double getTabletFontSize(BuildContext context, {required double phone, double? tablet}) {
    return isTablet(context) ? (tablet ?? phone * 1.2).sp : phone.sp;
  }
  
  // 태블릿 여부에 따른 너비 계산
  static double getTabletWidth(BuildContext context, {double phone = double.infinity, double? tablet}) {
    if (!isTablet(context)) return phone;
    
    // 태블릿에서는 최대 너비 제한
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = tablet ?? screenWidth * 0.85;
    return maxWidth > screenWidth ? screenWidth : maxWidth;
  }
  
  // 태블릿 여부에 따른 높이 계산
  static double getTabletHeight(BuildContext context, {required double phone, double? tablet}) {
    return isTablet(context) ? (tablet ?? phone * 1.3).h : phone.h;
  }
  
  // 태블릿에서 컬럼 수 계산
  static int getTabletColumns(BuildContext context, {int phone = 1, int tablet = 2}) {
    return isTablet(context) ? tablet : phone;
  }
  
  // 태블릿에서 그리드 컬럼 수 계산
  static int getTabletGridColumns(BuildContext context, {int phone = 2, int tablet = 3}) {
    return isTablet(context) ? tablet : phone;
  }
  
  // 태블릿 여부에 따른 AspectRatio 계산
  static double getTabletAspectRatio(BuildContext context, {double phone = 1.0, double tablet = 1.5}) {
    return isTablet(context) ? tablet : phone;
  }
  
  // 태블릿 대응 Container 래퍼
  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
    EdgeInsets? padding,
  }) {
    if (!isTablet(context)) return child;
    
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? MediaQuery.of(context).size.width * 0.85,
        ),
        padding: padding,
        child: child,
      ),
    );
  }
  
  // 태블릿 여부에 따른 EdgeInsets 계산
  static EdgeInsets getTabletEdgeInsets(
    BuildContext context, {
    EdgeInsets phone = const EdgeInsets.all(16),
    EdgeInsets? tablet,
  }) {
    if (!isTablet(context)) return phone;
    
    return tablet ?? EdgeInsets.symmetric(
      horizontal: phone.horizontal * 2,
      vertical: phone.vertical * 1.5,
    );
  }
  
  // 태블릿 여부에 따른 SizedBox 크기
  static double getTabletSpacing(BuildContext context, {double phone = 16, double? tablet}) {
    return isTablet(context) ? (tablet ?? phone * 1.5) : phone;
  }
}