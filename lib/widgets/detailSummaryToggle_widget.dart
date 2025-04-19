import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 키워드 상세화면에서 사용하는 뉴모피즘 스타일의 요약 토글 위젯
class DetailSummaryToggleWidget extends StatefulWidget {
  final String currentType;
  final Function(String) onChanged;

  const DetailSummaryToggleWidget({
    Key? key,
    required this.currentType,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<DetailSummaryToggleWidget> createState() => _DetailSummaryToggleWidgetState();
}

class _DetailSummaryToggleWidgetState extends State<DetailSummaryToggleWidget> {
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
    final double totalWidth = 220.w;
    final double buttonWidth = totalWidth / 3;
    final double buttonHeight = 28.h;

    return SizedBox(
      width: totalWidth,
      height: buttonHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 음각 뉴모피즘 배경 (전체 토글 바)
          Neumorphic(
            style: NeumorphicStyle(
              depth: -3, // 음수 값으로 들어간 효과
              intensity: 0.7,
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16.r)),
              color: Color(0xFFF1F1F3), // 배경 색상
              lightSource: LightSource.topLeft,
            ),
            child: Container(
              width: totalWidth,
              height: buttonHeight,
            ),
          ),

          // 양각 파란색 버튼 (선택된 부분)
          AnimatedPositioned(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            left: selectedIndex * buttonWidth,
            top: 0,
            child: Neumorphic(
              style: NeumorphicStyle(
                depth: 4, // 양수 값으로 튀어나온 효과
                intensity: 0.7,
                shape: NeumorphicShape.flat,
                lightSource: LightSource.topLeft,
                color: Color(0xFF19B3F6), // 버튼 색상 - 파란색
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16.r)),
              ),
              child: Container(
                width: buttonWidth,
                height: buttonHeight,
                alignment: Alignment.center,
                child: Text(
                  options[selectedIndex],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: Colors.white, // 선택된 텍스트는 흰색
                  ),
                ),
              ),
            ),
          ),

          // 터치 영역과 선택되지 않은 텍스트들
          Positioned.fill(
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
                      color: Colors.transparent, // 투명 배경으로 탭 이벤트만 받음
                      alignment: Alignment.center,
                      child: index != selectedIndex
                          ? Text(
                        options[index],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.black54, // 선택되지 않은 텍스트는 회색
                        ),
                      )
                          : null, // 선택된 텍스트는 위의 파란색 버튼에 표시됨
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