// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: (json['id'] as num).toInt(),
      discussion_room: (json['discussion_room'] as num).toInt(),
      ip_addr: json['ip_addr'] as String?,
      user: json['user'] as String,
      password: json['password'] as String,
      nick: json['nick'] as String,
      comment: json['comment'] as String,
      sub_comment_count: (json['sub_comment_count'] as num?)?.toInt() ?? 0,
      is_sub_comment: json['is_sub_comment'] as bool,
      parent: (json['parent'] as num?)?.toInt(),
      created_at: DateTime.parse(json['created_at'] as String),
      like_count: (json['like_count'] as num?)?.toInt() ?? 0,
      dislike_count: (json['dislike_count'] as num?)?.toInt() ?? 0,
      replies: (json['replies'] as num?)?.toInt(),
      timeAgo: json['timeAgo'] as String?,
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'discussion_room': instance.discussion_room,
      'ip_addr': instance.ip_addr,
      'user': instance.user,
      'password': instance.password,
      'nick': instance.nick,
      'comment': instance.comment,
      'sub_comment_count': instance.sub_comment_count,
      'is_sub_comment': instance.is_sub_comment,
      'parent': instance.parent,
      'created_at': instance.created_at.toIso8601String(),
      'like_count': instance.like_count,
      'dislike_count': instance.dislike_count,
      'replies': instance.replies,
      'timeAgo': instance.timeAgo,
    };
