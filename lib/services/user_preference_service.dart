// lib/services/user_preference_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// UserPreferenceService 클래스
/// 사용자의 상태 및 설정을 로컬 저장소에 관리하는 메서드를 포함하고 있습니다.
class UserPreferenceService {
  // 싱글톤 패턴 구현
  static final UserPreferenceService _instance = UserPreferenceService._internal();
  factory UserPreferenceService() => _instance;
  UserPreferenceService._internal();

  // SharedPreferences 키 상수
  static const String _commentedRoomsKey = 'commented_rooms';
  static const String _commentIdsKey = 'comment_ids';
  static const String _nicknameKey = 'discussion_nickname';
  static const String _passwordKey = 'discussion_password';
  static const String _sentimentsKey = 'room_sentiments';
  static const String _commentReactionsKey = 'comment_reactions';
  static const String _darkModeKey = 'dark_mode_enabled';

// 다크 모드 설정 저장
  Future<bool> saveDarkModePreference(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, isDarkMode);
      return true;
    } catch (e) {
      print('다크 모드 설정 저장 오류: $e');
      return false;
    }
  }

// 다크 모드 설정 가져오기
  Future<bool> getDarkModePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_darkModeKey) ?? false; // 기본값은 라이트 모드
    } catch (e) {
      print('다크 모드 설정 가져오기 오류: $e');
      return false; // 오류 발생 시 기본값은 라이트 모드
    }
  }

  // 내가 댓글을 작성한 토론방 ID 배열 저장
  Future<bool> saveCommentedRoom(int roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> roomIds = prefs.getStringList(_commentedRoomsKey) ?? [];

      final String roomIdStr = roomId.toString();
      if (!roomIds.contains(roomIdStr)) {
        roomIds.add(roomIdStr);
        await prefs.setStringList(_commentedRoomsKey, roomIds);
      }

      return true;
    } catch (e) {
      print('토론방 ID 저장 오류: $e');
      return false;
    }
  }

  // 내가 댓글을 작성한 토론방 ID 배열 가져오기
  Future<List<int>> getCommentedRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> roomIds = prefs.getStringList(_commentedRoomsKey) ?? [];
      return roomIds.map((id) => int.parse(id)).toList();
    } catch (e) {
      print('토론방 ID 목록 가져오기 오류: $e');
      return [];
    }
  }

  // 내가 작성한 댓글/답글 ID 배열 저장
  Future<bool> saveCommentId(int commentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> commentIds = prefs.getStringList(_commentIdsKey) ?? [];

      final String commentIdStr = commentId.toString();
      if (!commentIds.contains(commentIdStr)) {
        commentIds.add(commentIdStr);
        await prefs.setStringList(_commentIdsKey, commentIds);
      }

      return true;
    } catch (e) {
      print('댓글 ID 저장 오류: $e');
      return false;
    }
  }

  // 내가 작성한 댓글/답글 ID 배열 가져오기
  Future<List<int>> getCommentIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> commentIds = prefs.getStringList(_commentIdsKey) ?? [];
      return commentIds.map((id) => int.parse(id)).toList();
    } catch (e) {
      print('댓글 ID 목록 가져오기 오류: $e');
      return [];
    }
  }

  // 내가 설정한 토론방 닉네임(아이디) 저장
  Future<bool> saveDiscussionNickname(String nickname) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_nicknameKey, nickname);
      return true;
    } catch (e) {
      print('토론방 닉네임 저장 오류: $e');
      return false;
    }
  }

  // 내가 설정한 토론방 닉네임 가져오기
  Future<String?> getDiscussionNickname() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_nicknameKey);
    } catch (e) {
      print('토론방 닉네임 가져오기 오류: $e');
      return null;
    }
  }

  // 내가 설정한 토론방 비밀번호 저장
  Future<bool> saveDiscussionPassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_passwordKey, password);
      return true;
    } catch (e) {
      print('토론방 비밀번호 저장 오류: $e');
      return false;
    }
  }

  // 내가 설정한 토론방 비밀번호 가져오기
  Future<String?> getDiscussionPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_passwordKey);
    } catch (e) {
      print('토론방 비밀번호 가져오기 오류: $e');
      return null;
    }
  }

  // 내가 의견(긍정/중립/부정)을 남긴 토론방 정보 저장
  Future<bool> saveRoomSentiment(int roomId, String sentiment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sentimentsJson = prefs.getString(_sentimentsKey);

      // 기존 의견 데이터 가져오기
      Map<String, String> sentiments = {};
      if (sentimentsJson != null) {
        sentiments = Map<String, String>.from(json.decode(sentimentsJson));
      }

      // 새 의견 추가 또는 업데이트
      sentiments[roomId.toString()] = sentiment;

      // JSON으로 변환하여 저장
      await prefs.setString(_sentimentsKey, json.encode(sentiments));

      return true;
    } catch (e) {
      print('토론방 의견 저장 오류: $e');
      return false;
    }
  }

  // 특정 토론방 ID의 의견 가져오기
  Future<String?> getRoomSentiment(int roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sentimentsJson = prefs.getString(_sentimentsKey);

      if (sentimentsJson == null) return null;

      final Map<String, dynamic> sentiments = json.decode(sentimentsJson);
      return sentiments[roomId.toString()];
    } catch (e) {
      print('토론방 의견 가져오기 오류: $e');
      return null;
    }
  }

  // 모든 의견 정보 가져오기
  Future<Map<int, String>> getAllRoomSentiments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sentimentsJson = prefs.getString(_sentimentsKey);

      if (sentimentsJson == null) return {};

      final Map<String, dynamic> sentiments = json.decode(sentimentsJson);
      return sentiments.map((key, value) => MapEntry(int.parse(key), value as String));
    } catch (e) {
      print('모든 토론방 의견 가져오기 오류: $e');
      return {};
    }
  }

  // 특정 토론방 의견 삭제
  Future<bool> removeRoomSentiment(int roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sentimentsJson = prefs.getString(_sentimentsKey);

      if (sentimentsJson == null) return true;

      Map<String, dynamic> sentiments = json.decode(sentimentsJson);
      sentiments.remove(roomId.toString());

      await prefs.setString(_sentimentsKey, json.encode(sentiments));
      return true;
    } catch (e) {
      print('토론방 의견 삭제 오류: $e');
      return false;
    }
  }

  // 댓글 반응 저장 (좋아요/싫어요)
  Future<bool> saveCommentReaction(int commentId, String reaction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? reactionsJson = prefs.getString(_commentReactionsKey);

      // 기존 반응 데이터 가져오기
      Map<String, String> reactions = {};
      if (reactionsJson != null) {
        reactions = Map<String, String>.from(json.decode(reactionsJson));
      }

      // 새 반응 추가 또는 업데이트
      reactions[commentId.toString()] = reaction; // 'like' 또는 'dislike'

      // JSON으로 변환하여 저장
      await prefs.setString(_commentReactionsKey, json.encode(reactions));
      return true;
    } catch (e) {
      print('댓글 반응 저장 오류: $e');
      return false;
    }
  }

  // 댓글 반응 가져오기
  Future<String?> getCommentReaction(int commentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? reactionsJson = prefs.getString(_commentReactionsKey);

      if (reactionsJson == null) return null;

      final Map<String, dynamic> reactions = json.decode(reactionsJson);
      return reactions[commentId.toString()];
    } catch (e) {
      print('댓글 반응 가져오기 오류: $e');
      return null;
    }
  }

  // 모든 댓글 반응 가져오기
  Future<Map<int, String>> getAllCommentReactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? reactionsJson = prefs.getString(_commentReactionsKey);

      if (reactionsJson == null) return {};

      final Map<String, dynamic> reactions = json.decode(reactionsJson);
      return reactions.map((key, value) => MapEntry(int.parse(key), value as String));
    } catch (e) {
      print('모든 댓글 반응 가져오기 오류: $e');
      return {};
    }
  }

  // 댓글 반응 삭제
  Future<bool> removeCommentReaction(int commentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? reactionsJson = prefs.getString(_commentReactionsKey);

      if (reactionsJson == null) return true;

      Map<String, dynamic> reactions = json.decode(reactionsJson);
      reactions.remove(commentId.toString());

      await prefs.setString(_commentReactionsKey, json.encode(reactions));
      return true;
    } catch (e) {
      print('댓글 반응 삭제 오류: $e');
      return false;
    }
  }

  // 모든 데이터 초기화 (로그아웃 시)
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_commentedRoomsKey);
      await prefs.remove(_commentIdsKey);
      await prefs.remove(_nicknameKey);
      await prefs.remove(_passwordKey);
      await prefs.remove(_sentimentsKey);
      return true;
    } catch (e) {
      print('사용자 데이터 초기화 오류: $e');
      return false;
    }
  }
}