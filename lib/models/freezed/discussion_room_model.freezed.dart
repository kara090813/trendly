// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discussion_room_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DiscussionRoom _$DiscussionRoomFromJson(Map<String, dynamic> json) {
  return _DiscussionRoom.fromJson(json);
}

/// @nodoc
mixin _$DiscussionRoom {
  int get id => throw _privateConstructorUsedError;
  String get keyword => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  List<int> get keyword_id_list => throw _privateConstructorUsedError;
  bool get is_closed => throw _privateConstructorUsedError;
  DateTime get created_at => throw _privateConstructorUsedError;
  DateTime? get updated_at => throw _privateConstructorUsedError;
  DateTime? get closed_at => throw _privateConstructorUsedError;
  int? get comment_count => throw _privateConstructorUsedError;
  String? get comment_summary => throw _privateConstructorUsedError;
  int get positive_count => throw _privateConstructorUsedError;
  int get neutral_count => throw _privateConstructorUsedError;
  int get negative_count => throw _privateConstructorUsedError;
  List<SentimentSnapshot> get sentiment_snapshot =>
      throw _privateConstructorUsedError;

  /// Serializes this DiscussionRoom to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiscussionRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscussionRoomCopyWith<DiscussionRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionRoomCopyWith<$Res> {
  factory $DiscussionRoomCopyWith(
          DiscussionRoom value, $Res Function(DiscussionRoom) then) =
      _$DiscussionRoomCopyWithImpl<$Res, DiscussionRoom>;
  @useResult
  $Res call(
      {int id,
      String keyword,
      String category,
      List<int> keyword_id_list,
      bool is_closed,
      DateTime created_at,
      DateTime? updated_at,
      DateTime? closed_at,
      int? comment_count,
      String? comment_summary,
      int positive_count,
      int neutral_count,
      int negative_count,
      List<SentimentSnapshot> sentiment_snapshot});
}

/// @nodoc
class _$DiscussionRoomCopyWithImpl<$Res, $Val extends DiscussionRoom>
    implements $DiscussionRoomCopyWith<$Res> {
  _$DiscussionRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscussionRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? keyword = null,
    Object? category = null,
    Object? keyword_id_list = null,
    Object? is_closed = null,
    Object? created_at = null,
    Object? updated_at = freezed,
    Object? closed_at = freezed,
    Object? comment_count = freezed,
    Object? comment_summary = freezed,
    Object? positive_count = null,
    Object? neutral_count = null,
    Object? negative_count = null,
    Object? sentiment_snapshot = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      keyword: null == keyword
          ? _value.keyword
          : keyword // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      keyword_id_list: null == keyword_id_list
          ? _value.keyword_id_list
          : keyword_id_list // ignore: cast_nullable_to_non_nullable
              as List<int>,
      is_closed: null == is_closed
          ? _value.is_closed
          : is_closed // ignore: cast_nullable_to_non_nullable
              as bool,
      created_at: null == created_at
          ? _value.created_at
          : created_at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updated_at: freezed == updated_at
          ? _value.updated_at
          : updated_at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      closed_at: freezed == closed_at
          ? _value.closed_at
          : closed_at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      comment_count: freezed == comment_count
          ? _value.comment_count
          : comment_count // ignore: cast_nullable_to_non_nullable
              as int?,
      comment_summary: freezed == comment_summary
          ? _value.comment_summary
          : comment_summary // ignore: cast_nullable_to_non_nullable
              as String?,
      positive_count: null == positive_count
          ? _value.positive_count
          : positive_count // ignore: cast_nullable_to_non_nullable
              as int,
      neutral_count: null == neutral_count
          ? _value.neutral_count
          : neutral_count // ignore: cast_nullable_to_non_nullable
              as int,
      negative_count: null == negative_count
          ? _value.negative_count
          : negative_count // ignore: cast_nullable_to_non_nullable
              as int,
      sentiment_snapshot: null == sentiment_snapshot
          ? _value.sentiment_snapshot
          : sentiment_snapshot // ignore: cast_nullable_to_non_nullable
              as List<SentimentSnapshot>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiscussionRoomImplCopyWith<$Res>
    implements $DiscussionRoomCopyWith<$Res> {
  factory _$$DiscussionRoomImplCopyWith(_$DiscussionRoomImpl value,
          $Res Function(_$DiscussionRoomImpl) then) =
      __$$DiscussionRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String keyword,
      String category,
      List<int> keyword_id_list,
      bool is_closed,
      DateTime created_at,
      DateTime? updated_at,
      DateTime? closed_at,
      int? comment_count,
      String? comment_summary,
      int positive_count,
      int neutral_count,
      int negative_count,
      List<SentimentSnapshot> sentiment_snapshot});
}

