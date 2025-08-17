// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiscussionRoomImpl _$$DiscussionRoomImplFromJson(Map<String, dynamic> json) =>
    _$DiscussionRoomImpl(
      id: (json['id'] as num).toInt(),
      keyword: json['keyword'] as String,
      category: json['category'] as String,
      keyword_id_list: (json['keyword_id_list'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      is_closed: json['is_closed'] as bool? ?? false,
      created_at: DateTime.parse(json['created_at'] as String),
      updated_at: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      closed_at: json['closed_at'] == null
          ? null
          : DateTime.parse(json['closed_at'] as String),
      comment_count: (json['comment_count'] as num?)?.toInt(),
      comment_summary: json['comment_summary'] as String?,
      positive_count: (json['positive_count'] as num?)?.toInt() ?? 0,
      neutral_count: (json['neutral_count'] as num?)?.toInt() ?? 0,
      negative_count: (json['negative_count'] as num?)?.toInt() ?? 0,
      sentiment_snapshot: (json['sentiment_snapshot'] as List<dynamic>?)
              ?.map(
                  (e) => SentimentSnapshot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$DiscussionRoomImplToJson(
        _$DiscussionRoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'keyword': instance.keyword,
      'category': instance.category,
      'keyword_id_list': instance.keyword_id_list,
      'is_closed': instance.is_closed,
      'created_at': instance.created_at.toIso8601String(),
      'updated_at': instance.updated_at?.toIso8601String(),
      'closed_at': instance.closed_at?.toIso8601String(),
      'comment_count': instance.comment_count,
      'comment_summary': instance.comment_summary,
      'positive_count': instance.positive_count,
      'neutral_count': instance.neutral_count,
      'negative_count': instance.negative_count,
      'sentiment_snapshot': instance.sentiment_snapshot,
    };

_$SentimentSnapshotImpl _$$SentimentSnapshotImplFromJson(
        Map<String, dynamic> json) =>
    _$SentimentSnapshotImpl(
      t: json['t'] as String,
      pos: (json['pos'] as num).toInt(),
      neu: (json['neu'] as num).toInt(),
      neg: (json['neg'] as num).toInt(),
    );

Map<String, dynamic> _$$SentimentSnapshotImplToJson(
        _$SentimentSnapshotImpl instance) =>
    <String, dynamic>{
      't': instance.t,
      'pos': instance.pos,
      'neu': instance.neu,
      'neg': instance.neg,
    };
