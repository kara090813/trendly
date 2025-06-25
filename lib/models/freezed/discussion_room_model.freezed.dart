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
  @JsonKey(name: 'keyword_id_list')
  List<int> get keywordIdList => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_closed')
  bool get isClosed => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'closed_at')
  DateTime? get closedAt =>
      throw _privateConstructorUsedError; // comment_count에 null=True 추가
  @JsonKey(name: 'comment_count')
  int? get commentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'comment_summary')
  String? get commentSummary =>
      throw _privateConstructorUsedError; // 감정 반응 관련 필드 (기본값 추가)
  @JsonKey(name: 'positive_count')
  int get positiveCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'neutral_count')
  int get neutralCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'negative_count')
  int get negativeCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'sentiment_snapshot')
  List<SentimentSnapshot> get sentimentSnapshot =>
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
      @JsonKey(name: 'keyword_id_list') List<int> keywordIdList,
      @JsonKey(name: 'is_closed') bool isClosed,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'closed_at') DateTime? closedAt,
      @JsonKey(name: 'comment_count') int? commentCount,
      @JsonKey(name: 'comment_summary') String? commentSummary,
      @JsonKey(name: 'positive_count') int positiveCount,
      @JsonKey(name: 'neutral_count') int neutralCount,
      @JsonKey(name: 'negative_count') int negativeCount,
      @JsonKey(name: 'sentiment_snapshot')
      List<SentimentSnapshot> sentimentSnapshot});
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
    Object? keywordIdList = null,
    Object? isClosed = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? closedAt = freezed,
    Object? commentCount = freezed,
    Object? commentSummary = freezed,
    Object? positiveCount = null,
    Object? neutralCount = null,
    Object? negativeCount = null,
    Object? sentimentSnapshot = null,
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
      keywordIdList: null == keywordIdList
          ? _value.keywordIdList
          : keywordIdList // ignore: cast_nullable_to_non_nullable
              as List<int>,
      isClosed: null == isClosed
          ? _value.isClosed
          : isClosed // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      commentCount: freezed == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int?,
      commentSummary: freezed == commentSummary
          ? _value.commentSummary
          : commentSummary // ignore: cast_nullable_to_non_nullable
              as String?,
      positiveCount: null == positiveCount
          ? _value.positiveCount
          : positiveCount // ignore: cast_nullable_to_non_nullable
              as int,
      neutralCount: null == neutralCount
          ? _value.neutralCount
          : neutralCount // ignore: cast_nullable_to_non_nullable
              as int,
      negativeCount: null == negativeCount
          ? _value.negativeCount
          : negativeCount // ignore: cast_nullable_to_non_nullable
              as int,
      sentimentSnapshot: null == sentimentSnapshot
          ? _value.sentimentSnapshot
          : sentimentSnapshot // ignore: cast_nullable_to_non_nullable
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
      @JsonKey(name: 'keyword_id_list') List<int> keywordIdList,
      @JsonKey(name: 'is_closed') bool isClosed,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'closed_at') DateTime? closedAt,
      @JsonKey(name: 'comment_count') int? commentCount,
      @JsonKey(name: 'comment_summary') String? commentSummary,
      @JsonKey(name: 'positive_count') int positiveCount,
      @JsonKey(name: 'neutral_count') int neutralCount,
      @JsonKey(name: 'negative_count') int negativeCount,
      @JsonKey(name: 'sentiment_snapshot')
      List<SentimentSnapshot> sentimentSnapshot});
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
    Object? keywordIdList = null,
    Object? isClosed = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? closedAt = freezed,
    Object? commentCount = freezed,
    Object? commentSummary = freezed,
    Object? positiveCount = null,
    Object? neutralCount = null,
    Object? negativeCount = null,
    Object? sentimentSnapshot = null,
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
      keywordIdList: null == keywordIdList
          ? _value._keywordIdList
          : keywordIdList // ignore: cast_nullable_to_non_nullable
              as List<int>,
      isClosed: null == isClosed
          ? _value.isClosed
          : isClosed // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      commentCount: freezed == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int?,
      commentSummary: freezed == commentSummary
          ? _value.commentSummary
          : commentSummary // ignore: cast_nullable_to_non_nullable
              as String?,
      positiveCount: null == positiveCount
          ? _value.positiveCount
          : positiveCount // ignore: cast_nullable_to_non_nullable
              as int,
      neutralCount: null == neutralCount
          ? _value.neutralCount
          : neutralCount // ignore: cast_nullable_to_non_nullable
              as int,
      negativeCount: null == negativeCount
          ? _value.negativeCount
          : negativeCount // ignore: cast_nullable_to_non_nullable
              as int,
      sentimentSnapshot: null == sentimentSnapshot
          ? _value._sentimentSnapshot
          : sentimentSnapshot // ignore: cast_nullable_to_non_nullable
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
      @JsonKey(name: 'keyword_id_list')
      final List<int> keywordIdList = const [],
      @JsonKey(name: 'is_closed') this.isClosed = false,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'closed_at') this.closedAt,
      @JsonKey(name: 'comment_count') this.commentCount,
      @JsonKey(name: 'comment_summary') this.commentSummary,
      @JsonKey(name: 'positive_count') this.positiveCount = 0,
      @JsonKey(name: 'neutral_count') this.neutralCount = 0,
      @JsonKey(name: 'negative_count') this.negativeCount = 0,
      @JsonKey(name: 'sentiment_snapshot')
      final List<SentimentSnapshot> sentimentSnapshot = const []})
      : _keywordIdList = keywordIdList,
        _sentimentSnapshot = sentimentSnapshot;

  factory _$DiscussionRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscussionRoomImplFromJson(json);

  @override
  final int id;
  @override
  final String keyword;
  final List<int> _keywordIdList;
  @override
  @JsonKey(name: 'keyword_id_list')
  List<int> get keywordIdList {
    if (_keywordIdList is EqualUnmodifiableListView) return _keywordIdList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keywordIdList);
  }

  @override
  @JsonKey(name: 'is_closed')
  final bool isClosed;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'closed_at')
  final DateTime? closedAt;