/// @nodoc
class __$$DiscussionRoomImplCopyWithImpl<$Res>
    extends _$DiscussionRoomCopyWithImpl<$Res, _$DiscussionRoomImpl>
    implements _$$DiscussionRoomImplCopyWith<$Res> {
  __$$DiscussionRoomImplCopyWithImpl(
      _$DiscussionRoomImpl _value, $Res Function(_$DiscussionRoomImpl) _then)
      : super(_value, _then);

  /// Create a copy of DiscussionRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? keyword = null,
    Object? category = null,
    Object? keyword_id_list = null,
    Object? is_closed = null,
    Object? created_at = null,
    Object? updated_at = freezed,
    Object? closed_at = freezed,
    Object? comment_count = freezed,
    Object? comment_summary = freezed,
    Object? positive_count = null,
    Object? neutral_count = null,
    Object? negative_count = null,
    Object? sentiment_snapshot = null,
  }) {
    return _then(_$DiscussionRoomImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      keyword: null == keyword
          ? _value.keyword
          : keyword // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      keyword_id_list: null == keyword_id_list
          ? _value._keyword_id_list
          : keyword_id_list // ignore: cast_nullable_to_non_nullable
              as List<int>,
      is_closed: null == is_closed
          ? _value.is_closed
          : is_closed // ignore: cast_nullable_to_non_nullable
              as bool,
      created_at: null == created_at
          ? _value.created_at
          : created_at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updated_at: freezed == updated_at
          ? _value.updated_at
          : updated_at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      closed_at: freezed == closed_at
          ? _value.closed_at
          : closed_at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      comment_count: freezed == comment_count
          ? _value.comment_count
          : comment_count // ignore: cast_nullable_to_non_nullable
              as int?,
      comment_summary: freezed == comment_summary
          ? _value.comment_summary
          : comment_summary // ignore: cast_nullable_to_non_nullable
              as String?,
      positive_count: null == positive_count
          ? _value.positive_count
          : positive_count // ignore: cast_nullable_to_non_nullable
              as int,
      neutral_count: null == neutral_count
          ? _value.neutral_count
          : neutral_count // ignore: cast_nullable_to_non_nullable
              as int,
      negative_count: null == negative_count
          ? _value.negative_count
          : negative_count // ignore: cast_nullable_to_non_nullable
              as int,
      sentiment_snapshot: null == sentiment_snapshot
          ? _value._sentiment_snapshot
          : sentiment_snapshot // ignore: cast_nullable_to_non_nullable
              as List<SentimentSnapshot>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscussionRoomImpl implements _DiscussionRoom {
  const _$DiscussionRoomImpl(
      {required this.id,
      required this.keyword,
      required this.category,
      final List<int> keyword_id_list = const [],
      this.is_closed = false,
      required this.created_at,
      this.updated_at,
      this.closed_at,
      this.comment_count,
      this.comment_summary,
      this.positive_count = 0,
      this.neutral_count = 0,
      this.negative_count = 0,
      final List<SentimentSnapshot> sentiment_snapshot = const []})
      : _keyword_id_list = keyword_id_list,
        _sentiment_snapshot = sentiment_snapshot;

  factory _$DiscussionRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscussionRoomImplFromJson(json);

  @override
  final int id;
  @override
  final String keyword;
  @override
  final String category;
  final List<int> _keyword_id_list;
  @override
  @JsonKey()
  List<int> get keyword_id_list {
    if (_keyword_id_list is EqualUnmodifiableListView) return _keyword_id_list;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyword_id_list);
  }

  @override
  @JsonKey()
  final bool is_closed;
  @override
  final DateTime created_at;
  @override
  final DateTime? updated_at;
  @override
  final DateTime? closed_at;
  @override
  final int? comment_count;
  @override
  final String? comment_summary;
  @override
  @JsonKey()
  final int positive_count;
  @override
  @JsonKey()
  final int neutral_count;
  @override
  @JsonKey()
  final int negative_count;
  final List<SentimentSnapshot> _sentiment_snapshot;
  @override
  @JsonKey()
  List<SentimentSnapshot> get sentiment_snapshot {
    if (_sentiment_snapshot is EqualUnmodifiableListView)
      return _sentiment_snapshot;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sentiment_snapshot);
  }

  @override
  String toString() {
    return 'DiscussionRoom(id: $id, keyword: $keyword, category: $category, keyword_id_list: $keyword_id_list, is_closed: $is_closed, created_at: $created_at, updated_at: $updated_at, closed_at: $closed_at, comment_count: $comment_count, comment_summary: $comment_summary, positive_count: $positive_count, neutral_count: $neutral_count, negative_count: $negative_count, sentiment_snapshot: $sentiment_snapshot)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.keyword, keyword) || other.keyword == keyword) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality()
                .equals(other._keyword_id_list, _keyword_id_list) &&
            (identical(other.is_closed, is_closed) ||
                other.is_closed == is_closed) &&
            (identical(other.created_at, created_at) ||
                other.created_at == created_at) &&
            (identical(other.updated_at, updated_at) ||
                other.updated_at == updated_at) &&
            (identical(other.closed_at, closed_at) ||
                other.closed_at == closed_at) &&
            (identical(other.comment_count, comment_count) ||
                other.comment_count == comment_count) &&
            (identical(other.comment_summary, comment_summary) ||
                other.comment_summary == comment_summary) &&
            (identical(other.positive_count, positive_count) ||
                other.positive_count == positive_count) &&
            (identical(other.neutral_count, neutral_count) ||
                other.neutral_count == neutral_count) &&
            (identical(other.negative_count, negative_count) ||
                other.negative_count == negative_count) &&
            const DeepCollectionEquality()
                .equals(other._sentiment_snapshot, _sentiment_snapshot));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      keyword,
      category,
      const DeepCollectionEquality().hash(_keyword_id_list),
      is_closed,
      created_at,
      updated_at,
      closed_at,
      comment_count,
      comment_summary,
      positive_count,
      neutral_count,
      negative_count,
      const DeepCollectionEquality().hash(_sentiment_snapshot));

  /// Create a copy of DiscussionRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscussionRoomImplCopyWith<_$DiscussionRoomImpl> get copyWith =>
      __$$DiscussionRoomImplCopyWithImpl<_$DiscussionRoomImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscussionRoomImplToJson(
      this,
    );
  }
}

