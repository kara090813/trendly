import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/_models.dart';
import '../services/api_service.dart';
import '../providers/user_preference_provider.dart';
import '../app_theme.dart';
import 'stylishToast_widget.dart';
import 'passwordPopup_widget.dart';

class CommentOptionsWidget extends StatelessWidget {
  final Comment comment;
  final int discussionRoomId;
  final VoidCallback onDeleted;
  final VoidCallback onBlocked;
  final bool isMyComment;

  const CommentOptionsWidget({
    Key? key,
    required this.comment,
    required this.discussionRoomId,
    required this.onDeleted,
    required this.onBlocked,
    required this.isMyComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptionsModal(context),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.isDark(context)
              ? Colors.grey[800]?.withOpacity(0.3)
              : Colors.grey[200]?.withOpacity(0.7),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: AppTheme.isDark(context)
                ? Colors.grey[700]!.withOpacity(0.2)
                : Colors.grey[300]!.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.more_horiz,
          size: 16.sp,
          color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[500],
        ),
      ),
    );
  }

  void _showOptionsModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: 320.w),
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
                        Icons.more_horiz,
                        color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '댓글 옵션',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
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

                // 옵션 리스트
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Column(
                    children: [
                      // 삭제 옵션 (모든 유저에게 표시)
                      _buildOptionItem(
                        context: dialogContext,
                        icon: Icons.delete_outline,
                        iconColor: Colors.red,
                        iconBgColor: Colors.red.withOpacity(0.1),
                        title: '삭제',
                        titleColor: Colors.red,
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _showDeleteDialog(context);
                        },
                      ),

                      // 차단 옵션 (내 댓글이 아닌 경우만)
                      if (!isMyComment) ...[
                        _buildOptionItem(
                          context: dialogContext,
                          icon: Icons.block,
                          iconColor: Colors.orange,
                          iconBgColor: Colors.orange.withOpacity(0.1),
                          title: '차단',
                          titleColor: Colors.orange,
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _blockComment(context);
                          },
                        ),
                      ],

                      // 신고 옵션 (모든 댓글에 표시)
                      _buildOptionItem(
                        context: dialogContext,
                        icon: Icons.flag_outlined,
                        iconColor: AppTheme.isDark(context) ? Colors.grey[300]! : Colors.grey[700]!,
                        iconBgColor: (AppTheme.isDark(context) ? Colors.grey[300] : Colors.grey[700])!.withOpacity(0.1),
                        title: '신고',
                        titleColor: AppTheme.getTextColor(context),
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _showReportDialog(context);
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required Color titleColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: titleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20.sp,
                color: AppTheme.isDark(context) ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) async {
    final password = await PasswordPopupWidget.show(
      context,
      title: "댓글 삭제",
      message: "이 댓글을 삭제하려면 암호를 입력하세요",
      confirmButtonText: "삭제",
      cancelButtonText: "취소",
    );

    // 암호가 입력된 경우 삭제 처리
    if (password != null && password.isNotEmpty) {
      _deleteCommentWithPassword(context, password);
    }
  }

  Future<void> _deleteCommentWithPassword(BuildContext context, String password) async {
    try {
      final apiService = ApiService();
      final result = await apiService.deleteComment(
        discussionRoomId,
        comment.id,
        password,
      );

      if (result) {
        StylishToast.success(context, '댓글이 삭제되었습니다.');
        onDeleted();
      } else {
        StylishToast.error(context, '댓글 삭제에 실패했습니다. 암호가 올바른지 확인하세요.');
      }
    } catch (e) {
      print('댓글 삭제 오류: $e');
      StylishToast.error(context, '댓글 삭제 중 오류가 발생했습니다.');
    }
  }

  void _blockComment(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Container(
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
                        Icons.block,
                        color: Colors.orange,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '댓글 차단',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
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
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                  child: Text(
                    '이 댓글을 차단하시겠습니까?\n차단된 댓글은 더이상 표시되지 않습니다.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.isDark(context)
                          ? Colors.grey[300]
                          : Colors.grey[700],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // 버튼들
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            '취소',
                            style: TextStyle(
                              color: AppTheme.isDark(context)
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            final provider = Provider.of<UserPreferenceProvider>(context, listen: false);
                            await provider.blockComment(comment.id);
                            StylishToast.success(context, '댓글이 차단되었습니다.');
                            onBlocked();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            '차단',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    String selectedReason = '';
    final TextEditingController detailController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: 400.w,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
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
                            Icons.flag_outlined,
                            color: Color(0xFF19B3F6),
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '댓글 신고',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextColor(context),
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
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

                    // 내용
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '신고 사유를 선택해주세요:',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppTheme.isDark(context)
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ..._buildReportReasons().map((reason) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 4.h),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedReason = reason;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(
                                          color: selectedReason == reason
                                              ? Color(0xFF19B3F6)
                                              : (AppTheme.isDark(context)
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!),
                                          width: selectedReason == reason ? 2 : 1,
                                        ),
                                        color: selectedReason == reason
                                            ? Color(0xFF19B3F6).withOpacity(0.1)
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            selectedReason == reason
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_unchecked,
                                            color: selectedReason == reason
                                                ? Color(0xFF19B3F6)
                                                : (AppTheme.isDark(context)
                                                    ? Colors.grey[500]
                                                    : Colors.grey[400]),
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Text(
                                              reason,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: AppTheme.getTextColor(context),
                                                fontWeight: selectedReason == reason
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            SizedBox(height: 16.h),
                            TextField(
                              controller: detailController,
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppTheme.getTextColor(context),
                              ),
                              decoration: InputDecoration(
                                hintText: '추가 설명 (선택사항)',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppTheme.isDark(context)
                                      ? Colors.grey[500]
                                      : Colors.grey[400],
                                ),
                                filled: true,
                                fillColor: AppTheme.isDark(context)
                                    ? Colors.grey[800]?.withOpacity(0.5)
                                    : Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                    color: Color(0xFF19B3F6),
                                    width: 1,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(12.w),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 버튼들
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: Text(
                                '취소',
                                style: TextStyle(
                                  color: AppTheme.isDark(context)
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: selectedReason.isEmpty
                                  ? null
                                  : () {
                                      Navigator.pop(dialogContext);
                                      _submitReport(context, selectedReason, detailController.text);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedReason.isEmpty
                                    ? (AppTheme.isDark(context)
                                        ? Colors.grey[700]
                                        : Colors.grey[300])
                                    : Color(0xFF19B3F6),
                                foregroundColor: selectedReason.isEmpty
                                    ? (AppTheme.isDark(context)
                                        ? Colors.grey[500]
                                        : Colors.grey[500])
                                    : Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                '신고',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<String> _buildReportReasons() {
    return [
      '욕설 및 비속어',
      '성희롱 및 성적 콘텐츠',
      '혐오 발언',
      '스팸 및 광고',
      '개인정보 노출',
      '허위 정보',
      '기타',
    ];
  }

  Future<void> _submitReport(BuildContext context, String reportType, String reportReason) async {
    try {
      final apiService = ApiService();
      final result = await apiService.reportComment(
        commentId: comment.id,
        reportType: reportType,
        reportReason: reportReason.isNotEmpty ? reportReason : null,
      );

      if (result != null) {
        StylishToast.success(context, '신고가 접수되었습니다.');
      } else {
        StylishToast.error(context, '신고 접수에 실패했습니다. 다시 시도해 주세요.');
      }
    } catch (e) {
      print('댓글 신고 오류: $e');
      StylishToast.error(context, '신고 처리 중 오류가 발생했습니다.');
    }
  }
}