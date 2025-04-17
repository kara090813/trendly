import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/_models.dart';

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
    // 변화 수치 표시 (양수이면 +, 음수이면 - 붙이기)
    String changeText = '';
    Color changeColor = Colors.grey;

    // 임의로 변화 수치 계산 (실제로는 API에서 제공되어야 함)
    int change = 0;
    if (keyword.id % 3 == 0) {
      change = keyword.id % 50;
    } else if (keyword.id % 3 == 1) {
      change = -(keyword.id % 30);
    } else {
      change = keyword.id % 100;
    }

    if (change > 0) {
      changeText = '+ $change';
      changeColor = Colors.red;
    } else if (change < 0) {
      changeText = '$change';
      changeColor = Colors.blue;
    } else {
      changeText = '0';
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
                  fontSize: 20.sp,
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
                    fontSize: 19.sp,
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
                  width: 60,
                  alignment: Alignment.centerRight,
                  child: Text(
                    changeText,
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // 카테고리
                SizedBox(
                  width: 60,
                  child: Text(
                    keyword.category,
                    style: TextStyle(
                      fontSize: 12,
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