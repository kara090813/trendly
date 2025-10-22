import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  final String _version = '1.1.0';

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getContainerColor(context),
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.grey[800]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
              size: 20.sp,
            ),
          ),
        ),
        title: Text(
          '앱 정보',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // 앱 로고 및 기본 정보
            _buildAppHeader(),
            
            SizedBox(height: 32.h),
            
            // AI 컨텐츠 안내
            _buildAIContentNotice(),
            
            SizedBox(height: 20.h),
            
            // 데이터 수집 안내
            _buildDataCollectionNotice(),
            
            SizedBox(height: 20.h),
            
            // 개발사 정보
            _buildDeveloperInfo(),
            
            SizedBox(height: 20.h),
            
            // 버전 정보
            _buildVersionInfo(),
            
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 앱 로고 이미지
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.asset(
                'assets/img/logo_img_fix.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SizedBox(width: 20.w),
          
          // 앱 이름과 설명 (세로 배치)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trendly',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.isDark(context)
                        ? AppTheme.darkText
                        : AppTheme.lightText,
                  ),
                ),
                
                SizedBox(height: 6.h),
                
                Text(
                  '실시간 트렌드 분석 앱',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAIContentNotice() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.orange[600],
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  'AI 컨텐츠 안내',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.isDark(context)
                        ? AppTheme.darkText
                        : AppTheme.lightText,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Text(
            '본 앱의 실시간 검색어 요약, 키워드 분석, 토론 요약 등의 컨텐츠는 AI 기술을 활용하여 자동으로 생성됩니다.',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppTheme.isDark(context)
                  ? Colors.grey[300]
                  : Colors.grey[700],
              height: 1.5,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 2.h),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange[600],
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'AI로 생성된 컨텐츠는 실제와 다를 수 있으며, 정확성을 보장하지 않습니다. 중요한 정보는 원본 소스를 직접 확인해 주시기 바랍니다.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.orange[700],
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildDataCollectionNotice() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.storage,
                  color: AppTheme.primaryBlue,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  '데이터 수집 안내',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.isDark(context)
                        ? AppTheme.darkText
                        : AppTheme.lightText,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Text(
            '본 서비스는 2025년 10월 이후의 트렌드 데이터를 수집 및 저장하고 있습니다.',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppTheme.isDark(context)
                  ? Colors.grey[300]
                  : Colors.grey[700],
              height: 1.5,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryBlue,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '데이터 범위',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  '• 수집 시작: 2025년 9월\n• 데이터 소스: 뉴스, 소셜미디어, 커뮤니티\n• 업데이트 주기: 실시간',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.primaryBlue,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildDeveloperInfo() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.business,
                  color: Colors.green[600],
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  '개발사 정보',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.isDark(context)
                        ? AppTheme.darkText
                        : AppTheme.lightText,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // 회사명
          _buildInfoRow('개발사', 'Lamoss Tech'),

          SizedBox(height: 12.h),

          // 신고 및 문의
          _buildInfoRow('신고/문의', 'kara090813@gmail.com'),

          SizedBox(height: 12.h),

          // Copyright
          _buildInfoRow('저작권', 'Copyright © 2024 Lamoss Tech'),
          
          SizedBox(height: 16.h),
          
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'All rights reserved. 본 소프트웨어 및 관련 문서에 대한 모든 권리는 Lamoss Tech에 있습니다.',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.green[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.info,
                  color: Colors.purple[600],
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  '버전 정보',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.isDark(context)
                        ? AppTheme.darkText
                        : AppTheme.lightText,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          _buildInfoRow('현재 버전', 'v$_version'),

        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.isDark(context)
                  ? AppTheme.darkText
                  : AppTheme.lightText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}