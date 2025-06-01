// lib/widgets/enhancedSummaryBox_widget.dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../models/_models.dart';
import 'summaryToggle_widget.dart';

class EnhancedSummaryBoxWidget extends StatefulWidget {
  final List<Keyword> keywords; // 키워드 리스트로 변경
  final int currentIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoPrevious;
  final bool canGoNext;
  final Function(int)? onPageChanged; // 페이지 변경 콜백 추가

  const EnhancedSummaryBoxWidget({
    Key? key,
    required this.keywords,
    required this.currentIndex,
    required this.onPrevious,
    required this.onNext,
    required this.canGoPrevious,
    required this.canGoNext,
    this.onPageChanged,
  }) : super(key: key);

  @override
  State<EnhancedSummaryBoxWidget> createState() => _EnhancedSummaryBoxWidgetState();
}

class _EnhancedSummaryBoxWidgetState extends State<EnhancedSummaryBoxWidget>
    with SingleTickerProviderStateMixin {
  // type1, type2, type3 중 어떤 요약을 보여줄지 선택
  String _selectedSummaryType = '3줄'; // 기본값

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex);

    _animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(EnhancedSummaryBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // 인덱스가 변경되면 PageController 업데이트
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          widget.currentIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }

      // 애니메이션 재실행
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // 요약 타입 변경 핸들러
  void _onSummaryTypeChanged(String type) {
    setState(() {
      _selectedSummaryType = type;
    });
  }

  // 현재 키워드 가져오기
  Keyword get currentKeyword => widget.keywords[widget.currentIndex];

  // 요약 내용 생성
  String _getSummaryContent(Keyword keyword) {
    switch (_selectedSummaryType) {
      case '3줄':
        return _getShortSummary(keyword);
      case '짧은 글':
        return _getMediumSummary(keyword);
      case '긴 글':
        return _getLongSummary(keyword);
      default:
        return _getShortSummary(keyword);
    }
  }

  // _getSummaryContent() 메서드를 수정하여 단순 String 대신 RichText를 반환하도록 변경
  Widget _buildSummaryContent(Keyword keyword) {
    final String summaryText = _getSummaryContent(keyword);

    // 키워드 전체와 각 토큰을 모두 처리
    List<String> keywordTokens = [keyword.keyword]; // 전체 키워드 먼저 추가
    keywordTokens.addAll(keyword.keyword.split(' ')); // 공백으로 분리된 개별 토큰 추가

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
  String _getShortSummary(Keyword keyword) {
    try {
      // type1이 문자열로 저장된 JSON 형태일 경우 파싱
      List<String> summaryLines = [];

      if (keyword.type1.isNotEmpty) {
        // keyword.type1은 List<String>이지만 실제로는 하나의 문자열일 수 있음
        String type1String = keyword.type1.first;

        // JSON 형식의 문자열인지 확인 (대괄호로 시작하는지)
        if (type1String.trim().startsWith('[') && type1String.trim().endsWith(']')) {
          // 대괄호와 작은따옴표 제거하고 쉼표로 분리
          String cleaned = type1String.replaceAll(RegExp(r"[\[\]']"), "");
          summaryLines = cleaned.split(',').map((s) => s.trim()).toList();
        } else {
          // JSON 형식이 아니면 그냥 리스트의 모든 항목 사용
          summaryLines = keyword.type1;
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
  String _getMediumSummary(Keyword keyword) {
    return keyword.type2.isNotEmpty ? keyword.type2 : '오류가 발생했습니다.';
  }

  // 긴 글 요약 (type3)
  String _getLongSummary(Keyword keyword) {
    return keyword.type3.isNotEmpty ? keyword.type3 : '오류가 발생했습니다.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
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
                    SizedBox(height: 2.h),
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

          // 간결한 키워드 네비게이션 헤더
          _buildSimpleKeywordNavigationHeader(),

          SizedBox(height: 16.h),

          // 스와이프 가능한 키워드 컨텐츠
          Container(
            height: 500.h, // 고정 높이 설정
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                if (widget.onPageChanged != null) {
                  widget.onPageChanged!(index);
                }
              },
              physics: BouncingScrollPhysics(), // 부드러운 스와이프
              itemCount: widget.keywords.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _fadeAnimation,
                  child: _buildKeywordContent(widget.keywords[index]),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: child, // 수직 이동 제거
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 간결한 키워드 네비게이션 헤더
  Widget _buildSimpleKeywordNavigationHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? Color(0xFF2A2A36).withOpacity(0.5)
            : Color(0xFFF8F9FA).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.grey[700]!.withOpacity(0.3)
              : Colors.grey[300]!.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 이전 버튼
          _buildSimpleNavigationButton(
            icon: Icons.keyboard_arrow_left_rounded,
            onTap: widget.canGoPrevious ? widget.onPrevious : null,
            isEnabled: widget.canGoPrevious,
          ),

          Expanded(
            child: Column(
              children: [
                // 순위 표시
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Color(0xFF19B3F6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${widget.currentIndex + 1}위',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // 간단한 진행 표시기
                _buildSimpleProgressIndicator(),

                SizedBox(height: 4.h),

                // 위치 텍스트와 스와이프 힌트
                Text(
                  '${widget.currentIndex + 1} / ${widget.keywords.length} • 좌우 스와이프',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.isDark(context)
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 다음 버튼
          _buildSimpleNavigationButton(
            icon: Icons.keyboard_arrow_right_rounded,
            onTap: widget.canGoNext ? widget.onNext : null,
            isEnabled: widget.canGoNext,
          ),
        ],
      ),
    );
  }

  // 간단한 네비게이션 버튼
  Widget _buildSimpleNavigationButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: isEnabled
              ? Color(0xFF19B3F6)
              : (AppTheme.isDark(context) ? Colors.grey[700] : Colors.grey[300]),
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isEnabled
              ? [
            BoxShadow(
              color: Color(0xFF19B3F6).withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Icon(
          icon,
          color: isEnabled
              ? Colors.white
              : (AppTheme.isDark(context) ? Colors.grey[500] : Colors.grey[500]),
          size: 20.sp,
        ),
      ),
    );
  }

  // 간단한 진행 표시기
  Widget _buildSimpleProgressIndicator() {
    final int totalKeywords = widget.keywords.length;
    final int currentIndex = widget.currentIndex;

    // 최대 5개 도트만 표시
    final int maxDots = 5;
    final int dotsToShow = totalKeywords > maxDots ? maxDots : totalKeywords;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotsToShow, (index) {
        int actualIndex;

        if (totalKeywords <= maxDots) {
          actualIndex = index;
        } else {
          final int halfDots = maxDots ~/ 2;
          final int startIndex = (currentIndex - halfDots).clamp(0, totalKeywords - maxDots);
          actualIndex = startIndex + index;
        }

        final bool isActive = actualIndex == currentIndex;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          width: isActive ? 16.w : 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: isActive
                ? Color(0xFF19B3F6)
                : (AppTheme.isDark(context) ? Colors.grey[600] : Colors.grey[300]),
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      }),
    );
  }

  // 키워드 컨텐츠 (스와이프 가능)
  Widget _buildKeywordContent(Keyword keyword) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 키워드 제목
          InkWell(
            onTap: () {
              context.pushNamed(
                'keywordDetail',
                pathParameters: {'id': keyword.id.toString()},
              );
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppTheme.isDark(context)
                      ? [
                    Color(0xFF374151),
                    Color(0xFF1F2937),
                  ]
                      : [
                    Color(0xFFF8FAFC),
                    Color(0xFFE2E8F0),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppTheme.isDark(context)
                      ? Colors.grey[700]!.withOpacity(0.5)
                      : Colors.grey[300]!.withOpacity(0.7),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.isDark(context)
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AutoSizeText(
                      keyword.keyword,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextColor(context),
                      ),
                      minFontSize: 16,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Color(0xFF19B3F6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 카테고리
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Color(0xFF19B3F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Color(0xFF19B3F6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              keyword.category,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF19B3F6),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // 요약 내용
          _buildSummaryContent(keyword),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}