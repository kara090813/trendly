import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/_models.dart';

/// ApiService 클래스
/// API 통신과 관련된 모든 메서드를 포함하고 있습니다.
class ApiService {
  // 기본 API URL
  static const String _baseUrl = 'https://trendly.servehttp.com:10443/api';
  // static const String _baseUrl = 'http://localhost:8000/api';

  // 싱글톤 패턴 구현
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP 클라이언트
  final http.Client _client = http.Client();

  // 공통 헤더 설정
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// 현재 1~10위 실시간 키워드 목록 가져오기
  /// GET /keyword/now/
  Future<List<Keyword>> getCurrentKeywords() async {
    final String url = '$_baseUrl/keyword/now/';
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        
        // null 값들을 안전하게 처리
        return data.map((json) {
          final Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
          
          // null 값들을 기본값으로 처리
          safeJson['type2'] = safeJson['type2'] ?? '';
          safeJson['type3'] = safeJson['type3'] ?? '';
          safeJson['category'] = safeJson['category'] ?? '기타';
          safeJson['type1'] = safeJson['type1'] ?? [];
          safeJson['references'] = safeJson['references'] ?? {};
          
          return Keyword.fromJson(safeJson);
        }).toList();
      } else {
        throw Exception('Failed to load current keywords: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 특정 키워드 ID로 상세 정보 가져오기
  /// GET /keyword/get/<int:keyword_id>/
  Future<Keyword> getKeywordById(int keywordId) async {
    final String url = '$_baseUrl/keyword/get/$keywordId/';
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        
        // null 값들을 안전하게 처리
        final Map<String, dynamic> safeData = Map<String, dynamic>.from(data);
        safeData['type2'] = safeData['type2'] ?? '';
        safeData['type3'] = safeData['type3'] ?? '';
        safeData['category'] = safeData['category'] ?? '기타';
        safeData['type1'] = safeData['type1'] ?? [];
        safeData['references'] = safeData['references'] ?? {};
        
        return Keyword.fromJson(safeData);
      } else {
        throw Exception('Failed to load keyword: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 키워드 검색 - 키워드 이름과 시간 범위로 키워드 ID 목록 가져오기
  /// POST /keyword/search/
  Future<List<int>> searchKeywordIds(String keyword, DateTime startTime, DateTime endTime) async {
    final String url = '$_baseUrl';
    return Future.value([]);
  }

  /// 여러 키워드 ID로 키워드 정보 가져오기
  /// POST /keyword/get_keyword_many/
  Future<List<Keyword>> getKeywordsByIds(List<int> idList) async {
    final String url = '$_baseUrl';
    return Future.value([]);
  }

  /// 특정 시점의 1~10 키워드 가져오기 (타임머신 기능)
  /// GET /keyword/time_machine/<str:time>/
  Future<List<Keyword>> getKeywordsByTime(DateTime date) async {
    final String url = '$_baseUrl';
    return Future.value([]);
  }

  /// 임의의 키워드 히스토리 가져오기
  /// GET /random_keyword_history/
  Future<Map<String, dynamic>> getRandomKeywordHistory() async {
    final String url = '$_baseUrl';
    return Future.value({});
  }

  /// 특정 키워드의 히스토리 가져오기
  /// POST /keyword/history/
  Future<List<Keyword>> getKeywordHistory(String keyword) async {
    final String url = '$_baseUrl/keyword/history/';
    
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode({
          'keyword': keyword,
        }),
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        
        // null 값들을 안전하게 처리
        return data.map((json) {
          final Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
          
          // null 값들을 기본값으로 처리
          safeJson['type2'] = safeJson['type2'] ?? '';
          safeJson['type3'] = safeJson['type3'] ?? '';
          safeJson['category'] = safeJson['category'] ?? '기타';
          safeJson['type1'] = safeJson['type1'] ?? [];
          safeJson['references'] = safeJson['references'] ?? {};
          
          return Keyword.fromJson(safeJson);
        }).toList();
      } else if (response.statusCode == 404) {
        throw Exception('해당 키워드의 히스토리가 존재하지 않습니다.');
      } else {
        throw Exception('Failed to load keyword history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 임의의 키워드 n개 가져오기
  /// GET /keyword/random/<int:count>/
  Future<List<Keyword>> getRandomKeywords(int count) async {
    final String url = '$_baseUrl';
    return Future.value([]);
  }

  /// 키워드 간략 히스토리 가져오기
  /// POST /keyword/history_simple/
  Future<Map<String, dynamic>> getKeywordHistorySimple(String keyword, String period) async {
    final String url = '$_baseUrl';
    return Future.value({});
  }

  /// 토론방 수량 조회
  /// GET /discussion/count/<str:option>
  Future<int> getDiscussionCountByOption(String option) async {
    final String url = '$_baseUrl';
    return Future.value(0);
  }

  /// 토론방 페이징 조회
  /// GET /discussion/paging?option=N&sort=(new|pop)&page=N
  Future<List<DiscussionRoom>> getDiscussionRoomsPaging({
    required int option, // 0=all, 1=open, 2=closed
    required String sort, // new=갱신시각순, pop=(댓글+긍정)순
    required int page,
  }) async {
    final String url = '$_baseUrl';
    return Future.value([]);
  }

  /// 특정 날짜의 키워드 그룹 가져오기
  /// GET /keyword/date_groups/<str:datestr>/
  Future<Map<String, dynamic>> getKeywordDateGroups(String dateStr) async {
    final String url = '$_baseUrl';
    return Future.value({});
  }

  /// 특정 날짜의 일일 요약 가져오기
  /// GET /keyword/daily_summary/<str:datestr>/
  Future<Map<String, dynamic>> getKeywordDailySummary(String dateStr) async {
    final String url = '$_baseUrl';
    return Future.value({});
  }

  /// 현재 인기 키워드와 관련된 토론방 목록 가져오기
  /// GET /discussion/now/
  Future<List<DiscussionRoom>> getCurrentDiscussionRooms() async {
    final String url = '$_baseUrl';
    return Future.value([]);
  }

  /// 활성화된 토론방 목록 가져오기 (is_closed가 False인 토론방)
  /// GET /discussion/active?sort=[new|pop]&page=N&category=all
  Future<List<DiscussionRoom>> getActiveDiscussionRooms({
    String? sort, // 'new' or 'pop', null for default
    int page = 1,
    String category = 'all',
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'category': category,
    };
    
    if (sort != null) {
      queryParams['sort'] = sort;
    }
    
    final String url = Uri.parse('$_baseUrl/discussion/active')
        .replace(queryParameters: queryParams)
        .toString();
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => DiscussionRoom.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load active discussion rooms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 활성화된 토론방의 카테고리 목록 가져오기
  /// GET /discussion/category/
  Future<List<String>> getDiscussionCategories() async {
    final String url = '$_baseUrl/discussion/category/';
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.cast<String>();
      } else {
        throw Exception('Failed to load discussion categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 토론방 개수 가져오기
  /// GET /discussion/count?isActive=[true|false]&category=all
  Future<int> getDiscussionCount({
    bool isActive = true,
    String category = 'all',
  }) async {
    final Map<String, String> queryParams = {
      'isActive': isActive.toString(),
      'category': category,
    };
    
    final String url = Uri.parse('$_baseUrl/discussion/count')
        .replace(queryParameters: queryParams)
        .toString();
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return json.decode(decodedBody) as int;
      } else {
        throw Exception('Failed to load discussion count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 인기 토론방 목록 가져오기 (active 상태인 토론방 10개)
  /// GET /discussion/hot/
  Future<List<DiscussionRoom>> getHotDiscussionRooms() async {
    final String url = '$_baseUrl/discussion/hot/';
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => DiscussionRoom.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load hot discussion rooms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 전체 토론방 목록 가져오기
  /// GET /discussion/all?page=N
  Future<List<DiscussionRoom>> getAllDiscussionRooms({int page = 0}) async {
    final String url = '$_baseUrl';
    return Future.value([]);
  }

  /// 랜덤 토론방 가져오기
  /// GET /discussion/get_random/<int:count>/<int:option>/
  Future<List<DiscussionRoom>> getRandomDiscussionRooms(int count, {int option = 1}) async {
    final String url = '$_baseUrl';
    return Future.value([]);
  }

  /// 특정 토론방 정보 가져오기
  /// GET /discussion/get/<int:discussion_room_id>/
  Future<DiscussionRoom> getDiscussionRoomById(int roomId) async {
    final String url = '$_baseUrl/discussion/get/$roomId/';
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        return DiscussionRoom.fromJson(data);
      } else {
        throw Exception('Failed to load discussion room: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 토론방 ID로 최신 키워드 가져오기
  /// GET /discussion/get-latest-keyword-by-room-id/<int:discussion_room_id>/
  Future<Keyword> getLatestKeywordByDiscussionRoomId(int roomId) async {
    final String url = '$_baseUrl';
    return Future.error('Not implemented');
  }

  /// 특정 키워드 토론방 가져오기
  /// POST /discussion/
  Future<DiscussionRoom> getDiscussionRoomByKeyword(String keywordName) async {
    final String url = '$_baseUrl';
    return Future.error('Not implemented');
  }

  /// 해당 토론방 댓글 가져오기 (최신순 또는 인기순)
  /// GET /discussion/<room_id>/get_comment/[new/pop]
  Future<List<Comment>> getDiscussionComments(int roomId, {bool isPopular = false}) async {
    final String url = isPopular 
        ? '$_baseUrl/discussion/$roomId/get_comment/pop'
        : '$_baseUrl/discussion/$roomId/get_comment/';
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 특정 댓글의 서브댓글 가져오기
  /// GET /discussion/subcomment/<int:parent_comment_id>/[new/pop]/
  Future<List<Comment>> getSubComments(int parentCommentId, {bool isPopular = false}) async {
    final String url = isPopular 
        ? '$_baseUrl/discussion/subcomment/$parentCommentId/pop'
        : '$_baseUrl/discussion/subcomment/$parentCommentId/new';
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sub comments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 댓글 작성하기
  /// POST /discussion/<room_id>/add_comment/
  Future<bool> addComment(int roomId, String user, String password, String nick, String comment,
      {bool isSubComment = false, int? parentId}) async {
    final String url = '$_baseUrl/discussion/$roomId/add_comment/';
    
    try {
      Map<String, dynamic> requestBody = {
        'discussion_room': roomId,
        'user': user,
        'password': password,
        'nick': nick,
        'comment': comment,
        'is_sub_comment': isSubComment,
      };
      
      if (isSubComment && parentId != null) {
        requestBody['parent'] = parentId;
      }
      
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 댓글 삭제하기
  /// POST /discussion/<room_id>/del_comment/
  Future<bool> deleteComment(int roomId, int commentId, String password) async {
    final String url = '$_baseUrl/discussion/$roomId/del_comment/';
    
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode({
          'comment_id': commentId,
          'password': password,
        }),
      );
      
      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete comment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 토론방 감정 반응 설정
  /// POST /discussion/<int:discussion_room_id>/sentiment/
  Future<bool> setDiscussionSentiment(int discussionRoomId, String positive, String neutral, String negative) async {
    final String url = '$_baseUrl/discussion/$discussionRoomId/sentiment/';
    
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode({
          'positive': positive,
          'neutral': neutral,
          'negative': negative,
        }),
      );
      
      if (response.statusCode == 202) {
        return true;
      } else {
        throw Exception('Failed to set discussion sentiment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 특정 댓글 ID로 댓글 정보 가져오기
  /// GET /comment/<int:comment_id>/
  Future<Comment> getCommentById(int commentId) async {
    final String url = '$_baseUrl/comment/$commentId/';
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        return Comment.fromJson(data);
      } else {
        throw Exception('Failed to load comment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 댓글 추천 +1
  /// POST /comment/<int:comment_id>/like/
  Future<bool> likeComment(int commentId, {bool isCancel = false}) async {
    final String url = '$_baseUrl/comment/$commentId/like/';
    
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode({
          'is_cancel': isCancel,
        }),
      );
      
      if (response.statusCode == 202) {
        return true;
      } else if (response.statusCode == 400) {
        return false;
      } else {
        throw Exception('Failed to like comment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 댓글 비추천 +1
  /// POST /comment/<int:comment_id>/dislike/
  Future<bool> dislikeComment(int commentId, {bool isCancel = false}) async {
    final String url = '$_baseUrl/comment/$commentId/dislike/';
    
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode({
          'is_cancel': isCancel,
        }),
      );
      
      if (response.statusCode == 202) {
        return true;
      } else {
        throw Exception('Failed to dislike comment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 관심 키워드 저장 (로컬 저장소 활용)
  Future<bool> saveInterestKeyword(String keyword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedKeywords = prefs.getStringList('interest_keywords') ?? [];

      if (!savedKeywords.contains(keyword)) {
        savedKeywords.add(keyword);
        await prefs.setStringList('interest_keywords', savedKeywords);
      }

      return true;
    } catch (e) {
      print('관심 키워드 저장 오류: $e');
      print('저장하려는 키워드: $keyword');
      return false;
    }
  }

  /// 관심 키워드 제거
  Future<bool> removeInterestKeyword(String keyword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedKeywords = prefs.getStringList('interest_keywords') ?? [];

      if (savedKeywords.contains(keyword)) {
        savedKeywords.remove(keyword);
        await prefs.setStringList('interest_keywords', savedKeywords);
      }

      return true;
    } catch (e) {
      print('관심 키워드 제거 오류: $e');
      print('제거하려는 키워드: $keyword');
      return false;
    }
  }

  /// 관심 키워드 목록 가져오기
  Future<List<String>> getInterestKeywords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('interest_keywords') ?? [];
    } catch (e) {
      print('관심 키워드 가져오기 오류: $e');
      return [];
    }
  }

  /// 키워드 자동완성
  /// GET /api/keywords/autocomplete/
  Future<List<Map<String, dynamic>>> getKeywordAutocomplete(String query, {int limit = 10}) async {
    print('🔍 [AUTO] Starting autocomplete search for: "$query"');
    
    final Map<String, String> queryParams = {
      'q': query,
      'limit': limit.toString(),
    };
    
    final String url = Uri.parse('$_baseUrl/keywords/autocomplete/')
        .replace(queryParameters: queryParams)
        .toString();
    
    print('🔍 [AUTO] Request URL: $url');
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      print('🔍 [AUTO] Response status: ${response.statusCode}');
      print('🔍 [AUTO] Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        final List<dynamic> suggestions = data['suggestions'] ?? [];
        
        print('🔍 [AUTO] Parsed suggestions count: ${suggestions.length}');
        
        final results = suggestions.map((item) => {
          'keyword': (item['keyword'] ?? '').toString(),
          'search_count': (item['search_count'] ?? 0) as int,
        }).toList();
        
        print('🔍 [AUTO] Final results: $results');
        return results;
      } else {
        print('❌ [AUTO] API Error - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to get autocomplete: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [AUTO] Network error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// 인기 검색어 조회
  /// GET /api/keywords/popular/
  Future<List<Map<String, dynamic>>> getPopularKeywords({int limit = 100}) async {
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
    };
    
    final String url = Uri.parse('$_baseUrl/keywords/popular/')
        .replace(queryParameters: queryParams)
        .toString();
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        final List<dynamic> keywords = data['keywords'] ?? [];
        
        return keywords.map((item) => {
          'keyword': (item['keyword'] ?? '').toString(),
          'search_count': (item['search_count'] ?? 0) as int,
        }).toList();
      } else {
        throw Exception('Failed to get popular keywords: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 특정 날짜의 키워드 캡슐 데이터 조회
  /// GET /api/capsule/<str:date_str>/
  Future<CapsuleModel> getCapsule(String dateStr) async {
    final String url = '$_baseUrl/capsule/$dateStr/';
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        
        // 디버깅을 위한 로깅
        print('API Response: $data');
        
        // 필수 필드 확인 및 기본값 설정
        final top3Keywords = (data['top3_keywords'] as List<dynamic>?)
            ?.map((item) => {
                  'keyword': item['keyword']?.toString() ?? '',
                  'score': (item['score'] as num?)?.toDouble() ?? 0.0,
                  'appearance_count': (item['appearance_count'] as num?)?.toInt() ?? 0,
                  'avg_rank': (item['avg_rank'] as num?)?.toDouble() ?? 0.0,
                  'last_keyword_id': item['last_keyword_id'] as int?,
                })
            .toList() ?? [];
        
        final hourlyKeywords = (data['hourly_keywords'] as List<dynamic>?)
            ?.map((item) => {
                  'time': item['time']?.toString() ?? '00:00',
                  'keywords': (item['keywords'] as List<dynamic>?)
                      ?.map((keywordItem) {
                        if (keywordItem is String) {
                          // 간단한 문자열 형태의 키워드
                          return {
                            'id': 0,
                            'keyword': keywordItem,
                            'rank': 1,
                            'category': '기타',
                            'type2': null,
                          };
                        } else if (keywordItem is Map<String, dynamic>) {
                          // 복잡한 객체 형태의 키워드
                          return {
                            'id': keywordItem['id'] ?? 0,
                            'keyword': keywordItem['keyword']?.toString() ?? '',
                            'rank': keywordItem['rank'] ?? 1,
                            'category': keywordItem['category']?.toString() ?? '기타',
                            'type2': keywordItem['type2']?.toString(),
                          };
                        }
                        return {
                          'id': 0,
                          'keyword': keywordItem.toString(),
                          'rank': 1,
                          'category': '기타',
                          'type2': null,
                        };
                      })
                      .toList() ?? [],
                })
            .toList() ?? [];
        
        final capsuleData = {
          'date': data['date']?.toString() ?? dateStr,
          'top3_keywords': top3Keywords,
          'hourly_keywords': hourlyKeywords,
          'created_at': data['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        };
        
        return CapsuleModel.fromJson(capsuleData);
      } else if (response.statusCode == 404) {
        // 404 오류 처리 - 실제 API 오류 확인
        final String decodedBody = utf8.decode(response.bodyBytes);
        try {
          final Map<String, dynamic> errorData = json.decode(decodedBody);
          if (errorData['error'] == '해당 날짜의 캡슐이 존재하지 않습니다.') {
            throw Exception('해당 날짜의 캡슐이 존재하지 않습니다.');
          }
        } catch (e) {
          // JSON 파싱 실패시 기본 404 처리
        }
        // 개발 중에는 테스트 데이터 반환
        print('404 Error - returning test data');
        return _getTestCapsuleData(dateStr);
      } else if (response.statusCode == 400) {
        throw Exception('올바른 날짜 형식이 아닙니다. (YYYY-MM-DD)');
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
  
  /// 테스트용 캡슐 데이터 생성
  CapsuleModel _getTestCapsuleData(String dateStr) {
    final testData = {
      'date': dateStr,
      'top3_keywords': [
        {
          'keyword': '포켓몬 우유',
          'score': 85.5,
          'appearance_count': 12,
          'avg_rank': 2.5,
          'last_keyword_id': 1001,
        },
        {
          'keyword': '갤럭시 S25',
          'score': 78.0,
          'appearance_count': 10,
          'avg_rank': 3.2,
          'last_keyword_id': 1002,
        },
        {
          'keyword': '천국보다 아름다운',
          'score': 72.3,
          'appearance_count': 8,
          'avg_rank': 4.1,
          'last_keyword_id': 1003,
        },
      ],
      'hourly_keywords': [
        {
          'time': '00:00',
          'keywords': [
            {
              'id': 6938,
              'keyword': '김준호 김지민 결혼식',
              'rank': 1,
              'category': '연예/문화',
              'type2': '김준호와 김지민이 많은 동료들의 축복 속에 결혼식을 올렸다.\n결혼식에는 1200명이 넘는 하객이 참석하여 성황을 이루었다.\n코미디언 동료들뿐 아니라 유재석, 이찬원 등 다양한 분야의 유명인들이 참석하여 두 사람의 결혼을 축하했다.',
            },
            {
              'id': 6939,
              'keyword': '포켓몬 우유',
              'rank': 2,
              'category': '연예/문화',
              'type2': '포켓몬 우유가 인기를 끌고 있다.',
            },
            {
              'id': 6940,
              'keyword': '갤럭시 S25',
              'rank': 3,
              'category': 'IT',
              'type2': '갤럭시 S25의 새로운 기능들이 공개되었다.',
            },
            {
              'id': 6941,
              'keyword': '이재명',
              'rank': 4,
              'category': '정치',
              'type2': '이재명 관련 정치 이슈가 화제가 되고 있다.',
            },
          ],
        },
        {
          'time': '00:05',
          'keywords': [
            {
              'id': 6942,
              'keyword': '천국보다 아름다운',
              'rank': 1,
              'category': '연예/문화',
              'type2': '천국보다 아름다운 드라마가 인기를 끌고 있다.',
            },
            {
              'id': 6943,
              'keyword': '포켓몬 우유',
              'rank': 2,
              'category': '연예/문화',
              'type2': '포켓몬 우유 관련 이슈가 계속되고 있다.',
            },
            {
              'id': 6944,
              'keyword': '파워에이드',
              'rank': 3,
              'category': '경제',
              'type2': '파워에이드 관련 경제 뉴스가 있다.',
            },
            {
              'id': 6945,
              'keyword': '소금 우유',
              'rank': 4,
              'category': '문화',
              'type2': '소금 우유 트렌드가 화제다.',
            },
          ],
        },
        {
          'time': '08:00',
          'keywords': [
            {
              'id': 6946,
              'keyword': '갤럭시 S25',
              'rank': 1,
              'category': 'IT',
              'type2': '갤럭시 S25 출시 관련 소식이 전해졌다.',
            },
            {
              'id': 6947,
              'keyword': '김소현 복귀',
              'rank': 2,
              'category': '연예/문화',
              'type2': '김소현의 복귀 소식이 화제가 되고 있다.',
            },
            {
              'id': 6948,
              'keyword': '링스틱',
              'rank': 3,
              'category': 'IT',
              'type2': '링스틱 관련 기술 뉴스가 있다.',
            },
            {
              'id': 6949,
              'keyword': '투싹',
              'rank': 4,
              'category': '스포츠',
              'type2': '투싹 관련 스포츠 소식이 전해졌다.',
            },
          ],
        },
        {
          'time': '16:00',
          'keywords': [
            {
              'id': 6950,
              'keyword': '갤럭시탭',
              'rank': 1,
              'category': 'IT',
              'type2': '갤럭시탭 새로운 모델이 공개되었다.',
            },
            {
              'id': 6951,
              'keyword': '새마음',
              'rank': 2,
              'category': '사회',
              'type2': '새마음 관련 사회 이슈가 있다.',
            },
            {
              'id': 6952,
              'keyword': '포켓몬 우유',
              'rank': 3,
              'category': '연예/문화',
              'type2': '포켓몬 우유 열풍이 계속되고 있다.',
            },
            {
              'id': 6953,
              'keyword': '천국보다 아름다운',
              'rank': 4,
              'category': '연예/문화',
              'type2': '천국보다 아름다운 드라마의 인기가 지속되고 있다.',
            },
          ],
        },
        {
          'time': '20:00',
          'keywords': [
            {
              'id': 6954,
              'keyword': '이재명',
              'rank': 1,
              'category': '정치',
              'type2': '이재명 관련 정치 소식이 저녁 시간에 화제가 되었다.',
            },
            {
              'id': 6955,
              'keyword': '크레딧카드 개코',
              'rank': 2,
              'category': '연예/문화',
              'type2': '크레딧카드 개코 관련 이슈가 있다.',
            },
            {
              'id': 6956,
              'keyword': '갤럭시 S25',
              'rank': 3,
              'category': 'IT',
              'type2': '갤럭시 S25 관련 추가 소식이 전해졌다.',
            },
            {
              'id': 6957,
              'keyword': '파워에이드',
              'rank': 4,
              'category': '경제',
              'type2': '파워에이드 관련 경제 소식이 저녁에 화제가 되었다.',
            },
          ],
        },
      ],
      'created_at': DateTime.now().toIso8601String(),
    };
    
    return CapsuleModel.fromJson(testData);
  }

  /// API 요청 취소 및 자원 해제
  void dispose() {
    _client.close();
  }
}