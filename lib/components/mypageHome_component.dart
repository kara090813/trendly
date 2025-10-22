import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../providers/_providers.dart';

class MypageHomeComponent extends StatefulWidget {
  const MypageHomeComponent({super.key});

  @override
  State<MypageHomeComponent> createState() => _MypageHomeComponentState();
}

class _MypageHomeComponentState extends State<MypageHomeComponent>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<UserPreferenceProvider>(
      builder: (context, preferences, child) {
        final isDark = AppTheme.isDark(context);

        return Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            physics: Platform.isIOS
                ? const BouncingScrollPhysics()
                : const ClampingScrollPhysics(),
            slivers: [
              // 헤더 영역 (KeywordHome과 동일한 구조)
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.getContainerColor(context),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.5)
                            : Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        spreadRadius: 3,
                        offset: Offset(0, 6),
                      ),
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28.r),
                      bottomRight: Radius.circular(28.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                    child: Container(
                      height: 50, // KeywordHome의 로고 높이와 동일
                      child: Center(
                        child: Text(
                          "설정",
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.isDark(context)
                                ? AppTheme.darkText
                                : AppTheme.lightText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 메인 콘텐츠 영역
              SliverPadding(
                padding: EdgeInsets.all(14.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 빠른 설정 - 각 항목을 별도의 컨테이너로 분리
                    _buildDarkModeSettings(preferences),

                    SizedBox(height: 16.h),

                    _buildNotificationSettings(preferences),

                    SizedBox(height: 16.h),

                    _buildAppInfoSettings(),

                    SizedBox(height: 80.h), // 하단 여백
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 다크모드 설정 카드
  Widget _buildDarkModeSettings(UserPreferenceProvider preferences) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              preferences.effectiveDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 28.sp,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '라이트/다크 모드',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.isDark(context)
                        ? AppTheme.darkText
                        : AppTheme.lightText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  preferences.effectiveDarkMode ? '다크 모드 활성화' : '라이트 모드 활성화',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: preferences.effectiveDarkMode,
            onChanged: (value) async {
              await preferences.toggleDarkMode();
              HapticFeedback.lightImpact();
            },
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  // 푸시 알림 설정 카드
  Widget _buildNotificationSettings(UserPreferenceProvider preferences) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 28.sp,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '푸시 알림',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.isDark(context)
                        ? AppTheme.darkText
                        : AppTheme.lightText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  preferences.isPushNotificationEnabled
                      ? '알림 받음'
                      : '알림 받지 않음',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: preferences.isPushNotificationEnabled,
            onChanged: (value) async {
              await preferences.setPushNotificationEnabled(value);
              HapticFeedback.lightImpact();
            },
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  // 앱 정보 설정 카드
  Widget _buildAppInfoSettings() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/app-info');
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.getContainerColor(context),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.isDark(context)
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.info_outline,
                size: 28.sp,
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '앱 정보',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.isDark(context)
                          ? AppTheme.darkText
                          : AppTheme.lightText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '버전, 이용약관, 개발사 정보',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18.sp,
              color: Colors.grey[500],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
    );
  }

  // ===== 기존 메서드들 - 주석처리 =====
  /*
  String _getActivitySummary(UserPreferenceProvider preferences) {
    final stats = preferences.getParticipationStats();
    return '토론 ${stats['roomCount']}회 • 댓글 ${stats['commentCount']}개';
  }

  String _getInstallDateString(DateTime? installDate) {
    if (installDate == null) return '2024.01.01';
    return '${installDate.year}.${installDate.month.toString().padLeft(2, '0')}.${installDate.day.toString().padLeft(2, '0')}';
  }

  // 프로필 정보 카드 (헤더에서 이동)
  Widget _buildProfileInfoCard(UserPreferenceProvider preferences) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 아이콘
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Color(0xFF19B3F6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 0.5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 30.sp,
            ),
          ),
          SizedBox(width: 16.w),

          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preferences.nickname?.isNotEmpty == true
                      ? '${preferences.nickname}님'
                      : '익명 사용자',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.isDark(context)
                        ? AppTheme.darkText
                        : AppTheme.lightText,
                  ),
                ),
                SizedBox(height: 4.h),
                // 설치일
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16.sp,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '설치일: ${_getInstallDateString(preferences.installDate)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  // 빠른 설정
  Widget _buildQuickSettings(UserPreferenceProvider preferences) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, size: 20.sp, color: AppTheme.primaryBlue),
              SizedBox(width: 8.w),
              Text(
                '빠른 설정',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.isDark(context)
                      ? AppTheme.darkText
                      : AppTheme.lightText,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 다크모드 토글
          Row(
            children: [
              Icon(
                preferences.effectiveDarkMode ? Icons.dark_mode : Icons.light_mode,
                size: 22.sp,
                color: AppTheme.primaryBlue,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '라이트/다크 모드',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.isDark(context)
                            ? AppTheme.darkText
                            : AppTheme.lightText,
                      ),
                    ),
                    Text(
                      preferences.effectiveDarkMode ? '다크 모드' : '라이트 모드',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: preferences.effectiveDarkMode,
                onChanged: (value) async {
                  await preferences.toggleDarkMode();
                  HapticFeedback.lightImpact();
                },
                activeColor: AppTheme.primaryBlue,
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // 푸시 알림 토글
          Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 22.sp,
                color: AppTheme.primaryBlue,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '푸시 알림',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.isDark(context)
                            ? AppTheme.darkText
                            : AppTheme.lightText,
                      ),
                    ),
                    Text(
                      preferences.isPushNotificationEnabled
                          ? '알림 받음'
                          : '알림 받지 않음',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: preferences.isPushNotificationEnabled,
                onChanged: (value) async {
                  final success =
                      await preferences.setPushNotificationEnabled(value);
                  HapticFeedback.lightImpact();

                  // 더 이상 스낵바 메시지를 표시하지 않음 (직관적인 토글 느낌)
                },
                activeColor: AppTheme.primaryBlue,
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // 앱 정보 메뉴
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/app-info');
            },
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 22.sp,
                  color: AppTheme.primaryBlue,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '앱 정보',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.isDark(context)
                              ? AppTheme.darkText
                              : AppTheme.lightText,
                        ),
                      ),
                      Text(
                        '버전, 이용약관, 개발사 정보',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),

          // SizedBox(height: 8.h),

          // 홈 위젯 설정 - 기능 완성 후 활성화 예정
          /*
          Row(
            children: [
              Icon(
                Icons.widgets_outlined,
                size: 22.sp,
                color: AppTheme.primaryBlue,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '홈 위젯 설정',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.isDark(context)
                            ? AppTheme.darkText
                            : AppTheme.lightText,
                      ),
                    ),
                    Text(
                      '홈 화면에서 위젯을 추가해 주세요',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          */
          
          // SizedBox(height: 16.h),
          // _buildWidgetSettings(preferences),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  // 프로필 관리 섹션 (항상 열린 형태)
  Widget _buildProfileSection(UserPreferenceProvider preferences) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Icon(Icons.account_circle_outlined,
                  color: AppTheme.primaryBlue, size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                '프로필 관리',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.isDark(context)
                      ? AppTheme.darkText
                      : AppTheme.lightText,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '닉네임 및 비밀번호 설정',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),

          // 닉네임 설정
          _buildEditableField(
            label: '닉네임',
            controller: _nicknameController,
            isEditing: _isEditingNickname,
            onEdit: () => setState(() => _isEditingNickname = true),
            onSave: () async {
              if (_nicknameController.text.trim().isNotEmpty) {
                await preferences.setNickname(_nicknameController.text.trim());
                setState(() => _isEditingNickname = false);
                _showSnackBar('닉네임이 변경되었습니다');
              }
            },
            onCancel: () {
              setState(() {
                _isEditingNickname = false;
                _nicknameController.text = preferences.nickname ?? '';
              });
            },
            placeholder: '닉네임을 입력하세요',
          ),

          SizedBox(height: 16.h),

          // 비밀번호 변경
          _buildEditableField(
            label: '비밀번호',
            controller: _newPasswordController,
            isEditing: _showNewPasswordField,
            onEdit: () {
              setState(() {
                _showNewPasswordField = true;
                _newPasswordController.clear();
              });
            },
            onSave: () async {
              if (_newPasswordController.text.trim().isNotEmpty) {
                await preferences
                    .setPassword(_newPasswordController.text.trim());
                setState(() {
                  _showNewPasswordField = false;
                  _passwordController.text = _newPasswordController.text.trim();
                });
                _showSnackBar('비밀번호가 변경되었습니다');
              }
            },
            onCancel: () {
              setState(() {
                _showNewPasswordField = false;
                _newPasswordController.clear();
              });
            },
            placeholder: '새 비밀번호를 입력하세요',
            obscureText: false,
            displayText: preferences.password?.isEmpty ?? true
                ? '비밀번호를 설정하세요'
                : '••••••••',
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  // 내 활동 섹션 (항상 열린 형태)
  Widget _buildActivitySection(UserPreferenceProvider preferences) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Icon(Icons.history, color: AppTheme.primaryBlue, size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                '내 활동',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.isDark(context)
                      ? AppTheme.darkText
                      : AppTheme.lightText,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '토론방, 댓글, 좋아요 히스토리',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),

          // 활동 카드들
          _buildActivityCard(
            '참여한 토론방',
            '${(preferences.commentedRooms.toSet().union(preferences.roomSentiments.keys.toSet())).length}개',
            Icons.forum,
            () => context.push('/my-activity/rooms'),
          ),
          _buildActivityCard(
            '작성한 댓글',
            '${preferences.commentIds.length}개',
            Icons.chat_bubble,
            () => context.push('/my-activity/comments'),
          ),
          _buildActivityCard(
            '좋아요한 댓글',
            '${preferences.getLikedComments().length}개',
            Icons.thumb_up,
            () => context.push('/my-activity/likes'),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildActivityCard(
      String title, String count, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  size: 18.sp,
                  color: AppTheme.primaryBlue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.isDark(context)
                            ? AppTheme.darkText
                            : AppTheme.lightText,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Colors.grey[500],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onSave,
    required VoidCallback onCancel,
    required String placeholder,
    bool obscureText = false,
    String? displayText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Spacer(),
            if (!isEditing)
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '수정',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        if (isEditing) ...[
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppTheme.isDark(context)
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: controller,
                    obscureText: obscureText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.isDark(context)
                          ? AppTheme.darkText
                          : AppTheme.lightText,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: placeholder,
                      hintStyle: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onSave,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.isDark(context)
                  ? Colors.grey[800]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              displayText ??
                  (controller.text.isEmpty
                      ? placeholder
                      : (obscureText ? '••••••••' : controller.text)),
              style: TextStyle(
                fontSize: 16.sp,
                color: (displayText != null && displayText == placeholder) ||
                        controller.text.isEmpty
                    ? Colors.grey[500]
                    : (AppTheme.isDark(context)
                        ? AppTheme.darkText
                        : AppTheme.lightText),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 홈 위젯 가이드 섹션 - 완성 후 활성화 예정
  /*
  Widget _buildWidgetSettings(UserPreferenceProvider preferences) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? Colors.grey[800]?.withOpacity(0.3)
            : Colors.grey[100]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '홈 위젯 가이드',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.isDark(context)
                  ? AppTheme.darkText
                  : AppTheme.lightText,
            ),
          ),
          SizedBox(height: 12.h),

          // 위젯 추가 방법
          _buildGuideItem(
            icon: Icons.add_box_outlined,
            title: '위젯 추가하기',
            description: '홈 화면을 길게 눌러 위젯 메뉴에서 Trendly를 추가하세요.',
          ),

          SizedBox(height: 10.h),

          // 새로고침 버튼
          _buildGuideItem(
            icon: Icons.refresh_outlined,
            title: '수동 새로고침',
            description: '위젯 내 새로고침 버튼을 눌러 언제나 최신 데이터로 업데이트할 수 있습니다.',
          ),

          SizedBox(height: 10.h),

          // 자동 업데이트
          _buildGuideItem(
            icon: Icons.schedule_outlined,
            title: '자동 업데이트',
            description: '30분마다 자동으로 새로운 실시간 트렌드 데이터로 업데이트됩니다.',
          ),

          SizedBox(height: 10.h),

          // 다양한 크기
          _buildGuideItem(
            icon: Icons.view_agenda_outlined,
            title: '다양한 크기',
            description: '작은 크기(3개), 중간 크기(5개), 큰 크기(10개) 키워드를 지원합니다.',
          ),

          SizedBox(height: 10.h),

          // 키워드 클릭
          _buildGuideItem(
            icon: Icons.touch_app_outlined,
            title: '키워드 클릭',
            description: '위젯의 키워드를 클릭하면 앱이 열리며 해당 키워드 상세 페이지로 이동합니다.',
          ),
        ],
      ),
    );
  }
  */

  // 가이드 아이템 빌드 헬퍼 메소드 - 위젯 가이드와 함께 주석처리
  /*
  Widget _buildGuideItem({required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.primaryBlue,
          size: 16.w,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.isDark(context)
                      ? AppTheme.darkText
                      : AppTheme.lightText,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  */

  void _showSnackBarImmediate(String message) {
    // 현재 표시되고 있는 스낵바 즉시 제거
    ScaffoldMessenger.of(context).clearSnackBars();

    // 새로운 스낵바 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
  */
}
