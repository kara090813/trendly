// lib/providers/user_preference_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../services/firebase_messaging_service.dart';
import '../models/hive/user_preferences.dart';

class UserPreferenceProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  
  // 캐시된 UserPreferences 객체
  UserPreferences? _userPreferences;
  
  // 로딩 상태
  bool _isLoadingProfile = false;
  bool _isLoadingComments = false;
  bool _isLoadingSentiments = false;
  bool _isLoadingReactions = false;

  // Getters - UserPreferences 객체에서 직접 가져오기
  List<int> get commentedRooms => _userPreferences?.commentedRooms ?? [];
  
  List<int> get commentIds => _userPreferences?.commentIds ?? [];
  
  String? get nickname => _userPreferences?.nickname;
  
  String? get password => _userPreferences?.password;
  
  Map<int, String> get roomSentiments => _userPreferences?.roomSentiments ?? {};
  
  Map<int, String> get commentReactions => _userPreferences?.commentReactions ?? {};
  
  bool? get isDarkMode => _userPreferences?.isDarkMode;
  
  ThemeMode get themeMode {
    final darkModeValue = _userPreferences?.isDarkMode;
    if (darkModeValue == null) {
      return ThemeMode.system; // Follow system theme
    }
    return darkModeValue ? ThemeMode.dark : ThemeMode.light;
  }
  
  // 실제 표시되는 다크모드 상태 (시스템 설정 고려)
  bool get effectiveDarkMode {
    final darkModeValue = _userPreferences?.isDarkMode;
    if (darkModeValue == null) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return darkModeValue;
  }
  
  DateTime? get installDate => _userPreferences?.installDate;
  
  bool get isPushNotificationEnabled => _userPreferences?.isPushNotificationEnabled ?? true;
  
  int get discussionHomeLastTabIndex => _userPreferences?.discussionHomeLastTabIndex ?? 0;
  
  int get historyHomeLastTabIndex => _userPreferences?.historyHomeLastTabIndex ?? 0;
  
  bool get isLoadingProfile => _isLoadingProfile;
  
  bool get isLoadingComments => _isLoadingComments;
  
  bool get isLoadingSentiments => _isLoadingSentiments;
  
  bool get isLoadingReactions => _isLoadingReactions;

  // 앱 시작 시 기본 정보 로드
  Future<void> loadBasicInfo() async {
    _isLoadingProfile = true;
    notifyListeners();

    try {
      // Hive에서 UserPreferences 로드
      _userPreferences = _hiveService.getUserPreferences();
      print('✅ [PROVIDER] 사용자 정보 로드 완료');
    } catch (e) {
      print('❌ [PROVIDER] 기본 정보 로드 오류: $e');
      // Hive가 초기화되지 않은 경우 기본값 사용
      _userPreferences = null;
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  // 다크모드/라이트모드 토글
  Future<void> toggleDarkMode() async {
    try {
      bool newMode;
      final currentMode = isDarkMode;
      
      if (currentMode == null) {
        // 시스템 기본값 상태에서는 시스템 테마를 기반으로 반대로 토글
        // 시스템이 다크면 라이트로, 라이트면 다크로
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        newMode = brightness == Brightness.light; // 시스템이 라이트면 다크로 토글
      } else {
        // 다크/라이트 토글
        newMode = !currentMode;
      }
      
      await _hiveService.setDarkMode(newMode);
      _userPreferences = _hiveService.getUserPreferences();
      notifyListeners();
    } catch (e) {
      print('다크모드 설정 오류: $e');
    }
  }

  // 다크모드 설정 (true = 다크모드 강제, null = 시스템 기본값 따름)
  Future<void> setDarkMode(bool? isDark) async {
    try {
      if (isDarkMode != isDark) {
        await _hiveService.setDarkMode(isDark);
        _userPreferences = _hiveService.getUserPreferences();
        notifyListeners();
      }
    } catch (e) {
      print('다크모드 설정 오류: $e');
    }
  }

  // 푸시 알림 설정
  Future<bool> setPushNotificationEnabled(bool enabled) async {
    if (isPushNotificationEnabled == enabled) {
      return true; // 이미 같은 상태면 성공으로 처리
    }
    
    // Firebase 서비스에 시스템 권한 요청 및 서버 업데이트
    bool firebaseSuccess = true;
    try {
      firebaseSuccess = await FirebaseMessagingService().updatePushNotificationPermission(enabled);
      if (!firebaseSuccess && enabled) {
        // 푸시 알림 켜기를 시도했지만 시스템 권한이 거부된 경우
        return false;
      }
    } catch (e) {
      print('Firebase 서비스 업데이트 오류: $e');
      firebaseSuccess = false;
    }
    
    // 로컬 설정 업데이트 (Firebase 성공 여부와 관계없이)
    final localSuccess = await _hiveService.setPushNotificationEnabled(enabled);
    if (localSuccess) {
      _userPreferences = _hiveService.getUserPreferences();
      notifyListeners();
    }
    
    return localSuccess && firebaseSuccess;
  }

  // 댓글 관련 정보 로드 (필요할 때만)
  Future<void> loadCommentInfo() async {
    if (commentedRooms.isNotEmpty && commentIds.isNotEmpty) return;

    _isLoadingComments = true;
    notifyListeners();

    try {
      // Hive는 이미 메모리에 캐시되어 있으므로 추가 로드 불필요
      _userPreferences = _hiveService.getUserPreferences();
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
      _userPreferences = _hiveService.getUserPreferences();
    } catch (e) {
      print('의견 정보 로드 오류: $e');
    } finally {
      _isLoadingSentiments = false;
      notifyListeners();
    }
  }

  // 댓글 반응 정보 로드
  Future<void> loadCommentReactions() async {
    if (commentReactions.isNotEmpty) return;

    _isLoadingReactions = true;
    notifyListeners();

    try {
      _userPreferences = _hiveService.getUserPreferences();
    } catch (e) {
      print('댓글 반응 정보 로드 오류: $e');
    } finally {
      _isLoadingReactions = false;
      notifyListeners();
    }
  }

  // 특정 토론방 의견 확인
  Future<String?> checkRoomSentiment(int roomId) async {
    _userPreferences = _hiveService.getUserPreferences();
    return roomSentiments[roomId];
  }

  // 댓글 작성한 토론방 추가
  Future<void> addCommentedRoom(int roomId) async {
    if (commentedRooms.contains(roomId)) return;

    final success = await _hiveService.addCommentedRoom(roomId);
    if (success) {
      _userPreferences = _hiveService.getUserPreferences();
      notifyListeners();
    }
  }

  // 댓글 ID 추가
  Future<void> addCommentId(int commentId) async {
    if (commentIds.contains(commentId)) return;

    final success = await _hiveService.addCommentId(commentId);
    if (success) {
      _userPreferences = _hiveService.getUserPreferences();
      notifyListeners();
    }
  }

  // 닉네임 설정
  Future<void> setNickname(String nickname) async {
    final success = await _hiveService.setNickname(nickname);
    if (success) {
      _userPreferences = _hiveService.getUserPreferences();
      notifyListeners();
    }
  }

  // 비밀번호 설정
  Future<void> setPassword(String password) async {
    final success = await _hiveService.setPassword(password);
    if (success) {
      _userPreferences = _hiveService.getUserPreferences();
      notifyListeners();
    }
  }

  // 좋아요/싫어요 여부 확인
  String? getCommentReaction(int commentId) {
    return commentReactions[commentId];
  }

  // 댓글 좋아요/싫어요 설정
  Future<void> setCommentReaction(int commentId, String reaction) async {
    // 이미 같은 반응이 있으면 제거 (토글 효과)
    if (commentReactions[commentId] == reaction) {
      await removeCommentReaction(commentId);
      return;
    }

    final success = await _hiveService.setCommentReaction(commentId, reaction);
    if (success) {
      _userPreferences = _hiveService.getUserPreferences();
      notifyListeners();
    }
  }

  // 좋아요 토글
  Future<void> toggleLike(int commentId) async {
    // 이미 싫어요 누른 경우 싫어요 제거
    if (commentReactions[commentId] == 'dislike') {
      await removeCommentReaction(commentId);
    }

    // 좋아요 토글
    if (commentReactions[commentId] == 'like') {
      await removeCommentReaction(commentId);
    } else {
      await setCommentReaction(commentId, 'like');
    }
  }

  // 싫어요 토글
  Future<void> toggleDislike(int commentId) async {
    // 이미 좋아요 누른 경우 좋아요 제거
    if (commentReactions[commentId] == 'like') {
      await removeCommentReaction(commentId);
    }

    // 싫어요 토글
    if (commentReactions[commentId] == 'dislike') {
      await removeCommentReaction(commentId);
    } else {
      await setCommentReaction(commentId, 'dislike');
    }
  }

  // 댓글 반응 제거
  Future<void> removeCommentReaction(int commentId) async {
    final success = await _hiveService.removeCommentReaction(commentId);
    if (success) {
      _userPreferences = _hiveService.getUserPreferences();
      notifyListeners();
    }
  }

  // 좋아요 누른 댓글 목록 가져오기
  List<int> getLikedComments() {
    return _userPreferences?.getLikedComments() ?? [];
  }

  // 싫어요 누른 댓글 목록 가져오기
  List<int> getDislikedComments() {
    return _userPreferences?.getDislikedComments() ?? [];
  }

  // 토론방 의견 설정
  Future<void> setRoomSentiment(int roomId, String sentiment) async {
    final success = await _hiveService.setRoomSentiment(roomId, sentiment);
    if (success) {
      _userPreferences = _hiveService.getUserPreferences();
      notifyListeners();
    }
  }

  // 토론방 의견 삭제
  Future<void> removeRoomSentiment(int roomId) async {
    final success = await _hiveService.removeRoomSentiment(roomId);
    if (success) {
      _userPreferences = _hiveService.getUserPreferences();
      notifyListeners();
    }
  }

  // 특정 의견(긍정/중립/부정)에 해당하는 토론방 목록 가져오기
  List<int> getRoomsBySentiment(String sentiment) {
    return _userPreferences?.getRoomsBySentiment(sentiment) ?? [];
  }

  // 내 댓글인지 확인
  bool isMyComment(int commentId) {
    return _userPreferences?.isMyComment(commentId) ?? false;
  }

  // 내가 참여한 토론방인지 확인
  bool hasParticipatedInRoom(int roomId) {
    return _userPreferences?.hasParticipatedInRoom(roomId) ?? false;
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
    final success = await _hiveService.clearAllData();
    if (success) {
      _userPreferences = _hiveService.getUserPreferences();
      notifyListeners();
    }
  }

  // 참여 통계 가져오기
  Map<String, int> getParticipationStats() {
    return _userPreferences?.getParticipationStats() ?? {
      'roomCount': 0,
      'commentCount': 0,
      'sentimentCount': 0,
      'likeCount': 0,
      'dislikeCount': 0,
    };
  }

  // 토론방 홈 탭 인덱스 설정
  Future<void> setDiscussionHomeTabIndex(int index) async {
    final success = await _hiveService.setDiscussionHomeTabIndex(index);
    if (success) {
      _userPreferences = _hiveService.getUserPreferences();
      notifyListeners();
    }
  }

  // 히스토리 홈 탭 인덱스 설정
  Future<void> setHistoryHomeTabIndex(int index) async {
    final success = await _hiveService.setHistoryHomeTabIndex(index);
    if (success) {
      _userPreferences = _hiveService.getUserPreferences();
      notifyListeners();
    }
  }
}