// comment_count에 null=True 추가
  @override
  @JsonKey(name: 'comment_count')
  final int? commentCount;
  @override
  @JsonKey(name: 'comment_summary')
  final String? commentSummary;
// 감정 반응 관련 필드 (기본값 추가)
  @override
  @JsonKey(name: 'positive_count')
  final int positiveCount;
  @override
  @JsonKey(name: 'neutral_count')
  final int neutralCount;
  @override
  @JsonKey(name: 'negative_count')
  final int negativeCount;
  final List<SentimentSnapshot> _sentimentSnapshot;
  @override
  @JsonKey(name: 'sentiment_snapshot')
  List<SentimentSnapshot> get sentimentSnapshot {
    if (_sentimentSnapshot is EqualUnmodifiableListView)
      return _sentimentSnapshot;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sentimentSnapshot);
  }

  @override
  String toString() {
    return 'DiscussionRoom(id: $id, keyword: $keyword, keywordIdList: $keywordIdList, isClosed: $isClosed, createdAt: $createdAt, updatedAt: $updatedAt, closedAt: $closedAt, commentCount: $commentCount, commentSummary: $commentSummary, positiveCount: $positiveCount, neutralCount: $neutralCount, negativeCount: $negativeCount, sentimentSnapshot: $sentimentSnapshot)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.keyword, keyword) || other.keyword == keyword) &&
            const DeepCollectionEquality()
                .equals(other._keywordIdList, _keywordIdList) &&
            (identical(other.isClosed, isClosed) ||
                other.isClosed == isClosed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.commentSummary, commentSummary) ||
                other.commentSummary == commentSummary) &&
            (identical(other.positiveCount, positiveCount) ||
                other.positiveCount == positiveCount) &&
            (identical(other.neutralCount, neutralCount) ||
                other.neutralCount == neutralCount) &&
            (identical(other.negativeCount, negativeCount) ||
                other.negativeCount == negativeCount) &&
            const DeepCollectionEquality()
                .equals(other._sentimentSnapshot, _sentimentSnapshot));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      keyword,
      const DeepCollectionEquality().hash(_keywordIdList),
      isClosed,
      createdAt,
      updatedAt,
      closedAt,
      commentCount,
      commentSummary,
      positiveCount,
      neutralCount,
      negativeCount,
      const DeepCollectionEquality().hash(_sentimentSnapshot));

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
      @JsonKey(name: 'keyword_id_list') final List<int> keywordIdList,
      @JsonKey(name: 'is_closed') final bool isClosed,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt,
      @JsonKey(name: 'closed_at') final DateTime? closedAt,
      @JsonKey(name: 'comment_count') final int? commentCount,
      @JsonKey(name: 'comment_summary') final String? commentSummary,
      @JsonKey(name: 'positive_count') final int positiveCount,
      @JsonKey(name: 'neutral_count') final int neutralCount,
      @JsonKey(name: 'negative_count') final int negativeCount,
      @JsonKey(name: 'sentiment_snapshot')
      final List<SentimentSnapshot> sentimentSnapshot}) = _$DiscussionRoomImpl;

  factory _DiscussionRoom.fromJson(Map<String, dynamic> json) =
      _$DiscussionRoomImpl.fromJson;

  @override
  int get id;
  @override
  String get keyword;
  @override
  @JsonKey(name: 'keyword_id_list')
  List<int> get keywordIdList;
  @override
  @JsonKey(name: 'is_closed')
  bool get isClosed;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'closed_at')
  DateTime? get closedAt; // comment_count에 null=True 추가
  @override
  @JsonKey(name: 'comment_count')
  int? get commentCount;
  @override
  @JsonKey(name: 'comment_summary')
  String? get commentSummary; // 감정 반응 관련 필드 (기본값 추가)
  @override
  @JsonKey(name: 'positive_count')
  int get positiveCount;
  @override
  @JsonKey(name: 'neutral_count')
  int get neutralCount;
  @override
  @JsonKey(name: 'negative_count')
  int get negativeCount;
  @override
  @JsonKey(name: 'sentiment_snapshot')
  List<SentimentSnapshot> get sentimentSnapshot;

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
  @JsonKey(name: 't')
  String get time => throw _privateConstructorUsedError;
  @JsonKey(name: 'pos')
  int get positive => throw _privateConstructorUsedError;
  @JsonKey(name: 'neu')
  int get neutral => throw _privateConstructorUsedError;
  @JsonKey(name: 'neg')
  int get negative => throw _privateConstructorUsedError;

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
  $Res call(
      {@JsonKey(name: 't') String time,
      @JsonKey(name: 'pos') int positive,
      @JsonKey(name: 'neu') int neutral,
      @JsonKey(name: 'neg') int negative});
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
    Object? time = null,
    Object? positive = null,
    Object? neutral = null,
    Object? negative = null,
  }) {
    return _then(_value.copyWith(
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      positive: null == positive
          ? _value.positive
          : positive // ignore: cast_nullable_to_non_nullable
              as int,
      neutral: null == neutral
          ? _value.neutral
          : neutral // ignore: cast_nullable_to_non_nullable
              as int,
      negative: null == negative
          ? _value.negative
          : negative // ignore: cast_nullable_to_non_nullable
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
  $Res call(
      {@JsonKey(name: 't') String time,
      @JsonKey(name: 'pos') int positive,
      @JsonKey(name: 'neu') int neutral,
      @JsonKey(name: 'neg') int negative});
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
    Object? time = null,
    Object? positive = null,
    Object? neutral = null,
    Object? negative = null,
  }) {
    return _then(_$SentimentSnapshotImpl(
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      positive: null == positive
          ? _value.positive
          : positive // ignore: cast_nullable_to_non_nullable
              as int,
      neutral: null == neutral
          ? _value.neutral
          : neutral // ignore: cast_nullable_to_non_nullable
              as int,
      negative: null == negative
          ? _value.negative
          : negative // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SentimentSnapshotImpl implements _SentimentSnapshot {
  const _$SentimentSnapshotImpl(
      {@JsonKey(name: 't') required this.time,
      @JsonKey(name: 'pos') required this.positive,
      @JsonKey(name: 'neu') required this.neutral,
      @JsonKey(name: 'neg') required this.negative});

  factory _$SentimentSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$SentimentSnapshotImplFromJson(json);

  @override
  @JsonKey(name: 't')
  final String time;
  @override
  @JsonKey(name: 'pos')
  final int positive;
  @override
  @JsonKey(name: 'neu')
  final int neutral;
  @override
  @JsonKey(name: 'neg')
  final int negative;

  @override
  String toString() {
    return 'SentimentSnapshot(time: $time, positive: $positive, neutral: $neutral, negative: $negative)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SentimentSnapshotImpl &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.positive, positive) ||
                other.positive == positive) &&
            (identical(other.neutral, neutral) || other.neutral == neutral) &&
            (identical(other.negative, negative) ||
                other.negative == negative));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, time, positive, neutral, negative);

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
          {@JsonKey(name: 't') required final String time,
          @JsonKey(name: 'pos') required final int positive,
          @JsonKey(name: 'neu') required final int neutral,
          @JsonKey(name: 'neg') required final int negative}) =
      _$SentimentSnapshotImpl;

  factory _SentimentSnapshot.fromJson(Map<String, dynamic> json) =
      _$SentimentSnapshotImpl.fromJson;

  @override
  @JsonKey(name: 't')
  String get time;
  @override
  @JsonKey(name: 'pos')
  int get positive;
  @override
  @JsonKey(name: 'neu')
  int get neutral;
  @override
  @JsonKey(name: 'neg')
  int get negative;

  /// Create a copy of SentimentSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SentimentSnapshotImplCopyWith<_$SentimentSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
