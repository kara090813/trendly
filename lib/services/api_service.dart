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
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        return parseKeywords(decodedBody);
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('실시간 키워드 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('실시간 키워드 가져오기 오류: $e');
      print('요청 URL: $url');
      rethrow;
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
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        return Keyword.fromJson(data);
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('키워드 정보 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('키워드 정보 가져오기 오류: $e');
      print('요청 URL: $url');
      print('요청 파라미터: keywordId=$keywordId');
      rethrow;
    }
  }

  /// 키워드 검색 - 키워드 이름과 시간 범위로 키워드 ID 목록 가져오기
  /// POST /keyword/search/
  Future<List<int>> searchKeywordIds(String keyword, DateTime startTime, DateTime endTime) async {
    final String url = '$_baseUrl/keyword/search/';
    final Map<String, dynamic> requestData = {
      'keyword': keyword,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
    };

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        return List<int>.from(data['id_list']);
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        print('요청 데이터: $requestData');
        throw Exception('키워드 ID 검색 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('키워드 ID 검색 오류: $e');
      print('요청 URL: $url');
      print('요청 데이터: $requestData');
      rethrow;
    }
  }

  /// 여러 키워드 ID로 키워드 정보 가져오기
  /// POST /keyword/get_keyword_many/
  Future<List<Keyword>> getKeywordsByIds(List<int> idList) async {
    final String url = '$_baseUrl/keyword/get_keyword_many/';
    final Map<String, dynamic> requestData = {
      'id_list': idList,
    };

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((item) => Keyword.fromJson(item)).toList();
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        print('요청 데이터: $requestData');
        throw Exception('키워드 정보 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('키워드 정보 가져오기 오류: $e');
      print('요청 URL: $url');
      print('요청 데이터: $requestData');
      rethrow;
    }
  }

  /// 특정 시점의 1~10 키워드 가져오기 (타임머신 기능)
  /// GET /keyword/time_machine/<str:time>/
  Future<List<Keyword>> getKeywordsByTime(DateTime date) async {
    // 시간 형식을 ISO8601 형식으로 변환
    final String formattedDate = date.toUtc().toIso8601String();

    final String url = '$_baseUrl/keyword/time_machine/$formattedDate/';
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        return parseKeywords(decodedBody);
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('과거 키워드 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('과거 키워드 가져오기 오류: $e');
      print('요청 URL: $url');
      print('요청 파라미터: date=$date (formattedDate=$formattedDate)');
      rethrow;
    }
  }

  /// 임의의 키워드 히스토리 가져오기
  /// GET /random_keyword_history/
  Future<Map<String, dynamic>> getRandomKeywordHistory() async {
    final String url = '$_baseUrl/random_keyword_history/';
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        return json.decode(decodedBody);
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('랜덤 키워드 히스토리 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('랜덤 키워드 히스토리 가져오기 오류: $e');
      print('요청 URL: $url');
      rethrow;
    }
  }

  /// 특정 키워드의 히스토리 가져오기
  /// POST /keyword/history/
  Future<List<Map<String, dynamic>>> getKeywordHistory(String keyword) async {
    final String url = '$_baseUrl/keyword/history/';
    final Map<String, dynamic> requestData = {
      'keyword': keyword,
    };

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (response.statusCode == 404) {
        print('키워드 히스토리 없음: $keyword');
        return [];
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        print('요청 데이터: $requestData');
        throw Exception('키워드 히스토리 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('키워드 히스토리 가져오기 오류: $e');
      print('요청 URL: $url');
      print('요청 데이터: $requestData');
      rethrow;
    }
  }

  /// 임의의 키워드 n개 가져오기
  /// GET /keyword/random/<int:count>/
  Future<List<Keyword>> getRandomKeywords(int count) async {
    final String url = '$_baseUrl/keyword/random/$count/';
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((item) => Keyword.fromJson(item)).toList();
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('랜덤 키워드 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('랜덤 키워드 가져오기 오류: $e');
      print('요청 URL: $url');
      rethrow;
    }
  }

  /// 현재 인기 키워드와 관련된 토론방 목록 가져오기
  /// GET /discussion/now/
  Future<List<DiscussionRoom>> getCurrentDiscussionRooms() async {
    final String url = '$_baseUrl/discussion/now/';
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((item) => DiscussionRoom.fromJson(item)).toList();
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('현재 토론방 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('현재 토론방 가져오기 오류: $e');
      print('요청 URL: $url');
      rethrow;
    }
  }

  /// 활성화된 토론방 목록 가져오기 (is_closed가 False인 토론방)
  /// GET /discussion/active/
  Future<List<DiscussionRoom>> getActiveDiscussionRooms() async {
    final String url = '$_baseUrl/discussion/active/';
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((item) => DiscussionRoom.fromJson(item)).toList();
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('활성화된 토론방 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('활성화된 토론방 가져오기 오류: $e');
      print('요청 URL: $url');
      rethrow;
    }
  }

  /// 전체 토론방 목록 가져오기
  /// GET /discussion/all?page=N
  Future<List<DiscussionRoom>> getAllDiscussionRooms({int page = 0}) async {
    final String url = '$_baseUrl/discussion/all?page=$page';
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((item) => DiscussionRoom.fromJson(item)).toList();
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('전체 토론방 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('전체 토론방 가져오기 오류: $e');
      print('요청 URL: $url');
      rethrow;
    }
  }

  /// 랜덤 토론방 가져오기
  /// GET /discussion/get_random/<int:count>/<int:option>/
  Future<List<DiscussionRoom>> getRandomDiscussionRooms(int count, {int option = 1}) async {
    final String url = '$_baseUrl/discussion/get_random/$count/$option/';
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((item) => DiscussionRoom.fromJson(item)).toList();
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('랜덤 토론방 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('랜덤 토론방 가져오기 오류: $e');
      print('요청 URL: $url');
      rethrow;
    }
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
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        return DiscussionRoom.fromJson(data);
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('토론방 정보 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('토론방 정보 가져오기 오류: $e');
      print('요청 URL: $url');
      print('요청 파라미터: roomId=$roomId');
      rethrow;
    }
  }

  /// 토론방 ID로 최신 키워드 가져오기
  /// GET /discussion/get-latest-keyword-by-room-id/<int:discussion_room_id>/
  Future<Keyword> getLatestKeywordByDiscussionRoomId(int roomId) async {
    final String url = '$_baseUrl/discussion/get-latest-keyword-by-room-id/$roomId/';
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        return Keyword.fromJson(data);
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('토론방 관련 키워드 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('토론방 관련 키워드 가져오기 오류: $e');
      print('요청 URL: $url');
      print('요청 파라미터: roomId=$roomId');
      rethrow;
    }
  }

  /// 특정 키워드 토론방 가져오기
  /// POST /discussion/
  Future<DiscussionRoom> getDiscussionRoomByKeyword(String keywordName) async {
    final String url = '$_baseUrl/discussion/';
    final Map<String, dynamic> requestData = {
      'keyword': keywordName,
    };
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        return DiscussionRoom.fromJson(json.decode(decodedBody));
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        print('요청 데이터: $requestData');
        throw Exception('키워드 토론방 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('키워드 토론방 가져오기 오류: $e');
      print('요청 URL: $url');
      print('요청 데이터: $requestData');
      rethrow;
    }
  }

  /// 토론방의 모든 댓글 가져오기
  /// GET /discussion/<room_id>/comment/
  Future<List<Comment>> getAllDiscussionComments(int roomId) async {
    final String url = '$_baseUrl/discussion/$roomId/comment/';
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((item) => Comment.fromJson(item)).toList();
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('토론방 모든 댓글 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('토론방 모든 댓글 가져오기 오류: $e');
      print('요청 URL: $url');
      print('요청 파라미터: roomId=$roomId');
      rethrow;
    }
  }

  /// 해당 토론방 댓글 가져오기 (최신순 또는 인기순)
  /// GET /discussion/<room_id>/get_comment/[new/pop]
  Future<List<Comment>> getDiscussionComments(int roomId, {bool isPopular = false}) async {
    final String sortType = isPopular ? 'pop' : 'new';
    final String url = '$_baseUrl/discussion/$roomId/get_comment/$sortType';
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((item) => Comment.fromJson(item)).toList();
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('토론방 댓글 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('토론방 댓글 가져오기 오류: $e');
      print('요청 URL: $url');
      print('요청 파라미터: roomId=$roomId, isPopular=$isPopular');
      rethrow;
    }
  }

  /// 특정 댓글의 서브댓글 가져오기
  /// GET /discussion/subcomment/<int:parent_comment_id>/[new/pop]/
  Future<List<Comment>> getSubComments(int parentCommentId, {bool isPopular = false}) async {
    final String sortType = isPopular ? 'pop' : 'new';
    final String url = '$_baseUrl/discussion/subcomment/$parentCommentId/$sortType';
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        print('요청 URL: $url');
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((item) => Comment.fromJson(item)).toList();
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('서브댓글 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('서브댓글 가져오기 오류: $e');
      print('요청 URL: $url');
      print('요청 파라미터: parentCommentId=$parentCommentId, isPopular=$isPopular');
      rethrow;
    }
  }

  /// 댓글 작성하기
  /// POST /discussion/<room_id>/add_comment/
  Future<bool> addComment(int roomId, String user, String password, String nick, String comment,
      {bool isSubComment = false, int? parentId}) async {
    final String url = '$_baseUrl/discussion/$roomId/add_comment/';
    final Map<String, dynamic> requestData = {
      'discussion_room_id': roomId,
      'user': user,
      'password': password,
      'nick': nick,
      'comment': comment,
      'is_sub_comment': isSubComment,
    };

    if (isSubComment && parentId != null) {
      requestData['parent_id'] = parentId;
    }

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(requestData),
      );

      if (response.statusCode != 201) {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        print('요청 데이터: ${{"discussion_room_id": roomId, "user": user, "password": "****", "nick": nick, "comment": comment, "is_sub_comment": isSubComment, "parent_id": parentId}}');
      }

      return response.statusCode == 201;
    } catch (e) {
      print('댓글 작성 오류: $e');
      print('요청 URL: $url');
      print('요청 데이터: ${{"discussion_room_id": roomId, "user": user, "password": "****", "nick": nick, "comment": comment, "is_sub_comment": isSubComment, "parent_id": parentId}}');
      rethrow;
    }
  }

  /// 댓글 삭제하기
  /// POST /discussion/<room_id>/del_comment/
  Future<bool> deleteComment(int roomId, int commentId, String password) async {
    final String url = '$_baseUrl/discussion/$roomId/del_comment/';
    final Map<String, dynamic> requestData = {
      'comment_id': commentId,
      'password': password,
    };
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(requestData),
      );

      if (response.statusCode != 204) {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        print('요청 데이터: ${{"comment_id": commentId, "password": "****"}}');
      }

      return response.statusCode == 204;
    } catch (e) {
      print('댓글 삭제 오류: $e');
      print('요청 URL: $url');
      print('요청 데이터: ${{"comment_id": commentId, "password": "****"}}');
      rethrow;
    }
  }

  /// 토론방 감정 반응 설정
  /// POST /discussion/<int:discussion_room_id>/sentiment/
  Future<bool> setDiscussionSentiment(int roomId, int positive, int neutral, int negative) async {
    final String url = '$_baseUrl/discussion/$roomId/sentiment/';
    final Map<String, dynamic> requestData = {
      'positive': positive.toString(),
      'neutral': neutral.toString(),
      'negative': negative.toString(),
    };
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(requestData),
      );

      // 성공 시 202 상태 코드로 변경됨 (기존 200에서)
      if (response.statusCode != 202) {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        print('요청 데이터: $requestData');
      }

      return response.statusCode == 202;
    } catch (e) {
      print('감정 반응 설정 오류: $e');
      print('요청 URL: $url');
      print('요청 데이터: $requestData');
      rethrow;
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
        // UTF-8 디코딩 적용
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        return Comment.fromJson(data);
      } else {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        throw Exception('댓글 정보 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('댓글 정보 가져오기 오류: $e');
      print('요청 URL: $url');
      print('요청 파라미터: commentId=$commentId');
      rethrow;
    }
  }

  /// 댓글 추천 +1
  /// POST /comment/<int:comment_id>/like/
  Future<bool> likeComment(int commentId, {bool isCancel = false}) async {
    final String url = '$_baseUrl/comment/$commentId/like/';
    final Map<String, dynamic> requestData = {
      'is_cancel': isCancel,
    };

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(requestData),
      );

      // 성공 시 202 상태 코드로 변경됨 (기존 200에서)
      if (response.statusCode != 202) {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        print('요청 데이터: $requestData');
      }

      return response.statusCode == 202;
    } catch (e) {
      print('댓글 추천 오류: $e');
      print('요청 URL: $url');
      print('요청 파라미터: commentId=$commentId, isCancel=$isCancel');
      rethrow;
    }
  }

  /// 댓글 비추천 +1
  /// POST /comment/<int:comment_id>/dislike/
  Future<bool> dislikeComment(int commentId, {bool isCancel = false}) async {
    final String url = '$_baseUrl/comment/$commentId/dislike/';
    final Map<String, dynamic> requestData = {
      'is_cancel': isCancel,
    };

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(requestData),
      );

      // 성공 시 202 상태 코드로 변경됨 (기존 200에서)
      if (response.statusCode != 202) {
        print('API 요청 실패: 상태 코드 ${response.statusCode}');
        print('요청 URL: $url');
        print('요청 데이터: $requestData');
      }

      return response.statusCode == 202;
    } catch (e) {
      print('댓글 비추천 오류: $e');
      print('요청 URL: $url');
      print('요청 파라미터: commentId=$commentId, isCancel=$isCancel');
      rethrow;
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