import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../models/_models.dart';

class RandomKeywordTabComponent extends StatefulWidget {
  const RandomKeywordTabComponent({Key? key}) : super(key: key);

  @override
  State<RandomKeywordTabComponent> createState() => _RandomKeywordTabComponentState();
}

class _RandomKeywordTabComponentState extends State<RandomKeywordTabComponent> 
    with TickerProviderStateMixin {
  bool _isRandomLoading = false;
  late AnimationController _floatingController;
  List<Keyword> _randomKeywords = [];
  bool _isLoadingKeywords = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
    _loadRandomKeywords();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  // 현재 선택된 랜덤 키워드 인덱스
  int _currentRandomIndex = 0;

  // API에서 랜덤 키워드 로드
  Future<void> _loadRandomKeywords() async {
    try {
      setState(() {
        _isLoadingKeywords = true;
        _errorMessage = null;
      });
      
      final keywords = await ApiService().getRandomKeywordHistory();
      
      if (mounted) {
        setState(() {
          _randomKeywords = keywords;
          _isLoadingKeywords = false;
          if (_randomKeywords.isNotEmpty) {
            _currentRandomIndex = 0;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingKeywords = false;
        });
      }
    }
  }

  // 랜덤 키워드 기능
  void _randomizeKeyword() {
    if (_randomKeywords.isEmpty) {
      _loadRandomKeywords();
      return;
    }
    
    setState(() {
      _isRandomLoading = true;
    });

    // API에서 새로운 랜덤 키워드 가져오기
    ApiService().getRandomKeywordHistory().then((keywords) {
      if (mounted && keywords.isNotEmpty) {
        setState(() {
          _randomKeywords = keywords;
          // 새로운 키워드로 변경
          _currentRandomIndex = 0;
          _isRandomLoading = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isRandomLoading = false;
        });
        // 에러 발생 시 기존 키워드에서 다른 것 선택
        if (_randomKeywords.length > 1) {
          setState(() {
            int newIndex;
            do {
              newIndex = (DateTime.now().millisecondsSinceEpoch % _randomKeywords.length).toInt();
            } while (newIndex == _currentRandomIndex);
            _currentRandomIndex = newIndex;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // 로딩 중이거나 키워드가 없는 경우 처리
    if (_isLoadingKeywords) {
      return Center(
        child: CircularProgressIndicator(
          color: Color(0xFFEF4444),
        ),
      );
    }
    
    if (_errorMessage != null || _randomKeywords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              _errorMessage ?? '랜덤 키워드를 불러올 수 없습니다',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadRandomKeywords,
              child: Text('다시 시도'),
            ),
          ],
        ),
      );
    }
    
    final currentKeyword = _randomKeywords[_currentRandomIndex];
    
    return Stack(
      children: [
        // 배경 그라데이션 애니메이션
        Positioned.fill(
          child: AnimatedContainer(
            duration: Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        Color(0xFF0F172A),
                        Color(0xFF1E293B),
                        Color(0xFF0F172A),
                      ]
                    : [
                        Color(0xFFF8FAFC),
                        Color(0xFFE0E7FF),
                        Color(0xFFF8FAFC),
                      ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        
        // 플로팅 오브 효과 (최적화)
        ...List.generate(2, (index) => 
          Positioned(
            top: 150.h + (index * 300.h),
            left: index.isEven ? -30.w : null,
            right: index.isOdd ? -30.w : null,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    index.isEven ? _floatingController.value * 20 : -_floatingController.value * 20,
                    _floatingController.value * 15,
                  ),
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (index == 0 ? Colors.blue : Colors.purple)
                              .withOpacity(0.2),
                          (index == 0 ? Colors.blue : Colors.purple)
                              .withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            // 히어로 섹션
            SliverToBoxAdapter(
              child: _buildRandomKeywordHeader(currentKeyword),
            ),
            
            // 키워드 요약 섹션
            SliverToBoxAdapter(
              child: _buildKeywordSummary().animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.03, end: 0, duration: 600.ms),
            ),
            
            // 키워드 상세 정보 섹션  
            SliverToBoxAdapter(
              child: _buildRelatedNews().animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.03, end: 0, duration: 600.ms),
            ),
            
            // 하단 여백
            SliverToBoxAdapter(
              child: SizedBox(height: 100.h),
            ),
          ],
        ),
      ],
    );
  }


  // 랜덤 키워드 히어로 섹션 - TimeMachine 스타일
  Widget _buildRandomKeywordHeader(Keyword keyword) {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 구조화된 타이틀
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFEF4444).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shuffle_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "랜덤 키워드",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "예상치 못한 트렌드를 발견하세요",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 32.h),
          
          // 키워드 선택 카드
          GestureDetector(
            onTap: _randomizeKeyword,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Color(0xFF1E293B), Color(0xFF0F172A)]
                      : [Colors.white, Color(0xFFF8FAFC)],
                ),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.06),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: _isRandomLoading
                  ? SizedBox(
                      height: 80.h, // 카드 내용의 적절한 높이 설정
                      child: Center(
                        child: SizedBox(
                          width: 32.sp,
                          height: 32.sp,
                          child: CircularProgressIndicator(
                            color: Color(0xFFEF4444),
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                keyword.keyword,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.getTextColor(context),
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _formatDate(keyword.created_at),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Color(0xFFEF4444).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Color(0xFFEF4444).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            keyword.category,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            color: Color(0xFFEF4444),
                            size: 16.sp,
                          ),
                        ),
                      ],
                    ),
            ),
          ).animate()
              .fadeIn(duration: 800.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOutCubic)
              .scale(begin: Offset(0.95, 0.95), end: Offset(1, 1), duration: 800.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  // 키워드 요약 섹션 - TimeMachine 스타일
  Widget _buildKeywordSummary() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모던 섹션 헤더
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "키워드 요약",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    "AI 분석 핵심 포인트",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ).animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
          
          SizedBox(height: 24.h),
          
          // 요약 내용 컨테이너
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildKeywordSummaryPoints(),
              ),
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.03, end: 0, duration: 600.ms),
        ],
      ),
    );
  }

  // 번호가 있는 포인트 아이템 - TimeMachine 스타일
  Widget _buildNumberedPoint(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.4,
                color: AppTheme.getTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 키워드 상세 정보 섹션 - TimeMachine 스타일
  Widget _buildRelatedNews() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모던 섹션 헤더
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "키워드 상세",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    "상세 설명 및 추가 정보",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ).animate()
                .fadeIn(duration: 600.ms, delay: 800.ms)
                .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
          
          SizedBox(height: 24.h),
          
          // 키워드 상세 정보 컨테이너
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: _buildKeywordDetails(),
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 1000.ms)
              .slideY(begin: 0.03, end: 0, duration: 600.ms),
        ],
      ),
    );
  }

  // 날짜 포맷팅 헬퍼 메서드
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  // 키워드 요약 포인트 생성
  List<Widget> _buildKeywordSummaryPoints() {
    final currentKeyword = _randomKeywords[_currentRandomIndex];
    
    // type1이 List인 경우 각 항목을 번호로 표시
    if (currentKeyword.type1 is List && currentKeyword.type1.isNotEmpty) {
      final type1List = currentKeyword.type1 as List;
      return type1List.asMap().entries.map((entry) {
        return Padding(
          padding: EdgeInsets.only(bottom: entry.key < type1List.length - 1 ? 16.h : 0),
          child: _buildNumberedPoint(entry.key + 1, entry.value.toString()),
        );
      }).toList();
    }
    
    // type2가 있는 경우 단일 포인트로 표시
    if (currentKeyword.type2.isNotEmpty) {
      return [
        _buildNumberedPoint(1, currentKeyword.type2),
      ];
    }
    
    // 기본 메시지
    return [
      _buildNumberedPoint(1, '이 키워드에 대한 상세 정보가 곧 업데이트됩니다.'),
    ];
  }

  // 키워드 상세 정보
  Widget _buildKeywordDetails() {
    final currentKeyword = _randomKeywords[_currentRandomIndex];
    final isDark = AppTheme.isDark(context);
    
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentKeyword.type3.isNotEmpty) ...[
            Text(
              '상세 설명',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextColor(context),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              currentKeyword.type3,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.5,
                color: AppTheme.getTextColor(context),
              ),
            ),
            SizedBox(height: 20.h),
          ],
          
          // 참조 링크들
          if (_hasReferences(currentKeyword.references)) ...[
            Text(
              '관련 링크',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextColor(context),
              ),
            ),
            SizedBox(height: 12.h),
            ..._buildReferencesList(currentKeyword.references, isDark),
          ] else ...[
            Center(
              child: Text(
                '추가 정보가 곧 업데이트됩니다.',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // references 데이터가 있는지 확인하는 헬퍼 메서드
  bool _hasReferences(dynamic references) {
    if (references == null) return false;
    
    if (references is Map) {
      return references.isNotEmpty;
    } else if (references is List) {
      return references.isNotEmpty;
    }
    
    return false;
  }

  // references 데이터를 위젯 리스트로 변환하는 헬퍼 메서드
  List<Widget> _buildReferencesList(dynamic references, bool isDark) {
    List<Widget> widgets = [];
    
    if (references is Map<String, dynamic>) {
      // Map 형태의 references 처리
      for (var entry in references.entries) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else if (references is List) {
      // List 형태의 references 처리
      for (int i = 0; i < references.length; i++) {
        final ref = references[i];
        String displayText = '';
        
        if (ref is String) {
          displayText = ref;
        } else if (ref is Map) {
          displayText = ref['title']?.toString() ?? ref['url']?.toString() ?? ref.toString();
        } else {
          displayText = ref.toString();
        }
        
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    return widgets;
  }

}