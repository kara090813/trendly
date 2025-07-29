import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter_state_model.freezed.dart';
part 'filter_state_model.g.dart';

@freezed
class HistoryFilterState with _$HistoryFilterState {
  const factory HistoryFilterState({
    // 기존 필드들 (이전 호환성 유지)
    @Default('') String searchQuery,
    @Default('전체') String selectedCategory,
    @Default('newest') String sortOption,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? minComments,
    int? maxComments,
    @Default([]) List<String> categories,
    @Default('all') String sentimentFilter,
    @Default(false) bool isAdvancedMode,
    
    // DiscussionRoom 모델 기반 새 필터들
    // 날짜 범위 필터 (created_at, updated_at, closed_at 기준)
    DateTime? dateFromCreated,
    DateTime? dateToCreated,
    DateTime? dateFromClosed,
    DateTime? dateToClosed,
    DateTime? dateFromUpdated,
    DateTime? dateToUpdated,
    @Default('created_at') String dateFilterType, // 'created_at', 'updated_at', 'closed_at'
    
    // 감정 반응 필터 (positive_count, neutral_count, negative_count)
    int? minPositiveReactions,
    int? maxPositiveReactions,
    int? minNeutralReactions,
    int? maxNeutralReactions,
    int? minNegativeReactions,
    int? maxNegativeReactions,
    int? minTotalReactions,
    int? maxTotalReactions,
    @Default('all') String dominantSentiment, // 'positive', 'neutral', 'negative', 'all'
    
    // 토론방 상태 필터 (is_closed)
    @Default('all') String roomStatus, // 'all', 'closed', 'active'
    
    // 키워드 관련 필터 (keyword_id_list)
    @Default([]) List<int> relatedKeywordIds,
    @Default(false) bool hasMultipleKeywords,
    
    // 기타 필터
    @Default(false) bool hasSummary, // comment_summary가 있는지
    
    // 시간대별 필터
    @Default('all') String timeOfDay, // 'morning', 'afternoon', 'evening', 'night', 'all'
    @Default('all') String dayOfWeek, // 'monday', 'tuesday', ..., 'weekend', 'weekday', 'all'
    
    // 활동 수준 필터
    @Default('all') String activityLevel, // 'high', 'medium', 'low', 'all' (댓글+반응 기준)
  }) = _HistoryFilterState;

  factory HistoryFilterState.fromJson(Map<String, dynamic> json) =>
      _$HistoryFilterStateFromJson(json);
}

extension HistoryFilterStateExtension on HistoryFilterState {
  /// POST 요청 body용 필터 데이터 생성 (API 명세서 기준)
  Map<String, dynamic> toPostFilters() {
    final filters = <String, dynamic>{};
    
    // 검색 필터
    if (searchQuery.isNotEmpty) {
      filters['search'] = searchQuery;
    }
    
    // 날짜 필터 - API 명세서에 맞게 수정
    switch (dateFilterType) {
      case 'created_at':
        if (dateFromCreated != null) {
          filters['created_from'] = dateFromCreated!.toIso8601String();
        }
        if (dateToCreated != null) {
          filters['created_to'] = dateToCreated!.toIso8601String();
        }
        break;
      case 'updated_at':
        if (dateFromUpdated != null) {
          filters['updated_from'] = dateFromUpdated!.toIso8601String();
        }
        if (dateToUpdated != null) {
          filters['updated_to'] = dateToUpdated!.toIso8601String();
        }
        break;
      case 'closed_at':
        if (dateFromClosed != null) {
          filters['closed_from'] = dateFromClosed!.toIso8601String();
        }
        if (dateToClosed != null) {
          filters['closed_to'] = dateToClosed!.toIso8601String();
        }
        break;
    }
    
    // 댓글 수 필터
    if (minComments != null) {
      filters['min_comments'] = minComments;
    }
    if (maxComments != null) {
      filters['max_comments'] = maxComments;
    }
    
    // 감정 반응 필터
    if (minPositiveReactions != null) {
      filters['min_positive'] = minPositiveReactions;
    }
    if (maxPositiveReactions != null) {
      filters['max_positive'] = maxPositiveReactions;
    }
    if (minNeutralReactions != null) {
      filters['min_neutral'] = minNeutralReactions;
    }
    if (maxNeutralReactions != null) {
      filters['max_neutral'] = maxNeutralReactions;
    }
    if (minNegativeReactions != null) {
      filters['min_negative'] = minNegativeReactions;
    }
    if (maxNegativeReactions != null) {
      filters['max_negative'] = maxNegativeReactions;
    }
    if (minTotalReactions != null) {
      filters['min_total_reactions'] = minTotalReactions;
    }
    if (maxTotalReactions != null) {
      filters['max_total_reactions'] = maxTotalReactions;
    }
    
    // 지배적 감정 필터
    if (dominantSentiment != 'all') {
      filters['dominant_sentiment'] = dominantSentiment;
    }
    
    // 활동 수준 필터
    if (activityLevel != 'all') {
      filters['activity_level'] = activityLevel;
    }
    
    // 요약 존재 여부
    if (hasSummary) {
      filters['has_summary'] = true;
    }
    
    // 시간대 필터
    if (timeOfDay != 'all') {
      filters['time_of_day'] = timeOfDay;
    }
    
    // 요일 필터
    if (dayOfWeek != 'all') {
      filters['day_of_week'] = dayOfWeek;
    }
    
    return filters;
  }

