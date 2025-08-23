import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../providers/_providers.dart';
import '../widgets/_widgets.dart';

class MypageHomeComponent extends StatefulWidget {
  const MypageHomeComponent({super.key});

  @override
  State<MypageHomeComponent> createState() => _MypageHomeComponentState();
}

class _MypageHomeComponentState extends State<MypageHomeComponent>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isEditingNickname = false;
  bool _showNewPasswordField = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final provider =
        Provider.of<UserPreferenceProvider>(context, listen: false);
    _nicknameController.text = provider.nickname ?? '';
    _passwordController.text = provider.password ?? '';
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
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
            physics: const BouncingScrollPhysics(),
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
                    padding: EdgeInsets.only(top: 50.h, bottom: 10.h),
                    child: Container(
                      height: 50, // KeywordHome의 로고 높이와 동일
                      child: Center(
                        child: Text(
                          "마이페이지",
                          style: TextStyle(
                            fontSize: 22.sp,
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
                    // 프로필 정보 카드 (헤더에서 이동)
                    _buildProfileInfoCard(preferences),

                    SizedBox(height: 16.h),

                    // 내 활동
                    _buildActivitySection(preferences),

                    SizedBox(height: 16.h),

                    // 빠른 설정
                    _buildQuickSettings(preferences),

                    SizedBox(height: 16.h),

                    // 프로필 관리
                    _buildProfileSection(preferences),

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
              size: 28.sp,
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
                    fontSize: 20.sp,
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
                      size: 14.sp,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '설치일: ${_getInstallDateString(preferences.installDate)}',
                      style: TextStyle(
                        fontSize: 12.sp,
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
              Icon(Icons.tune, size: 18.sp, color: AppTheme.primaryBlue),
              SizedBox(width: 8.w),
              Text(
                '빠른 설정',
                style: TextStyle(
                  fontSize: 16.sp,
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
                size: 20.sp,
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.isDark(context)
                            ? AppTheme.darkText
                            : AppTheme.lightText,
                      ),
                    ),
                    Text(
                      preferences.effectiveDarkMode ? '다크 모드' : '라이트 모드',
                      style: TextStyle(
                        fontSize: 11.sp,
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
                size: 20.sp,
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
                        fontSize: 14.sp,
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
                        fontSize: 11.sp,
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
                  color: AppTheme.primaryBlue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '프로필 관리',
                style: TextStyle(
                  fontSize: 16.sp,
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
              fontSize: 12.sp,
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
              Icon(Icons.history, color: AppTheme.primaryBlue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '내 활동',
                style: TextStyle(
                  fontSize: 16.sp,
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
              fontSize: 12.sp,
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
                  size: 16.sp,
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
                        fontSize: 14.sp,
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14.sp,
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
                fontSize: 14.sp,
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
                      fontSize: 12.sp,
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
                      fontSize: 14.sp,
                      color: AppTheme.isDark(context)
                          ? AppTheme.darkText
                          : AppTheme.lightText,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: placeholder,
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
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
                    size: 16.sp,
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
                    size: 16.sp,
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
                fontSize: 14.sp,
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
}
