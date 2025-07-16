// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capsule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CapsuleModelImpl _$$CapsuleModelImplFromJson(Map<String, dynamic> json) =>
    _$CapsuleModelImpl(
      date: json['date'] as String,
      top3Keywords: (json['top3_keywords'] as List<dynamic>?)
              ?.map((e) => Top3Keyword.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hourlyKeywords: (json['hourly_keywords'] as List<dynamic>?)
              ?.map((e) => HourlyKeyword.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$CapsuleModelImplToJson(_$CapsuleModelImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'top3_keywords': instance.top3Keywords,
      'hourly_keywords': instance.hourlyKeywords,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$Top3KeywordImpl _$$Top3KeywordImplFromJson(Map<String, dynamic> json) =>
    _$Top3KeywordImpl(
      keyword: json['keyword'] as String,
      score: (json['score'] as num).toDouble(),
      appearanceCount: (json['appearance_count'] as num).toInt(),
      avgRank: (json['avg_rank'] as num).toDouble(),
      lastKeywordId: (json['last_keyword_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$Top3KeywordImplToJson(_$Top3KeywordImpl instance) =>
    <String, dynamic>{
      'keyword': instance.keyword,
      'score': instance.score,
      'appearance_count': instance.appearanceCount,
      'avg_rank': instance.avgRank,
      'last_keyword_id': instance.lastKeywordId,
    };

_$HourlyKeywordImpl _$$HourlyKeywordImplFromJson(Map<String, dynamic> json) =>
    _$HourlyKeywordImpl(
      time: json['time'] as String,
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => SimpleKeyword.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$HourlyKeywordImplToJson(_$HourlyKeywordImpl instance) =>
    <String, dynamic>{
      'time': instance.time,
      'keywords': instance.keywords,
    };

_$SimpleKeywordImpl _$$SimpleKeywordImplFromJson(Map<String, dynamic> json) =>
    _$SimpleKeywordImpl(
      id: (json['id'] as num).toInt(),
      keyword: json['keyword'] as String,
      rank: (json['rank'] as num).toInt(),
      category: json['category'] as String,
      type2: json['type2'] as String?,
    );

Map<String, dynamic> _$$SimpleKeywordImplToJson(_$SimpleKeywordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'keyword': instance.keyword,
      'rank': instance.rank,
      'category': instance.category,
      'type2': instance.type2,
    };
