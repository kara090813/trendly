import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hive/user_preferences.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String userPreferencesBoxName = 'userPreferencesBox';
  static const String userPreferencesKey = 'userPreferences';

  late Box<UserPreferences> _userPreferencesBox;
  UserPreferences? _cachedPreferences;
  bool _isInitialized = false;

  // Hive 초기화
  Future<void> initializeHive() async {
    await Hive.initFlutter();
    
    // 어댑터 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserPreferencesAdapter());
    }

    try {
      // Box 열기
      _userPreferencesBox = await Hive.openBox<UserPreferences>(userPreferencesBoxName);
    } catch (e) {
      print('⚠️ [HIVE] Box 열기 실패, 기존 데이터 삭제 후 재시도: $e');
      try {
        // 기존 Box 삭제
        await Hive.deleteBoxFromDisk(userPreferencesBoxName);
      } catch (deleteError) {
        print('⚠️ [HIVE] Box 삭제 실패 (무시하고 계속): $deleteError');
      }
      // 다시 시도
      _userPreferencesBox = await Hive.openBox<UserPreferences>(userPreferencesBoxName);
    }
    
    // 기존 SharedPreferences 데이터 마이그레이션
    await _migrateFromSharedPreferences();
    
    // 캐시 로드
    _loadCachedPreferences();
    
    // 초기화 완료 플래그 설정
    _isInitialized = true;
  }

  // 캐시된 preferences 로드
  void _loadCachedPreferences() {
    _cachedPreferences = _userPreferencesBox.get(userPreferencesKey);
    if (_cachedPreferences == null) {
      _cachedPreferences = UserPreferences.empty();
      _userPreferencesBox.put(userPreferencesKey, _cachedPreferences!);
    }
  }

  // 캐시 초기화 (데이터 변경 시)
  void _clearCache() {
    _cachedPreferences = null;
  }

  // UserPreferences 가져오기
  UserPreferences getUserPreferences() {
    if (!_isInitialized) {
      throw StateError('HiveService has not been initialized. Call initializeHive() first.');
    }
    if (_cachedPreferences == null) {
      _loadCachedPreferences();
    }
    return _cachedPreferences!;
  }

  // UserPreferences 저장
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    preferences.lastUpdated = DateTime.now();
    await _userPreferencesBox.put(userPreferencesKey, preferences);
    _cachedPreferences = preferences;
  }

  // 닉네임 설정
  Future<bool> setNickname(String nickname) async {
    try {
      final prefs = getUserPreferences();
      prefs.nickname = nickname;
      await saveUserPreferences(prefs);
      return true;
    } catch (e) {
      print('닉네임 저장 오류: $e');
      return false;
    }
  }

  // 비밀번호 설정
  Future<bool> setPassword(String password) async {
    try {
      final prefs = getUserPreferences();
      prefs.password = password;
      await saveUserPreferences(prefs);
      return true;
    } catch (e) {
      print('비밀번호 저장 오류: $e');
      return false;
    }
  }

  // 다크 모드 설정 (null = system, false = light, true = dark)
  Future<bool> setDarkMode(bool? isDarkMode) async {
    try {
      final prefs = getUserPreferences();
      prefs.isDarkMode = isDarkMode;
      await saveUserPreferences(prefs);
      return true;
    } catch (e) {
      print('다크 모드 저장 오류: $e');
      return false;
    }
  }

  // 댓글 작성한 토론방 추가
  Future<bool> addCommentedRoom(int roomId) async {
    try {
      final prefs = getUserPreferences();
      prefs.addCommentedRoom(roomId);
      await saveUserPreferences(prefs);
      return true;
    } catch (e) {
      print('토론방 ID 저장 오류: $e');
      return false;
    }
  }

  // 댓글 ID 추가
  Future<bool> addCommentId(int commentId) async {
    try {
      final prefs = getUserPreferences();
      prefs.addCommentId(commentId);
      await saveUserPreferences(prefs);
      return true;
    } catch (e) {
      print('댓글 ID 저장 오류: $e');
      return false;
    }
  }

  // 토론방 감정 설정
  Future<bool> setRoomSentiment(int roomId, String sentiment) async {
    try {
      final prefs = getUserPreferences();
      prefs.setRoomSentiment(roomId, sentiment);
      await saveUserPreferences(prefs);
      return true;
    } catch (e) {
      print('토론방 감정 저장 오류: $e');
      return false;
    }
  }

  // 토론방 감정 제거
  Future<bool> removeRoomSentiment(int roomId) async {
    try {
      final prefs = getUserPreferences();
      prefs.removeRoomSentiment(roomId);
      await saveUserPreferences(prefs);
      return true;
    } catch (e) {
      print('토론방 감정 삭제 오류: $e');
      return false;
    }
  }

  // 댓글 반응 설정
  Future<bool> setCommentReaction(int commentId, String reaction) async {
    try {
      final prefs = getUserPreferences();
      prefs.setCommentReaction(commentId, reaction);
      await saveUserPreferences(prefs);
      return true;
    } catch (e) {
      print('댓글 반응 저장 오류: $e');
      return false;
    }
  }

  // 댓글 반응 제거
  Future<bool> removeCommentReaction(int commentId) async {
    try {
      final prefs = getUserPreferences();
      prefs.removeCommentReaction(commentId);
      await saveUserPreferences(prefs);
      return true;
    } catch (e) {
      print('댓글 반응 삭제 오류: $e');
      return false;
    }
  }

  // 푸시 알림 설정
  Future<bool> setPushNotificationEnabled(bool enabled) async {
    try {
      final prefs = getUserPreferences();
      prefs.isPushNotificationEnabled = enabled;
      prefs.lastUpdated = DateTime.now();
      await saveUserPreferences(prefs);
      _clearCache(); // 캐시 초기화
      return true;
    } catch (e) {
      print('푸시 알림 설정 저장 오류: $e');
      return false;
    }
  }

  // 모든 데이터 초기화
  Future<bool> clearAllData() async {
    try {
      final prefs = getUserPreferences();
      prefs.clearAllData();
      await saveUserPreferences(prefs);
      return true;
    } catch (e) {
      print('데이터 초기화 오류: $e');
      return false;
    }
  }

  // SharedPreferences에서 Hive로 데이터 마이그레이션
  Future<void> _migrateFromSharedPreferences() async {
    try {
      // 이미 마이그레이션 완료된 경우 스킵
      if (_userPreferencesBox.containsKey(userPreferencesKey)) {
        final existing = _userPreferencesBox.get(userPreferencesKey);
        if (existing != null && existing.lastUpdated != null) {
          print('Hive 데이터가 이미 존재합니다. 마이그레이션 스킵.');
          return;
        }
      }

      print('SharedPreferences에서 Hive로 데이터 마이그레이션 시작...');
      
      final prefs = await SharedPreferences.getInstance();
      final userPrefs = UserPreferences.empty();
      
      // 닉네임과 비밀번호
      userPrefs.nickname = prefs.getString('discussion_nickname');
      userPrefs.password = prefs.getString('discussion_password');
      
      // 다크 모드 (기존 설정이 없으면 null로 시스템 따라가기)
      if (prefs.containsKey('dark_mode_enabled')) {
        userPrefs.isDarkMode = prefs.getBool('dark_mode_enabled');
      } else {
        userPrefs.isDarkMode = null; // Follow system theme by default
      }
      
      // 댓글 작성한 토론방 목록
      final commentedRooms = prefs.getStringList('commented_rooms') ?? [];
      userPrefs.commentedRooms = commentedRooms.map((id) => int.tryParse(id) ?? 0).where((id) => id != 0).toList();
      
      // 작성한 댓글 ID 목록
      final commentIds = prefs.getStringList('comment_ids') ?? [];
      userPrefs.commentIds = commentIds.map((id) => int.tryParse(id) ?? 0).where((id) => id != 0).toList();
      
      // 토론방 감정 (JSON 파싱)
      final sentimentsJson = prefs.getString('room_sentiments');
      if (sentimentsJson != null && sentimentsJson.isNotEmpty) {
        try {
          // dart:convert의 json.decode 사용
          final dynamic decoded = json.decode(sentimentsJson);
          if (decoded is Map) {
            userPrefs.roomSentiments = decoded.map((key, value) => 
              MapEntry(int.tryParse(key.toString()) ?? 0, value.toString())
            );
            userPrefs.roomSentiments.remove(0); // 잘못된 키 제거
          }
        } catch (e) {
          print('토론방 감정 마이그레이션 오류: $e');
        }
      }
      
      // 댓글 반응 (JSON 파싱)
      final reactionsJson = prefs.getString('comment_reactions');
      if (reactionsJson != null && reactionsJson.isNotEmpty) {
        try {
          // dart:convert의 json.decode 사용
          final dynamic decoded = json.decode(reactionsJson);
          if (decoded is Map) {
            userPrefs.commentReactions = decoded.map((key, value) => 
              MapEntry(int.tryParse(key.toString()) ?? 0, value.toString())
            );
            userPrefs.commentReactions.remove(0); // 잘못된 키 제거
          }
        } catch (e) {
          print('댓글 반응 마이그레이션 오류: $e');
        }
      }
      
      final now = DateTime.now();
      userPrefs.lastUpdated = now;
      
      // 설치일 설정 (마이그레이션 시에는 현재 시간을 설치일로 설정)
      if (userPrefs.installDate == null) {
        userPrefs.installDate = now;
      }
      
      // Hive에 저장
      await _userPreferencesBox.put(userPreferencesKey, userPrefs);
      _cachedPreferences = userPrefs;
      
      print('마이그레이션 완료: ');
      print('- 닉네임: ${userPrefs.nickname}');
      print('- 댓글 작성 토론방: ${userPrefs.commentedRooms.length}개');
      print('- 작성한 댓글: ${userPrefs.commentIds.length}개');
      print('- 토론방 감정: ${userPrefs.roomSentiments.length}개');
      print('- 댓글 반응: ${userPrefs.commentReactions.length}개');
      
    } catch (e) {
      print('마이그레이션 중 오류 발생: $e');
    }
  }

  // 토론방 홈 탭 인덱스 설정
  Future<bool> setDiscussionHomeTabIndex(int index) async {
    try {
      final prefs = getUserPreferences();
      prefs.setDiscussionHomeTabIndex(index);
      await saveUserPreferences(prefs);
      return true;
    } catch (e) {
      print('토론방 홈 탭 인덱스 저장 오류: $e');
      return false;
    }
  }

  // 히스토리 홈 탭 인덱스 설정
  Future<bool> setHistoryHomeTabIndex(int index) async {
    try {
      final prefs = getUserPreferences();
      prefs.setHistoryHomeTabIndex(index);
      await saveUserPreferences(prefs);
      return true;
    } catch (e) {
      print('히스토리 홈 탭 인덱스 저장 오류: $e');
      return false;
    }
  }

  // 욕설 필터링 설정
  Future<bool> setProfanityFilterEnabled(bool enabled) async {
    try {
      final prefs = getUserPreferences();
      prefs.setProfanityFilterEnabled(enabled);
      await saveUserPreferences(prefs);
      print('🔧 [HIVE] 욕설 필터 설정 저장 완료: $enabled');
      return true;
    } catch (e) {
      print('❌ [HIVE] 욕설 필터 설정 저장 오류: $e');
      return false;
    }
  }

  // 커스텀 비속어 추가
  Future<bool> addCustomProfanityWord(String word) async {
    if (word.trim().isEmpty) return false;

    try {
      final prefs = getUserPreferences();
      final currentWords = Set<String>.from(prefs.customProfanityWords ?? []);

      // 중복 확인 (대소문자 구분 안 함)
      final lowerWord = word.trim().toLowerCase();
      if (currentWords.any((w) => w.toLowerCase() == lowerWord)) {
        print('⚠️ [HIVE] 이미 존재하는 커스텀 단어: $word');
        return false;
      }

      currentWords.add(word.trim());
      prefs.customProfanityWords = currentWords.toList();
      prefs.lastUpdated = DateTime.now();

      await saveUserPreferences(prefs);
      _clearCache(); // 캐시 초기화
      print('✅ [HIVE] 커스텀 비속어 추가 완료: $word');
      return true;
    } catch (e) {
      print('❌ [HIVE] 커스텀 비속어 추가 오류: $e');
      return false;
    }
  }

  // 커스텀 비속어 제거
  Future<bool> removeCustomProfanityWord(String word) async {
    if (word.trim().isEmpty) return false;

    try {
      final prefs = getUserPreferences();
      final currentWords = Set<String>.from(prefs.customProfanityWords ?? []);

      // 대소문자 구분 없이 제거
      final lowerWord = word.trim().toLowerCase();
      final wordToRemove = currentWords.firstWhere(
        (w) => w.toLowerCase() == lowerWord,
        orElse: () => '',
      );

      if (wordToRemove.isEmpty) {
        print('⚠️ [HIVE] 존재하지 않는 커스텀 단어: $word');
        return false;
      }

      currentWords.remove(wordToRemove);
      prefs.customProfanityWords = currentWords.toList();
      prefs.lastUpdated = DateTime.now();

      await saveUserPreferences(prefs);
      _clearCache(); // 캐시 초기화
      print('✅ [HIVE] 커스텀 비속어 제거 완료: $wordToRemove');
      return true;
    } catch (e) {
      print('❌ [HIVE] 커스텀 비속어 제거 오류: $e');
      return false;
    }
  }

  // 모든 커스텀 비속어 목록 가져오기
  List<String> getCustomProfanityWords() {
    try {
      final prefs = getUserPreferences();
      return List<String>.from(prefs.customProfanityWords ?? []);
    } catch (e) {
      print('⚠️ [HIVE] 커스텀 비속어 목록 로드 오류: $e');
      return [];
    }
  }

  // 모든 커스텀 비속어 초기화
  Future<bool> clearCustomProfanityWords() async {
    try {
      final prefs = getUserPreferences();
      prefs.customProfanityWords = [];
      prefs.lastUpdated = DateTime.now();

      await saveUserPreferences(prefs);
      _clearCache(); // 캐시 초기화
      print('✅ [HIVE] 모든 커스텀 비속어 초기화 완료');
      return true;
    } catch (e) {
      print('❌ [HIVE] 커스텀 비속어 초기화 오류: $e');
      return false;
    }
  }

  // Hive Box 닫기
  Future<void> closeHive() async {
    await _userPreferencesBox.close();
  }
}