abstract class _DiscussionRoom implements DiscussionRoom {
  const factory _DiscussionRoom(
      {required final int id,
      required final String keyword,
      required final String category,
      final List<int> keyword_id_list,
      final bool is_closed,
      required final DateTime created_at,
      final DateTime? updated_at,
      final DateTime? closed_at,
      final int? comment_count,
      final String? comment_summary,
      final int positive_count,
      final int neutral_count,
      final int negative_count,
      final List<SentimentSnapshot> sentiment_snapshot}) = _$DiscussionRoomImpl;

  factory _DiscussionRoom.fromJson(Map<String, dynamic> json) =
      _$DiscussionRoomImpl.fromJson;

  @override
  int get id;
  @override
  String get keyword;
  @override
  String get category;
  @override
  List<int> get keyword_id_list;
  @override
  bool get is_closed;
  @override
  DateTime get created_at;
  @override
  DateTime? get updated_at;
  @override
  DateTime? get closed_at;
  @override
  int? get comment_count;
  @override
  String? get comment_summary;
  @override
  int get positive_count;
  @override
  int get neutral_count;
  @override
  int get negative_count;
  @override
  List<SentimentSnapshot> get sentiment_snapshot;

  /// Create a copy of DiscussionRoom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscussionRoomImplCopyWith<_$DiscussionRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SentimentSnapshot _$SentimentSnapshotFromJson(Map<String, dynamic> json) {
  return _SentimentSnapshot.fromJson(json);
}

