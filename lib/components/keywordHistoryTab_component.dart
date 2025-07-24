import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:async';
import '../app_theme.dart';
import '../widgets/_widgets.dart';
import '../services/api_service.dart';
import '../models/_models.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeywordHistoryTabComponent extends StatefulWidget {
  const KeywordHistoryTabComponent({Key? key}) : super(key: key);

  @override
  State<KeywordHistoryTabComponent> createState() => _KeywordHistoryTabComponentState();
}

class _KeywordHistoryTabComponentState extends State<KeywordHistoryTabComponent> 
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  
  // API 관련 변수
  final ApiService _apiService = ApiService();
  List<Keyword> _keywordHistory = [];
  bool _isLoading = false;
  String _selectedKeyword = '강선우'; // 기본 키워드
  String? _errorMessage;
  
  // 자동완성 관련 변수
  List<Map<String, dynamic>> _autocompleteResults = [];
  bool _isLoadingAutocomplete = false;
  List<Map<String, dynamic>> _popularKeywords = [];
  Timer? _debounceTimer;
  String _lastSearchQuery = '';
  
  // 검색 UI 상태 관리
  bool _isSearchFocused = false;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = []; // 최근 검색어
  
  // 페이징 관련
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  
  // 선택된 날짜의 상세 정보
  int? _selectedDateIndex;
  
  // 필터 상태 변수
  bool _showDailyBest = true; // false: 모든 데이터, true: 일별 대표 데이터
  String _sortBy = 'date'; // 'date': 날짜순, 'rank': 랭크순
  bool _sortAscending = false; // false: 내림차순, true: 오름차순
  DateTime? _startDate; // 시작 날짜
  DateTime? _endDate; // 종료 날짜
  int _maxRank = 10; // 최대 순위 (N위 이상만 보기)

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
    
    // 랜덤 키워드 로드 후 히스토리 로드
    _loadRandomKeywordAndHistory();
    // 인기 키워드 로드
    _loadPopularKeywords();
    // 최근 검색어 로드
    _loadRecentSearches();
    
    // 포커스 리스너 추가
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _debounceTimer?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// 랜덤 키워드 로드 후 히스토리 로드
  Future<void> _loadRandomKeywordAndHistory() async {
    try {
      // 랜덤 키워드 가져오기
      final randomKeywordData = await _apiService.getRandomKeyword();
      final randomKeyword = randomKeywordData['keyword'] as String;
      
      if (randomKeyword.isNotEmpty) {
        setState(() {
          _selectedKeyword = randomKeyword;
        });
        
        // 랜덤 키워드로 히스토리 로드
        _loadKeywordHistory();
      } else {
        // 랜덤 키워드를 가져오지 못한 경우 기본 키워드로 로드
        _loadKeywordHistory();
      }
    } catch (e) {
      print('Failed to load random keyword: $e');
      // 에러 발생 시 기본 키워드로 히스토리 로드
      _loadKeywordHistory();
    }
  }

  /// 키워드 히스토리 로드
  Future<void> _loadKeywordHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Keyword> history = await _apiService.getKeywordHistory(_selectedKeyword);
      setState(() {
        _keywordHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // 키워드 히스토리가 없는 경우 빈 리스트로 처리 (에러 메시지 표시하지 않음)
        if (e.toString().contains('해당 키워드의 히스토리가 존재하지 않습니다')) {
          _keywordHistory = [];
          _errorMessage = null; // 에러 메시지를 null로 설정하여 친화적인 UI 표시
        } else {
          _errorMessage = e.toString();
        }
        _isLoading = false;
      });
    }
  }

  /// 인기 키워드 로드
  Future<void> _loadPopularKeywords() async {
    try {
      final keywords = await _apiService.getPopularKeywords(limit: 20);
      setState(() {
        _popularKeywords = keywords;
      });
    } catch (e) {
      print('Failed to load popular keywords: $e');
    }
  }

  /// 최근 검색어 로드
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList('recent_keyword_searches') ?? [];
      setState(() {
        _recentSearches = searches;
      });
    } catch (e) {
      print('Failed to load recent searches: $e');
    }
  }

  /// 최근 검색어 저장
  Future<void> _saveRecentSearch(String keyword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = List<String>.from(_recentSearches);
      
      // 이미 있으면 제거 후 맨 앞에 추가
      searches.remove(keyword);
      searches.insert(0, keyword);
      
      // 최대 10개까지만 저장
      if (searches.length > 10) {
        searches.removeRange(10, searches.length);
      }
      
      await prefs.setStringList('recent_keyword_searches', searches);
      setState(() {
        _recentSearches = searches;
      });
    } catch (e) {
      print('Failed to save recent search: $e');
    }
  }

  /// 최근 검색어 삭제
  Future<void> _removeRecentSearch(String keyword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = List<String>.from(_recentSearches);
      searches.remove(keyword);
      
      await prefs.setStringList('recent_keyword_searches', searches);
      setState(() {
        _recentSearches = searches;
      });
    } catch (e) {
      print('Failed to remove recent search: $e');
    }
  }

  /// 최근 검색어 전체 삭제
  Future<void> _clearAllRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recent_keyword_searches', []);
      setState(() {
        _recentSearches = [];
      });
    } catch (e) {
      print('Failed to clear all recent searches: $e');
    }
  }

  /// 키워드 3줄 요약 모달 표시
  void _showKeywordSummaryModal(Keyword keyword) {
    final bool isDark = AppTheme.isDark(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(top: 100.h),
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 핸들바
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[600] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // 키워드 정보
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getRankGradient(keyword.rank),
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${keyword.rank}위',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          keyword.keyword,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  Text(
                    DateFormat('yyyy년 M월 d일').format(keyword.created_at),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // 3줄 요약 헤더
                  Row(
                    children: [
                      Container(
                        width: 3.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '3줄 요약',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // 3줄 요약 내용
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Color(0xFF0F172A).withOpacity(0.5)
                          : Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isDark 
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      children: _buildSummaryLines(keyword.type1, isDark),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // 닫기 버튼
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                        backgroundColor: isDark 
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      child: Text(
                        '닫기',
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 3줄 요약 라인들을 위젯으로 변환
  List<Widget> _buildSummaryLines(dynamic type1Data, bool isDark) {
    List<String> summaryLines = [];
    
    if (type1Data is List) {
      summaryLines = type1Data.map((item) => item.toString()).toList();
    } else if (type1Data is String) {
      summaryLines = type1Data.split('\n').where((line) => line.trim().isNotEmpty).toList();
    }
    
    if (summaryLines.isEmpty) {
      return [
        Text(
          '요약 정보가 없습니다.',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ];
    }
    
    return summaryLines.asMap().entries.map((entry) {
      final int index = entry.key;
      final String line = entry.value;
      
      return Container(
        margin: EdgeInsets.only(bottom: index < summaryLines.length - 1 ? 12.h : 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 4.h, right: 8.w),
              width: 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                line.trim(),
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.5,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  /// 자동완성 검색 (디바운싱 적용)
  void _searchAutocomplete(String query, [void Function(void Function())? modalSetState]) {
    print('🔍 [UI] _searchAutocomplete called with: "$query"');
    
    // 이전 타이머 취소
    _debounceTimer?.cancel();
    print('🔍 [UI] Previous timer cancelled');
    
    // 빈 문자열이면 결과 초기화
    if (query.trim().isEmpty) {
      print('🔍 [UI] Empty query, clearing results');
      setState(() {
        _autocompleteResults = [];
        _isLoadingAutocomplete = false;
        _lastSearchQuery = '';
      });
      if (modalSetState != null) modalSetState(() {});
      return;
    }
    
    // 같은 쿼리면 중복 요청 방지
    if (query.trim() == _lastSearchQuery) {
      print('🔍 [UI] Duplicate query prevented: "$query"');
      return;
    }
    
    // 최소 1글자 이상만 검색
    if (query.trim().length < 1) {
      print('🔍 [UI] Query too short (${query.trim().length} chars), clearing results');
      setState(() {
        _autocompleteResults = [];
        _isLoadingAutocomplete = false;
      });
      if (modalSetState != null) modalSetState(() {});
      return;
    }

    // 로딩 상태 시작
    print('🔍 [UI] Setting loading state to true');
    setState(() {
      _isLoadingAutocomplete = true;
    });
    if (modalSetState != null) modalSetState(() {});

    // 500ms 후 실제 검색 실행
    print('🔍 [UI] Starting 500ms timer for query: "${query.trim()}"');
    _debounceTimer = Timer(Duration(milliseconds: 500), () async {
      print('🔍 [UI] Timer fired, calling _performAutocompleteSearch');
      await _performAutocompleteSearch(query.trim(), modalSetState);
    });
  }

  /// 실제 자동완성 검색 수행
  Future<void> _performAutocompleteSearch(String query, [void Function(void Function())? modalSetState]) async {
    print('🔍 [UI] _performAutocompleteSearch starting for: "$query"');
    
    try {
      _lastSearchQuery = query;
      print('🔍 [UI] Set lastSearchQuery to: "$_lastSearchQuery"');
      
      print('🔍 [UI] Calling API...');
      final results = await _apiService.getKeywordAutocomplete(query, limit: 8);
      print('🔍 [UI] API call completed, results: $results');
      
      // 위젯이 여전히 마운트되어 있는지 확인
      if (!mounted) {
        print('🔍 [UI] Widget not mounted, skipping setState');
        return;
      }
      
      print('🔍 [UI] Setting results and loading=false');
      setState(() {
        _autocompleteResults = results;
        _isLoadingAutocomplete = false;
      });
      
      // 모달의 setState도 호출 (있다면)
      if (modalSetState != null) {
        print('🔍 [UI] Calling modal setState (success)');
        modalSetState(() {});
      }
      
      print('🔍 [UI] setState completed');
    } catch (e) {
      print('❌ [UI] Error in _performAutocompleteSearch: $e');
      
      // 위젯이 여전히 마운트되어 있는지 확인
      if (!mounted) {
        print('🔍 [UI] Widget not mounted after error, skipping setState');
        return;
      }
      
      print('🔍 [UI] Setting empty results and loading=false due to error');
      setState(() {
        _autocompleteResults = [];
        _isLoadingAutocomplete = false;
      });
      
      // 모달의 setState도 호출 (있다면)
      if (modalSetState != null) {
        print('🔍 [UI] Calling modal setState (error)');
        modalSetState(() {});
      }
      
      print('Failed to get autocomplete: $e');
    }
  }


  /// 키워드 변경 및 히스토리 재로드
  void _changeKeyword(String keyword) {
    setState(() {
      _selectedKeyword = keyword;
      _currentPage = 0;
      _selectedDateIndex = null;
      // 필터 초기화
      _showDailyBest = false;
      _sortBy = 'date';
      _sortAscending = false;
      _startDate = null;
      _endDate = null;
      _maxRank = 10;
    });
    
    // 최근 검색어에 저장
    _saveRecentSearch(keyword);
    _loadKeywordHistory();
  }

  /// 검색 실행
  void _performSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    
    // 자동완성 상태 초기화
    _debounceTimer?.cancel();
    setState(() {
      _selectedKeyword = keyword.trim();
      _autocompleteResults = [];
      _isLoadingAutocomplete = false;
      _lastSearchQuery = '';
      _isSearchFocused = false;
    });
    
    // 검색어를 텍스트 필드에 설정
    _searchController.text = keyword.trim();
    _searchFocusNode.unfocus();
    
    // 최근 검색어에 저장하고 히스토리 로드
    _saveRecentSearch(keyword.trim());
    _loadKeywordHistory();
  }

  /// 통계 계산
  Map<String, dynamic> _calculateStats() {
    if (_keywordHistory.isEmpty) {
      return {
        'firstAppearance': '-',
        'bestRank': '-',
        'averageRank': '-',
        'appearanceCount': 0,
        'categories': [],
      };
    }

    // 최초 등장일
    final firstAppearance = _keywordHistory.first.created_at;
    
    // 최고 순위
    final bestRank = _keywordHistory.map((k) => k.rank).reduce((a, b) => a < b ? a : b);
    
    // 평균 순위
    final averageRank = _keywordHistory.map((k) => k.rank).reduce((a, b) => a + b) / _keywordHistory.length;
    
    // 등장 횟수
    final appearanceCount = _keywordHistory.length;
    
    // 카테고리 (중복 제거) - 현재는 비어있음, 나중에 API에서 받아올 예정
    final categories = <String>[];

    return {
      'firstAppearance': DateFormat('yyyy년 M월 d일').format(firstAppearance),
      'bestRank': bestRank,
      'averageRank': averageRank.toStringAsFixed(1),
      'appearanceCount': appearanceCount,
      'categories': categories,
    };
  }

  /// 필터링된 데이터 가져오기
  List<Keyword> get _filteredHistory {
    List<Keyword> filtered = List.from(_keywordHistory);
    
    // 1. 순위 필터링 (N위 이상만)
    filtered = filtered.where((keyword) => keyword.rank <= _maxRank).toList();
    
    // 2. 날짜 필터링
    if (_startDate != null || _endDate != null) {
      filtered = filtered.where((keyword) {
        final date = keyword.created_at;
        if (_startDate != null && date.isBefore(_startDate!)) return false;
        if (_endDate != null && date.isAfter(_endDate!.add(Duration(days: 1)))) return false;
        return true;
      }).toList();
    }
    
    // 3. 일별 대표 데이터 필터링
    if (_showDailyBest) {
      final Map<String, List<Keyword>> dailyGroups = {};
      for (var keyword in filtered) {
        final dateKey = DateFormat('yyyy-MM-dd').format(keyword.created_at);
        dailyGroups[dateKey] ??= [];
        dailyGroups[dateKey]!.add(keyword);
      }
      
      filtered = [];
      for (var dayKeywords in dailyGroups.values) {
        // 해당 날짜의 최고 순위 키워드만 추가
        final bestKeyword = dayKeywords.reduce((a, b) => a.rank < b.rank ? a : b);
        filtered.add(bestKeyword);
      }
    }
    
    // 4. 정렬
    filtered.sort((a, b) {
      int comparison = 0;
      
      if (_sortBy == 'date') {
        comparison = a.created_at.compareTo(b.created_at);
      } else if (_sortBy == 'rank') {
        comparison = a.rank.compareTo(b.rank);
      }
      
      return _sortAscending ? comparison : -comparison;
    });
    
    return filtered;
  }
  
  /// 페이징된 데이터 가져오기
  List<Keyword> get _paginatedHistory {
    final filtered = _filteredHistory;
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  /// 총 페이지 수
  int get _totalPages => (_filteredHistory.length / _itemsPerPage).ceil();

  /// 새로운 검색 페이지로 이동
  void _openSearchPage() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _SearchPage(
          apiService: _apiService,
          popularKeywords: _popularKeywords,
          recentSearches: _recentSearches,
          onSearchSelected: _performSearch,
          onRemoveRecentSearch: _removeRecentSearch,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(
              begin: Offset(0.0, 1.0),
              end: Offset.zero,
            )),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }
  
  /// 필터 적용 및 페이지 초기화
  void _applyFilters() {
    setState(() {
      _currentPage = 0;
      _selectedDateIndex = null;
    });
  }

  /// 필터 모달 표시
  void _showFiltersModal() {
    final bool isDark = AppTheme.isDark(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.r),
                ),
              ),
              child: Column(
                children: [
                  // 모달 헤더
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '필터 설정',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 정렬 기준
                          _buildFilterSection(
                            '정렬 기준',
                            Container(
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildModalToggleButton(
                                    '날짜순',
                                    _sortBy == 'date',
                                    () => setModalState(() => _sortBy = 'date'),
                                    isFirst: true,
                                  ),
                                  _buildModalToggleButton(
                                    '랭크순',
                                    _sortBy == 'rank',
                                    () => setModalState(() => _sortBy = 'rank'),
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 24.h),
                          
                          // 정렬 방향
                          _buildFilterSection(
                            '정렬 방향',
                            Container(
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildModalToggleButton(
                                    '내림차순',
                                    !_sortAscending,
                                    () => setModalState(() => _sortAscending = false),
                                    isFirst: true,
                                  ),
                                  _buildModalToggleButton(
                                    '오름차순',
                                    _sortAscending,
                                    () => setModalState(() => _sortAscending = true),
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 24.h),
                          
                          // 날짜 범위
                          _buildFilterSection(
                            '날짜 범위',
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateButton(
                                        '시작 날짜',
                                        _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : '선택',
                                        () async {
                                          final DateTime? picked = await showDatePicker(
                                            context: context,
                                            initialDate: _startDate ?? DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime.now(),
                                            locale: Locale('ko', 'KR'),
                                          );
                                          if (picked != null) {
                                            setModalState(() => _startDate = picked);
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: _buildDateButton(
                                        '종료 날짜',
                                        _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : '선택',
                                        () async {
                                          final DateTime? picked = await showDatePicker(
                                            context: context,
                                            initialDate: _endDate ?? DateTime.now(),
                                            firstDate: _startDate ?? DateTime(2020),
                                            lastDate: DateTime.now(),
                                            locale: Locale('ko', 'KR'),
                                          );
                                          if (picked != null) {
                                            setModalState(() => _endDate = picked);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                if (_startDate != null || _endDate != null)
                                  GestureDetector(
                                    onTap: () => setModalState(() {
                                      _startDate = null;
                                      _endDate = null;
                                    }),
                                    child: Container(
                                      width: double.infinity,
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10.r),
                                        border: Border.all(
                                          color: Colors.orange.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '날짜 범위 초기화',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 24.h),
                          
                          // 순위 필터
                          _buildFilterSection(
                            '순위 필터',
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_maxRank}위 이상만 표시',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Color(0xFF3B82F6),
                                    inactiveTrackColor: Color(0xFF3B82F6).withOpacity(0.3),
                                    thumbColor: Color(0xFF3B82F6),
                                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                                    overlayColor: Color(0xFF3B82F6).withOpacity(0.3),
                                    overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
                                  ),
                                  child: Slider(
                                    value: _maxRank.toDouble(),
                                    min: 1,
                                    max: 10,
                                    divisions: 9,
                                    label: '${_maxRank}위',
                                    onChanged: (value) {
                                      setModalState(() => _maxRank = value.round());
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                  
                  // 버튼 영역
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _resetFilters();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              foregroundColor: AppTheme.getTextColor(context),
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              '초기화',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              _applyFilters();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              '적용',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 필터 섹션 빌더
  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.getTextColor(context),
          ),
        ),
        SizedBox(height: 12.h),
        content,
      ],
    );
  }

  /// 모달용 토글 버튼
  Widget _buildModalToggleButton(String text, bool isSelected, VoidCallback onTap, {bool isFirst = false, bool isLast = false}) {
    final bool isDark = AppTheme.isDark(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF3B82F6) : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? Radius.circular(10.r) : Radius.zero,
              right: isLast ? Radius.circular(10.r) : Radius.zero,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 날짜 버튼 빌더
  Widget _buildDateButton(String label, String value, VoidCallback onTap) {
    final bool isDark = AppTheme.isDark(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 필터 초기화
  void _resetFilters() {
    setState(() {
      _showDailyBest = true;
      _sortBy = 'date';
      _sortAscending = false;
      _startDate = null;
      _endDate = null;
      _maxRank = 10;
      _currentPage = 0;
      _selectedDateIndex = null;
    });
  }
  
  /// 날짜 범위 선택 다이얼로그
  Future<void> _showDateRangePicker() async {
    final bool isDark = AppTheme.isDark(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? tempStartDate = _startDate;
        DateTime? tempEndDate = _endDate;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Text(
                '날짜 범위 선택',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 시작 날짜
                  Text(
                    '시작 날짜',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: tempStartDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          tempStartDate = date;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: Color(0xFF3B82F6),
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            tempStartDate != null
                                ? DateFormat('yyyy년 M월 d일').format(tempStartDate!)
                                : '시작 날짜를 선택하세요',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: tempStartDate != null
                                  ? AppTheme.getTextColor(context)
                                  : (isDark ? Colors.grey[500] : Colors.grey[400]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // 종료 날짜
                  Text(
                    '종료 날짜',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: tempEndDate ?? DateTime.now(),
                        firstDate: tempStartDate ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          tempEndDate = date;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: Color(0xFF3B82F6),
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            tempEndDate != null
                                ? DateFormat('yyyy년 M월 d일').format(tempEndDate!)
                                : '종료 날짜를 선택하세요',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: tempEndDate != null
                                  ? AppTheme.getTextColor(context)
                                  : (isDark ? Colors.grey[500] : Colors.grey[400]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                    Navigator.of(context).pop();
                    _applyFilters();
                  },
                  child: Text(
                    '초기화',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _startDate = tempStartDate;
                      _endDate = tempEndDate;
                    });
                    Navigator.of(context).pop();
                    _applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    '적용',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
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
        
        // 플로팅 오브 효과
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
            // 키워드 선택 섹션
            SliverToBoxAdapter(
              child: _buildKeywordSelector(),
            ),
            
            // 키워드 통계 카드
            SliverToBoxAdapter(
              child: _buildKeywordStats(),
            ),
            
            // 키워드 맵 섹션
            SliverToBoxAdapter(
              child: _buildKeywordMap(),
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

  // 키워드 선택기
  Widget _buildKeywordSelector() {
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
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF8B5CF6).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.history_rounded,
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
                      "키워드 히스토리",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "키워드의 과거 순위 변화를 추적하고 분석하세요",
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
          
          // 키워드 검색 바
          _buildKeywordSearchBar(),
        ],
      ),
    );
  }

  // 키워드 검색 카드 (검색 필드 스타일)
  Widget _buildKeywordSearchBar() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      child: GestureDetector(
        onTap: _openSearchPage,
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
          child: Row(
            children: [
              
              // 검색 필드 (현재 검색 중인 키워드 표시)
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Color(0xFF0F172A).withOpacity(0.7)
                        : Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedKeyword.isNotEmpty 
                              ? _selectedKeyword 
                              : '키워드를 검색해보세요...',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: _selectedKeyword.isNotEmpty 
                                ? FontWeight.w600 
                                : FontWeight.w500,
                            color: _selectedKeyword.isNotEmpty
                                ? AppTheme.getTextColor(context)
                                : (isDark ? Colors.grey[400] : Colors.grey[500]),
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (_isLoading) ...[
                        SizedBox(width: 12.w),
                        SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                          ),
                        ),
                      ] else if (_selectedKeyword.isNotEmpty) ...[
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.search_rounded,
                          size: 24.sp,
                          color: Color(0xFF3B82F6),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 800.ms, delay: 200.ms)
        .slideY(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOutCubic)
        .scale(begin: Offset(0.95, 0.95), end: Offset(1, 1), duration: 800.ms, curve: Curves.easeOutCubic);
  }

  // 키워드 통계 카드
  Widget _buildKeywordStats() {
    final bool isDark = AppTheme.isDark(context);
    final stats = _calculateStats();
    
    if (_isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        height: 200.h,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
        ),
      );
    }
    
    if (_errorMessage != null) {
      // 실제 에러가 있는 경우 (네트워크 오류 등)
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    if (_keywordHistory.isEmpty) {
      // 키워드 히스토리가 없는 경우 - 친화적인 UI
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        padding: EdgeInsets.all(40.w),
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
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 아이콘
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6).withOpacity(0.1), Color(0xFF1D4ED8).withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.timeline_rounded,
                size: 32.sp,
                color: Color(0xFF3B82F6),
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // 메인 메시지
            Text(
              '아직 추적 중인 키워드에요',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextColor(context),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.h),
            
            // 설명
            Text(
              '"${_selectedKeyword}"의 히스토리 데이터를\n수집하고 있어요',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 20.h),
            
            // 다른 키워드 제안
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Color(0xFF10B981).withOpacity(0.2),
                ),
              ),
              child: Text(
                '💡 다른 트렌드 키워드를 검색해보세요',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
      ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
    }
    
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
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
                "키워드 통계",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.getTextColor(context),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ).animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 20.h),
          
          // 통계 카드
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.h,horizontal: 10.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Color(0xFF1E293B), Color(0xFF0F172A)]
                    : [Colors.white, Color(0xFFFAFAFA)],
              ),
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
              children: [
                // 첫 번째 줄 - 최초등장, 최고랭크
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.calendar_today_rounded,
                        label: "최초등장",
                        value: stats['firstAppearance'],
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 80.h,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.emoji_events_rounded,
                        label: "최고랭크",
                        value: "${stats['bestRank']}위",
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
                
                Container(
                  height: 1,
                  margin: EdgeInsets.symmetric(vertical: 16.h),
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                ),
                
                // 두 번째 줄 - 평균랭크, 등장횟수
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.analytics_rounded,
                        label: "평균랭크",
                        value: "${stats['averageRank']}위",
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 80.h,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.repeat_rounded,
                        label: "등장횟수",
                        value: "${stats['appearanceCount']}회",
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                
                // 카테고리 리스트 (현재 비어있음)
                if (stats['categories'].isNotEmpty) ...[
                  Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(vertical: 16.h),
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.category_rounded,
                        size: 20.sp,
                        color: Color(0xFFFF6B35),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "분류: ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 8.w,
                          children: stats['categories'].map<Widget>((category) {
                            return Chip(
                              label: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              backgroundColor: Color(0xFFFF6B35).withOpacity(0.2),
                              side: BorderSide.none,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  // 통계 아이템 위젯
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  // 키워드 맵 필터
  Widget _buildKeywordMapFilters() {
    final bool isDark = AppTheme.isDark(context);
    
    if (_keywordHistory.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 데이터 타입 선택
          Expanded(
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  _buildToggleButton(
                    '일별 최고순위',
                    _showDailyBest,
                    () {
                      setState(() {
                        _showDailyBest = true;
                      });
                      _applyFilters();
                    },
                    isFirst: true,
                  ),
                  _buildToggleButton(
                    '전체 기록',
                    !_showDailyBest,
                    () {
                      setState(() {
                        _showDailyBest = false;
                      });
                      _applyFilters();
                    },
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(width: 12.w),

          // 필터 버튼
          GestureDetector(
            onTap: _showFiltersModal,
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: _hasActiveFilters() 
                    ? Color(0xFF3B82F6) 
                    : (isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: _hasActiveFilters()
                      ? Colors.transparent
                      : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 16.sp,
                    color: _hasActiveFilters()
                        ? Colors.white
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '필터',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _hasActiveFilters()
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                  if (_hasActiveFilters()) ...[
                    SizedBox(width: 4.w),
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          SizedBox(width: 8.w),
          
          // 초기화 버튼
          if (_hasActiveFilters())
            GestureDetector(
              onTap: _resetFilters,
              child: Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 16.sp,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '초기화',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: 800.ms)
        .slideY(begin: 0.03, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  /// 활성 필터가 있는지 확인
  bool _hasActiveFilters() {
    return _sortBy != 'date' || 
           _sortAscending != false || 
           _startDate != null || 
           _endDate != null || 
           _maxRank != 10;
  }

  // 토글 버튼 헬퍼
  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap, {bool isFirst = false, bool isLast = false}) {
    final bool isDark = AppTheme.isDark(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF3B82F6) : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? Radius.circular(8.r) : Radius.zero,
              right: isLast ? Radius.circular(8.r) : Radius.zero,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 키워드 맵
  Widget _buildKeywordMap() {
    final bool isDark = AppTheme.isDark(context);
    
    if (_keywordHistory.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
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
                "키워드 맵",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.getTextColor(context),
                  letterSpacing: -0.5,
                ),
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${_currentPage + 1} / $_totalPages",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_filteredHistory.length != _keywordHistory.length)
                    Text(
                      "필터 적용됨",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ).animate()
              .fadeIn(duration: 600.ms, delay: 800.ms)
              .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 20.h),
          
          // 필터 섹션 (키워드 맵 제목 아래에 배치)
          _buildKeywordMapFilters(),

          
          // 키워드 카드 리스트 (모던 디자인)
          Column(
            children: [
              ..._paginatedHistory.asMap().entries.map((entry) {
                final index = entry.key;
                final keyword = entry.value;
                final globalIndex = _currentPage * _itemsPerPage + index;
                final isSelected = _selectedDateIndex == globalIndex;
                final isLast = index == _paginatedHistory.length - 1;
                
                return _buildKeywordCard(keyword, globalIndex, isSelected, isLast);
              }),
              
              // 페이징 컨트롤 (모던 디자인)
              if (_totalPages > 1)
                Container(
                  margin: EdgeInsets.only(top: 16.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : Colors.grey).withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentPage > 0 ? () {
                          setState(() {
                            _currentPage--;
                            _selectedDateIndex = null;
                          });
                        } : null,
                        icon: Icon(Icons.chevron_left_rounded),
                        color: _currentPage > 0 
                            ? Color(0xFF3B82F6) 
                            : (isDark ? Colors.grey[600] : Colors.grey[400]),
                      ),
                      SizedBox(width: 20.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          "${_currentPage + 1} / $_totalPages",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      IconButton(
                        onPressed: _currentPage < _totalPages - 1 ? () {
                          setState(() {
                            _currentPage++;
                            _selectedDateIndex = null;
                          });
                        } : null,
                        icon: Icon(Icons.chevron_right_rounded),
                        color: _currentPage < _totalPages - 1 
                            ? Color(0xFF3B82F6) 
                            : (isDark ? Colors.grey[600] : Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
            ],
          ).animate()
              .fadeIn(duration: 600.ms, delay: 1000.ms)
              .slideY(begin: 0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  // 개별 키워드 카드 (모던 디자인)
  Widget _buildKeywordCard(Keyword keyword, int globalIndex, bool isSelected, bool isLast) {
    final bool isDark = AppTheme.isDark(context);
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: isSelected 
            ? (isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC))
            : (isDark ? Color(0xFF1E293B).withOpacity(0.5) : Colors.white),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected
              ? Color(0xFF3B82F6).withOpacity(0.5)
              : (isDark ? Colors.white : Colors.black).withOpacity(0.08),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? Color(0xFF3B82F6).withOpacity(0.1)
                : (isDark ? Colors.black : Colors.grey).withOpacity(0.05),
            blurRadius: isSelected ? 12 : 8,
            offset: Offset(0, isSelected ? 4 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 키워드 카드 클릭 시 선택 상태만 변경 (모달 표시하지 않음)
            setState(() {
              _selectedDateIndex = isSelected ? null : globalIndex;
            });
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  children: [
                    // 순위 태그 (간결하게)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getRankGradient(keyword.rank),
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: _getRankGradient(keyword.rank).first.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${keyword.rank}위',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 12.w),
                    
                    // 키워드 이름
                    Expanded(
                      child: Text(
                        keyword.keyword,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getTextColor(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // 토글 아이콘
                    AnimatedRotation(
                      turns: isSelected ? 0.5 : 0,
                      duration: Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8.h),
                
                // 날짜-시간 한줄 표시
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    SizedBox(width: 6.w),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          // 연도 부분 (2025.)
                          TextSpan(
                            text: DateFormat('yyyy.').format(keyword.created_at),
                          ),
                          // 월/일 부분 (07.16) - 두껍게, 더 진한 색
                          TextSpan(
                            text: DateFormat('MM.dd').format(keyword.created_at),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getTextColor(context),
                            ),
                          ),
                          // 시간 부분 ( 23:00)
                          TextSpan(
                            text: ' ${DateFormat('HH:mm').format(keyword.created_at)}',
                          ),
                        ],
                      ),
                    ),
                    if (keyword.category != null) ...[
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          keyword.category ?? '',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                // type1 요약 표시 (선택되었을 때만)
                if (isSelected && keyword.type1 != null) ...[
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.white.withOpacity(0.05)
                          : Color(0xFF3B82F6).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Color(0xFF3B82F6).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 3.w,
                              height: 16.h,
                              decoration: BoxDecoration(
                                color: Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '3줄 요약',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        // type1이 List인 경우와 String인 경우 모두 처리
                        if (keyword.type1 is List)
                          ...List.generate(
                            (keyword.type1 as List).length,
                            (index) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '•',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      (keyword.type1 as List)[index].toString(),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Text(
                            keyword.type1.toString(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.1, end: 0, duration: 300.ms),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 순위에 따른 그라데이션 색상
  List<Color> _getRankGradient(int rank) {
    switch (rank) {
      case 1:
        return [Color(0xFFFFD700), Color(0xFFFFA500)]; // 금색
      case 2:
        return [Color(0xFFC0C0C0), Color(0xFF808080)]; // 은색
      case 3:
        return [Color(0xFFCD7F32), Color(0xFF8B4513)]; // 동색
      default:
        return [Color(0xFF6B7280), Color(0xFF4B5563)]; // 회색
    }
  }
}

/// 새로운 검색 페이지 (네이버 스타일)
class _SearchPage extends StatefulWidget {
  final ApiService apiService;
  final List<Map<String, dynamic>> popularKeywords;
  final List<String> recentSearches;
  final Function(String) onSearchSelected;
  final Function(String) onRemoveRecentSearch;

  const _SearchPage({
    required this.apiService,
    required this.popularKeywords,
    required this.recentSearches,
    required this.onSearchSelected,
    required this.onRemoveRecentSearch,
  });

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> _autocompleteResults = [];
  bool _isLoadingAutocomplete = false;
  Timer? _debounceTimer;
  String _lastSearchQuery = '';
  late List<String> _localRecentSearches;

  @override
  void initState() {
    super.initState();
    // 자동 포커스 비활성화 - 사용자가 직접 클릭해야 함
    _localRecentSearches = List<String>.from(widget.recentSearches);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// 자동완성 검색
  void _searchAutocomplete(String query) {
    _debounceTimer?.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _autocompleteResults = [];
        _isLoadingAutocomplete = false;
        _lastSearchQuery = '';
      });
      return;
    }
    
    if (query.trim() == _lastSearchQuery || query.trim().length < 1) {
      return;
    }

    setState(() {
      _isLoadingAutocomplete = true;
    });

    _debounceTimer = Timer(Duration(milliseconds: 300), () async {
      await _performAutocompleteSearch(query.trim());
    });
  }

  /// 실제 자동완성 검색 수행
  Future<void> _performAutocompleteSearch(String query) async {
    try {
      _lastSearchQuery = query;
      final results = await widget.apiService.getKeywordAutocomplete(query, limit: 8);
      
      if (!mounted) return;
      
      setState(() {
        _autocompleteResults = results;
        _isLoadingAutocomplete = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _autocompleteResults = [];
        _isLoadingAutocomplete = false;
      });
    }
  }

  /// 검색 실행
  void _performSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    widget.onSearchSelected(keyword.trim());
    Navigator.pop(context);
  }

  /// 로컬 최근 검색어 삭제 (실시간 반영)
  void _removeLocalRecentSearch(String keyword) {
    setState(() {
      _localRecentSearches.remove(keyword);
    });
    // 부모 컴포넌트의 상태도 업데이트
    widget.onRemoveRecentSearch(keyword);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final hasKeyboard = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 배경 그라데이션 (기존 페이지와 동일)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
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
          
          SafeArea(
            child: Column(
              children: [
                // 상단 헤더 영역 (뒤로가기 + 제목)
                Container(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                  child: Row(
                    children: [
                      // 뒤로가기 버튼 (미니멀 디자인)
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: isDark ? Colors.white : Colors.black87,
                            size: 20.sp,
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 16.w),
                      
                      // 제목
                      Text(
                        '키워드 검색',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 검색 필드 영역 (분리된 디자인)
                Container(
                  margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Color(0xFF1E293B)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: _focusNode.hasFocus
                          ? Color(0xFF3B82F6)
                          : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
                      width: _focusNode.hasFocus ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _focusNode.hasFocus 
                            ? Color(0xFF3B82F6).withOpacity(0.1)
                            : (isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04)),
                        blurRadius: _focusNode.hasFocus ? 20 : 8,
                        offset: Offset(0, _focusNode.hasFocus ? 6 : 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 검색 아이콘
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Icon(
                          Icons.search_rounded,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 24.sp,
                        ),
                      ),
                      
                      // 검색 텍스트 필드
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getTextColor(context),
                              height: 1.4,
                            ),
                            decoration: InputDecoration(
                              hintText: '키워드를 검색해보세요...',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: _searchAutocomplete,
                            onSubmitted: _performSearch,
                          ),
                        ),
                      ),
                      
                      // 클리어 버튼
                      if (_controller.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() {
                              _autocompleteResults = [];
                              _isLoadingAutocomplete = false;
                              _lastSearchQuery = '';
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Icon(
                              Icons.clear_rounded,
                              color: isDark ? Colors.grey[400] : Colors.grey[500],
                              size: 20.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            
            // 메인 콘텐츠
            Expanded(
              child: _controller.text.isNotEmpty && _focusNode.hasFocus
                  ? _buildAutocompleteResults(isDark)
                  : _buildInitialContent(isDark, hasKeyboard),
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  /// 자동완성 결과 영역
  Widget _buildAutocompleteResults(bool isDark) {
    if (_isLoadingAutocomplete) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32.w,
              height: 32.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              '검색 중...',
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_autocompleteResults.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80.h, horizontal: 40.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 검색 결과 없음 아이콘 (그라데이션 배경)
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [Color(0xFF374151).withOpacity(0.3), Color(0xFF1F2937).withOpacity(0.1)]
                        : [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 48.sp,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // 메인 메시지
              Text(
                '검색 결과를 찾을 수 없어요',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getTextColor(context),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 12.h),
              
              // 부가 설명
              Text(
                '다른 키워드로 검색하거나\n철자를 확인해 보세요',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 32.h),
              
              // 인기 검색어 제안 (간단한 버전)
              if (widget.popularKeywords.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Color(0xFF374151).withOpacity(0.2)
                        : Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark 
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.06),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '💡 인기 검색어를 확인해보세요',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        children: widget.popularKeywords.take(3).map((keyword) {
                          final keywordText = keyword['keyword'] as String;
                          return GestureDetector(
                            onTap: () => _performSearch(keywordText),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: Color(0xFF3B82F6).withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                keywordText,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _autocompleteResults.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
        indent: 60.w,
      ),
      itemBuilder: (context, index) {
        final result = _autocompleteResults[index];
        final keyword = result['keyword'] as String;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _performSearch(keyword),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  // 검색 아이콘
                  Icon(
                    Icons.search_rounded,
                    size: 20.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                  
                  SizedBox(width: 16.w),
                  
                  // 키워드 텍스트
                  Expanded(
                    child: Text(
                      keyword,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 초기 콘텐츠 (인기 키워드, 최근 검색어)
  Widget _buildInitialContent(bool isDark, bool hasKeyboard) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        // 최근 검색어 (키보드가 없을 때만 표시)
        if (!hasKeyboard && _localRecentSearches.isNotEmpty) ...[
          // 섹션 헤더 (기존 스타일과 통일)
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
              Expanded(
                child: Text(
                  "최근 검색어",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getTextColor(context),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // 전체 삭제 확인 다이얼로그
                  final bool? confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        title: Text(
                          '최근 검색어 전체 삭제',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                        content: Text(
                          '모든 최근 검색어를 삭제하시겠습니까?',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              '취소',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              '삭제',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  
                  if (confirmed == true) {
                    // 전체 삭제 실행
                    setState(() {
                      _localRecentSearches = [];
                    });
                    // SharedPreferences에서도 삭제
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setStringList('recent_keyword_searches', []);
                  }
                },
                child: Text(
                  '전체삭제',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ).animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          SizedBox(height: 20.h),
          ..._localRecentSearches.take(3).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final keyword = entry.value;
            
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Color(0xFF1E293B), Color(0xFF0F172A)]
                      : [Colors.white, Color(0xFFFAFAFA)],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey).withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _performSearch(keyword),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Color(0xFF10B981).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.history_rounded,
                            size: 16.sp,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            keyword,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextColor(context),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _removeLocalRecentSearch(keyword),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14.sp,
                              color: isDark ? Colors.grey[400] : Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate()
                .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
          }).toList(),
          SizedBox(height: 32.h),
        ],
        
        // 인기 키워드 (키보드가 없을 때만 표시)
        if (!hasKeyboard && widget.popularKeywords.isNotEmpty) ...[
          // 섹션 헤더 (기존 스타일과 통일)
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
                "인기 검색어",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.getTextColor(context),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ).animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.popularKeywords.take(10).map((keywordData) {
              final keyword = keywordData['keyword'] as String;
              final searchCount = keywordData['search_count'] as int;
              final index = widget.popularKeywords.indexOf(keywordData);
              
              return GestureDetector(
                onTap: () => _performSearch(keyword),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [Color(0xFF1E293B), Color(0xFF0F172A)]
                          : [Colors.white, Color(0xFFF8FAFC)],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : Colors.grey).withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getRankGradient(index + 1),
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getRankGradient(index + 1).first.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(
                        Icons.trending_up_rounded,
                        size: 14.sp,
                        color: Color(0xFF3B82F6),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        keyword,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      if (searchCount > 0) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '${searchCount}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate()
                  .fadeIn(duration: 400.ms, delay: (index * 80).ms)
                  .scale(begin: Offset(0.8, 0.8), end: Offset(1, 1), duration: 500.ms, curve: Curves.easeOutCubic);
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// 순위별 그라데이션 색상 반환 (기존 메소드 재사용)
  List<Color> _getRankGradient(int rank) {
    switch (rank) {
      case 1:
        return [Color(0xFFFFD700), Color(0xFFFFA500)]; // 금색
      case 2:
        return [Color(0xFFC0C0C0), Color(0xFF808080)]; // 은색
      case 3:
        return [Color(0xFFCD7F32), Color(0xFF8B4513)]; // 동색
      default:
        return [Color(0xFF3B82F6), Color(0xFF1D4ED8)]; // 파란색
    }
  }
}