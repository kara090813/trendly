// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: (json['id'] as num).toInt(),
      discussionRoomId: (json['discussion_room_id'] as num).toInt(),
      user: json['user'] as String,
      nick: json['nick'] as String,
      comment: json['comment'] as String,
      isSubComment: json['is_sub_comment'] as bool,
      parentId: (json['parent_id'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      likeCount: (json['like_count'] as num?)?.toInt(),
      dislikeCount: (json['dislike_count'] as num?)?.toInt(),
      replies: (json['replies'] as num?)?.toInt(),
      timeAgo: json['timeAgo'] as String?,
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'discussion_room_id': instance.discussionRoomId,
      'user': instance.user,
      'nick': instance.nick,
      'comment': instance.comment,
      'is_sub_comment': instance.isSubComment,
      'parent_id': instance.parentId,
      'created_at': instance.createdAt.toIso8601String(),
      'like_count': instance.likeCount,
      'dislike_count': instance.dislikeCount,
      'replies': instance.replies,
      'timeAgo': instance.timeAgo,
    };
