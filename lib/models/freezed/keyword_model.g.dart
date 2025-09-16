// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyword_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KeywordImpl _$$KeywordImplFromJson(Map<String, dynamic> json) =>
    _$KeywordImpl(
      id: (json['id'] as num).toInt(),
      keyword: json['keyword'] as String,
      rank: (json['rank'] as num).toInt(),
      created_at: DateTime.parse(json['created_at'] as String),
      type1: json['type1'] ?? const [],
      type2: json['type2'] as String,
      type3: json['type3'] as String,
      category: json['category'] as String,
      references: json['references'],
      current_discussion_room:
          (json['current_discussion_room'] as num?)?.toInt(),
      rank_change: json['rank_change'] as String?,
    );

Map<String, dynamic> _$$KeywordImplToJson(_$KeywordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'keyword': instance.keyword,
      'rank': instance.rank,
      'created_at': instance.created_at.toIso8601String(),
      'type1': instance.type1,
      'type2': instance.type2,
      'type3': instance.type3,
      'category': instance.category,
      'references': instance.references,
      'current_discussion_room': instance.current_discussion_room,
      'rank_change': instance.rank_change,
    };

_$ReferenceImpl _$$ReferenceImplFromJson(Map<String, dynamic> json) =>
    _$ReferenceImpl(
      type: json['type'] as String,
      title: json['title'] as String,
      link: json['link'] as String,
      date: json['date'] as String,
      thumbnail: json['thumbnail'] as String?,
    );

Map<String, dynamic> _$$ReferenceImplToJson(_$ReferenceImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'link': instance.link,
      'date': instance.date,
      'thumbnail': instance.thumbnail,
    };
