import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_theme.dart';
import '../utils/device_utils.dart';

class SummaryToggleWidget extends StatefulWidget {
  final String currentType;
  final Function(String) onChanged;

  const SummaryToggleWidget({
    Key? key,
    required this.currentType,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SummaryToggleWidget> createState() => _SummaryToggleWidgetState();
}

class _SummaryToggleWidgetState extends State<SummaryToggleWidget> {
  final List<String> options = ['3줄', '짧은 글', '긴 글'];
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = options.indexOf(widget.currentType);
    if (selectedIndex < 0) selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = DeviceUtils.isTablet(context);
    final double totalWidth = isTablet ? 180.w : 230.w;
    final double buttonWidth = totalWidth / 3;
    final double buttonHeight = isTablet ? 32.h : 36.h;

    return SizedBox(
      width: totalWidth,
      height: buttonHeight + 4.h, // 튀어나온 부분 고려한 높이
      child: Stack(
        clipBehavior: Clip.none, // 버튼이 배경보다 튀어나올 수 있도록 함
        children: [
          // 오목한 파란색 배경
          Positioned(
            top: 2.h, // 튀어나온 버튼 고려해서 약간 아래로
            child: Container(
              width: totalWidth,
              height: buttonHeight,
              decoration: BoxDecoration(
                color: Color(0xFF1CB3F8),
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  // 오목한 효과를 주는 그림자
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 3,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // 애니메이션 흰색 버튼 (튀어나온 효과)
          AnimatedPositioned(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            left: selectedIndex * buttonWidth,
            top: 0, // 상단에 위치하여 튀어나온 효과 표현
            child: Container(
              width: buttonWidth,
              height: buttonHeight + 4.h, // 살짝 더 큰 높이로 튀어나옴
              decoration: BoxDecoration(
                color: AppTheme.getToggleButtonColor(context),
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  // 튀어나온 효과를 주는 그림자
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    spreadRadius: 0.5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // 터치 가능한 버튼 텍스트 (포지션 고정)
          Positioned(
            top: 2.h, // 파란색 배경과 같은 위치
            child: SizedBox(
              width: totalWidth,
              height: buttonHeight,
              child: Row(
                children: List.generate(
                  options.length,
                      (index) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (index != selectedIndex) {
                          setState(() {
                            selectedIndex = index;
                          });
                          widget.onChanged(options[index]);
                        }
                      },
                      child: Container(
                        height: buttonHeight,
                        alignment: Alignment.center,
                        color: Colors.transparent, // 투명 배경으로 탭 이벤트만 받음
                        child: Text(
                          options[index],
                          style: AppTheme.isDark(context) ? TextStyle(
                            fontSize: DeviceUtils.isTablet(context) ? 12.sp : 16.sp,
                            fontWeight: FontWeight.w600,
                            color: index == selectedIndex ? Colors.white : Colors.black ,
                          ) :  TextStyle(
                            fontSize: DeviceUtils.isTablet(context) ? 12.sp : 16.sp,
                            fontWeight: FontWeight.w600,
                            color: index == selectedIndex ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}