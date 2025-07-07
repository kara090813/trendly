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
  int get discussion_room => throw _privateConstructorUsedError;
  String? get ip_addr => throw _privateConstructorUsedError;
  String get user => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get nick => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;
  int get sub_comment_count => throw _privateConstructorUsedError;
  bool get is_sub_comment => throw _privateConstructorUsedError;
  int? get parent => throw _privateConstructorUsedError;
  DateTime get created_at => throw _privateConstructorUsedError;
  int get like_count => throw _privateConstructorUsedError;
  int get dislike_count =>
      throw _privateConstructorUsedError; // UI에서만 쓰이는 필드들은 여전히 남겨둠
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
      int discussion_room,
      String? ip_addr,
      String user,
      String password,
      String nick,
      String comment,
      int sub_comment_count,
      bool is_sub_comment,
      int? parent,
      DateTime created_at,
      int like_count,
      int dislike_count,
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
    Object? discussion_room = null,
    Object? ip_addr = freezed,
    Object? user = null,
    Object? password = null,
    Object? nick = null,
    Object? comment = null,
    Object? sub_comment_count = null,
    Object? is_sub_comment = null,
    Object? parent = freezed,
    Object? created_at = null,
    Object? like_count = null,
    Object? dislike_count = null,
    Object? replies = freezed,
    Object? timeAgo = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      discussion_room: null == discussion_room
          ? _value.discussion_room
          : discussion_room // ignore: cast_nullable_to_non_nullable
              as int,
      ip_addr: freezed == ip_addr
          ? _value.ip_addr
          : ip_addr // ignore: cast_nullable_to_non_nullable
              as String?,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      nick: null == nick
          ? _value.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      sub_comment_count: null == sub_comment_count
          ? _value.sub_comment_count
          : sub_comment_count // ignore: cast_nullable_to_non_nullable
              as int,
      is_sub_comment: null == is_sub_comment
          ? _value.is_sub_comment
          : is_sub_comment // ignore: cast_nullable_to_non_nullable
              as bool,
      parent: freezed == parent
          ? _value.parent
          : parent // ignore: cast_nullable_to_non_nullable
              as int?,
      created_at: null == created_at
          ? _value.created_at
          : created_at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      like_count: null == like_count
          ? _value.like_count
          : like_count // ignore: cast_nullable_to_non_nullable
              as int,
      dislike_count: null == dislike_count
          ? _value.dislike_count
          : dislike_count // ignore: cast_nullable_to_non_nullable
              as int,
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
      int discussion_room,
      String? ip_addr,
      String user,
      String password,
      String nick,
      String comment,
      int sub_comment_count,
      bool is_sub_comment,
      int? parent,
      DateTime created_at,
      int like_count,
      int dislike_count,
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
    Object? discussion_room = null,
    Object? ip_addr = freezed,
    Object? user = null,
    Object? password = null,
    Object? nick = null,
    Object? comment = null,
    Object? sub_comment_count = null,
    Object? is_sub_comment = null,
    Object? parent = freezed,
    Object? created_at = null,
    Object? like_count = null,
    Object? dislike_count = null,
    Object? replies = freezed,
    Object? timeAgo = freezed,
  }) {
    return _then(_$CommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      discussion_room: null == discussion_room
          ? _value.discussion_room
          : discussion_room // ignore: cast_nullable_to_non_nullable
              as int,
      ip_addr: freezed == ip_addr
          ? _value.ip_addr
          : ip_addr // ignore: cast_nullable_to_non_nullable
              as String?,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      nick: null == nick
          ? _value.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      sub_comment_count: null == sub_comment_count
          ? _value.sub_comment_count
          : sub_comment_count // ignore: cast_nullable_to_non_nullable
              as int,
      is_sub_comment: null == is_sub_comment
          ? _value.is_sub_comment
          : is_sub_comment // ignore: cast_nullable_to_non_nullable
              as bool,
      parent: freezed == parent
          ? _value.parent
          : parent // ignore: cast_nullable_to_non_nullable
              as int?,
      created_at: null == created_at
          ? _value.created_at
          : created_at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      like_count: null == like_count
          ? _value.like_count
          : like_count // ignore: cast_nullable_to_non_nullable
              as int,
      dislike_count: null == dislike_count
          ? _value.dislike_count
          : dislike_count // ignore: cast_nullable_to_non_nullable
              as int,
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
      required this.discussion_room,
      this.ip_addr,
      required this.user,
      required this.password,
      required this.nick,
      required this.comment,
      this.sub_comment_count = 0,
      required this.is_sub_comment,
      this.parent,
      required this.created_at,
      this.like_count = 0,
      this.dislike_count = 0,
      this.replies,
      this.timeAgo});

  factory _$CommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentImplFromJson(json);

  @override
  final int id;
  @override
  final int discussion_room;
  @override
  final String? ip_addr;
  @override
  final String user;
  @override
  final String password;
  @override
  final String nick;
  @override
  final String comment;
  @override
  @JsonKey()
  final int sub_comment_count;
  @override
  final bool is_sub_comment;
  @override
  final int? parent;
  @override
  final DateTime created_at;
  @override
  @JsonKey()
  final int like_count;
  @override
  @JsonKey()
  final int dislike_count;
