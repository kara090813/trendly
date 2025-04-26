// lib/providers/user_preference_provider.dart
import 'package:flutter/foundation.dart';
import '../services/user_preference_service.dart';

class UserPreferenceProvider with ChangeNotifier {
  final UserPreferenceService _prefService = UserPreferenceService();

  // 상태 저장 변수들
  List<int> _commentedRooms = [];
  List<int> _commentIds = [];
  String? _nickname;
  String? _password;
  Map<int, String> _roomSentiments = {};
  Map<int, String> _commentReactions = {};

  // 로딩 상태
  bool _isLoadingProfile = false;
  bool _isLoadingComments = false;
  bool _isLoadingSentiments = false;
  bool _isLoadingReactions = false;

  // Getters
  List<int> get commentedRooms => _commentedRooms;

  List<int> get commentIds => _commentIds;

  String? get nickname => _nickname;

  String? get password => _password;

  Map<int, String> get roomSentiments => _roomSentiments;

  Map<int, String> get commentReactions => _commentReactions;

  bool get isLoadingProfile => _isLoadingProfile;

  bool get isLoadingComments => _isLoadingComments;

  bool get isLoadingSentiments => _isLoadingSentiments;

  bool get isLoadingReactions => _isLoadingReactions;

  // 앱 시작 시 기본 정보 로드 (닉네임, 비밀번호만)
  Future<void> loadBasicInfo() async {
    _isLoadingProfile = true;
    notifyListeners();

    try {
      _nickname = await _prefService.getDiscussionNickname();
      _password = await _prefService.getDiscussionPassword();
    } catch (e) {
      print('기본 정보 로드 오류: $e');
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  // 댓글 관련 정보 로드 (필요할 때만)
  Future<void> loadCommentInfo() async {
    if (_commentedRooms.isNotEmpty && _commentIds.isNotEmpty) return;

    _isLoadingComments = true;
    notifyListeners();

    try {
      _commentedRooms = await _prefService.getCommentedRooms();
      _commentIds = await _prefService.getCommentIds();
    } catch (e) {
      print('댓글 정보 로드 오류: $e');
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  // 토론방 의견 정보 로드 (필요할 때만)
  Future<void> loadSentiments() async {
    _isLoadingSentiments = true;
    notifyListeners();

    try {
      _roomSentiments = await _prefService.getAllRoomSentiments();
    } catch (e) {
      print('의견 정보 로드 오류: $e');
    } finally {
      _isLoadingSentiments = false;
      notifyListeners();
    }
  }

  Future<void> loadCommentReactions() async {
    if (_commentReactions.isNotEmpty) return; // 이미 로드된 경우 중복 로드 방지

    _isLoadingReactions = true;
    notifyListeners();

    try {
      _commentReactions = await _prefService.getAllCommentReactions();
    } catch (e) {
      print('댓글 반응 정보 로드 오류: $e');
    } finally {
      _isLoadingReactions = false;
      notifyListeners();
    }
  }

  // 특정 토론방 의견 확인 (로드 확인 후 반환)
  Future<String?> checkRoomSentiment(int roomId) async {
    // 메모리에 없으면 개별적으로 로드
    if (_roomSentiments.isEmpty) {
      final sentiment = await _prefService.getRoomSentiment(roomId);
      if (sentiment != null) {
        _roomSentiments[roomId] = sentiment;
        notifyListeners();
      }
      return sentiment;
    }

    return _roomSentiments[roomId];
  }

  // 댓글 작성한 토론방 추가
  Future<void> addCommentedRoom(int roomId) async {
    if (_commentedRooms.contains(roomId)) return;

    final success = await _prefService.saveCommentedRoom(roomId);
    if (success) {
      _commentedRooms.add(roomId);
      notifyListeners();
    }
  }

  // 댓글 ID 추가
  Future<void> addCommentId(int commentId) async {
    if (_commentIds.contains(commentId)) return;

    final success = await _prefService.saveCommentId(commentId);
    if (success) {
      _commentIds.add(commentId);
      notifyListeners();
    }
  }

  // 닉네임 설정
  Future<void> setNickname(String nickname) async {
    final success = await _prefService.saveDiscussionNickname(nickname);
    if (success) {
      _nickname = nickname;
      notifyListeners();
    }
  }

  // 비밀번호 설정
  Future<void> setPassword(String password) async {
    final success = await _prefService.saveDiscussionPassword(password);
    if (success) {
      _password = password;
      notifyListeners();
    }
  }

  // 좋아요/싫어요 여부 확인
  String? getCommentReaction(int commentId) {
    return _commentReactions[commentId];
  }

  // 댓글 좋아요/싫어요 설정
  Future<void> setCommentReaction(int commentId, String reaction) async {
    // 이미 같은 반응이 있으면 제거 (토글 효과)
    if (_commentReactions[commentId] == reaction) {
      await removeCommentReaction(commentId);
      return;
    }

    final success = await _prefService.saveCommentReaction(commentId, reaction);
    if (success) {
      _commentReactions[commentId] = reaction;
      notifyListeners();
    }
  }

  // 좋아요 토글
  Future<void> toggleLike(int commentId) async {
    // 이미 싫어요 누른 경우 싫어요 제거
    if (_commentReactions[commentId] == 'dislike') {
      await removeCommentReaction(commentId);
    }

    // 좋아요 토글
    if (_commentReactions[commentId] == 'like') {
      await removeCommentReaction(commentId);
    } else {
      await setCommentReaction(commentId, 'like');
    }
  }

  // 싫어요 토글
  Future<void> toggleDislike(int commentId) async {
    // 이미 좋아요 누른 경우 좋아요 제거
    if (_commentReactions[commentId] == 'like') {
      await removeCommentReaction(commentId);
    }

    // 싫어요 토글
    if (_commentReactions[commentId] == 'dislike') {
      await removeCommentReaction(commentId);
    } else {
      await setCommentReaction(commentId, 'dislike');
    }
  }

  // 댓글 반응 제거
  Future<void> removeCommentReaction(int commentId) async {
    final success = await _prefService.removeCommentReaction(commentId);
    if (success) {
      _commentReactions.remove(commentId);
      notifyListeners();
    }
  }

  // 좋아요 누른 댓글 목록 가져오기
  List<int> getLikedComments() {
    return _commentReactions.entries
        .where((entry) => entry.value == 'like')
        .map((entry) => entry.key)
        .toList();
  }

  // 싫어요 누른 댓글 목록 가져오기
  List<int> getDislikedComments() {
    return _commentReactions.entries
        .where((entry) => entry.value == 'dislike')
        .map((entry) => entry.key)
        .toList();
  }

  // 토론방 의견 설정
  Future<void> setRoomSentiment(int roomId, String sentiment) async {
    final success = await _prefService.saveRoomSentiment(roomId, sentiment);
    if (success) {
      _roomSentiments[roomId] = sentiment;
      notifyListeners();
    }
  }

  // 토론방 의견 삭제
  Future<void> removeRoomSentiment(int roomId) async {
    final success = await _prefService.removeRoomSentiment(roomId);
    if (success) {
      _roomSentiments.remove(roomId);
      notifyListeners();
    }
  }

  // 특정 의견(긍정/중립/부정)에 해당하는 토론방 목록 가져오기
  List<int> getRoomsBySentiment(String sentiment) {
    return _roomSentiments.entries
        .where((entry) => entry.value == sentiment)
        .map((entry) => entry.key)
        .toList();
  }

  // 내 댓글인지 확인
  bool isMyComment(int commentId) {
    return _commentIds.contains(commentId);
  }

  // 내가 참여한 토론방인지 확인
  bool hasParticipatedInRoom(int roomId) {
    return _commentedRooms.contains(roomId);
  }

  // 댓글 작성 및 토론방 참여 처리 (한번에 두 정보 저장)
  Future<void> addComment(int roomId, int commentId) async {
    await addCommentedRoom(roomId);
    await addCommentId(commentId);
  }

  // 사용자 정보 초기화 (토론방 정보)
  Future<void> initializeUserInfo(String nickname, String password) async {
    await setNickname(nickname);
    await setPassword(password);
  }

  // 모든 사용자 데이터 초기화
  Future<void> clearAllData() async {
    final success = await _prefService.clearAllData();
    if (success) {
      _commentedRooms = [];
      _commentIds = [];
      _nickname = null;
      _password = null;
      _roomSentiments = {};
      notifyListeners();
    }
  }

  // 참여 통계 가져오기
  Map<String, int> getParticipationStats() {
    return {
      'roomCount': _commentedRooms.length,
      'commentCount': _commentIds.length,
      'sentimentCount': _roomSentiments.length,
    };
  }
}
