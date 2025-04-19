import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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

  // 리스트만 로딩하기 위한 별도 상태 변수
  bool _isInitialLoading = true;
  bool _isRefreshing = false;

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

    _loadKeywords(isInitial: true);
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadKeywords({bool isInitial = false}) async {
    try {
      // isInitial이 true면 초기 로딩 상태, 그렇지 않으면 리프레싱 상태로 설정
      setState(() {
        if (isInitial) {
          _isInitialLoading = true;
        } else {
          _isRefreshing = true;
          // 리프레시 애니메이션 시작
          _refreshAnimationController.reset();
          _refreshAnimationController.forward();
        }
        _error = null;
      });

      final keywords = await _apiService.getCurrentKeywords();

      if (mounted) {
        setState(() {
          _keywords = keywords;
          _isInitialLoading = false;
          _isRefreshing = false;

          if (_selectedKeyword != null) {
            final selectedId = _selectedKeyword!.id;

            _selectedKeyword = _keywords.isNotEmpty
                ? _keywords.firstWhere(
                  (k) => k.id == selectedId,
              orElse: () => _keywords.first,
            )
                : null;
          }
          else if (_keywords.isNotEmpty) {
            _selectedKeyword = _keywords.first;
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

    if (_keywords.isEmpty) {
      return const Center(child: Text('표시할 키워드가 없습니다.'));
    }

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

          // 키워드 목록 리스트 (퍼포먼스 최적화) - 로딩 중일 때 쉬머 효과 또는 애니메이션 적용
          _isRefreshing
              ? _buildShimmerList()
              : AnimationLimiter(
            child: SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              sliver: SliverList.builder(
                itemCount: _keywords.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: RepaintBoundary(
                          child: KeywordBoxWidget(
                            keyword: _keywords[index],
                            rank: index + 1,
                            isSelected: _selectedKeyword?.id == _keywords[index].id,
                            onTap: () => _selectKeyword(_keywords[index]),
                          ),
                        ),
                      ),
                    ),
                  );
                },
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

  // 로딩 중일 때 표시할 쉬머 효과의 리스트
  Widget _buildShimmerList() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      sliver: SliverList.builder(
        itemCount: 10, // 기본 10개 아이템 표시
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: EdgeInsets.only(bottom: 1),
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: index == 9 ? null : Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 순위
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // 키워드
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 14.w, right: 6.w),
                      child: Container(
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // 변화 수치
                  Column(
                    children: [
                      Container(
                        width: 60,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        width: 60,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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