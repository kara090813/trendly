import 'package:home_widget/home_widget.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_service.dart';
import 'hive_service.dart';
import '../models/freezed/keyword_model.dart';

class HomeWidgetService {
  static const String _groupId = 'group.net.lamoss.trendly.widgdet';
  static const String _widgetName = 'TrendlyWidget';
  
  // 홈 위젯 초기화
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_groupId);
    
    // 초기화 시 위젯 데이터 업데이트 시도
    try {
      await updateWidgetInBackground();
      print('✅ 위젯 초기 데이터 로드 성공');
    } catch (e) {
      print('⚠️ 위젯 초기 데이터 로드 실패: $e');
      // 실패해도 초기화는 계속 진행
    }
  }
  
  // 위젯 데이터 업데이트
  static Future<void> updateWidget({required List<Keyword> keywords}) async {
    try {
      if (keywords.isEmpty) {
        print('⚠️ 위젯 업데이트: 키워드 데이터가 비어있음');
        // 빈 데이터일 경우 로딩 상태 클리어
        await HomeWidget.saveWidgetData('keywords', jsonEncode([]));
        await HomeWidget.saveWidgetData('lastUpdate', DateTime.now().toIso8601String());
      } else {
        // 키워드 데이터를 JSON으로 변환하여 저장
        final keywordData = keywords.map((k) => {
          'id': k.id,
          'keyword': k.keyword,
          'rank': k.rank,
          'category': k.category,
        }).toList();
        
        print('✅ 위젯 업데이트: ${keywordData.length}개 키워드 저장');
        
        final keywordJson = jsonEncode(keywordData);
        print('📝 저장할 키워드 JSON: $keywordJson');
        
        await HomeWidget.saveWidgetData('keywords', keywordJson);
        await HomeWidget.saveWidgetData('lastUpdate', DateTime.now().toIso8601String());
        
        print('💾 위젯 데이터 저장 완료');
      }
      
      // 위젯 업데이트 요청
      await HomeWidget.updateWidget(
        qualifiedAndroidName: 'com.trendly.TrendlyWidgetProvider',
        iOSName: 'TrendlyWidget',
      );
      
      print('✅ 위젯 플랫폼 업데이트 완료');
    } catch (e) {
      print('❌ 홈 위젯 업데이트 실패: $e');
      // 에러 발생 시에도 위젯 상태 업데이트
      try {
        await HomeWidget.saveWidgetData('keywords', jsonEncode([]));
        await HomeWidget.saveWidgetData('lastUpdate', DateTime.now().toIso8601String());
        await HomeWidget.updateWidget(
          qualifiedAndroidName: 'com.trendly.TrendlyWidgetProvider',
          iOSName: 'TrendlyWidget',
        );
      } catch (updateError) {
        print('❌ 위젯 에러 상태 업데이트 실패: $updateError');
      }
    }
  }
  
  // 백그라운드에서 위젯 데이터 업데이트
  static Future<void> updateWidgetInBackground() async {
    try {
      print('🔄 위젯 데이터 업데이트 시작...');
      
      // API에서 키워드 데이터 가져오기
      final apiService = ApiService();
      print('📡 API 호출 중...');
      
      final keywords = await apiService.getCurrentKeywords();
      print('✅ API 호출 성공: ${keywords.length}개 키워드 수신');
      
      // 디버그: 받은 키워드 출력
      for (int i = 0; i < keywords.length && i < 3; i++) {
        print('  키워드 ${i+1}: ${keywords[i].keyword} (순위: ${keywords[i].rank})');
      }
      
      // 사용자 설정에서 키워드 개수 가져오기
      final hiveService = HiveService();
      final userPrefs = hiveService.getUserPreferences();
      final keywordCount = userPrefs?.homeWidgetKeywordCount ?? 5;
      
      // 설정된 개수만큼 키워드 사용
      final selectedKeywords = keywords.take(keywordCount).toList();
      
      print('✅ 위젯 키워드 ${selectedKeywords.length}개 업데이트 중...');
      await updateWidget(keywords: selectedKeywords);
    } catch (e) {
      print('❌ 백그라운드 위젯 업데이트 실패: $e');
      print('❌ 에러 상세: ${e.toString()}');
      
      // 에러 발생시에도 위젯 업데이트하여 에러 메시지 표시
      await updateWidget(keywords: []);
    }
  }
  
  // 위젯 데이터 수동 업데이트 (백그라운드 작업 대신 사용)
  static Future<bool> refreshWidgetData() async {
    try {
      await updateWidgetInBackground();
      return true;
    } catch (e) {
      print('위젯 데이터 새로고침 실패: $e');
      return false;
    }
  }
  
  // 위젯 자동 새로고침 설정 (네이티브에서 처리)
  static Future<void> enableAutoRefresh(bool enabled) async {
    // Android/iOS 네이티브에서 타이머 또는 시스템 알람을 통해 처리
    // 여기서는 설정 상태만 저장
    await HomeWidget.saveWidgetData('auto_refresh_enabled', enabled.toString());
  }
  
  // 위젯에서 앱으로의 클릭 처리
  static void setupWidgetClickListener(Function(String?) onWidgetClick) {
    HomeWidget.widgetClicked.listen((Uri? uri) {
      final keywordId = uri?.queryParameters['keywordId'];
      onWidgetClick(keywordId);
    });
  }
  
  // 위젯 데이터 클리어
  static Future<void> clearWidgetData() async {
    try {
      await HomeWidget.saveWidgetData('keywords', '[]');
      await HomeWidget.saveWidgetData('lastUpdate', '');
      
      await HomeWidget.updateWidget(
        qualifiedAndroidName: 'com.trendly.TrendlyWidgetProvider',
        iOSName: 'TrendlyWidget',
      );
    } catch (e) {
      print('위젯 데이터 클리어 실패: $e');
    }
  }
}