// lib/widgets/sortPopup_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SortOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDefault;

  const SortOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isDefault = false,
  });
}

class SortPopupWidget extends StatelessWidget {
  final bool isPopularSort;
  final Function(bool) onSortChanged;
  final Color accentColor;
  final EdgeInsets padding;
  final String? headerTitle;
  final List<SortOption>? customOptions;

  const SortPopupWidget({
    Key? key,
    required this.isPopularSort,
    required this.onSortChanged,
    this.accentColor = const Color(0xFF19B3F6),
    this.padding = EdgeInsets.zero,
    this.headerTitle,
    this.customOptions,
  }) : super(key: key);

  // 기본 정렬 옵션
  List<SortOption> get _defaultOptions => [
    SortOption(
      title: '추천순',
      subtitle: '좋아요를 많이 받은 댓글부터 보여줍니다',
      icon: Icons.thumb_up_rounded,
      isDefault: true,
    ),
    SortOption(
      title: '최신순',
      subtitle: '최근에 작성된 댓글부터 보여줍니다',
      icon: Icons.access_time_rounded,
    ),
  ];

  // 중앙 팝업을 표시하는 메서드
  Future<void> showSortPopup(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: _buildPopupContent(context),
        );
      },
    );
  }

  // 팝업 내용 빌드
  Widget _buildPopupContent(BuildContext context) {
    final options = customOptions ?? _defaultOptions;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 500.w), // 최대 너비 설정
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더 - 더 작게 조정
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 8.h),
            child: Row(
              children: [
                Text(
                  headerTitle ?? "정렬 방식",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, size: 22.sp),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  splashRadius: 20.r,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: Colors.grey[200]),

          // 옵션 목록
          ...List.generate(options.length, (index) {
            final option = options[index];
            final bool isSelected = index == 0 ? isPopularSort : !isPopularSort;

            return Column(
              children: [
                _buildSortOption(
                  context: context,
                  icon: option.icon,
                  title: option.title,
                  subtitle: option.subtitle,
                  isSelected: isSelected,
                  onTap: () {
                    onSortChanged(index == 0);
                    Navigator.pop(context);
                  },
                ),
                if (index < options.length - 1)
                  Divider(height: 1, indent: 70.w, endIndent: 20.w, color: Colors.grey[200]),
              ],
            );
          }),

          SizedBox(height: 16.h), // 하단 여백 축소
        ],
      ),
    );
  }

  // 개선된 정렬 옵션 아이템 UI
  Widget _buildSortOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 아이콘 영역
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withOpacity(0.1)
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: isSelected ? accentColor : Colors.grey[400],
                ),
              ),

              SizedBox(width: 14.w),

              // 텍스트 영역 - 개선된 레이아웃
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? accentColor : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 개선된 체크 아이콘
              SizedBox(width: 8.w),
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.grey[300]!, width: 1.5),
                ),
                child: isSelected
                    ? Icon(
                  Icons.check_rounded,
                  size: 18.sp,
                  color: Colors.white,
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = customOptions ?? _defaultOptions;
    final currentOption = isPopularSort ? options[0] : options[1];

    return GestureDetector(
      onTap: () => showSortPopup(context),
      child: Container(
        padding: padding == EdgeInsets.zero
            ? EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h)
            : padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              currentOption.icon,
              size: 18.sp,
              color: accentColor,
            ),
            SizedBox(width: 6.w),
            Text(
              currentOption.title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(width: 2.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18.sp,
              color: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}