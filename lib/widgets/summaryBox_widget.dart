import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../models/_models.dart';
import 'summaryToggle_widget.dart';

class SummaryBoxWidget extends StatefulWidget {
  final Keyword keyword;

  const SummaryBoxWidget({
    Key? key,
    required this.keyword,
  }) : super(key: key);

  @override
  State<SummaryBoxWidget> createState() => _SummaryBoxWidgetState();
}

class _SummaryBoxWidgetState extends State<SummaryBoxWidget> {
  // type1, type2, type3 중 어떤 요약을 보여줄지 선택
  String _selectedSummaryType = '3줄'; // 기본값

  // 요약 타입 변경 핸들러
  void _onSummaryTypeChanged(String type) {
    setState(() {
      _selectedSummaryType = type;
    });
  }

  // 요약 내용 생성
  String _getSummaryContent() {
    switch (_selectedSummaryType) {
      case '3줄':
        return _getShortSummary();
      case '짧은 글':
        return _getMediumSummary();
      case '긴 글':
        return _getLongSummary();
      default:
        return _getShortSummary();
    }
  }

  // _getSummaryContent() 메서드를 수정하여 단순 String 대신 RichText를 반환하도록 변경
  Widget _buildSummaryContent() {
    final String summaryText = _getSummaryContent();

    // 키워드 전체와 각 토큰을 모두 처리
    List<String> keywordTokens = [widget.keyword.keyword]; // 전체 키워드 먼저 추가
    keywordTokens.addAll(widget.keyword.keyword.split(' ')); // 공백으로 분리된 개별 토큰 추가

    // 중복 제거 및 빈 문자열 제거
    keywordTokens = keywordTokens.where((token) => token.isNotEmpty).toSet().toList();

    // 더 긴 키워드부터 처리하도록 정렬 (전체 키워드가 먼저 매칭되도록)
    keywordTokens.sort((a, b) => b.length.compareTo(a.length));

    // 문단 분리
    final List<String> paragraphs = summaryText.split('\n\n');
    final List<TextSpan> spans = [];

    for (int i = 0; i < paragraphs.length; i++) {
      if (i > 0) {
        spans.add(TextSpan(text: '\n\n'));
      }

      String paragraph = paragraphs[i];
      List<TextSpan> paragraphSpans = [];

      // 처리할 텍스트의 시작과 끝 위치를 추적
      int currentPos = 0;
      final int paragraphLength = paragraph.length;

      // 현재 위치에서 끝까지 모든 텍스트 처리
      while (currentPos < paragraphLength) {
        bool foundMatch = false;

        // 모든 키워드 토큰에 대해 현재 위치에서 매치되는지 확인
        for (String token in keywordTokens) {
          // 대소문자 구분 없이 현재 위치부터 키워드가 있는지 확인
          if (currentPos + token.length <= paragraphLength &&
              paragraph.substring(currentPos, currentPos + token.length).toLowerCase() ==
                  token.toLowerCase()) {
            // 매치된 텍스트는 볼드체로 추가
            paragraphSpans.add(TextSpan(
              text: paragraph.substring(currentPos, currentPos + token.length),
              style: TextStyle(
                fontSize: 18.sp,
                height: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ));

            currentPos += token.length;
            foundMatch = true;
            break; // 매치되었으므로 다음 토큰은 확인할 필요 없음
          }
        }

        // 매치된 키워드가 없으면 한 문자씩 처리
        if (!foundMatch) {
          // 현재 위치에서 다음 매치가 발견될 때까지 검색
          int nextMatchPos = paragraphLength;

          for (String token in keywordTokens) {
            int pos = paragraph.toLowerCase().indexOf(token.toLowerCase(), currentPos);
            if (pos != -1 && pos < nextMatchPos) {
              nextMatchPos = pos;
            }
          }

          // 현재 위치부터 다음 매치 시작 위치까지의 텍스트를 일반 스타일로 추가
          paragraphSpans.add(TextSpan(
            text: paragraph.substring(currentPos, nextMatchPos),
            style: TextStyle(fontSize: 18.sp, height: 1.5),
          ));

          currentPos = nextMatchPos;
        }
      }

      // 문단의 모든 TextSpan을 메인 spans 리스트에 추가
      spans.addAll(paragraphSpans);
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  // 3줄 요약 (type1)
  String _getShortSummary() {
    try {
      // type1이 문자열로 저장된 JSON 형태일 경우 파싱
      List<String> summaryLines = [];

      if (widget.keyword.type1.isNotEmpty) {
        // widget.keyword.type1은 List<String>이지만 실제로는 하나의 문자열일 수 있음
        String type1String = widget.keyword.type1.first;

        // JSON 형식의 문자열인지 확인 (대괄호로 시작하는지)
        if (type1String.trim().startsWith('[') && type1String.trim().endsWith(']')) {
          // 대괄호와 작은따옴표 제거하고 쉼표로 분리
          String cleaned = type1String.replaceAll(RegExp(r"[\[\]']"), "");
          summaryLines = cleaned.split(',').map((s) => s.trim()).toList();
        } else {
          // JSON 형식이 아니면 그냥 리스트의 모든 항목 사용
          summaryLines = widget.keyword.type1;
        }
      }

      if (summaryLines.isNotEmpty) {
        // 파싱된 데이터가 있는 경우
        final StringBuffer formattedLines = StringBuffer();
        for (int i = 0; i < summaryLines.length; i++) {
          formattedLines.write('${summaryLines[i]}\n\n');
        }
        return formattedLines.toString().trim();
      }
    } catch (e) {
      print('3줄 요약 파싱 오류: $e');
    }

    // 기본 임시 데이터
    return '오류가 발생했습니다.';
  }

  // 짧은 글 요약 (type2)
  String _getMediumSummary() {
    return widget.keyword.type2.isNotEmpty ? widget.keyword.type2 : '오류가 발생했습니다.';
  }

  // 긴 글 요약 (type3)
  String _getLongSummary() {
    return widget.keyword.type3.isNotEmpty ? widget.keyword.type3 : '오류가 발생했습니다.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 7,
            spreadRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 실검 요약 타이틀과 토글 버튼
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 2.h,
                      ),
                      Text(
                        '실검 요약',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SummaryToggleWidget(
                    currentType: _selectedSummaryType,
                    onChanged: _onSummaryTypeChanged,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),

            // 키워드 제목
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 뉴모픽 버튼 대신 일반 InkWell + Container 사용
                  InkWell(
                    onTap: () {
                      // 키워드 상세 페이지로 이동 (이제 ID만 전달)
                      context.pushNamed(
                        'keywordDetail',
                        pathParameters: {'id': widget.keyword.id.toString()},
                      );
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.only(top: 4.h, bottom: 4.h, left: 14.w, right: 4.w),
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F1F3),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            offset: Offset(3, 3),
                            blurRadius: 5,
                            spreadRadius: 0.5,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.9),
                            offset: Offset(-3, -3),
                            blurRadius: 5,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: AutoSizeText(
                              widget.keyword.keyword,
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              minFontSize: 8,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 6.w,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 5.h,
                              ),
                              Image.asset(
                                'assets/img/items/leftArrow.png',
                                width: 30.w,
                                color: Color(0xFF1AB2F7),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.keyword.category,
                          style: TextStyle(
                            fontSize: 17.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        _buildSummaryContent(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 60.h,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}