// UI에서만 쓰이는 필드들은 여전히 남겨둠
  @override
  final int? replies;
  @override
  final String? timeAgo;

  @override
  String toString() {
    return 'Comment(id: $id, discussion_room: $discussion_room, ip_addr: $ip_addr, user: $user, password: $password, nick: $nick, comment: $comment, sub_comment_count: $sub_comment_count, is_sub_comment: $is_sub_comment, parent: $parent, created_at: $created_at, like_count: $like_count, dislike_count: $dislike_count, replies: $replies, timeAgo: $timeAgo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.discussion_room, discussion_room) ||
                other.discussion_room == discussion_room) &&
            (identical(other.ip_addr, ip_addr) || other.ip_addr == ip_addr) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.nick, nick) || other.nick == nick) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.sub_comment_count, sub_comment_count) ||
                other.sub_comment_count == sub_comment_count) &&
            (identical(other.is_sub_comment, is_sub_comment) ||
                other.is_sub_comment == is_sub_comment) &&
            (identical(other.parent, parent) || other.parent == parent) &&
            (identical(other.created_at, created_at) ||
                other.created_at == created_at) &&
            (identical(other.like_count, like_count) ||
                other.like_count == like_count) &&
            (identical(other.dislike_count, dislike_count) ||
                other.dislike_count == dislike_count) &&
            (identical(other.replies, replies) || other.replies == replies) &&
            (identical(other.timeAgo, timeAgo) || other.timeAgo == timeAgo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      discussion_room,
      ip_addr,
      user,
      password,
      nick,
      comment,
      sub_comment_count,
      is_sub_comment,
      parent,
      created_at,
      like_count,
      dislike_count,
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
      required final int discussion_room,
      final String? ip_addr,
      required final String user,
      required final String password,
      required final String nick,
      required final String comment,
      final int sub_comment_count,
      required final bool is_sub_comment,
      final int? parent,
      required final DateTime created_at,
      final int like_count,
      final int dislike_count,
      final int? replies,
      final String? timeAgo}) = _$CommentImpl;

  factory _Comment.fromJson(Map<String, dynamic> json) = _$CommentImpl.fromJson;

  @override
  int get id;
  @override
  int get discussion_room;
  @override
  String? get ip_addr;
  @override
  String get user;
  @override
  String get password;
  @override
  String get nick;
  @override
  String get comment;
  @override
  int get sub_comment_count;
  @override
  bool get is_sub_comment;
  @override
  int? get parent;
  @override
  DateTime get created_at;
  @override
  int get like_count;
  @override
  int get dislike_count; // UI에서만 쓰이는 필드들은 여전히 남겨둠
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
