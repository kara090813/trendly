import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math'; // 랜덤 함수 사용을 위해 추가
import '../services/api_service.dart';
import '../models/_models.dart';
import '../widgets/_widgets.dart';

class KeywordHomeComponent extends StatefulWidget {
  const KeywordHomeComponent({super.key});

  @override
  State<KeywordHomeComponent> createState() => _KeywordHomeComponentState();
}

class _KeywordHomeComponentState extends State<KeywordHomeComponent> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Keyword> _keywords = [];
  List<Keyword> _previousKeywords = []; // 이전 키워드 목록 저장용

  // 리스트만 로딩하기 위한 별도 상태 변수
  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  bool _showKeywordAnimation = false;
  bool _showShimmerEffect = false;

  // 랜덤 애니메이션 선택을 위한 변수
  int _currentAnimationIndex = 0;
  final Random _random = Random();

  String? _error;
  Keyword? _selectedKeyword;
  final ScrollController _scrollController = ScrollController();

  // 리프레시 애니메이션을 위한 컨트롤러
  late AnimationController _refreshAnimationController;
  late Animation<double> _refreshAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

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
              }
            });
          } else {
            _isRefreshing = false;
            _showKeywordAnimation = true;
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

  void _selectKeyword(Keyword keyword) {
    setState(() {
      _selectedKeyword = keyword;
    });
  }

  // 랜덤 로딩 애니메이션 위젯 생성
  Widget _buildRandomLoadingAnimation() {
    switch (_currentAnimationIndex) {
      case 0:
        return SpinKitFadingGrid(
          color: Color(0xFF19B3F6),
          size: 80.w,
          shape: BoxShape.circle,
        );
      case 1:
        return SpinKitPouringHourGlass(
          color: Color(0xFF19B3F6),
          size: 80.w,
        );
      case 2:
        return SpinKitSpinningLines(
          color: Color(0xFF19B3F6),
          size: 80.w,
        );
      case 3:
        return SpinKitDancingSquare(
          color: Color(0xFF19B3F6),
          size: 70.w,
        );
      case 4:
        return SpinKitWaveSpinner(
          color: Color(0xFF19B3F6),
          size: 80.w,
          waveColor: Color(0xFF19B3F6).withOpacity(0.7),
          trackColor: Color(0xFF19B3F6).withOpacity(0.3),
        );
      case 5:
        return SpinKitPianoWave(
          color: Color(0xFF19B3F6),
          size: 80.w,
          itemCount: 5,
        );
      case 6:
        return SpinKitFoldingCube(
          color: Color(0xFF19B3F6),
          size: 60.w,
        );
      case 7:
        return SpinKitRipple(
          color: Color(0xFF19B3F6),
          size: 100.w,
          borderWidth: 6.0,
        );
      case 8:
        return SpinKitPulse(
          color: Color(0xFF19B3F6),
          size: 80.w,
        );
      case 9:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitRing(
              color: Color(0xFF19B3F6),
              size: 60.w,
              lineWidth: 4.0,
            ),
            SizedBox(height: 10.h),
            Icon(
              Icons.trending_up,
              color: Color(0xFF19B3F6),
              size: 32.w,
            ),
          ],
        );
      default:
        return SpinKitFadingGrid(
          color: Color(0xFF19B3F6),
          size: 80.w,
          shape: BoxShape.circle,
        );
    }
  }

  Widget _buildElevatedIcon(String imagePath, {Color? color}) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Color(0xFFFBFBFC),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
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
          child: Image.asset(
            imagePath,
            width: 28.sp,
            height: 28.sp,
            color: color ?? Color(0xFF19B3F6),
          ),
        ),
      ),
    );
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
    final displayKeywords = _isRefreshing && _previousKeywords.isNotEmpty ? _previousKeywords : _keywords;

    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 헤더 + 디자인 (상단 고정된 부분)
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 7,
                    spreadRadius: 3,
                    offset: const Offset(0, 1),
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
                                  color: Color(0xFF19B3F6),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      spreadRadius: 0.5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text("로고",
                                    style: TextStyle(color: Colors.white, fontSize: 14)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "트렌들리",
                              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
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
                                  _buildElevatedIcon('assets/img/items/dark.png'),
                                  SizedBox(width: 8),
                                  _buildElevatedIcon('assets/img/items/alarm.png'),
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
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _isRefreshing ? null : () => _loadKeywords(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Color(0xFFFAFAFF),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
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
                                  child: Icon(Icons.refresh, size: 18.sp, color: Color(0xFF19B3F6)),
                                )
                                    : Icon(Icons.refresh, size: 18.sp, color: Color(0xFF4A4A4A)),
                                SizedBox(width: 4.w),
                                Text(
                                  _getFormattedTime(),
                                  style: TextStyle(fontSize: 14.sp, color: Color(0xFF4A4A4A)),
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
            sliver: SliverToBoxAdapter(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 기본 키워드 리스트 (이전 키워드 또는 현재 키워드)
                  Opacity(
                    opacity: _isRefreshing ? 0.3 : 1.0, // 로딩 중에는 흐리게 표시
                    child: _showShimmerEffect
                        ? _buildShimmerKeywordList(displayKeywords) // Shimmer 효과 적용된 리스트
                        : _buildKeywordList(displayKeywords), // 일반 리스트
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
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
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
                          Text(
                            "최신 트렌드로 새로고침 중...",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF19B3F6),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 선택된 키워드 요약
          if (_selectedKeyword != null)
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: SummaryBoxWidget(keyword: _selectedKeyword!),
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
                onTap: () => _selectKeyword(keywords[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  // 키워드 리스트 생성 함수 (별도로 분리)
  Widget _buildKeywordList(List<Keyword> keywords) {
    if (keywords.isEmpty) return SizedBox();

    // 애니메이션 사용 여부
    final bool useAnimation = _showKeywordAnimation && !_isRefreshing;

    return AnimationLimiter(
      child: Column(
        mainAxisSize: MainAxisSize.min, // 필요한 높이만 사용
        children: List.generate(
          keywords.length,
              (index) {
            final Widget keywordWidget = RepaintBoundary(
              child: KeywordBoxWidget(
                keyword: keywords[index],
                rank: index + 1,
                isSelected: _selectedKeyword?.id == keywords[index].id,
                onTap: () => _selectKeyword(keywords[index]),
              ),
            );

            // 애니메이션 적용 여부에 따라 다른 위젯 반환
            if (useAnimation) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: keywordWidget,
                  ),
                ),
              );
            } else {
              return keywordWidget;
            }
          },
        ),
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