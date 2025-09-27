import 'package:korean_profanity_filter/korean_profanity_filter.dart';
import '../services/hive_service.dart';

/// 한국어 욕설 필터링 유틸리티 (커스텀 단어 지원)
class ProfanityFilterUtils {
  /// 커스텀 비속어 목록 (기본 제공)
  static final List<String> _defaultCustomWords = [
    // 여기에 기본 커스텀 비속어 추가 가능
    '바보야',
    '멍청이',
    '개새끼',
  ];

  /// 텍스트의 욕설을 ***로 치환 (기본 패키지 + 커스텀 단어)
  static String filterText(String text) {
    if (text.isEmpty) return text;

    try {
      String filtered = text;

      // 1. 기본 korean_profanity_filter 패키지 적용
      filtered = filtered.replaceBadWords('***');

      // 2. 커스텀 비속어 필터링 적용
      filtered = _applyCustomFilter(filtered);

      return filtered;
    } catch (e) {
      print('❌ [FILTER] 필터링 오류: $e');
      return text;
    }
  }

  /// 커스텀 비속어 필터링 적용
  static String _applyCustomFilter(String text) {
    String filtered = text;

    // 기본 커스텀 단어 필터링
    for (String word in _defaultCustomWords) {
      if (word.isNotEmpty) {
        filtered = filtered.replaceAll(RegExp(word, caseSensitive: false), '***');
      }
    }

    // Hive에서 사용자 커스텀 단어 가져와서 필터링
    try {
      final customWords = HiveService().getCustomProfanityWords();
      for (String word in customWords) {
        if (word.isNotEmpty) {
          filtered = filtered.replaceAll(RegExp(word, caseSensitive: false), '***');
        }
      }
    } catch (e) {
      print('⚠️ [FILTER] 커스텀 단어 로드 실패: $e');
    }

    return filtered;
  }

  /// 필터링 기능 즉시 테스트
  static void testNow() {
    print('🧪 [FILTER TEST] 즉시 테스트 시작');
    List<String> testCases = [
      '시발놈아',
      '시발',
      '븅신',
      '바보'
    ];

    for (String test in testCases) {
      String filtered = filterText(test);
      print('🧪 즉시 테스트: "$test" → "$filtered"');
    }
    print('🧪 [FILTER TEST] 즉시 테스트 완료');
  }

  /// 텍스트에 욕설이 포함되어 있는지 확인 (디버깅용)
  static bool containsProfanity(String text) {
    if (text.isEmpty) return false;
    try {
      bool result = text.containsBadWords;
      print('📋 [FILTER] "$text" 욕설 포함: $result');
      return result;
    } catch (e) {
      print('❌ [FILTER] 검사 오류: $e');
      return false;
    }
  }

  /// 필터링 테스트 (디버깅용)
  static void testFiltering() {
    print('🧪 [FILTER TEST] 필터링 테스트 시작');

    List<String> testCases = [
      '시발놈아',
      '시발',
      '븅신',
      '바보',
      '안녕하세요',
      '시발 진짜',
      '이 븅신아',
    ];

    for (String test in testCases) {
      bool hasProfanity = containsProfanity(test);
      String filtered = filterText(test);
      print('🧪 원본: "$test" | 욕설: $hasProfanity | 필터링: "$filtered"');
    }

    print('🧪 [FILTER TEST] 테스트 완료');
  }

  /// 커스텀 비속어 추가
  static Future<bool> addCustomWord(String word) async {
    if (word.trim().isEmpty) return false;
    try {
      return await HiveService().addCustomProfanityWord(word.trim());
    } catch (e) {
      print('❌ [FILTER] 커스텀 단어 추가 실패: $e');
      return false;
    }
  }

  /// 커스텀 비속어 제거
  static Future<bool> removeCustomWord(String word) async {
    if (word.trim().isEmpty) return false;
    try {
      return await HiveService().removeCustomProfanityWord(word.trim());
    } catch (e) {
      print('❌ [FILTER] 커스텀 단어 제거 실패: $e');
      return false;
    }
  }

  /// 모든 커스텀 비속어 목록 가져오기
  static List<String> getCustomWords() {
    try {
      final hiveWords = HiveService().getCustomProfanityWords();
      return [..._defaultCustomWords, ...hiveWords];
    } catch (e) {
      print('⚠️ [FILTER] 커스텀 단어 목록 로드 실패: $e');
      return _defaultCustomWords;
    }
  }

  /// 사용자가 추가한 커스텀 비속어만 가져오기 (기본 제외)
  static List<String> getUserCustomWords() {
    try {
      return HiveService().getCustomProfanityWords();
    } catch (e) {
      print('⚠️ [FILTER] 사용자 커스텀 단어 로드 실패: $e');
      return [];
    }
  }

}