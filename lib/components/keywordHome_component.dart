import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math'; // 랜덤 함수 사용을 위해 추가
import '../app_theme.dart';
import '../providers/_providers.dart';
import '../services/api_service.dart';
import '../services/ad_service.dart';
import '../services/firebase_messaging_service.dart';
import '../models/_models.dart';
import '../widgets/_widgets.dart';

class KeywordHomeComponent extends StatefulWidget {
  const KeywordHomeComponent({super.key});

  @override
  State<KeywordHomeComponent> createState() => _KeywordHomeComponentState();
}

class _KeywordHomeComponentState extends State<KeywordHomeComponent>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final FirebaseMessagingService _fcmService = FirebaseMessagingService();
  List<Keyword> _keywords = [];
  List<Keyword> _previousKeywords = []; // 이전 키워드 목록 저장용

  // 리스트만 로딩하기 위한 별도 상태 변수
  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  bool _showKeywordAnimation = false;
  bool _showShimmerEffect = false;
  bool _hasPlayedInitialAnimation = false; // 초기 애니메이션 재생 여부 추적

  // 랜덤 애니메이션 선택을 위한 변수
  int _currentAnimationIndex = 0;
  final Random _random = Random();
  
  // 🎲 두 번째 광고 표시 여부 (30% 확률)
  bool _shouldShowSecondAd = false;

  String? _error;
  Keyword? _selectedKeyword;
  int _selectedKeywordIndex = 0; // 선택된 키워드의 인덱스 추가
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _summaryBoxKey = GlobalKey(); // SummaryBox 위치 추적용

  // 리프레시 애니메이션을 위한 컨트롤러
  late AnimationController _refreshAnimationController;
  late Animation<double> _refreshAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    // 🎲 앱 시작 시 30% 확률로 두 번째 광고 표시 결정
    _shouldShowSecondAd = _random.nextDouble() < 0.3;

    // 리프레시 애니메이션 컨트롤러 초기화
    _refreshAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshAnimationController,
      curve: Curves.easeInOut,
    ));

    // 초기 애니메이션 선택
    _selectRandomAnimation();

    _loadKeywords(isInitial: true);
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 랜덤 애니메이션 선택 함수
  void _selectRandomAnimation() {
    setState(() {
      _currentAnimationIndex = _random.nextInt(10); // 0-9 사이의 랜덤 인덱스
    });
  }

  Future<void> _loadKeywords({bool isInitial = false}) async {
    try {
      // 🎲 키워드 새로고침 시마다 30% 확률로 두 번째 광고 표시 결정
      _shouldShowSecondAd = _random.nextDouble() < 0.3;
      
      // isInitial이 true면 초기 로딩 상태, 그렇지 않으면 리프레싱 상태로 설정
      setState(() {
        if (isInitial) {
          _isInitialLoading = true;
        } else {
          // 이전 키워드 저장 (UI 높이 유지를 위해)
          _previousKeywords = List.from(_keywords);
          _isRefreshing = true;
          _showKeywordAnimation = false;
          _showShimmerEffect = false;

          // 랜덤 애니메이션 선택
          _selectRandomAnimation();

          // 리프레시 애니메이션 시작
          _refreshAnimationController.reset();
          _refreshAnimationController.forward();
        }
        _error = null;
      });

      final keywords = await _apiService.getCurrentKeywords();

      // 약간의 딜레이 추가 (로딩 애니메이션이 보이도록)
      if (!isInitial) {
        await Future.delayed(Duration(milliseconds: 1500));
      }

      if (mounted) {
        setState(() {
          _keywords = keywords;
          _isInitialLoading = false;

          // 새로운 실검 리스트가 로딩되면 1위 키워드를 자동 선택
          if (_keywords.isNotEmpty) {
            _selectedKeyword = _keywords.first;
            _selectedKeywordIndex = 0;
          }

          if (!isInitial) {
            _isRefreshing = false;
            _previousKeywords = [];

            // 로딩 완료 후 Shimmer 효과 활성화
            _showShimmerEffect = true;

            // Shimmer 효과가 잠시 표시된 후 키워드 애니메이션 활성화
            Future.delayed(Duration(milliseconds: 800), () {
              if (mounted) {
                setState(() {
                  _showKeywordAnimation = true;
                  _showShimmerEffect = false; // Shimmer 효과 비활성화
                });
                
                // 애니메이션 완료 후 플래그 설정 (애니메이션 지속 시간 후)
                Future.delayed(Duration(milliseconds: 500), () {
                  if (mounted) {
                    setState(() {
                      _hasPlayedInitialAnimation = true; // 초기 애니메이션 완료
                    });
                  }
                });
              }
            });
          } else {
            _isRefreshing = false;
            _showKeywordAnimation = true;
            
            // 새로고침 시에는 바로 애니메이션 완료로 설정 (초기 로딩이 아니므로)
            if (!_isInitialLoading) {
              Future.delayed(Duration(milliseconds: 500), () {
                if (mounted) {
                  setState(() {
                    _hasPlayedInitialAnimation = true;
                  });
                }
              });
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '키워드를 불러오는 중 오류가 발생했습니다: $e';
          _isInitialLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  void _selectKeyword(Keyword keyword, {bool isManualClick = false}) async {
    final index = _keywords.indexWhere((k) => k.id == keyword.id);
    if (index != -1) {
      setState(() {
        _selectedKeyword = keyword;
        _selectedKeywordIndex = index;
      });

      // 요약 영역으로 자동 스크롤
      _scrollToSummary();
      
      // 사용자가 직접 클릭한 경우에만 로그 기록
      if (isManualClick) {
        try {
          final token = await _fcmService.getTokenForLogging();
          final result = await _apiService.logKeywordView(
            token: token,
            category: keyword.category ?? '기타',
            keyword: keyword.keyword,
          );
          
          if (result != null) {
            print('📊 [LOG] Keyword view logged: ${keyword.keyword}');
          } else {
            print('📊 [LOG] Keyword view log skipped (no token): ${keyword.keyword}');
          }
        } catch (e) {
          print('❌ [LOG] Failed to log keyword view: $e');
        }
      }
    }
  }

  // 요약 영역으로 스크롤하는 함수
  void _scrollToSummary() {
    if (_summaryBoxKey.currentContext != null) {
      Future.delayed(Duration(milliseconds: 50), () {
        final RenderBox? renderBox = _summaryBoxKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          // 단순하게 SummaryBox 상단이 화면 상단에 오도록 (여백 80픽셀)
          final targetOffset = _scrollController.offset + position.dy - 80.h;

          _scrollController.animateTo(
            targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  // 이전 키워드로 이동
  void _goToPreviousKeyword() {
    if (_keywords.isNotEmpty && _selectedKeywordIndex > 0) {
      setState(() {
        _selectedKeywordIndex--;
        _selectedKeyword = _keywords[_selectedKeywordIndex];
      });
    }
  }

  // 다음 키워드로 이동
  void _goToNextKeyword() {
    if (_keywords.isNotEmpty && _selectedKeywordIndex < _keywords.length - 1) {
      setState(() {
        _selectedKeywordIndex++;
        _selectedKeyword = _keywords[_selectedKeywordIndex];
      });
    }
  }

  // 랜덤 로딩 애니메이션 위젯 생성
  Widget _buildRandomLoadingAnimation() {
    // 브랜드 색상 (테마와 상관없이 유지)
    final Color primaryBlue = Color(0xFF19B3F6);

    switch (_currentAnimationIndex) {
      case 0:
        return SpinKitFadingGrid(
          color: primaryBlue,
          size: 80.w,
          shape: BoxShape.circle,
        );
      case 1:
        return SpinKitPouringHourGlass(
          color: primaryBlue,
          size: 80.w,
        );
      case 2:
        return SpinKitSpinningLines(
          color: primaryBlue,
          size: 80.w,
        );
      case 3:
        return SpinKitDancingSquare(
          color: primaryBlue,
          size: 70.w,
        );
      case 4:
        return SpinKitWaveSpinner(
          color: primaryBlue,
          size: 80.w,
          waveColor: primaryBlue.withOpacity(0.7),
          trackColor: primaryBlue.withOpacity(0.3),
        );
      case 5:
        return SpinKitPianoWave(
          color: primaryBlue,
          size: 80.w,
          itemCount: 5,
        );
      case 6:
        return SpinKitFoldingCube(
          color: primaryBlue,
          size: 60.w,
        );
      case 7:
        return SpinKitRipple(
          color: primaryBlue,
          size: 100.w,
          borderWidth: 6.0,
        );
      case 8:
        return SpinKitPulse(
          color: primaryBlue,
          size: 80.w,
        );
      case 9:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitRing(
              color: primaryBlue,
              size: 60.w,
              lineWidth: 4.0,
            ),
            SizedBox(height: 10.h),
            Icon(
              Icons.trending_up,
              color: primaryBlue,
              size: 32.w,
            ),
          ],
        );
      default:
        return SpinKitFadingGrid(
          color: primaryBlue,
          size: 80.w,
          shape: BoxShape.circle,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _keywords.isEmpty) {
      return _buildErrorWidget();
    }

    if (_keywords.isEmpty && _previousKeywords.isEmpty) {
      return const Center(child: Text('표시할 키워드가 없습니다.'));
    }

    // 표시할 키워드 목록 (로딩 중에는 이전 키워드 목록 사용)
    final displayKeywords = _isRefreshing && _previousKeywords.isNotEmpty
        ? _previousKeywords
        : _keywords;

    final themeProvider = Provider.of<UserPreferenceProvider>(context);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 헤더 + 디자인 (상단 고정된 부분)
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getContainerColor(context),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    spreadRadius: 3,
                    offset: Offset(0, 6),
                  ),
                  // 추가 그림자 레이어
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28.r),
                  bottomRight: Radius.circular(28.r),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 50.h, bottom: 30.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 18.w),
                              child: Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Image.asset(
                                    'assets/img/logo_img.png',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                SizedBox(height: 4.h,),
                                Image.asset(
                                  'assets/img/logo_title.png',
                                  height: 18.h,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 18.w),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleButtonWidget(
                                    context: context,
                                    onTap: () {
                                      themeProvider.toggleDarkMode();
                                    },
                                    icon: themeProvider.effectiveDarkMode 
                                        ? Icons.light_mode  // 다크모드일 때 해 아이콘
                                        : Icons.dark_mode,  // 라이트모드일 때 달 아이콘
                                    color: AppTheme.primaryBlue,
                                    iconSize: 24.w,
                                    containerSize: 42.w,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: Row(
                      children: [
                        SizedBox(width: 10.w),
                        Text(
                          '실시간 인기 검색어',
                          style: TextStyle(
                              fontSize: 20.sp, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _isRefreshing ? null : () => _loadKeywords(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppTheme.getButtonColor(context),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppTheme.isDark(context)
                                  ? [
                              ]
                                  : [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                  spreadRadius: 0.5,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.9),
                                  offset: Offset(-2, -2),
                                  blurRadius: 4,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // 로딩 중에는 회전하는 새로고침 아이콘 표시
                                _isRefreshing
                                    ? RotationTransition(
                                  turns: _refreshAnimation,
                                  child: Icon(Icons.refresh,
                                      size: 18.sp,
                                      color: Color(0xFF19B3F6)),
                                )
                                    : Icon(Icons.refresh,
                                    size: 18.sp,
                                    color: AppTheme.isDark(context)
                                        ? Colors.white
                                        : Color(0xFF4A4A4A)),
                                SizedBox(width: 4.w),
                                Text(
                                  _getFormattedTime(),
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppTheme.isDark(context)
                                          ? Colors.white
                                          : Color(0xFF4A4A4A)),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),

          // 키워드 목록 리스트 영역 (Stack 구조로 로딩 애니메이션 오버레이)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            sliver: _buildOptimizedKeywordSliver(),
          ),

          // 선택된 키워드 요약
          if (_keywords.isNotEmpty)
            SliverToBoxAdapter(
              child: RepaintBoundary(
                key: _summaryBoxKey,
                child: EnhancedSummaryBoxWidget(
                  keywords: _keywords,
                  currentIndex: _selectedKeywordIndex,
                  onPrevious: _goToPreviousKeyword,
                  onNext: _goToNextKeyword,
                  canGoPrevious: _selectedKeywordIndex > 0,
                  canGoNext: _selectedKeywordIndex < _keywords.length - 1,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedKeywordIndex = index;
                      _selectedKeyword = _keywords[index];
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Shimmer 효과가 적용된 키워드 리스트
  Widget _buildShimmerKeywordList(List<Keyword> keywords) {
    if (keywords.isEmpty) return SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        keywords.length,
            (index) {
          return Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Color(0xFF19B3F6).withOpacity(0.3),
            child: RepaintBoundary(
              child: KeywordBoxWidget(
                keyword: keywords[index],
                rank: index + 1,
                isSelected: _selectedKeyword?.id == keywords[index].id,
                onTap: () => _selectKeyword(keywords[index], isManualClick: true),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🚀 성능 최적화: SliverList를 사용한 가상화 키워드 리스트
  Widget _buildOptimizedKeywordSliver() {
    // 표시할 키워드 결정: 새로고침 중이면 이전 키워드 유지
    final displayKeywords = _isRefreshing && _previousKeywords.isNotEmpty
        ? _previousKeywords
        : _keywords;
    
    if (displayKeywords.isEmpty && _isInitialLoading) {
      // 초기 로딩 중
      return SliverToBoxAdapter(
        child: Container(
          height: 200.h,
          child: Center(child: _buildRandomLoadingAnimation()),
        ),
      );
    } else if (displayKeywords.isEmpty && _error != null) {
      // 에러 상태
      return SliverToBoxAdapter(child: _buildErrorWidget());
    }

    // 광고를 포함한 아이템 목록 생성
    List<Widget> allItems = _buildOptimizedItemList(displayKeywords);
    
    // 🎯 Stack 구조로 로딩 애니메이션 오버레이
    return SliverToBoxAdapter(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 기본 키워드 리스트
          Opacity(
            opacity: _isRefreshing ? 0.3 : 1.0, // 로딩 중에는 흐리게 표시
            child: _showShimmerEffect
                ? _buildShimmerKeywordList(displayKeywords) // Shimmer 효과
                : AnimationLimiter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: allItems,
                    ),
                  ),
          ),
          
          // 로딩 애니메이션 (중앙에 표시)
          if (_isRefreshing)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 랜덤 로딩 애니메이션
                  Container(
                    width: 160.w,
                    height: 160.w,
                    decoration: BoxDecoration(
                      color: AppTheme.isDark(context)
                          ? Color(0xFF21202C).withOpacity(0.9)
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.isDark(context)
                              ? Colors.black.withOpacity(0.4)
                              : Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _buildRandomLoadingAnimation(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // 텍스트에 배경 추가
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppTheme.isDark(context)
                          ? Color(0xFF21202C).withOpacity(0.9)
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.isDark(context)
                              ? Colors.black.withOpacity(0.4)
                              : Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      "최신 트렌드로 새로고침 중...",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF19B3F6), // 브랜드 색상 유지
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 최적화된 아이템 리스트 생성 (키워드 + 광고)
  List<Widget> _buildOptimizedItemList(List<Keyword> keywords) {
    // 🎯 애니메이션 최적화: 초기 로딩 시에만 애니메이션 실행
    final bool useAnimation = AdService.enableAnimations && 
                             _showKeywordAnimation && 
                             !_isRefreshing && 
                             !_isInitialLoading &&
                             !_hasPlayedInitialAnimation; // 한 번만 실행
    
    // 📌 성능 최적화: 광고 위젯을 const로 미리 생성하여 재사용
    const bannerAd1 = BannerAdWidget(key: ValueKey('banner_ad_1'));
    const bannerAd2 = BannerAdWidget(key: ValueKey('banner_ad_2'));
    
    List<Widget> items = [];
    
    for (int i = 0; i < keywords.length; i++) {
      // 일반 키워드 위젯 생성
      final keywordWidget = KeywordBoxWidget(
        keyword: keywords[i],
        rank: i + 1,
        isSelected: _selectedKeyword?.id == keywords[i].id,
        onTap: () => _selectKeyword(keywords[i], isManualClick: true),
      );

      // 애니메이션 적용 여부에 따라 다른 위젯 추가
      if (useAnimation) {
        items.add(
          AnimationConfiguration.staggeredList(
            position: items.length,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: keywordWidget),
            ),
          ),
        );
      } else {
        items.add(keywordWidget);
      }
      
      // 🎯 3위 다음(3위와 4위 사이)에 첫 번째 광고 삽입
      if (i == 2 && keywords.length > 3) { // i=2는 3위
        final adWidget = useAnimation 
          ? AnimationConfiguration.staggeredList(
              position: items.length,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: bannerAd1),
              ),
            )
          : bannerAd1;
        items.add(adWidget);
      }
      
      // 🎯 6위 다음(6위와 7위 사이)에 두 번째 광고 삽입 (30% 확률)
      if (i == 5 && keywords.length > 6 && _shouldShowSecondAd) { // i=5는 6위
        final adWidget = useAnimation 
          ? AnimationConfiguration.staggeredList(
              position: items.length,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: bannerAd2),
              ),
            )
          : bannerAd2;
        items.add(adWidget);
      }
    }
    
    return items;
  }

  // 키워드 리스트 생성 함수 (별도로 분리) - 광고 포함
  Widget _buildKeywordList(List<Keyword> keywords) {
    if (keywords.isEmpty) return SizedBox();

    // 🎯 성능 최적화: 애니메이션 조건 강화
    // 🎯 애니메이션 최적화: 초기 로딩 시에만 애니메이션 실행
    final bool useAnimation = AdService.enableAnimations && 
                             _showKeywordAnimation && 
                             !_isRefreshing && 
                             !_isInitialLoading &&
                             !_hasPlayedInitialAnimation; // 한 번만 실행
    
    // 📌 성능 최적화: 광고 위젯을 const로 미리 생성하여 재사용
    const bannerAd1 = BannerAdWidget(key: ValueKey('banner_ad_1'));
    const bannerAd2 = BannerAdWidget(key: ValueKey('banner_ad_2'));
    
    // 광고를 포함한 위젯 리스트 생성
    List<Widget> widgetList = [];

    for (int i = 0; i < keywords.length; i++) {
      // 일반 키워드 위젯 생성
      final Widget keywordWidget = RepaintBoundary(
        child: KeywordBoxWidget(
          keyword: keywords[i],
          rank: i + 1,
          isSelected: _selectedKeyword?.id == keywords[i].id,
          onTap: () => _selectKeyword(keywords[i], isManualClick: true),
        ),
      );

      // 애니메이션 적용 여부에 따라 다른 위젯 추가
      if (useAnimation) {
        widgetList.add(
          AnimationConfiguration.staggeredList(
            position: widgetList.length,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: keywordWidget,
              ),
            ),
          ),
        );
      } else {
        widgetList.add(keywordWidget);
      }
      
      // 🎯 3위 다음(3위와 4위 사이)에 첫 번째 광고 삽입
      if (i == 2 && keywords.length > 3) { // i=2는 3위
        if (useAnimation) {
          widgetList.add(
            AnimationConfiguration.staggeredList(
              position: widgetList.length,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: bannerAd1),
              ),
            ),
          );
        } else {
          widgetList.add(bannerAd1);
        }
      }
      
      // 🎯 6위 다음(6위와 7위 사이)에 두 번째 광고 삽입 (30% 확률)
      if (i == 5 && keywords.length > 6 && _shouldShowSecondAd) { // i=5는 6위
        if (useAnimation) {
          widgetList.add(
            AnimationConfiguration.staggeredList(
              position: widgetList.length,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: bannerAd2),
              ),
            ),
          );
        } else {
          widgetList.add(bannerAd2);
        }
      }
    }

    return AnimationLimiter(
      child: Column(
        mainAxisSize: MainAxisSize.min, // 필요한 높이만 사용
        children: widgetList,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadKeywords(isInitial: true),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }
}