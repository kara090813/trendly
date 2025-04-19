// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyword_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KeywordImpl _$$KeywordImplFromJson(Map<String, dynamic> json) =>
    _$KeywordImpl(
      id: (json['id'] as num).toInt(),
      keyword: json['keyword'] as String,
      category: json['category'] as String,
      rank: (json['rank'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      type1: (json['type1'] as List<dynamic>).map((e) => e as String).toList(),
      type2: json['type2'] as String,
      type3: json['type3'] as String,
      references: (json['references'] as List<dynamic>)
          .map((e) => Reference.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentDiscussionRoomId:
          (json['current_discussion_room_id'] as num).toInt(),
    );

Map<String, dynamic> _$$KeywordImplToJson(_$KeywordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'keyword': instance.keyword,
      'category': instance.category,
      'rank': instance.rank,
      'created_at': instance.createdAt.toIso8601String(),
      'type1': instance.type1,
      'type2': instance.type2,
      'type3': instance.type3,
      'references': instance.references,
      'current_discussion_room_id': instance.currentDiscussionRoomId,
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
