import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    required int id,
    required int discussion_room,
    String? ip_addr,
    required String user,
    required String password,
    required String nick,
    required String comment,
    @Default(0) int sub_comment_count,
    required bool is_sub_comment,
    int? parent,
    required DateTime created_at,
    @Default(0) int like_count,
    @Default(0) int dislike_count,

    // UI에서만 쓰이는 필드들은 여전히 남겨둠
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
