import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_theme.dart';

class SortToggleWidget extends StatefulWidget {
  final bool isPopularSort;
  final Function(bool) onSortChanged;

  const SortToggleWidget({
    Key? key,
    required this.isPopularSort,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  State<SortToggleWidget> createState() => _SortToggleWidgetState();
}

class _SortToggleWidgetState extends State<SortToggleWidget> {
  @override
  Widget build(BuildContext context) {
    final double totalWidth = 160.w;
    final double buttonWidth = totalWidth / 2;
    final double buttonHeight = 32.h;

    return Container(
      width: totalWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: AppTheme.isDark(context) ? Color(0xFF2A2A36) : Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          // 선택 인디케이터 (슬라이딩 효과)
          AnimatedPositioned(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            left: widget.isPopularSort ? 0 : buttonWidth,
            top: 0,
            bottom: 0,
            width: buttonWidth,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF19B3F6),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF19B3F6).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.isPopularSort ? '추천순' : '최신순',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // 터치 영역과 텍스트
          Row(
            children: [
              // 추천순 버튼
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () {
                      if (!widget.isPopularSort) {
                        widget.onSortChanged(true);
                      }
                    },
                    child: Center(
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 200),
                        opacity: widget.isPopularSort ? 0.0 : 1.0,
                        child: Text(
                          '추천순',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.isDark(context)
                                ? Colors.grey[400]
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 최신순 버튼
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () {
                      if (widget.isPopularSort) {
                        widget.onSortChanged(false);
                      }
                    },
                    child: Center(
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 200),
                        opacity: widget.isPopularSort ? 1.0 : 0.0,
                        child: Text(
                          '최신순',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.isDark(context)
                                ? Colors.grey[400]
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}