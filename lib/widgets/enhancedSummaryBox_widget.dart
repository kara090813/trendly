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
  final Map<int, ScrollController> _scrollControllers = {}; // 각 카드별 스크롤 컨트롤러
  bool _showSwipeHint = true;
  bool _isAnimatingToPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.currentIndex,
      viewportFraction: 1.0, // 전체 화면 사용
    );
    // 각 키워드별 스크롤 컨트롤러 초기화 (최상단부터 시작)
    for (int i = 0; i < widget.keywords.length; i++) {
      _scrollControllers[i] = ScrollController(initialScrollOffset: 0.0);
    }

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

    // 스와이프 힌트 애니메이션 (카드 애니메이션 완료 후 시작)
    _cardAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 1000), () {
          if (mounted && widget.keywords.length > 1) {
            _swipeHintController.repeat(reverse: true);

            // 5초 후 힌트 숨기기
            Future.delayed(Duration(seconds: 5), () {
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
    });
  }

  @override
  void didUpdateWidget(EnhancedSummaryBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // PageController 업데이트
      if (_pageController.hasClients && !_isAnimatingToPage) {
        _isAnimatingToPage = true;
        _pageController.animateToPage(
          widget.currentIndex,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        ).then((_) {
          _isAnimatingToPage = false;
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
    
    // 요약 타입 변경시 스크롤 위치 초기화
    if (oldWidget.keywords != widget.keywords) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final controller in _scrollControllers.values) {
          if (controller.hasClients) {
            controller.jumpTo(0.0);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _swipeHintController.dispose();
    _pageController.dispose();
    // 모든 스크롤 컨트롤러 해제
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onSummaryTypeChanged(String type) {
    setState(() {
      _selectedSummaryType = type;
    });
    
    // 요약 타입 변경시 스크롤 위치 초기화 및 상태 업데이트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final controller in _scrollControllers.values) {
        if (controller.hasClients) {
          controller.animateTo(
            0.0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
      // 스크롤바 상태 업데이트를 위해 rebuild 강제
      if (mounted) {
        setState(() {});
      }
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
    final List<Widget> paragraphWidgets = [];

    for (int i = 0; i < paragraphs.length; i++) {
      if (i > 0) {
        paragraphWidgets.add(SizedBox(height: 16.h));
      }

      String paragraph = paragraphs[i];
      List<TextSpan> paragraphSpans = [];
      int currentPos = 0;
      final int paragraphLength = paragraph.length;

      // 3줄 요약의 경우만 숫자와 함께 처리
      bool is3LineType = _selectedSummaryType == '3줄' && i < 3;

      while (currentPos < paragraphLength) {
        bool foundMatch = false;

        for (String token in keywordTokens) {
          if (currentPos + token.length <= paragraphLength &&
              paragraph.substring(currentPos, currentPos + token.length).toLowerCase() ==
                  token.toLowerCase()) {
            paragraphSpans.add(TextSpan(
              text: paragraph.substring(currentPos, currentPos + token.length),
              style: TextStyle(
                fontSize: 18.sp,
                height: 1.7,
                fontWeight: FontWeight.w700,
                color: Color(0xFF19B3F6),
                backgroundColor: Color(0xFF19B3F6).withOpacity(0.1),
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
              fontSize: 18.sp,
              height: 1.7,
              fontWeight: FontWeight.w400,
              color: AppTheme.isDark(context) 
                  ? Colors.white.withOpacity(0.9)
                  : Colors.black87,
            ),
          ));

          currentPos = nextMatchPos;
        }
      }

      // 위젯 추가
      if (is3LineType) {
        // 3줄 요약은 숫자와 함께 Row로 표시
        paragraphWidgets.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                margin: EdgeInsets.only(right: 8.w, top: 6.h),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF19B3F6), Color(0xFF0EA5E9)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF19B3F6).withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(children: paragraphSpans),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        );
      } else {
        // 일반 텍스트 표시
        paragraphWidgets.add(
          Container(
            width: double.infinity,
            child: RichText(
              text: TextSpan(children: paragraphSpans),
              textAlign: TextAlign.left,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphWidgets,
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

  // 안전한 글래스모피즘 스크롤바
  Widget _buildCustomScrollbar(int index) {
    final controller = _scrollControllers[index]!;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            // 컨트롤러가 준비되지 않았으면 빈 위젯 반환
            if (!controller.hasClients) {
              // 컨트롤러가 연결될 때까지 잠시 기다린 후 다시 빌드
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && controller.hasClients) {
                  setState(() {});
                }
              });
              return SizedBox.shrink();
            }

            // 안전한 방식으로 스크롤 정보 접근
            try {
              final scrollPosition = controller.position;
              final maxScrollExtent = scrollPosition.maxScrollExtent;
              final currentScroll = scrollPosition.pixels;
              final containerHeight = scrollPosition.viewportDimension;
              
              // 스크롤할 내용이 없으면 스크롤바 숨김
              if (maxScrollExtent <= 0) {
                return SizedBox.shrink();
              }

              final scrollRatio = (currentScroll / maxScrollExtent).clamp(0.0, 1.0);
              final thumbHeight = (containerHeight * 0.25).clamp(40.h, containerHeight * 0.7);
              final trackHeight = containerHeight - 16.h;
              final thumbPosition = (trackHeight - thumbHeight) * scrollRatio + 8.h;

              return Container(
                width: 12.w,
                height: containerHeight,
                child: Stack(
                  children: [
                    // 글래스모피즘 트랙
                    Positioned(
                      right: 2.w,
                      top: 8.h,
                      bottom: 8.h,
                      child: Container(
                        width: 8.w,
                        decoration: BoxDecoration(
                          color: AppTheme.isDark(context)
                              ? Colors.white.withOpacity(0.08)
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: AppTheme.isDark(context)
                                ? Colors.white.withOpacity(0.15)
                                : Colors.white.withOpacity(0.6),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.isDark(context)
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.grey[300]!.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 글래스모피즘 썸
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 80),
                      top: thumbPosition,
                      right: 0.w,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          try {
                            final delta = details.delta.dy;
                            final scrollSensitivity = maxScrollExtent / trackHeight;
                            final newPosition = currentScroll + (delta * scrollSensitivity);
                            controller.jumpTo(newPosition.clamp(0.0, maxScrollExtent));
                          } catch (e) {
                            // 드래그 중 에러 무시
                          }
                        },
                        child: Container(
                          width: 12.w,
                          height: thumbHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: AppTheme.isDark(context)
                                  ? [
                                      Colors.white.withOpacity(0.25),
                                      Colors.white.withOpacity(0.15),
                                      Colors.white.withOpacity(0.25),
                                    ]
                                  : [
                                      Colors.white.withOpacity(0.9),
                                      Colors.white.withOpacity(0.6),
                                      Colors.white.withOpacity(0.9),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppTheme.isDark(context)
                                  ? Colors.white.withOpacity(0.3)
                                  : Color(0xFF19B3F6).withOpacity(0.2),
                              width: 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.isDark(context)
                                    ? Colors.black.withOpacity(0.3)
                                    : Color(0xFF19B3F6).withOpacity(0.2),
                                blurRadius: 6,
                                spreadRadius: 0,
                                offset: Offset(0, 3),
                              ),
                              // 상단 하이라이트
                              BoxShadow(
                                color: Colors.white.withOpacity(0.6),
                                blurRadius: 2,
                                spreadRadius: 0,
                                offset: Offset(0, -1),
                              ),
                            ],
                          ),
                          child: Container(
                            margin: EdgeInsets.all(1.5.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.4),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } catch (e) {
              // 에러 발생시 빈 위젯 반환
              return SizedBox.shrink();
            }
          },
        );
      },
    );
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

          // 메인 카드 영역 - 요약 타입별 동적 높이
          AnimatedBuilder(
            animation: _cardScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _cardScaleAnimation.value,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  height: _getCardHeightBySummaryType(), // 요약 타입별 높이
                  child: Stack(
                    children: [
                      // 부드러운 PageView
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          if (!_isAnimatingToPage && widget.onPageChanged != null) {
                            widget.onPageChanged!(index);
                          }
                        },
                        itemCount: widget.keywords.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: _buildStreamlinedCard(widget.keywords[index], index),
                          );
                        },
                      ),

                      // 스와이프 힌트 애니메이션
                      if (_showSwipeHint && widget.keywords.length > 1 && _cardAnimationController.isCompleted)
                        AnimatedBuilder(
                          animation: _swipeHintAnimation,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                // 좌측 화살표
                                Positioned(
                                  left: -5.w + (10 * _swipeHintAnimation.value),
                                  top: 0,
                                  bottom: 0,
                                  child: IgnorePointer(
                                    child: Center(
                                      child: Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF19B3F6).withOpacity(0.9),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFF19B3F6).withOpacity(0.4),
                                              blurRadius: 10,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.chevron_left,
                                          color: Colors.white,
                                          size: 22.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // 우측 화살표
                                Positioned(
                                  right: -5.w + (10 * _swipeHintAnimation.value),
                                  top: 0,
                                  bottom: 0,
                                  child: IgnorePointer(
                                    child: Center(
                                      child: Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF19B3F6).withOpacity(0.9),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFF19B3F6).withOpacity(0.4),
                                              blurRadius: 10,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                          size: 22.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

  // 요약 타입별 동적 높이
  double _getCardHeightBySummaryType() {
    switch (_selectedSummaryType) {
      case '3줄':
        return 520.h; // 3줄 요약용 기본 높이
      case '짧은 글':
        return 600.h; // 짧은 글용 증가된 높이
      case '긴 글':
        return 720.h; // 긴 글용 최대 높이
      default:
        return 520.h;
    }
  }

  // 콘텐츠 크기 기반 카드 디자인 - 스크롤 없음
  Widget _buildStreamlinedCard(Keyword keyword, int index) {
    final bool isCurrentCard = index == widget.currentIndex;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.only(bottom: 20.h, top: 4.h), // 상하단 그림자 공간
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: AppTheme.isDark(context)
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(isCurrentCard ? 0.3 : 0.2),
                    blurRadius: isCurrentCard ? 20 : 10,
                    spreadRadius: isCurrentCard ? 0 : -2,
                    offset: Offset(0, isCurrentCard ? 8 : 4),
                  ),
                ]
              : [
                  // 라이트모드 - 짙은 색상의 아담한 그림자
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: Offset(0, 6),
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
                  Colors.white,
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 헤더 영역
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
                            fontSize: 13.sp,
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
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF19B3F6),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // 키워드 제목 - 버튼형 디자인
                  InkWell(
                    onTap: () {
                      context.pushNamed(
                        'keywordDetail',
                        pathParameters: {'id': keyword.id.toString()},
                      );
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Color(0xFF19B3F6).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Color(0xFF19B3F6).withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF19B3F6).withOpacity(0.1),
                            blurRadius: 4,
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
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.getTextColor(context),
                                letterSpacing: -0.3,
                              ),
                              minFontSize: 18,
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Color(0xFF19B3F6),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // 요약 타입 토글
                  Row(
                    children: [
                      Text(
                        '요약',
                        style: TextStyle(
                          fontSize: 16.sp,
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

                  // 트렌디한 요약 내용 박스
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppTheme.isDark(context)
                              ? [
                                  Color(0xFF1E1E2E).withOpacity(0.9),
                                  Color(0xFF2A2A3E).withOpacity(0.9),
                                ]
                              : [
                                  Color(0xFFF8F9FA),
                                  Color(0xFFF0F2F5),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: AppTheme.isDark(context)
                              ? Colors.white.withOpacity(0.08)
                              : Color(0xFF19B3F6).withOpacity(0.15),
                          width: 1.5,
                        ),
                        boxShadow: AppTheme.isDark(context) 
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : [
                                // 내부 그림자 효과 (inset 느낌)
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.6),
                                  blurRadius: 12,
                                  spreadRadius: -5,
                                  offset: Offset(0, -3),
                                ),
                                // 외부 그림자 (깊이감)
                                BoxShadow(
                                  color: Color(0xFF19B3F6).withOpacity(0.12),
                                  blurRadius: 16,
                                  spreadRadius: -2,
                                  offset: Offset(0, 6),
                                ),
                              ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Stack(
                          children: [
                            // 배경 패턴
                            Positioned(
                              top: -50,
                              right: -50,
                              child: Container(
                                width: 150.w,
                                height: 150.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Color(0xFF19B3F6).withOpacity(0.1),
                                      Color(0xFF19B3F6).withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // 콘텐츠
                            // 콘텐츠 - 독특한 스크롤바 디자인
                            Padding(
                              padding: EdgeInsets.fromLTRB(16.w, 16.w, 4.w, 16.w), // 우측 패딩 최소화
                              child: Stack(
                                children: [
                                  // 메인 콘텐츠 영역
                                  Padding(
                                    padding: EdgeInsets.only(right: 16.w), // 스크롤바 공간 확보
                                    child: SingleChildScrollView(
                                      controller: _scrollControllers[index],
                                      physics: BouncingScrollPhysics(),
                                      child: _selectedSummaryType == '3줄'
                                          ? Center(
                                              child: _buildSummaryContent(keyword),
                                            )
                                          : _buildSummaryContent(keyword),
                                    ),
                                  ),
                                  // 커스텀 스크롤바
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: _buildCustomScrollbar(index),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}