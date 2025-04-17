// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiscussionRoomImpl _$$DiscussionRoomImplFromJson(Map<String, dynamic> json) =>
    _$DiscussionRoomImpl(
      id: (json['id'] as num).toInt(),
      keyword: json['keyword'] as String,
      keywordIdList: (json['keyword_id_list'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      isClosed: json['is_closed'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      closedAt: json['closed_at'] == null
          ? null
          : DateTime.parse(json['closed_at'] as String),
      commentCount: (json['comment_count'] as num?)?.toInt(),
      commentSummary: json['comment_summary'] as String?,
      positiveCount: (json['positive_count'] as num?)?.toInt(),
      neutralCount: (json['neutral_count'] as num?)?.toInt(),
      negativeCount: (json['negative_count'] as num?)?.toInt(),
      sentimentSnapshot: (json['sentiment_snapshot'] as List<dynamic>?)
          ?.map((e) => SentimentSnapshot.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$DiscussionRoomImplToJson(
        _$DiscussionRoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'keyword': instance.keyword,
      'keyword_id_list': instance.keywordIdList,
      'is_closed': instance.isClosed,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'closed_at': instance.closedAt?.toIso8601String(),
      'comment_count': instance.commentCount,
      'comment_summary': instance.commentSummary,
      'positive_count': instance.positiveCount,
      'neutral_count': instance.neutralCount,
      'negative_count': instance.negativeCount,
      'sentiment_snapshot': instance.sentimentSnapshot,
    };

_$SentimentSnapshotImpl _$$SentimentSnapshotImplFromJson(
        Map<String, dynamic> json) =>
    _$SentimentSnapshotImpl(
      time: json['t'] as String,
      positive: (json['pos'] as num).toInt(),
      neutral: (json['neu'] as num).toInt(),
      negative: (json['neg'] as num).toInt(),
    );

Map<String, dynamic> _$$SentimentSnapshotImplToJson(
        _$SentimentSnapshotImpl instance) =>
    <String, dynamic>{
      't': instance.time,
      'pos': instance.positive,
      'neu': instance.neutral,
      'neg': instance.negative,
    };
