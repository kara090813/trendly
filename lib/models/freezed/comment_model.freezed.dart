// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return _Comment.fromJson(json);
}

/// @nodoc
mixin _$Comment {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'discussion_room_id')
  int get discussionRoomId => throw _privateConstructorUsedError;
  String get user => throw _privateConstructorUsedError;
  String get nick => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_sub_comment')
  bool get isSubComment => throw _privateConstructorUsedError;
  @JsonKey(name: 'parent_id')
  int? get parentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'sub_comment_count')
  int? get subCommentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'like_count')
  int? get likeCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'dislike_count')
  int? get dislikeCount => throw _privateConstructorUsedError;
  int? get replies => throw _privateConstructorUsedError;
  String? get timeAgo => throw _privateConstructorUsedError;

  /// Serializes this Comment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentCopyWith<Comment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentCopyWith<$Res> {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) then) =
      _$CommentCopyWithImpl<$Res, Comment>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'discussion_room_id') int discussionRoomId,
      String user,
      String nick,
      String comment,
      @JsonKey(name: 'is_sub_comment') bool isSubComment,
      @JsonKey(name: 'parent_id') int? parentId,
      @JsonKey(name: 'sub_comment_count') int? subCommentCount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'like_count') int? likeCount,
      @JsonKey(name: 'dislike_count') int? dislikeCount,
      int? replies,
      String? timeAgo});
}

/// @nodoc
class _$CommentCopyWithImpl<$Res, $Val extends Comment>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? discussionRoomId = null,
    Object? user = null,
    Object? nick = null,
    Object? comment = null,
    Object? isSubComment = null,
    Object? parentId = freezed,
    Object? subCommentCount = freezed,
    Object? createdAt = null,
    Object? likeCount = freezed,
    Object? dislikeCount = freezed,
    Object? replies = freezed,
    Object? timeAgo = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      discussionRoomId: null == discussionRoomId
          ? _value.discussionRoomId
          : discussionRoomId // ignore: cast_nullable_to_non_nullable
              as int,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      nick: null == nick
          ? _value.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      isSubComment: null == isSubComment
          ? _value.isSubComment
          : isSubComment // ignore: cast_nullable_to_non_nullable
              as bool,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int?,
      subCommentCount: freezed == subCommentCount
          ? _value.subCommentCount
          : subCommentCount // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      likeCount: freezed == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int?,
      dislikeCount: freezed == dislikeCount
          ? _value.dislikeCount
          : dislikeCount // ignore: cast_nullable_to_non_nullable
              as int?,
      replies: freezed == replies
          ? _value.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as int?,
      timeAgo: freezed == timeAgo
          ? _value.timeAgo
          : timeAgo // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentImplCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$$CommentImplCopyWith(
          _$CommentImpl value, $Res Function(_$CommentImpl) then) =
      __$$CommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'discussion_room_id') int discussionRoomId,
      String user,
      String nick,
      String comment,
      @JsonKey(name: 'is_sub_comment') bool isSubComment,
      @JsonKey(name: 'parent_id') int? parentId,
      @JsonKey(name: 'sub_comment_count') int? subCommentCount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'like_count') int? likeCount,
      @JsonKey(name: 'dislike_count') int? dislikeCount,
      int? replies,
      String? timeAgo});
}

