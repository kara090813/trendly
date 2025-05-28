// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: (json['id'] as num).toInt(),
      discussionRoomId: (json['discussion_room'] as num).toInt(),
      ipAddr: json['ip_addr'] as String,
      user: json['user'] as String,
      password: json['password'] as String,
      nick: json['nick'] as String,
      comment: json['comment'] as String,
      isSubComment: json['is_sub_comment'] as bool,
      parentId: (json['parent'] as num?)?.toInt(),
      subCommentCount: (json['sub_comment_count'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      likeCount: (json['like_count'] as num?)?.toInt(),
      dislikeCount: (json['dislike_count'] as num?)?.toInt(),
      replies: (json['replies'] as num?)?.toInt(),
      timeAgo: json['timeAgo'] as String?,
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'discussion_room': instance.discussionRoomId,
      'ip_addr': instance.ipAddr,
      'user': instance.user,
      'password': instance.password,
      'nick': instance.nick,
      'comment': instance.comment,
      'is_sub_comment': instance.isSubComment,
      'parent': instance.parentId,
      'sub_comment_count': instance.subCommentCount,
      'created_at': instance.createdAt.toIso8601String(),
      'like_count': instance.likeCount,
      'dislike_count': instance.dislikeCount,
      'replies': instance.replies,
      'timeAgo': instance.timeAgo,
    };
