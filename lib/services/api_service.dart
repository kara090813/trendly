import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/_models.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional imports for platform-specific HTTP client
import 'api_service_stub.dart'
    if (dart.library.io) 'api_service_io.dart'
    if (dart.library.html) 'api_service_web.dart' as platform;

/// ApiService 클래스
/// API 통신과 관련된 모든 메서드를 포함하고 있습니다.
class ApiService {
  // 기본 API URL
  static const String _baseUrl = 'https://trendly.servehttp.com:10443/api';
  // static const String _baseUrl = 'http://localhost:8000/api';

  // SSL 인증서 우회 설정 (개발 환경에서만 true로 설정)
  static const bool _bypassSSL = true; // 프로덕션에서는 false로 변경해야 함

  // 싱글톤 패턴 구현
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initializeClient();
  }

  // HTTP 클라이언트
  late final http.Client _client;
  
  // HTTP 클라이언트 초기화
  void _initializeClient() {
    _client = platform.createHttpClient(_bypassSSL);
    if (_bypassSSL && !kIsWeb) {
      print('⚠️ WARNING: SSL certificate verification is bypassed. This should only be used in development!');
    }
  }

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




  /// 임의의 키워드 히스토리 가져오기
  /// GET /keyword/random/1/
  Future<List<Keyword>> getRandomKeywordHistory() async {
    final String url = '$_baseUrl/keyword/random/1/';
    
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
        throw Exception('Failed to load random keywords: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
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



  /// 종료된 토론방 목록 가져오기 (기본 GET 방식)
  /// GET /discussion/closed?sort=[newest|oldest|popular]&page=N&category=all
  Future<Map<String, dynamic>> getClosedDiscussionRooms({
    String sort = 'newest',
    int page = 1,
    String category = 'all',
  }) async {
    final Map<String, String> queryParams = {
      'sort': sort,
      'page': page.toString(),
      'category': category,
    };
    
    final String url = Uri.parse('$_baseUrl/discussion/closed')
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
        
        return {
          'results': (data['results'] as List<dynamic>)
              .map((json) => DiscussionRoom.fromJson(json))
              .toList(),
          'page': data['page'] ?? page,
          'total_pages': data['total_pages'] ?? 1,
          'total_count': data['total_count'] ?? 0,
          'has_next': data['has_next'] ?? false,
          'has_previous': data['has_previous'] ?? false,
        };
      } else if (response.statusCode == 404) {
        // 임시 데이터 반환
        return _generateMockClosedRoomsResponse(page, category);
      } else {
        throw Exception('Failed to load closed discussion rooms: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류 시 임시 데이터 반환
      return _generateMockClosedRoomsResponse(page, category);
    }
  }

  /// 여러 토론방을 ID 리스트로 한번에 조회
  /// POST /discussion/get-many/
  Future<List<DiscussionRoom>> getDiscussionRoomsByIds(List<int> idList) async {
    const String url = '$_baseUrl/discussion/get-many/';
    
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode({
          'id_list': idList,
        }),
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        
        return data.map((json) => DiscussionRoom.fromJson(json)).toList();
      } else {
        print('Failed to get discussion rooms by IDs: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting discussion rooms by IDs: $e');
      return [];
    }
  }
  
  /// 여러 댓글을 ID 리스트로 한번에 조회
  /// POST /comment/get-many/
  Future<List<Comment>> getCommentsByIds(List<int> idList) async {
    const String url = '$_baseUrl/comment/get-many/';
    
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode({
          'id_list': idList,
        }),
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        print('Failed to get comments by IDs: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting comments by IDs: $e');
      return [];
    }
  }

  /// 종료된 토론방 목록 가져오기 (고급 필터링 POST 방식)
  /// POST /discussion/closed?sort=[newest|oldest|popular]&page=N&category=all
  /// 전체 종료된 토론방 개수 조회
  /// GET /api/discussion/closed/total-count/
  Future<int> getClosedDiscussionTotalCount() async {
    final String url = '$_baseUrl/discussion/closed/total-count/';
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        return data['total_count'] ?? 0;
      } else {
        throw Exception('Failed to load total count: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류 시 기본값 반환
      return 1000; // Mock 데이터
    }
  }

  /// 필터링된 카테고리별 종료된 토론방 개수 조회
  /// POST /api/discussion/closed/category-counts/
  Future<Map<String, int>> getClosedDiscussionCategoryCounts({
    Map<String, dynamic>? filters,
  }) async {
    final String url = '$_baseUrl/discussion/closed/category-counts/';
    
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(filters ?? {}),
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        final Map<String, dynamic> counts = data['counts'] ?? {};
        
        // int 타입으로 변환
        return counts.map((key, value) => MapEntry(key, (value as num).toInt()));
      } else {
        throw Exception('Failed to load category counts: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류 시 Mock 데이터 반환
      return _generateMockCategoryCounts();
    }
  }

  /// Mock 카테고리 카운트 데이터 생성
  Map<String, int> _generateMockCategoryCounts() {
    return {
      '전체': 1000,
      '정치/사회': 250,
      '경제/기술': 200,
      '연예/문화': 180,
      '생활/정보': 150,
      '사건/사고': 120,
      '커뮤/이슈': 80,
      '스포츠': 20,
      '국제': 0,
      '기타': 0,
    };
  }

  Future<Map<String, dynamic>> getClosedDiscussionRoomsWithFilters({
    String sort = 'newest',
    int page = 1,
    String category = 'all',
    Map<String, dynamic>? filters,
  }) async {
    final Map<String, String> queryParams = {
      'sort': sort,
      'page': page.toString(),
      'category': category,
    };
    
    final String url = Uri.parse('$_baseUrl/discussion/closed')
        .replace(queryParameters: queryParams)
        .toString();
    
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(filters ?? {}),
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        
        return {
          'results': (data['results'] as List<dynamic>)
              .map((json) => DiscussionRoom.fromJson(json))
              .toList(),
          'page': data['page'] ?? page,
          'total_pages': data['total_pages'] ?? 1,
          'total_count': data['total_count'] ?? 0,
          'has_next': data['has_next'] ?? false,
          'has_previous': data['has_previous'] ?? false,
        };
      } else if (response.statusCode == 404) {
        // 임시 데이터 반환
        return _generateMockClosedRoomsResponse(page, category);
      } else {
        throw Exception('Failed to load closed discussion rooms with filters: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류 시 임시 데이터 반환
      return _generateMockClosedRoomsResponse(page, category);
    }
  }

  List<DiscussionRoom> _generateMockClosedRooms(int page, String category) {
    final List<DiscussionRoom> mockRooms = [];
    final keywords = [
      '대통령 탄핵', '비트코인 급락', '아이돌 논란', '월드컵 경기', '인공지능 발전',
      '부동산 정책', '코로나 백신', '기후변화', '우크라이나 전쟁', '메타버스',
      '주 52시간', '최저임금', '4차 산업혁명', '전기차 시대', '우주 개발',
      '넷플릭스 오징어게임', 'K-POP 월드투어', '배달음식 규제', '카카오톡 장애',
      '삼성 반도체', 'LG 배터리', '현대차 수소차', '네이버 웹툰', '쿠팡 물류',
    ];
    
    final categories = ['정치', '경제', '사회', '문화', '스포츠', '국제', '과학'];
    
    for (int i = 0; i < 20; i++) {
      final idx = (page - 1) * 20 + i;
      final createdAt = DateTime.now().subtract(Duration(days: idx + 1));
      final closedAt = createdAt.add(Duration(hours: 12 + (idx % 20)));
      
      mockRooms.add(DiscussionRoom(
        id: 3000 + idx,
        keyword: keywords[idx % keywords.length] + (idx > 24 ? ' ${idx ~/ 25 + 1}' : ''),
        keyword_id_list: [100 + idx],
        is_closed: true,
        created_at: createdAt,
        updated_at: closedAt,
        closed_at: closedAt,
        comment_count: 15 + (idx % 200),
        comment_summary: '활발한 토론이 진행되었습니다. 다양한 의견이 교환되었고...',
        positive_count: 20 + (idx % 50),
        neutral_count: 15 + (idx % 30),
        negative_count: 10 + (idx % 25),
        sentiment_snapshot: [],
        category: category == 'all' ? categories[idx % categories.length] : category,
      ));
    }
    
    return mockRooms;
  }

  /// Mock 데이터를 새로운 응답 형식으로 반환
  Map<String, dynamic> _generateMockClosedRoomsResponse(int page, String category) {
    final mockRooms = _generateMockClosedRooms(page, category);
    final totalCount = 1000; // 가상의 전체 개수
    final totalPages = (totalCount / 20).ceil();
    
    return {
      'results': mockRooms,
      'page': page,
      'total_pages': totalPages,
      'total_count': totalCount,
      'has_next': page < totalPages,
      'has_previous': page > 1,
    };
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

  /// 랜덤 키워드 조회
  /// GET /api/keywords/random/
  Future<Map<String, dynamic>> getRandomKeyword() async {
    final String url = '$_baseUrl/keywords/random/';
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        
        // 응답 데이터 검증 및 기본값 설정
        return {
          'keyword': data['keyword']?.toString() ?? '',
          'search_count': (data['search_count'] as num?)?.toInt() ?? 0,
          'last_searched': data['last_searched'],
          'last_appeared': data['last_appeared']?.toString() ?? '',
        };
      } else {
        throw Exception('Failed to load random keyword: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 특정 날짜의 키워드 캡슐 데이터 조회
  /// GET /api/capsule/<str:date_str>/
  Future<CapsuleModel> getCapsule(String dateStr) async {
    final String url = '$_baseUrl/capsule/$dateStr/';
    print(url);
    
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
        // 데이터가 없으면 예외 던지기
        print('404 Error - no data available for this date');
        throw Exception('해당 날짜의 캡슐이 존재하지 않습니다.');
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
  
  /// 테스트용 캡슐 데이터 생성 (더 이상 사용하지 않음)
  CapsuleModel _getTestCapsuleData(String dateStr) {
    final testData = {
      'date': dateStr,
      'top3_keywords': [],
      'hourly_keywords': [],
      'created_at': DateTime.now().toIso8601String(),
    };
    
    return CapsuleModel.fromJson(testData);
  }

  /// Enhanced History API with advanced filtering and cursor-based pagination
  /// GET /api/discussion/history
  Future<Map<String, dynamic>> getHistoryWithAdvancedFilters({
    required Map<String, dynamic> filters,
    String? cursor,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      
      // Add cursor if provided
      if (cursor != null && cursor.isNotEmpty) {
        queryParams['cursor'] = cursor;
      }
      
      // Add filters
      filters.forEach((key, value) {
        if (value != null) {
          if (value is List) {
            queryParams[key] = value.join(',');
          } else {
            queryParams[key] = value.toString();
          }
        }
      });
      
      final uri = Uri.parse('$_baseUrl/discussion/history').replace(
        queryParameters: queryParams,
      );
      
      final response = await _client.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        
        return {
          'data': data['data'] ?? [],
          'pagination': data['pagination'] ?? {
            'next_cursor': null,
            'has_next_page': false,
            'total_count': 0,
          },
          'aggregations': data['aggregations'] ?? {
            'categories': <String, int>{},
            'date_distribution': <String, int>{},
            'sentiment_summary': {
              'positive': 0,
              'neutral': 0,
              'negative': 0,
            },
          },
        };
      } else {
        throw Exception('Advanced history API failed: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to existing API with limitations
      print('Advanced API failed, falling back to legacy: $e');
      throw Exception('Advanced filtering not available: $e');
    }
  }
  
  /// Get filter suggestions for autocomplete
  /// GET /api/discussion/history/suggest
  Future<List<Map<String, dynamic>>> getFilterSuggestions({
    required String type,
    String? context,
  }) async {
    try {
      final queryParams = <String, String>{
        'type': type,
      };
      
      if (context != null && context.isNotEmpty) {
        queryParams['context'] = context;
      }
      
      final uri = Uri.parse('$_baseUrl/discussion/history/suggest').replace(
        queryParameters: queryParams,
      );
      
      final response = await _client.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Filter suggestions failed: ${response.statusCode}');
      }
    } catch (e) {
      // Return empty suggestions on error
      return [];
    }
  }
  
  /// Export history data in various formats
  /// POST /api/discussion/history/export
  Future<bool> exportHistoryData({
    required Map<String, dynamic> filters,
    required String format,
    required String email,
  }) async {
    try {
      final body = {
        'filters': filters,
        'format': format,
        'email': email,
      };
      
      final response = await _client.post(
        Uri.parse('$_baseUrl/discussion/history/export'),
        headers: _headers,
        body: json.encode(body),
      );
      
      return response.statusCode == 202; // Accepted for async processing
    } catch (e) {
      return false;
    }
  }
  
  /// Get performance metrics and cache statistics
  /// GET /api/discussion/history/metrics
  Future<Map<String, dynamic>> getHistoryMetrics() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/discussion/history/metrics'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return json.decode(decodedBody);
      } else {
        return {
          'query_performance': <String, dynamic>{},
          'cache_metrics': <String, dynamic>{},
          'search_patterns': <String, dynamic>{},
        };
      }
    } catch (e) {
      return {
        'query_performance': <String, dynamic>{},
        'cache_metrics': <String, dynamic>{},
        'search_patterns': <String, dynamic>{},
        'error': e.toString(),
      };
    }
  }
  
  /// Get aggregated statistics for dashboard
  /// GET /api/discussion/history/stats
  Future<Map<String, dynamic>> getHistoryStatistics({
    String period = 'month',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/discussion/history/stats').replace(
        queryParameters: {'period': period},
      );
      
      final response = await _client.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return json.decode(decodedBody);
      } else {
        return _getMockStatistics();
      }
    } catch (e) {
      return _getMockStatistics();
    }
  }
  
  /// Mock statistics for development
  Map<String, dynamic> _getMockStatistics() {
    return {
      'total_discussions': 2847,
      'categories': {
        '정치': 523,
        'IT': 412,
        '연예/문화': 389,
        '스포츠': 298,
        '경제': 245,
        '사회': 231,
        '기타': 749,
      },
      'monthly_trends': {
        '2024-01': 145,
        '2024-02': 189,
        '2024-03': 234,
        '2024-04': 298,
        '2024-05': 356,
        '2024-06': 412,
        '2024-07': 467,
      },
      'top_keywords': [
        {'keyword': '데이터 없음', 'discussions': 0},
      ],
      'engagement_metrics': {
        'avg_comments_per_discussion': 14.7,
        'avg_reactions_per_discussion': 8.3,
        'peak_hours': ['20:00', '21:00', '22:00'],
        'most_active_day': 'Sunday',
      },
    };
  }

  /// FCM 토큰 등록/업데이트
  /// POST /push/register/
  Future<Map<String, dynamic>> registerPushToken({
    required String token,
    required bool isPushAllowed,
  }) async {
    print(token);
    final String url = '$_baseUrl/push/register/';
    
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode({
          'token': token,
          'is_push_allowed': isPushAllowed,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return json.decode(decodedBody);
      } else {
        throw Exception('Failed to register push token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 키워드 조회 로그 기록
  /// POST /log/keyword-view/
  Future<Map<String, dynamic>?> logKeywordView({
    required String token,
    required String category,
    String? keyword,
  }) async {
    final String url = '$_baseUrl/log/keyword-view/';
    
    try {
      // 토큰이 비어있으면 로그 전송을 스킵하고 null 반환
      if (token.isEmpty) {
        print('⚠️ [API] FCM token not available - skipping keyword view log');
        return null;
      }
      
      final Map<String, dynamic> requestBody = {
        'token': token,
        'category': category,
      };
      
      // keyword는 선택적 파라미터
      if (keyword != null && keyword.isNotEmpty) {
        requestBody['keyword'] = keyword;
      }
      
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 201) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return json.decode(decodedBody);
      } else if (response.statusCode == 404) {
        print('⚠️ [API] Device token not found - log skipped');
        return null;
      } else if (response.statusCode == 400) {
        print('⚠️ [API] Invalid request - log skipped');
        return null;
      } else {
        throw Exception('Failed to log keyword view: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [API] Error logging keyword view (continuing without log): $e');
      return null; // 로그 실패해도 앱 사용에 지장이 없도록 null 반환
    }
  }

  /// 베스트 댓글 일괄 조회
  /// POST /api/discussion/best-comments/
  /// 여러 토론방의 베스트 댓글을 한 번에 가져오기
  Future<Map<int, Map<String, dynamic>?>> getBestComments(List<int> discussionRoomIds) async {
    final String url = '$_baseUrl/discussion/best-comments/';
    
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode({
          'discussion_room_ids': discussionRoomIds,
        }),
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        final List<dynamic> results = data['results'] ?? [];
        
        // 토론방 ID를 키로 하는 Map으로 변환
        final Map<int, Map<String, dynamic>?> bestCommentsMap = {};
        
        for (var result in results) {
          final int roomId = result['discussion_room_id'];
          final bestComment = result['best_comment'];
          
          if (bestComment != null) {
            bestCommentsMap[roomId] = {
              'id': bestComment['id'],
              'user': bestComment['user'] ?? '익명',
              'comment': bestComment['comment'] ?? '',
              'like_count': bestComment['like_count'] ?? 0,
              'created_at': bestComment['created_at'] != null 
                ? DateTime.parse(bestComment['created_at'])
                : DateTime.now(),
            };
          } else {
            bestCommentsMap[roomId] = null;
          }
        }
        return bestCommentsMap;
      } else {
        throw Exception('Failed to get best comments: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [API] Error getting best comments: $e');
      // 에러 시 빈 Map 반환
      return {};
    }
  }

  /// 토론방 인기 댓글 가져오기
  /// GET /discussion/<int:discussion_room_id>/top-comments/<int:count>/
  Future<Map<String, dynamic>> getTopComments(int discussionRoomId, int count) async {
    final String url = '$_baseUrl/discussion/$discussionRoomId/top-comments/$count/';
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        
        return {
          'discussion_room_id': data['discussion_room_id'] ?? discussionRoomId,
          'requested_count': data['requested_count'] ?? count,
          'actual_count': data['actual_count'] ?? 0,
          'comments': (data['comments'] as List<dynamic>?)
              ?.map((json) => Comment.fromJson(json))
              .toList() ?? [],
        };
      } else {
        throw Exception('Failed to get top comments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// API 요청 취소 및 자원 해제
  void dispose() {
    _client.close();
  }
}