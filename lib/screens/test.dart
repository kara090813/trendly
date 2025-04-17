import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/api_service.dart';
import '../models/_models.dart';
import '../widgets/keywordBox_widget.dart';
import '../widgets/summaryBox_widget.dart';

class KeywordHomeComponent extends StatefulWidget {
  const KeywordHomeComponent({super.key});

  @override
  State<KeywordHomeComponent> createState() => _KeywordHomeComponentState();
}

class _KeywordHomeComponentState extends State<KeywordHomeComponent> {
  final ApiService _apiService = ApiService();
  List<Keyword> _keywords = [];
  bool _isLoading = true;
  String? _error;
  Keyword? _selectedKeyword;

  @override
  void initState() {
    super.initState();
    _loadKeywords();
  }

  Future<void> _loadKeywords() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final keywords = await _apiService.getCurrentKeywords();

      setState(() {
        _keywords = keywords;
        _isLoading = false;
        // 선택된 키워드가 있었다면 업데이트된 리스트에서 다시 찾기
        if (_selectedKeyword != null) {
          final int selectedId = _selectedKeyword!.id;
          try {
            _selectedKeyword = _keywords.firstWhere((k) => k.id == selectedId);
          } catch (e) {
            // 선택된 키워드가 리스트에 없으면 첫 번째 키워드 선택 (리스트가 비어있지 않은 경우)
            if (_keywords.isNotEmpty) {
              _selectedKeyword = _keywords.first;
            } else {
              _selectedKeyword = null;
            }
          }
        } else if (_keywords.isNotEmpty) {
          // 초기에 첫 번째 키워드 선택
          _selectedKeyword = _keywords.first;
        }
      });
    } catch (e) {
      setState(() {
        _error = '키워드를 불러오는 중 오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }

  void _selectKeyword(Keyword keyword) {
    setState(() {
      _selectedKeyword = keyword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // 헤더 (앱 이름, 시간, 테마 토글, 알림 아이콘)
          _buildHeader(),

          // 나머지 컨텐츠를 스크롤 가능하게 처리
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildErrorWidget()
                : _keywords.isEmpty
                ? const Center(child: Text('표시할 키워드가 없습니다.'))
                : RefreshIndicator(
              onRefresh: _loadKeywords,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 실시간 인기 검색어 컨테이너
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 실시간 인기 검색어 타이틀 및 시간
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Text(
                                  '실시간 인기 검색어',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                // 시간 표시
                                Row(
                                  children: [
                                    Icon(Icons.refresh,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getFormattedTime(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // 키워드 리스트 (스크롤 없이 전체 표시)
                          Column(
                            children: List.generate(
                              _keywords.length,
                                  (index) => KeywordBoxWidget(
                                keyword: _keywords[index],
                                rank: index + 1,
                                isSelected:
                                _selectedKeyword?.id == _keywords[index].id,
                                onTap: () => _selectKeyword(_keywords[index]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 선택된 키워드의 요약 정보
                    if (_selectedKeyword != null)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: SummaryBoxWidget(keyword: _selectedKeyword!),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _error!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadKeywords,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top:60.h,left: 10.w,right: 10.w),
      child: Row(
        children: [
          // 로고 또는 뒤로가기 버튼
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black54),
          ),

          const Spacer(),

          // 앱 이름
          const Text(
            '트렌들리',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          // 다크모드 토글
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.dark_mode, color: Colors.grey[600]),
          ),

          // 알림 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none, color: Colors.grey[600]),
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
