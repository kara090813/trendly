import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';

class TimeMachineHourlyTrendsWidget extends StatefulWidget {
  final Map<String, Color> categoryColors;
  final Function(int) getKeywordsForHour;
  final int initialSelectedHour;

  const TimeMachineHourlyTrendsWidget({
    Key? key,
    required this.categoryColors,
    required this.getKeywordsForHour,
    this.initialSelectedHour = 12,
  }) : super(key: key);

  @override
  State<TimeMachineHourlyTrendsWidget> createState() => _TimeMachineHourlyTrendsWidgetState();
}

class _TimeMachineHourlyTrendsWidgetState extends State<TimeMachineHourlyTrendsWidget> {
  late int _selectedHour;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialSelectedHour;
  }

  @override
  Widget build(BuildContext context) {
    return _buildContainer(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Color(0xFF27AE60),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF27AE60).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "시간별 트렌드",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // 시간 선택 슬라이더
          _buildHourSelector(),

          SizedBox(height: 20.h),

          // 선택된 시간의 키워드 리스트
          _buildSelectedHourKeywords(),

          SizedBox(height: 16.h),

          // 전체 시간별 미니 리스트
          _buildAllHoursPreview(),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.grey[800]!.withOpacity(0.3)
              : Colors.grey[300]!.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHourSelector() {
    return Container(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 24,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedHour;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedHour = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color(0xFF19B3F6)
                    : AppTheme.isDark(context)
                    ? Color(0xFF2A2A36)
                    : Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? Color(0xFF19B3F6)
                      : AppTheme.isDark(context)
                      ? Colors.grey[700]!
                      : Colors.grey[300]!,
                  width: 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Color(0xFF19B3F6).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ] : [],
              ),
              child: Center(
                child: Text(
                  "${index.toString().padLeft(2, '0')}시",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.getTextColor(context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedHourKeywords() {
    final keywords = widget.getKeywordsForHour(_selectedHour);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? Color(0xFF2A2A36).withOpacity(0.5)
            : Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(0xFF19B3F6).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${_selectedHour.toString().padLeft(2, '0')}시 TOP 10 키워드",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF19B3F6),
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: keywords.asMap().entries.map((entry) {
              final index = entry.key;
              final keyword = entry.value;
              return _buildKeywordChip(keyword, index + 1);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordChip(Map<String, dynamic> keyword, int rank) {
    final categoryColor = widget.categoryColors[keyword['category']] ?? Colors.grey;
    final change = keyword['change'] as int;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 순위
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: categoryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // 키워드명
          Text(
            keyword['keyword'],
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(width: 6.w),
          // 변화량
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                change > 0 ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 14.sp,
                color: change > 0 ? Colors.red : Colors.blue,
              ),
              Text(
                change.abs().toString(),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: change > 0 ? Colors.red : Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllHoursPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "24시간 전체 미리보기",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Color(0xFF27AE60),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 24,
            itemBuilder: (context, hour) {
              return _buildHourPreviewCard(hour);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHourPreviewCard(int hour) {
    final keywords = widget.getKeywordsForHour(hour).take(3).toList();

    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? Color(0xFF21202C)
            : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.grey[700]!
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${hour.toString().padLeft(2, '0')}시",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF27AE60),
            ),
          ),
          SizedBox(height: 8.h),
          ...keywords.map((keyword) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: widget.categoryColors[keyword['category']] ?? Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    keyword['keyword'],
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppTheme.getTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}