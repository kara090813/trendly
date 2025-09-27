import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_preference_provider.dart';
import '../app_theme.dart';

class EulaDialog extends StatefulWidget {
  const EulaDialog({super.key});

  @override
  State<EulaDialog> createState() => _EulaDialogState();
}

class _EulaDialogState extends State<EulaDialog> {
  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return WillPopScope(
      onWillPop: () async => false, // 뒤로가기 버튼으로 닫을 수 없음
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목
              Container(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Text(
                  '[트렌들리] 최종 사용자 이용 약관',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // 약관 내용 스크롤 영역
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('약관 동의',
                        '트렌들리(이하 "서비스")를 이용함으로써 사용자는 본 약관에 동의한 것으로 간주됩니다. 동의하지 않을 경우 서비스 이용이 제한됩니다.',
                        isDark),

                      _buildSection('허용되지 않는 콘텐츠 및 행위',
                        '사용자는 서비스 내 토론방, 댓글, 답글 작성 시 다음과 같은 행위를 해서는 안 됩니다.\n\n'
                        '• 차별, 혐오, 음란, 폭력, 불법적 내용 게시\n'
                        '• 타인 비방, 괴롭힘, 사생활 침해 행위\n'
                        '• 스팸성 댓글, 상업적 광고 또는 홍보 목적의 게시물 작성\n'
                        '• 타인의 지적 재산권이나 개인정보 침해',
                        isDark),

                      _buildSection('무관용 정책',
                        '트렌들리는 위 금지 행위에 대해 무관용 원칙을 적용합니다. 위반 시 사전 경고 없이 댓글/답글 삭제, 계정 정지 또는 영구 차단이 이루어질 수 있습니다.',
                        isDark),

                      _buildSection('콘텐츠 관리 및 신고/차단 기능',
                        '• 사용자는 불건전한 댓글/답글을 신고할 수 있습니다.\n'
                        '• 사용자는 원치 않는 사용자를 차단하여 댓글/답글을 보지 않을 수 있습니다.\n'
                        '• 운영팀은 신고 접수 후 24시간 이내에 검토 및 조치를 진행하며, 필요 시 게시물 삭제 및 사용자 퇴출을 할 수 있습니다.',
                        isDark),

                      _buildSection('사용자 책임',
                        '모든 댓글 및 답글은 해당 작성자의 책임 하에 작성됩니다. 본 서비스는 사용자 간 의견 교환을 위한 플랫폼을 제공할 뿐, 작성된 콘텐츠에 대한 법적 책임은 각 사용자에게 있습니다.',
                        isDark),

                      _buildSection('책임의 한계',
                        '서비스 제공자는 사용자 간 상호작용에서 발생하는 분쟁, 피해, 손해에 대해 법적 책임을 지지 않습니다. 단, 법령에서 달리 규정된 경우는 예외로 합니다.',
                        isDark),

                      _buildSection('약관 변경',
                        '본 약관은 필요 시 변경될 수 있으며, 변경 시 서비스 내 공지를 통해 안내합니다.',
                        isDark),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // 동의 버튼
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    _acceptEula();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    '동의하고 계속하기',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // 경고 텍스트
              Text(
                '동의하지 않으면 앱을 사용할 수 없습니다.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _acceptEula() {
    final userPrefs = Provider.of<UserPreferenceProvider>(context, listen: false);
    userPrefs.acceptEula();
    Navigator.of(context).pop();
  }
}