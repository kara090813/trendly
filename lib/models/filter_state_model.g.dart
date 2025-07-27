// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HistoryFilterStateImpl _$$HistoryFilterStateImplFromJson(
        Map<String, dynamic> json) =>
    _$HistoryFilterStateImpl(
      searchQuery: json['searchQuery'] as String? ?? '',
      selectedCategory: json['selectedCategory'] as String? ?? '전체',
      sortOption: json['sortOption'] as String? ?? 'newest',
      dateFrom: json['dateFrom'] == null
          ? null
          : DateTime.parse(json['dateFrom'] as String),
      dateTo: json['dateTo'] == null
          ? null
          : DateTime.parse(json['dateTo'] as String),
      minComments: (json['minComments'] as num?)?.toInt(),
      maxComments: (json['maxComments'] as num?)?.toInt(),
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sentimentFilter: json['sentimentFilter'] as String? ?? 'all',
      isAdvancedMode: json['isAdvancedMode'] as bool? ?? false,
      dateFromCreated: json['dateFromCreated'] == null
          ? null
          : DateTime.parse(json['dateFromCreated'] as String),
      dateToCreated: json['dateToCreated'] == null
          ? null
          : DateTime.parse(json['dateToCreated'] as String),
      dateFromClosed: json['dateFromClosed'] == null
          ? null
          : DateTime.parse(json['dateFromClosed'] as String),
      dateToClosed: json['dateToClosed'] == null
          ? null
          : DateTime.parse(json['dateToClosed'] as String),
      dateFromUpdated: json['dateFromUpdated'] == null
          ? null
          : DateTime.parse(json['dateFromUpdated'] as String),
      dateToUpdated: json['dateToUpdated'] == null
          ? null
          : DateTime.parse(json['dateToUpdated'] as String),
      dateFilterType: json['dateFilterType'] as String? ?? 'created_at',
      minPositiveReactions: (json['minPositiveReactions'] as num?)?.toInt(),
      maxPositiveReactions: (json['maxPositiveReactions'] as num?)?.toInt(),
      minNeutralReactions: (json['minNeutralReactions'] as num?)?.toInt(),
      maxNeutralReactions: (json['maxNeutralReactions'] as num?)?.toInt(),
      minNegativeReactions: (json['minNegativeReactions'] as num?)?.toInt(),
      maxNegativeReactions: (json['maxNegativeReactions'] as num?)?.toInt(),
      minTotalReactions: (json['minTotalReactions'] as num?)?.toInt(),
      maxTotalReactions: (json['maxTotalReactions'] as num?)?.toInt(),
      dominantSentiment: json['dominantSentiment'] as String? ?? 'all',
      roomStatus: json['roomStatus'] as String? ?? 'all',
      relatedKeywordIds: (json['relatedKeywordIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      hasMultipleKeywords: json['hasMultipleKeywords'] as bool? ?? false,
      hasSummary: json['hasSummary'] as bool? ?? false,
      timeOfDay: json['timeOfDay'] as String? ?? 'all',
      dayOfWeek: json['dayOfWeek'] as String? ?? 'all',
      activityLevel: json['activityLevel'] as String? ?? 'all',
    );

Map<String, dynamic> _$$HistoryFilterStateImplToJson(
        _$HistoryFilterStateImpl instance) =>
    <String, dynamic>{
      'searchQuery': instance.searchQuery,
      'selectedCategory': instance.selectedCategory,
      'sortOption': instance.sortOption,
      'dateFrom': instance.dateFrom?.toIso8601String(),
      'dateTo': instance.dateTo?.toIso8601String(),
      'minComments': instance.minComments,
      'maxComments': instance.maxComments,
      'categories': instance.categories,
      'sentimentFilter': instance.sentimentFilter,
      'isAdvancedMode': instance.isAdvancedMode,
      'dateFromCreated': instance.dateFromCreated?.toIso8601String(),
      'dateToCreated': instance.dateToCreated?.toIso8601String(),
      'dateFromClosed': instance.dateFromClosed?.toIso8601String(),
      'dateToClosed': instance.dateToClosed?.toIso8601String(),
      'dateFromUpdated': instance.dateFromUpdated?.toIso8601String(),
      'dateToUpdated': instance.dateToUpdated?.toIso8601String(),
      'dateFilterType': instance.dateFilterType,
      'minPositiveReactions': instance.minPositiveReactions,
      'maxPositiveReactions': instance.maxPositiveReactions,
      'minNeutralReactions': instance.minNeutralReactions,
      'maxNeutralReactions': instance.maxNeutralReactions,
      'minNegativeReactions': instance.minNegativeReactions,
      'maxNegativeReactions': instance.maxNegativeReactions,
      'minTotalReactions': instance.minTotalReactions,
      'maxTotalReactions': instance.maxTotalReactions,
      'dominantSentiment': instance.dominantSentiment,
      'roomStatus': instance.roomStatus,
      'relatedKeywordIds': instance.relatedKeywordIds,
      'hasMultipleKeywords': instance.hasMultipleKeywords,
      'hasSummary': instance.hasSummary,
      'timeOfDay': instance.timeOfDay,
      'dayOfWeek': instance.dayOfWeek,
      'activityLevel': instance.activityLevel,
    };
