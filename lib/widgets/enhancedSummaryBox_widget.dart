// lib/widgets/improvedSummaryBox_widget.dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../models/_models.dart';
import 'summaryToggle_widget.dart';

class EnhancedSummaryBoxWidget extends StatefulWidget {
  final List<Keyword> keywords;
  final int currentIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoPrevious;
  final bool canGoNext;
  final Function(int)? onPageChanged;

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
    with TickerProviderStateMixin {
  String _selectedSummaryType = '3줄';

  late AnimationController _cardAnimationController;
  late AnimationController _swipeHintController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _swipeHintAnimation;
  late PageController _pageController;

  bool _showSwipeHint = true;
  bool _isAnimatingToPage = false; // 프로그래밍적 페이지 변경 플래그

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.currentIndex,
      viewportFraction: 0.92, // 양옆 카드가 살짝 보이도록
    );

    _cardAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _swipeHintController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _cardScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));

    _swipeHintAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _swipeHintController,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 시작
    _cardAnimationController.forward();

    // 스와이프 힌트 애니메이션 (3초 후 시작하여 반복)
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted && widget.keywords.length > 1) {
        _swipeHintController.repeat(reverse: true);

        // 6초 후 힌트 숨기기
        Future.delayed(Duration(seconds: 6), () {
          if (mounted) {
            setState(() {
              _showSwipeHint = false;
            });
            _swipeHintController.stop();
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(EnhancedSummaryBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      if (_pageController.hasClients) {
        _isAnimatingToPage = true; // 프로그래밍적 변경 시작
        _pageController.animateToPage(
          widget.currentIndex,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        ).then((_) {
          _isAnimatingToPage = false; // 프로그래밍적 변경 완료
        });
      }
      // 사용자가 스와이프하면 힌트 숨기기
      if (_showSwipeHint) {
        setState(() {
          _showSwipeHint = false;
        });
        _swipeHintController.stop();
      }
    }
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _swipeHintController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onSummaryTypeChanged(String type) {
    setState(() {
      _selectedSummaryType = type;
    });
  }

  Keyword get currentKeyword => widget.keywords[widget.currentIndex];

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

  Widget _buildSummaryContent(Keyword keyword) {
    final String summaryText = _getSummaryContent(keyword);
    List<String> keywordTokens = [keyword.keyword];
    keywordTokens.addAll(keyword.keyword.split(' '));
    keywordTokens = keywordTokens.where((token) => token.isNotEmpty).toSet().toList();
    keywordTokens.sort((a, b) => b.length.compareTo(a.length));

    final List<String> paragraphs = summaryText.split('\n\n');
    final List<TextSpan> spans = [];

    for (int i = 0; i < paragraphs.length; i++) {
      if (i > 0) {
        spans.add(TextSpan(text: '\n\n'));
      }

      String paragraph = paragraphs[i];
      List<TextSpan> paragraphSpans = [];
      int currentPos = 0;
      final int paragraphLength = paragraph.length;

      while (currentPos < paragraphLength) {
        bool foundMatch = false;

        for (String token in keywordTokens) {
          if (currentPos + token.length <= paragraphLength &&
              paragraph.substring(currentPos, currentPos + token.length).toLowerCase() ==
                  token.toLowerCase()) {
            paragraphSpans.add(TextSpan(
              text: paragraph.substring(currentPos, currentPos + token.length),
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF19B3F6),
              ),
            ));

            currentPos += token.length;
            foundMatch = true;
            break;
          }
        }

        if (!foundMatch) {
          int nextMatchPos = paragraphLength;

          for (String token in keywordTokens) {
            int pos = paragraph.toLowerCase().indexOf(token.toLowerCase(), currentPos);
            if (pos != -1 && pos < nextMatchPos) {
              nextMatchPos = pos;
            }
          }

          paragraphSpans.add(TextSpan(
            text: paragraph.substring(currentPos, nextMatchPos),
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.5,
              color: AppTheme.isDark(context) ? Colors.grey[300] : Colors.grey[700],
            ),
          ));

          currentPos = nextMatchPos;
        }
      }

      spans.addAll(paragraphSpans);
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }

  String _getShortSummary(Keyword keyword) {
    try {
      List<String> summaryLines = [];

      if (keyword.type1.isNotEmpty) {
        String type1String = keyword.type1.first;

        if (type1String.trim().startsWith('[') && type1String.trim().endsWith(']')) {
          String cleaned = type1String.replaceAll(RegExp(r"[\[\]']"), "");
          summaryLines = cleaned.split(',').map((s) => s.trim()).toList();
        } else {
          summaryLines = keyword.type1;
        }
      }

      if (summaryLines.isNotEmpty) {
        final StringBuffer formattedLines = StringBuffer();
        for (int i = 0; i < summaryLines.length; i++) {
          formattedLines.write('${summaryLines[i]}\n\n');
        }
        return formattedLines.toString().trim();
      }
    } catch (e) {
      print('3줄 요약 파싱 오류: $e');
    }

    return '오류가 발생했습니다.';
  }

  String _getMediumSummary(Keyword keyword) {
    return keyword.type2.isNotEmpty ? keyword.type2 : '오류가 발생했습니다.';
  }

  String _getLongSummary(Keyword keyword) {
    return keyword.type3.isNotEmpty ? keyword.type3 : '오류가 발생했습니다.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppTheme.isDark(context)
              ? [
            Color(0xFF1A1A1A),
            Color(0xFF0F0F0F),
          ]
              : [
            Color(0xFFF8F9FA),
            Color(0xFFE9ECEF),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 핵심: 컨텐츠 크기에 맞게 조정
        children: [
          // 상단 핸들
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppTheme.isDark(context) ? Colors.grey[600] : Colors.grey[400],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // 스와이프 안내 텍스트 (여러 개일 때만)
          if (widget.keywords.length > 1)
            Container(
              margin: EdgeInsets.only(bottom: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swipe,
                    size: 16.sp,
                    color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '좌우로 넘겨서 다른 키워드 보기',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // 메인 카드 영역 - 고정 높이 제거하고 컨텐츠에 맞게 조정
          AnimatedBuilder(
            animation: _cardScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _cardScaleAnimation.value,
                child: Container(
                  height: _calculateCardHeight(), // 동적 높이 계산
                  child: Stack(
                    children: [
                      // 메인 PageView
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          // 프로그래밍적 변경이 아닌 사용자 스와이프일 때만 콜백 호출
                          if (!_isAnimatingToPage && widget.onPageChanged != null) {
                            widget.onPageChanged!(index);
                          }
                        },
                        itemCount: widget.keywords.length,
                        itemBuilder: (context, index) {
                          return _buildStreamlinedCard(widget.keywords[index], index);
                        },
                      ),

                      // 스와이프 힌트 애니메이션 (좌우 화살표)
                      if (_showSwipeHint && widget.keywords.length > 1)
                        AnimatedBuilder(
                          animation: _swipeHintAnimation,
                          builder: (context, child) {
                            return Positioned.fill(
                              child: IgnorePointer(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // 좌측 화살표
                                    if (widget.canGoPrevious)
                                      Transform.translate(
                                        offset: Offset(-10 + (20 * _swipeHintAnimation.value), 0),
                                        child: Container(
                                          margin: EdgeInsets.only(left: 20.w),
                                          padding: EdgeInsets.all(8.w),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF19B3F6).withOpacity(0.8),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFF19B3F6).withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.chevron_left,
                                            color: Colors.white,
                                            size: 20.sp,
                                          ),
                                        ),
                                      ),

                                    // 우측 화살표
                                    if (widget.canGoNext)
                                      Transform.translate(
                                        offset: Offset(10 - (20 * _swipeHintAnimation.value), 0),
                                        child: Container(
                                          margin: EdgeInsets.only(right: 20.w),
                                          padding: EdgeInsets.all(8.w),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF19B3F6).withOpacity(0.8),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFF19B3F6).withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.chevron_right,
                                            color: Colors.white,
                                            size: 20.sp,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 페이지 인디케이터 (여러 개일 때만)
          if (widget.keywords.length > 1)
            Container(
              margin: EdgeInsets.only(top: 16.h, bottom: 20.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.keywords.length,
                      (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: index == widget.currentIndex ? 16.w : 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: index == widget.currentIndex
                          ? Color(0xFF19B3F6)
                          : AppTheme.isDark(context)
                          ? Colors.grey[600]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
            ),

          // 단일 키워드일 때 하단 여백
          if (widget.keywords.length == 1)
            SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // 요약 타입과 내용에 따라 카드 높이 동적 계산
  double _calculateCardHeight() {
    // 기본 높이 (헤더 부분)
    double baseHeight = 120.h;

    // 요약 타입에 따른 추가 높이
    switch (_selectedSummaryType) {
      case '3줄':
        baseHeight += 200.h; // 3줄 요약에 적합한 높이
        break;
      case '짧은 글':
        baseHeight += 280.h; // 짧은 글에 적합한 높이
        break;
      case '긴 글':
        baseHeight += 360.h; // 긴 글에 적합한 높이
        break;
      default:
        baseHeight += 200.h;
    }

    return baseHeight;
  }

  // 간소화된 카드 디자인 - 패딩 최소화 및 내부 박스 제거
  Widget _buildStreamlinedCard(Keyword keyword, int index) {
    final bool isCurrentCard = index == widget.currentIndex;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: isCurrentCard ? 0 : 6.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isCurrentCard ? 0.15 : 0.08),
              blurRadius: isCurrentCard ? 20 : 10,
              spreadRadius: isCurrentCard ? 0 : -2,
              offset: Offset(0, isCurrentCard ? 8 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppTheme.isDark(context)
                    ? [
                  Color(0xFF2A2A36),
                  Color(0xFF1E1E2A),
                ]
                    : [
                  Colors.white,
                  Color(0xFFF8F9FA),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w), // 전체 패딩 최소화
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 영역 - 패딩 최소화
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF19B3F6), Color(0xFF0EA5E9)],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF19B3F6).withOpacity(0.3),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${index + 1}위',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      Spacer(),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Color(0xFF19B3F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Color(0xFF19B3F6).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          keyword.category,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF19B3F6),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // 키워드 제목 - 패딩 최소화
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        'keywordDetail',
                        pathParameters: {'id': keyword.id.toString()},
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            keyword.keyword,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getTextColor(context),
                              letterSpacing: -0.3,
                            ),
                            minFontSize: 16,
                            maxLines: 2,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF19B3F6),
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // 요약 타입 토글 - 패딩 최소화
                  Row(
                    children: [
                      Text(
                        '요약',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      Spacer(),
                      SummaryToggleWidget(
                        currentType: _selectedSummaryType,
                        onChanged: _onSummaryTypeChanged,
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // 요약 내용 영역 - 내부 박스 제거, 스크롤 제거
                  Expanded(
                    child: _buildSummaryContent(keyword),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}