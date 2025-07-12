import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/_models.dart';

/// ApiService 클래스
/// API 통신과 관련된 모든 메서드를 포함하고 있습니다.
class ApiService {
  // 기본 API URL
  static const String _baseUrl = 'https://trendly.servehttp.com:10443/api';

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
        return data.map((json) => Keyword.fromJson(json)).toList();
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
        return Keyword.fromJson(data);
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
  Future<List<Map<String, dynamic>>> getKeywordHistory(String keyword) async {
    final String url = '$_baseUrl';
    return Future.value([]);
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

  /// API 요청 취소 및 자원 해제
  void dispose() {
    _client.close();
  }
}