  /// 레거시 호환성을 위한 API 필터 (기존 코드용)
  Map<String, dynamic> toApiFilters() {
    final filters = <String, dynamic>{};
    
    // 검색 및 카테고리
    if (searchQuery.isNotEmpty) {
      filters['search'] = searchQuery;
    }
    
    if (selectedCategory != '전체') {
      filters['category'] = [selectedCategory];
    }
    
    // 날짜 필터
    switch (dateFilterType) {
      case 'created_at':
        if (dateFromCreated != null) {
          filters['created_from'] = dateFromCreated!.toIso8601String();
        }
        if (dateToCreated != null) {
          filters['created_to'] = dateToCreated!.toIso8601String();
        }
        break;
      case 'updated_at':
        if (dateFromUpdated != null) {
          filters['updated_from'] = dateFromUpdated!.toIso8601String();
        }
        if (dateToUpdated != null) {
          filters['updated_to'] = dateToUpdated!.toIso8601String();
        }
        break;
      case 'closed_at':
        if (dateFromClosed != null) {
          filters['closed_from'] = dateFromClosed!.toIso8601String();
        }
        if (dateToClosed != null) {
          filters['closed_to'] = dateToClosed!.toIso8601String();
        }
        break;
    }
    
    // 이전 호환성을 위한 dateFrom/dateTo 처리
    if (dateFrom != null) {
      filters['date_from'] = dateFrom!.toIso8601String();
    }
    if (dateTo != null) {
      filters['date_to'] = dateTo!.toIso8601String();
    }
    
    // 댓글 수 필터
    if (minComments != null) {
      filters['min_comments'] = minComments;
    }
    if (maxComments != null) {
      filters['max_comments'] = maxComments;
    }
    
    // 감정 반응 필터
    if (minPositiveReactions != null) {
      filters['min_positive'] = minPositiveReactions;
    }
    if (maxPositiveReactions != null) {
      filters['max_positive'] = maxPositiveReactions;
    }
    if (minNeutralReactions != null) {
      filters['min_neutral'] = minNeutralReactions;
    }
    if (maxNeutralReactions != null) {
      filters['max_neutral'] = maxNeutralReactions;
    }
    if (minNegativeReactions != null) {
      filters['min_negative'] = minNegativeReactions;
    }
    if (maxNegativeReactions != null) {
      filters['max_negative'] = maxNegativeReactions;
    }
    if (minTotalReactions != null) {
      filters['min_total_reactions'] = minTotalReactions;
    }
    if (maxTotalReactions != null) {
      filters['max_total_reactions'] = maxTotalReactions;
    }
    
    if (dominantSentiment != 'all') {
      filters['dominant_sentiment'] = dominantSentiment;
    }
    
    // 토론방 상태
    if (roomStatus != 'all') {
      filters['is_closed'] = roomStatus == 'closed';
    }
    
    // 키워드 관련
    if (relatedKeywordIds.isNotEmpty) {
      filters['related_keywords'] = relatedKeywordIds;
    }
    if (hasMultipleKeywords) {
      filters['has_multiple_keywords'] = true;
    }
    
    // 기타 필터
    if (hasSummary) {
      filters['has_summary'] = true;
    }
    
    if (timeOfDay != 'all') {
      filters['time_of_day'] = timeOfDay;
    }
    
    if (dayOfWeek != 'all') {
      filters['day_of_week'] = dayOfWeek;
    }
    
    if (activityLevel != 'all') {
      filters['activity_level'] = activityLevel;
    }
    
    filters['sort'] = sortOption;
    
    // 이전 호환성을 위한 sentimentFilter 처리
    if (sentimentFilter != 'all') {
      filters['sentiment_ratio'] = sentimentFilter;
    }
    
    return filters;
  }
  