/// @nodoc
class __$$CommentImplCopyWithImpl<$Res>
    extends _$CommentCopyWithImpl<$Res, _$CommentImpl>
    implements _$$CommentImplCopyWith<$Res> {
  __$$CommentImplCopyWithImpl(
      _$CommentImpl _value, $Res Function(_$CommentImpl) _then)
      : super(_value, _then);

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? discussionRoomId = null,
    Object? user = null,
    Object? nick = null,
    Object? comment = null,
    Object? isSubComment = null,
    Object? parentId = freezed,
    Object? subCommentCount = freezed,
    Object? createdAt = null,
    Object? likeCount = freezed,
    Object? dislikeCount = freezed,
    Object? replies = freezed,
    Object? timeAgo = freezed,
  }) {
    return _then(_$CommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      discussionRoomId: null == discussionRoomId
          ? _value.discussionRoomId
          : discussionRoomId // ignore: cast_nullable_to_non_nullable
              as int,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      nick: null == nick
          ? _value.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      isSubComment: null == isSubComment
          ? _value.isSubComment
          : isSubComment // ignore: cast_nullable_to_non_nullable
              as bool,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int?,
      subCommentCount: freezed == subCommentCount
          ? _value.subCommentCount
          : subCommentCount // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      likeCount: freezed == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int?,
      dislikeCount: freezed == dislikeCount
          ? _value.dislikeCount
          : dislikeCount // ignore: cast_nullable_to_non_nullable
              as int?,
      replies: freezed == replies
          ? _value.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as int?,
      timeAgo: freezed == timeAgo
          ? _value.timeAgo
          : timeAgo // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentImpl implements _Comment {
  const _$CommentImpl(
      {required this.id,
      @JsonKey(name: 'discussion_room_id') required this.discussionRoomId,
      required this.user,
      required this.nick,
      required this.comment,
      @JsonKey(name: 'is_sub_comment') required this.isSubComment,
      @JsonKey(name: 'parent_id') this.parentId,
      @JsonKey(name: 'sub_comment_count') this.subCommentCount,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'like_count') this.likeCount,
      @JsonKey(name: 'dislike_count') this.dislikeCount,
      this.replies,
      this.timeAgo});

  factory _$CommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'discussion_room_id')
  final int discussionRoomId;
  @override
  final String user;
  @override
  final String nick;
  @override
  final String comment;
  @override
  @JsonKey(name: 'is_sub_comment')
  final bool isSubComment;
  @override
  @JsonKey(name: 'parent_id')
  final int? parentId;
  @override
  @JsonKey(name: 'sub_comment_count')
  final int? subCommentCount;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'like_count')
  final int? likeCount;
  @override
  @JsonKey(name: 'dislike_count')
  final int? dislikeCount;
  @override
  final int? replies;
  @override
  final String? timeAgo;

  @override
  String toString() {
    return 'Comment(id: $id, discussionRoomId: $discussionRoomId, user: $user, nick: $nick, comment: $comment, isSubComment: $isSubComment, parentId: $parentId, subCommentCount: $subCommentCount, createdAt: $createdAt, likeCount: $likeCount, dislikeCount: $dislikeCount, replies: $replies, timeAgo: $timeAgo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.discussionRoomId, discussionRoomId) ||
                other.discussionRoomId == discussionRoomId) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.nick, nick) || other.nick == nick) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.isSubComment, isSubComment) ||
                other.isSubComment == isSubComment) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.subCommentCount, subCommentCount) ||
                other.subCommentCount == subCommentCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.dislikeCount, dislikeCount) ||
                other.dislikeCount == dislikeCount) &&
            (identical(other.replies, replies) || other.replies == replies) &&
            (identical(other.timeAgo, timeAgo) || other.timeAgo == timeAgo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      discussionRoomId,
      user,
      nick,
      comment,
      isSubComment,
      parentId,
      subCommentCount,
      createdAt,
      likeCount,
      dislikeCount,
      replies,
      timeAgo);

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      __$$CommentImplCopyWithImpl<_$CommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentImplToJson(
      this,
    );
  }
}

abstract class _Comment implements Comment {
  const factory _Comment(
      {required final int id,
      @JsonKey(name: 'discussion_room_id') required final int discussionRoomId,
      required final String user,
      required final String nick,
      required final String comment,
      @JsonKey(name: 'is_sub_comment') required final bool isSubComment,
      @JsonKey(name: 'parent_id') final int? parentId,
      @JsonKey(name: 'sub_comment_count') final int? subCommentCount,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'like_count') final int? likeCount,
      @JsonKey(name: 'dislike_count') final int? dislikeCount,
      final int? replies,
      final String? timeAgo}) = _$CommentImpl;

  factory _Comment.fromJson(Map<String, dynamic> json) = _$CommentImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'discussion_room_id')
  int get discussionRoomId;
  @override
  String get user;
  @override
  String get nick;
  @override
  String get comment;
  @override
  @JsonKey(name: 'is_sub_comment')
  bool get isSubComment;
  @override
  @JsonKey(name: 'parent_id')
  int? get parentId;
  @override
  @JsonKey(name: 'sub_comment_count')
  int? get subCommentCount;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'like_count')
  int? get likeCount;
  @override
  @JsonKey(name: 'dislike_count')
  int? get dislikeCount;
  @override
  int? get replies;
  @override
  String? get timeAgo;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
