// lib/widgets/enhancedSummaryBox_widget.dart
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
  late AnimationController _playerAnimationController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _playerSlideAnimation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.currentIndex,
      viewportFraction: 0.85, // 양옆 카드가 보이도록
    );

    _cardAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _playerAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _cardScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));

    _playerSlideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _playerAnimationController,
      curve: Curves.easeOutBack,
    ));

    // 애니메이션 시작
    _cardAnimationController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _playerAnimationController.forward();
    });
  }

  @override
  void didUpdateWidget(EnhancedSummaryBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          widget.currentIndex,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _playerAnimationController.dispose();
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
                fontSize: 16.sp,
                height: 1.4,
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
              fontSize: 16.sp,
              height: 1.4,
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
        children: [
          // 상단 핸들
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppTheme.isDark(context) ? Colors.grey[600] : Colors.grey[400],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // 메인 카드 영역
          Container(
            height: 520.h,
            child: AnimatedBuilder(
              animation: _cardScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _cardScaleAnimation.value,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      if (widget.onPageChanged != null) {
                        widget.onPageChanged!(index);
                      }
                    },
                    itemCount: widget.keywords.length,
                    itemBuilder: (context, index) {
                      return _buildMusicCard(widget.keywords[index], index);
                    },
                  ),
                );
              },
            ),
          ),

          // 음악 플레이어 스타일 컨트롤러
          AnimatedBuilder(
            animation: _playerSlideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _playerSlideAnimation.value * 100.h),
                child: _buildMusicPlayerController(),
              );
            },
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // 음악 앨범 커버 스타일 카드
  Widget _buildMusicCard(Keyword keyword, int index) {
    final bool isCurrentCard = index == widget.currentIndex;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: isCurrentCard ? 0 : 20.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isCurrentCard ? 0.3 : 0.1),
              blurRadius: isCurrentCard ? 20 : 10,
              spreadRadius: isCurrentCard ? 0 : -2,
              offset: Offset(0, isCurrentCard ? 8 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
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
            child: Stack(
              children: [
                // 백그라운드 패턴
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xFF19B3F6).withOpacity(0.05),
                          Colors.transparent,
                          Color(0xFF19B3F6).withOpacity(0.02),
                        ],
                      ),
                    ),
                  ),
                ),

                // 메인 컨텐츠
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더 (순위 + 카테고리)
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF19B3F6), Color(0xFF0EA5E9)],
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF19B3F6).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${index + 1}위',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          Spacer(),

                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Color(0xFF19B3F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Color(0xFF19B3F6).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              keyword.category,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF19B3F6),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // 키워드 제목
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(
                            'keywordDetail',
                            pathParameters: {'id': keyword.id.toString()},
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: AppTheme.isDark(context)
                                  ? [
                                Color(0xFF374151).withOpacity(0.6),
                                Color(0xFF1F2937).withOpacity(0.4),
                              ]
                                  : [
                                Colors.white.withOpacity(0.8),
                                Color(0xFFF1F5F9).withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppTheme.isDark(context)
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  keyword.keyword,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.getTextColor(context),
                                    letterSpacing: -0.5,
                                  ),
                                  minFontSize: 16,
                                  maxLines: 2,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF19B3F6),
                                size: 24.sp,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

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

                      // 요약 내용 (스크롤 가능)
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppTheme.isDark(context)
                                ? Color(0xFF1E1E2A).withOpacity(0.5)
                                : Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppTheme.isDark(context)
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.05),
                              width: 1,
                            ),
                          ),
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: _buildSummaryContent(keyword),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 음악 플레이어 스타일 컨트롤러
  Widget _buildMusicPlayerController() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 진행 바
          Row(
            children: [
              Text(
                '${widget.currentIndex + 1}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF19B3F6),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppTheme.isDark(context)
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (widget.currentIndex + 1) / widget.keywords.length,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF19B3F6), Color(0xFF0EA5E9)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '${widget.keywords.length}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 컨트롤 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 이전 버튼
              _buildPlayerButton(
                icon: Icons.skip_previous_rounded,
                onTap: widget.canGoPrevious ? widget.onPrevious : null,
                isEnabled: widget.canGoPrevious,
                size: 28.sp,
              ),

              SizedBox(width: 32.w),

              // 현재 키워드 정보
              Expanded(
                child: Column(
                  children: [
                    Text(
                      currentKeyword.keyword,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextColor(context),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _selectedSummaryType,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Color(0xFF19B3F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 32.w),

              // 다음 버튼
              _buildPlayerButton(
                icon: Icons.skip_next_rounded,
                onTap: widget.canGoNext ? widget.onNext : null,
                isEnabled: widget.canGoNext,
                size: 28.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 플레이어 버튼
  Widget _buildPlayerButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(
            colors: [Color(0xFF19B3F6), Color(0xFF0EA5E9)],
          )
              : null,
          color: !isEnabled
              ? (AppTheme.isDark(context) ? Colors.grey[700] : Colors.grey[300])
              : null,
          shape: BoxShape.circle,
          boxShadow: isEnabled
              ? [
            BoxShadow(
              color: Color(0xFF19B3F6).withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.grey[500],
          size: size,
        ),
      ),
    );
  }
}