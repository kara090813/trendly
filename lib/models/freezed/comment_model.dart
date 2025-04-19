import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    required int id,
    @JsonKey(name: 'discussion_room_id') required int discussionRoomId,
    required String user,
    required String nick,
    required String comment,
    @JsonKey(name: 'is_sub_comment') required bool isSubComment,
    @JsonKey(name: 'parent_id') int? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'like_count') int? likeCount,
    @JsonKey(name: 'dislike_count') int? dislikeCount,
    int? replies,
    String? timeAgo,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
}

// 댓글 목록 변환 함수
List<Comment> parseComments(String jsonString) {
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => Comment.fromJson(json)).toList();
}