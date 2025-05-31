import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/_widgets.dart';

class TimeMachineTabComponent extends StatefulWidget {
  const TimeMachineTabComponent({Key? key}) : super(key: key);

  @override
  State<TimeMachineTabComponent> createState() =>
      _TimeMachineTabComponentState();
}

class _TimeMachineTabComponentState extends State<TimeMachineTabComponent> {
  DateTime _selectedDate =
      DateTime.now().subtract(const Duration(days: 1)); // 기본값: 어제

  // 카테고리 색상 매핑
  final Map<String, Color> categoryColors = {
    '정치': Color(0xFF4A90E2),
    '사회': Color(0xFF27AE60),
    '연예': Color(0xFFE74C3C),
    '스포츠': Color(0xFFF39C12),
    'IT': Color(0xFF9B59B6),
    '경제': Color(0xFF1ABC9C),
    '국제': Color(0xFF34495E),
    '문화': Color(0xFFE67E22),
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      physics: BouncingScrollPhysics(),
      children: [
        // 날짜 선택기
        TimeMachineDateSelectorWidget(
          selectedDate: _selectedDate,
          onDateTap: _selectDate,
        ),

        SizedBox(height: 20.h),

        // 일일 요약
        TimeMachineDailySummaryWidget(
          summaryData: _getDailySummaryData(),
        ),

        SizedBox(height: 20.h),

        // 시간별 트렌드
        TimeMachineHourlyTrendsWidget(
          categoryColors: categoryColors,
          getKeywordsForHour: _getKeywordsForHour,
          availableTimes: [
            DateTime(2025, 1, 15, 0, 32),
            DateTime(2025, 1, 15, 1, 30),
            DateTime(2025, 1, 15, 2, 1),
            DateTime(2025, 1, 15, 2, 1),
            DateTime(2025, 1, 15, 8, 1),
            DateTime(2025, 1, 15, 16, 1),
            DateTime(2025, 1, 15, 18, 1),
            DateTime(2025, 1, 15, 19, 1),
            DateTime(2025, 1, 15, 20, 1),
            DateTime(2025, 1, 15, 21, 1),
            DateTime(2025, 1, 15, 23, 1)
            // API에서 받아온 DateTime 리스트들
          ],
        ),
        SizedBox(height: 20.h),

        // 워드클라우드
        TimeMachineWordCloudWidget(
          categoryColors: categoryColors,
          wordCloudImagePath: 'assets/img/items/word_cloud.png',
        ),

        SizedBox(height: 200.h),
      ],
    );
  }

  // 날짜 선택
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF19B3F6),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 일일 요약 데이터 생성
  Map<String, dynamic> _getDailySummaryData() {
    return {
      'topKeyword': '천국보다 아름다운',
      'topKeywordStats': '15.2만 검색',
      'topCategory': '연예',
      'topCategoryStats': '전체 40%',
      'topDiscussion': '갤럭시 S25',
      'topDiscussionStats': '댓글 1,847개 • 반응 3,291개',
      'insights': [
        {
          'icon': '🚀',
          'text': '연예계 이슈가 급부상하며 포켓몬 관련 밈이 대세로 자리잡았습니다.',
        },
        {
          'icon': '⏰',
          'text': '오후 9시경 검색량이 집중되며 IT 기기 관련 토론이 활발했습니다.',
        },
        {
          'icon': '📈',
          'text': '전체적으로 엔터테인먼트 콘텐츠에 대한 관심도가 크게 증가했습니다.',
        },
      ],
    };
  }

  // 시간별 키워드 데이터 (임시 데이터)
  List<Map<String, dynamic>> _getKeywordsForHour(int hour) {
    // 실제로는 API에서 가져올 데이터
    final baseKeywords = [
      {'keyword': '포켓몬 우유', 'category': '연예', 'change': 5},
      {'keyword': '갤럭시 S25', 'category': 'IT', 'change': -2},
      {'keyword': '크레딧카드 개코', 'category': '연예', 'change': 8},
      {'keyword': '파워에이드', 'category': '경제', 'change': 3},
      {'keyword': '소금 우유', 'category': '문화', 'change': -1},
      {'keyword': '김소현 복귀', 'category': '연예', 'change': 12},
      {'keyword': '링스틱', 'category': 'IT', 'change': 4},
      {'keyword': '투싹', 'category': '스포츠', 'change': -3},
      {'keyword': '갤럭시탭', 'category': 'IT', 'change': 6},
      {'keyword': '새마음', 'category': '사회', 'change': 1},
    ];

    // 시간대별로 약간씩 다른 데이터 반환 (실제로는 API에서 시간별 데이터를 가져옴)
    return baseKeywords;
  }
}