/// @nodoc
mixin _$SentimentSnapshot {
  String get t => throw _privateConstructorUsedError;
  int get pos => throw _privateConstructorUsedError;
  int get neu => throw _privateConstructorUsedError;
  int get neg => throw _privateConstructorUsedError;

  /// Serializes this SentimentSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SentimentSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SentimentSnapshotCopyWith<SentimentSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SentimentSnapshotCopyWith<$Res> {
  factory $SentimentSnapshotCopyWith(
          SentimentSnapshot value, $Res Function(SentimentSnapshot) then) =
      _$SentimentSnapshotCopyWithImpl<$Res, SentimentSnapshot>;
  @useResult
  $Res call({String t, int pos, int neu, int neg});
}

/// @nodoc
class _$SentimentSnapshotCopyWithImpl<$Res, $Val extends SentimentSnapshot>
    implements $SentimentSnapshotCopyWith<$Res> {
  _$SentimentSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SentimentSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? t = null,
    Object? pos = null,
    Object? neu = null,
    Object? neg = null,
  }) {
    return _then(_value.copyWith(
      t: null == t
          ? _value.t
          : t // ignore: cast_nullable_to_non_nullable
              as String,
      pos: null == pos
          ? _value.pos
          : pos // ignore: cast_nullable_to_non_nullable
              as int,
      neu: null == neu
          ? _value.neu
          : neu // ignore: cast_nullable_to_non_nullable
              as int,
      neg: null == neg
          ? _value.neg
          : neg // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SentimentSnapshotImplCopyWith<$Res>
    implements $SentimentSnapshotCopyWith<$Res> {
  factory _$$SentimentSnapshotImplCopyWith(_$SentimentSnapshotImpl value,
          $Res Function(_$SentimentSnapshotImpl) then) =
      __$$SentimentSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String t, int pos, int neu, int neg});
}

/// @nodoc
class __$$SentimentSnapshotImplCopyWithImpl<$Res>
    extends _$SentimentSnapshotCopyWithImpl<$Res, _$SentimentSnapshotImpl>
    implements _$$SentimentSnapshotImplCopyWith<$Res> {
  __$$SentimentSnapshotImplCopyWithImpl(_$SentimentSnapshotImpl _value,
      $Res Function(_$SentimentSnapshotImpl) _then)
      : super(_value, _then);

  /// Create a copy of SentimentSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? t = null,
    Object? pos = null,
    Object? neu = null,
    Object? neg = null,
  }) {
    return _then(_$SentimentSnapshotImpl(
      t: null == t
          ? _value.t
          : t // ignore: cast_nullable_to_non_nullable
              as String,
      pos: null == pos
          ? _value.pos
          : pos // ignore: cast_nullable_to_non_nullable
              as int,
      neu: null == neu
          ? _value.neu
          : neu // ignore: cast_nullable_to_non_nullable
              as int,
      neg: null == neg
          ? _value.neg
          : neg // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SentimentSnapshotImpl implements _SentimentSnapshot {
  const _$SentimentSnapshotImpl(
      {required this.t,
      required this.pos,
      required this.neu,
      required this.neg});

  factory _$SentimentSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$SentimentSnapshotImplFromJson(json);

  @override
  final String t;
  @override
  final int pos;
  @override
  final int neu;
  @override
  final int neg;

  @override
  String toString() {
    return 'SentimentSnapshot(t: $t, pos: $pos, neu: $neu, neg: $neg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SentimentSnapshotImpl &&
            (identical(other.t, t) || other.t == t) &&
            (identical(other.pos, pos) || other.pos == pos) &&
            (identical(other.neu, neu) || other.neu == neu) &&
            (identical(other.neg, neg) || other.neg == neg));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, t, pos, neu, neg);

  /// Create a copy of SentimentSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SentimentSnapshotImplCopyWith<_$SentimentSnapshotImpl> get copyWith =>
      __$$SentimentSnapshotImplCopyWithImpl<_$SentimentSnapshotImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SentimentSnapshotImplToJson(
      this,
    );
  }
}

abstract class _SentimentSnapshot implements SentimentSnapshot {
  const factory _SentimentSnapshot(
      {required final String t,
      required final int pos,
      required final int neu,
      required final int neg}) = _$SentimentSnapshotImpl;

  factory _SentimentSnapshot.fromJson(Map<String, dynamic> json) =
      _$SentimentSnapshotImpl.fromJson;

  @override
  String get t;
  @override
  int get pos;
  @override
  int get neu;
  @override
  int get neg;

  /// Create a copy of SentimentSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SentimentSnapshotImplCopyWith<_$SentimentSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