  String generateCacheKey() {
    final keyParts = [
      'history',
      searchQuery,
      selectedCategory,
      sortOption,
      dateFilterType,
      dateFromCreated?.millisecondsSinceEpoch.toString() ?? '',
      dateToCreated?.millisecondsSinceEpoch.toString() ?? '',
      dateFromClosed?.millisecondsSinceEpoch.toString() ?? '',
      dateToClosed?.millisecondsSinceEpoch.toString() ?? '',
      dateFromUpdated?.millisecondsSinceEpoch.toString() ?? '',
      dateToUpdated?.millisecondsSinceEpoch.toString() ?? '',
      dateFrom?.millisecondsSinceEpoch.toString() ?? '',
      dateTo?.millisecondsSinceEpoch.toString() ?? '',
      minComments?.toString() ?? '',
      maxComments?.toString() ?? '',
      minPositiveReactions?.toString() ?? '',
      maxPositiveReactions?.toString() ?? '',
      minNeutralReactions?.toString() ?? '',
      maxNeutralReactions?.toString() ?? '',
      minNegativeReactions?.toString() ?? '',
      maxNegativeReactions?.toString() ?? '',
      minTotalReactions?.toString() ?? '',
      maxTotalReactions?.toString() ?? '',
      dominantSentiment,
      roomStatus,
      relatedKeywordIds.join(','),
      hasMultipleKeywords.toString(),
      hasSummary.toString(),
      timeOfDay,
      dayOfWeek,
      activityLevel,
      sentimentFilter,
    ];
    
    return keyParts.join('_');
  }
  
  bool get hasActiveFilters {
    return searchQuery.isNotEmpty ||
           selectedCategory != '전체' ||
           dateFromCreated != null ||
           dateToCreated != null ||
           dateFromClosed != null ||
           dateToClosed != null ||
           dateFromUpdated != null ||
           dateToUpdated != null ||
           dateFrom != null ||
           dateTo != null ||
           minComments != null ||
           maxComments != null ||
           minPositiveReactions != null ||
           maxPositiveReactions != null ||
           minNeutralReactions != null ||
           maxNeutralReactions != null ||
           minNegativeReactions != null ||
           maxNegativeReactions != null ||
           minTotalReactions != null ||
           maxTotalReactions != null ||
           dominantSentiment != 'all' ||
           roomStatus != 'all' ||
           relatedKeywordIds.isNotEmpty ||
           hasMultipleKeywords ||
           hasSummary ||
           timeOfDay != 'all' ||
           dayOfWeek != 'all' ||
           activityLevel != 'all' ||
           sentimentFilter != 'all';
  }
  
  int get filterComplexity {
    int complexity = 0;
    if (searchQuery.isNotEmpty) complexity++;
    if (selectedCategory != '전체') complexity++;
    if (dateFromCreated != null || dateToCreated != null || 
        dateFromClosed != null || dateToClosed != null ||
        dateFromUpdated != null || dateToUpdated != null ||
        dateFrom != null || dateTo != null) complexity++;
    if (minComments != null || maxComments != null) complexity++;
    if (minPositiveReactions != null || maxPositiveReactions != null ||
        minNeutralReactions != null || maxNeutralReactions != null ||
        minNegativeReactions != null || maxNegativeReactions != null ||
        minTotalReactions != null || maxTotalReactions != null) complexity++;
    if (dominantSentiment != 'all') complexity++;
    if (roomStatus != 'all') complexity++;
    if (relatedKeywordIds.isNotEmpty) complexity++;
    if (hasMultipleKeywords) complexity++;
    if (hasSummary) complexity++;
    if (timeOfDay != 'all') complexity++;
    if (dayOfWeek != 'all') complexity++;
    if (activityLevel != 'all') complexity++;
    if (sentimentFilter != 'all') complexity++;
    return complexity;
  }
  
  // 필터 리셋
  HistoryFilterState resetFilters() {
    return const HistoryFilterState();
  }
  
  // 빠른 필터 프리셋
  HistoryFilterState applyPreset(String presetName) {
    switch (presetName) {
      case 'high_activity':
        return copyWith(
          minComments: 10,
          minTotalReactions: 5,
          activityLevel: 'high',
        );
      case 'recent_week':
        return copyWith(
          dateFromCreated: DateTime.now().subtract(Duration(days: 7)),
          dateToCreated: DateTime.now(),
          dateFilterType: 'created_at',
        );
      case 'popular_discussions':
        return copyWith(
          sortOption: 'popular',
          minTotalReactions: 3,
          dominantSentiment: 'positive',
        );
      case 'controversial':
        return copyWith(
          minNegativeReactions: 2,
          minPositiveReactions: 2,
          sortOption: 'popular',
        );
      case 'long_discussions':
        return copyWith(
          minComments: 20,
          sortOption: 'active',
        );
      default:
        return this;
    }
  }
  
  // 활동 수준 계산 헬퍼
  String calculateActivityLevel(int commentCount, int totalReactions) {
    final score = commentCount + (totalReactions * 0.5);
    if (score >= 20) return 'high';
    if (score >= 5) return 'medium';
    return 'low';
  }
  
  // 지배적 감정 계산 헬퍼
  String calculateDominantSentiment(int positive, int neutral, int negative) {
    if (positive >= neutral && positive >= negative) return 'positive';
    if (negative >= neutral && negative >= positive) return 'negative';
    return 'neutral';
  }
}