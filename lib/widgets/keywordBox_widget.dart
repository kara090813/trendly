import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/_models.dart';
import '../utils/device_utils.dart';

class KeywordBoxWidget extends StatelessWidget {
  final Keyword keyword;
  final int rank;
  final bool isSelected;
  final VoidCallback onTap;

  const KeywordBoxWidget({
    Key? key,
    required this.keyword,
    required this.rank,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 변화 수치 표시 (실제 API 데이터 사용)
    String changeText = '';
    Color changeColor = Colors.grey;
    IconData? changeIcon;

    if (keyword.rank_change != null) {
      if (keyword.rank_change == 'NEW') {
        changeText = 'NEW';
        changeColor = Colors.orange;
      } else if (keyword.rank_change == '0') {
        changeText = '-';
        changeColor = Colors.grey;
      } else {
        // 숫자 파싱 시도
        final rankChange = keyword.rank_change!;
        if (rankChange.startsWith('+')) {
          changeText = rankChange;
          changeColor = Colors.red;
          changeIcon = Icons.arrow_upward;
        } else if (rankChange.startsWith('-')) {
          changeText = rankChange.substring(1); // 마이너스 기호 제거
          changeColor = Colors.blue;
          changeIcon = Icons.arrow_downward;
        } else {
          changeText = '-';
          changeColor = Colors.grey;
        }
      }
    } else {
      changeText = '-';
      changeColor = Colors.grey;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding:  EdgeInsets.symmetric(vertical: 7.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null,
          border: rank == 10 ? null : Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // 순위
            Container(
              width: 24.w,
              alignment: Alignment.center,
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: DeviceUtils.isTablet(context) ? 16.sp : 20.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // 키워드
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left:14.w,right: 6.w),
                child: Text(
                  keyword.keyword,
                  style: TextStyle(
                    fontSize: DeviceUtils.isTablet(context) ? 15.sp : 19.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // 변화 수치
            Column(
              children: [
                Container(
                  width: DeviceUtils.isTablet(context) ? 80.w : 60.w,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (changeIcon != null) ...[
                        Icon(
                          changeIcon,
                          size: DeviceUtils.isTablet(context) ? 12.sp : 14.sp,
                          color: changeColor,
                        ),
                        SizedBox(width: 2.w),
                      ],
                      Text(
                        changeText,
                        style: TextStyle(
                          color: changeColor,
                          fontWeight: FontWeight.w500,
                          fontSize: DeviceUtils.isTablet(context) ? 13.sp : 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // 카테고리
                SizedBox(
                  width: DeviceUtils.isTablet(context) ? 80.w : 60.w,
                  child: Text(
                    keyword.category,
                    style: TextStyle(
                      fontSize: DeviceUtils.isTablet(context) ? 10.sp : 12.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}