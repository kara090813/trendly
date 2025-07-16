// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capsule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CapsuleModel _$CapsuleModelFromJson(Map<String, dynamic> json) {
  return _CapsuleModel.fromJson(json);
}

/// @nodoc
mixin _$CapsuleModel {
  String get date => throw _privateConstructorUsedError;
  @JsonKey(name: 'top3_keywords')
  List<Top3Keyword> get top3Keywords => throw _privateConstructorUsedError;
  @JsonKey(name: 'hourly_keywords')
  List<HourlyKeyword> get hourlyKeywords => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CapsuleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CapsuleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CapsuleModelCopyWith<CapsuleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CapsuleModelCopyWith<$Res> {
  factory $CapsuleModelCopyWith(
          CapsuleModel value, $Res Function(CapsuleModel) then) =
      _$CapsuleModelCopyWithImpl<$Res, CapsuleModel>;
  @useResult
  $Res call(
      {String date,
      @JsonKey(name: 'top3_keywords') List<Top3Keyword> top3Keywords,
      @JsonKey(name: 'hourly_keywords') List<HourlyKeyword> hourlyKeywords,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$CapsuleModelCopyWithImpl<$Res, $Val extends CapsuleModel>
    implements $CapsuleModelCopyWith<$Res> {
  _$CapsuleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CapsuleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? top3Keywords = null,
    Object? hourlyKeywords = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      top3Keywords: null == top3Keywords
          ? _value.top3Keywords
          : top3Keywords // ignore: cast_nullable_to_non_nullable
              as List<Top3Keyword>,
      hourlyKeywords: null == hourlyKeywords
          ? _value.hourlyKeywords
          : hourlyKeywords // ignore: cast_nullable_to_non_nullable
              as List<HourlyKeyword>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CapsuleModelImplCopyWith<$Res>
    implements $CapsuleModelCopyWith<$Res> {
  factory _$$CapsuleModelImplCopyWith(
          _$CapsuleModelImpl value, $Res Function(_$CapsuleModelImpl) then) =
      __$$CapsuleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String date,
      @JsonKey(name: 'top3_keywords') List<Top3Keyword> top3Keywords,
      @JsonKey(name: 'hourly_keywords') List<HourlyKeyword> hourlyKeywords,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$CapsuleModelImplCopyWithImpl<$Res>
    extends _$CapsuleModelCopyWithImpl<$Res, _$CapsuleModelImpl>
    implements _$$CapsuleModelImplCopyWith<$Res> {
  __$$CapsuleModelImplCopyWithImpl(
      _$CapsuleModelImpl _value, $Res Function(_$CapsuleModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CapsuleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? top3Keywords = null,
    Object? hourlyKeywords = null,
    Object? createdAt = null,
  }) {
    return _then(_$CapsuleModelImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      top3Keywords: null == top3Keywords
          ? _value._top3Keywords
          : top3Keywords // ignore: cast_nullable_to_non_nullable
              as List<Top3Keyword>,
      hourlyKeywords: null == hourlyKeywords
          ? _value._hourlyKeywords
          : hourlyKeywords // ignore: cast_nullable_to_non_nullable
              as List<HourlyKeyword>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CapsuleModelImpl implements _CapsuleModel {
  const _$CapsuleModelImpl(
      {required this.date,
      @JsonKey(name: 'top3_keywords')
      final List<Top3Keyword> top3Keywords = const [],
      @JsonKey(name: 'hourly_keywords')
      final List<HourlyKeyword> hourlyKeywords = const [],
      @JsonKey(name: 'created_at') required this.createdAt})
      : _top3Keywords = top3Keywords,
        _hourlyKeywords = hourlyKeywords;

  factory _$CapsuleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CapsuleModelImplFromJson(json);

  @override
  final String date;
  final List<Top3Keyword> _top3Keywords;
  @override
  @JsonKey(name: 'top3_keywords')
  List<Top3Keyword> get top3Keywords {
    if (_top3Keywords is EqualUnmodifiableListView) return _top3Keywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_top3Keywords);
  }

  final List<HourlyKeyword> _hourlyKeywords;
  @override
  @JsonKey(name: 'hourly_keywords')
  List<HourlyKeyword> get hourlyKeywords {
    if (_hourlyKeywords is EqualUnmodifiableListView) return _hourlyKeywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hourlyKeywords);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'CapsuleModel(date: $date, top3Keywords: $top3Keywords, hourlyKeywords: $hourlyKeywords, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CapsuleModelImpl &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality()
                .equals(other._top3Keywords, _top3Keywords) &&
            const DeepCollectionEquality()
                .equals(other._hourlyKeywords, _hourlyKeywords) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      const DeepCollectionEquality().hash(_top3Keywords),
      const DeepCollectionEquality().hash(_hourlyKeywords),
      createdAt);

  /// Create a copy of CapsuleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CapsuleModelImplCopyWith<_$CapsuleModelImpl> get copyWith =>
      __$$CapsuleModelImplCopyWithImpl<_$CapsuleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CapsuleModelImplToJson(
      this,
    );
  }
}

abstract class _CapsuleModel implements CapsuleModel {
  const factory _CapsuleModel(
          {required final String date,
          @JsonKey(name: 'top3_keywords') final List<Top3Keyword> top3Keywords,
          @JsonKey(name: 'hourly_keywords')
          final List<HourlyKeyword> hourlyKeywords,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$CapsuleModelImpl;

  factory _CapsuleModel.fromJson(Map<String, dynamic> json) =
      _$CapsuleModelImpl.fromJson;

  @override
  String get date;
  @override
  @JsonKey(name: 'top3_keywords')
  List<Top3Keyword> get top3Keywords;
  @override
  @JsonKey(name: 'hourly_keywords')
  List<HourlyKeyword> get hourlyKeywords;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of CapsuleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CapsuleModelImplCopyWith<_$CapsuleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Top3Keyword _$Top3KeywordFromJson(Map<String, dynamic> json) {
  return _Top3Keyword.fromJson(json);
}

/// @nodoc
mixin _$Top3Keyword {
  String get keyword => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  @JsonKey(name: 'appearance_count')
  int get appearanceCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_rank')
  double get avgRank => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_keyword_id')
  int? get lastKeywordId => throw _privateConstructorUsedError;

  /// Serializes this Top3Keyword to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Top3Keyword
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $Top3KeywordCopyWith<Top3Keyword> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $Top3KeywordCopyWith<$Res> {
  factory $Top3KeywordCopyWith(
          Top3Keyword value, $Res Function(Top3Keyword) then) =
      _$Top3KeywordCopyWithImpl<$Res, Top3Keyword>;
  @useResult
  $Res call(
      {String keyword,
      double score,
      @JsonKey(name: 'appearance_count') int appearanceCount,
      @JsonKey(name: 'avg_rank') double avgRank,
      @JsonKey(name: 'last_keyword_id') int? lastKeywordId});
}

/// @nodoc
class _$Top3KeywordCopyWithImpl<$Res, $Val extends Top3Keyword>
    implements $Top3KeywordCopyWith<$Res> {
  _$Top3KeywordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Top3Keyword
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? keyword = null,
    Object? score = null,
    Object? appearanceCount = null,
    Object? avgRank = null,
    Object? lastKeywordId = freezed,
  }) {
    return _then(_value.copyWith(
      keyword: null == keyword
          ? _value.keyword
          : keyword // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      appearanceCount: null == appearanceCount
          ? _value.appearanceCount
          : appearanceCount // ignore: cast_nullable_to_non_nullable
              as int,
      avgRank: null == avgRank
          ? _value.avgRank
          : avgRank // ignore: cast_nullable_to_non_nullable
              as double,
      lastKeywordId: freezed == lastKeywordId
          ? _value.lastKeywordId
          : lastKeywordId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$Top3KeywordImplCopyWith<$Res>
    implements $Top3KeywordCopyWith<$Res> {
  factory _$$Top3KeywordImplCopyWith(
          _$Top3KeywordImpl value, $Res Function(_$Top3KeywordImpl) then) =
      __$$Top3KeywordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String keyword,
      double score,
      @JsonKey(name: 'appearance_count') int appearanceCount,
      @JsonKey(name: 'avg_rank') double avgRank,
      @JsonKey(name: 'last_keyword_id') int? lastKeywordId});
}

/// @nodoc
class __$$Top3KeywordImplCopyWithImpl<$Res>
    extends _$Top3KeywordCopyWithImpl<$Res, _$Top3KeywordImpl>
    implements _$$Top3KeywordImplCopyWith<$Res> {
  __$$Top3KeywordImplCopyWithImpl(
      _$Top3KeywordImpl _value, $Res Function(_$Top3KeywordImpl) _then)
      : super(_value, _then);

  /// Create a copy of Top3Keyword
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? keyword = null,
    Object? score = null,
    Object? appearanceCount = null,
    Object? avgRank = null,
    Object? lastKeywordId = freezed,
  }) {
    return _then(_$Top3KeywordImpl(
      keyword: null == keyword
          ? _value.keyword
          : keyword // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      appearanceCount: null == appearanceCount
          ? _value.appearanceCount
          : appearanceCount // ignore: cast_nullable_to_non_nullable
              as int,
      avgRank: null == avgRank
          ? _value.avgRank
          : avgRank // ignore: cast_nullable_to_non_nullable
              as double,
      lastKeywordId: freezed == lastKeywordId
          ? _value.lastKeywordId
          : lastKeywordId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$Top3KeywordImpl implements _Top3Keyword {
  const _$Top3KeywordImpl(
      {required this.keyword,
      required this.score,
      @JsonKey(name: 'appearance_count') required this.appearanceCount,
      @JsonKey(name: 'avg_rank') required this.avgRank,
      @JsonKey(name: 'last_keyword_id') this.lastKeywordId});

  factory _$Top3KeywordImpl.fromJson(Map<String, dynamic> json) =>
      _$$Top3KeywordImplFromJson(json);

  @override
  final String keyword;
  @override
  final double score;
  @override
  @JsonKey(name: 'appearance_count')
  final int appearanceCount;
  @override
  @JsonKey(name: 'avg_rank')
  final double avgRank;
  @override
  @JsonKey(name: 'last_keyword_id')
  final int? lastKeywordId;

  @override
  String toString() {
    return 'Top3Keyword(keyword: $keyword, score: $score, appearanceCount: $appearanceCount, avgRank: $avgRank, lastKeywordId: $lastKeywordId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Top3KeywordImpl &&
            (identical(other.keyword, keyword) || other.keyword == keyword) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.appearanceCount, appearanceCount) ||
                other.appearanceCount == appearanceCount) &&
            (identical(other.avgRank, avgRank) || other.avgRank == avgRank) &&
            (identical(other.lastKeywordId, lastKeywordId) ||
                other.lastKeywordId == lastKeywordId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, keyword, score, appearanceCount, avgRank, lastKeywordId);

  /// Create a copy of Top3Keyword
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$Top3KeywordImplCopyWith<_$Top3KeywordImpl> get copyWith =>
      __$$Top3KeywordImplCopyWithImpl<_$Top3KeywordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$Top3KeywordImplToJson(
      this,
    );
  }
}

abstract class _Top3Keyword implements Top3Keyword {
  const factory _Top3Keyword(
          {required final String keyword,
          required final double score,
          @JsonKey(name: 'appearance_count') required final int appearanceCount,
          @JsonKey(name: 'avg_rank') required final double avgRank,
          @JsonKey(name: 'last_keyword_id') final int? lastKeywordId}) =
      _$Top3KeywordImpl;

  factory _Top3Keyword.fromJson(Map<String, dynamic> json) =
      _$Top3KeywordImpl.fromJson;

  @override
  String get keyword;
  @override
  double get score;
  @override
  @JsonKey(name: 'appearance_count')
  int get appearanceCount;
  @override
  @JsonKey(name: 'avg_rank')
  double get avgRank;
  @override
  @JsonKey(name: 'last_keyword_id')
  int? get lastKeywordId;

  /// Create a copy of Top3Keyword
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$Top3KeywordImplCopyWith<_$Top3KeywordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HourlyKeyword _$HourlyKeywordFromJson(Map<String, dynamic> json) {
  return _HourlyKeyword.fromJson(json);
}

/// @nodoc
mixin _$HourlyKeyword {
  String get time => throw _privateConstructorUsedError;
  List<SimpleKeyword> get keywords => throw _privateConstructorUsedError;

  /// Serializes this HourlyKeyword to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HourlyKeyword
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HourlyKeywordCopyWith<HourlyKeyword> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HourlyKeywordCopyWith<$Res> {
  factory $HourlyKeywordCopyWith(
          HourlyKeyword value, $Res Function(HourlyKeyword) then) =
      _$HourlyKeywordCopyWithImpl<$Res, HourlyKeyword>;
  @useResult
  $Res call({String time, List<SimpleKeyword> keywords});
}

/// @nodoc
class _$HourlyKeywordCopyWithImpl<$Res, $Val extends HourlyKeyword>
    implements $HourlyKeywordCopyWith<$Res> {
  _$HourlyKeywordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HourlyKeyword
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? keywords = null,
  }) {
    return _then(_value.copyWith(
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      keywords: null == keywords
          ? _value.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<SimpleKeyword>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HourlyKeywordImplCopyWith<$Res>
    implements $HourlyKeywordCopyWith<$Res> {
  factory _$$HourlyKeywordImplCopyWith(
          _$HourlyKeywordImpl value, $Res Function(_$HourlyKeywordImpl) then) =
      __$$HourlyKeywordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String time, List<SimpleKeyword> keywords});
}

/// @nodoc
class __$$HourlyKeywordImplCopyWithImpl<$Res>
    extends _$HourlyKeywordCopyWithImpl<$Res, _$HourlyKeywordImpl>
    implements _$$HourlyKeywordImplCopyWith<$Res> {
  __$$HourlyKeywordImplCopyWithImpl(
      _$HourlyKeywordImpl _value, $Res Function(_$HourlyKeywordImpl) _then)
      : super(_value, _then);

  /// Create a copy of HourlyKeyword
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? keywords = null,
  }) {
    return _then(_$HourlyKeywordImpl(
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      keywords: null == keywords
          ? _value._keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<SimpleKeyword>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HourlyKeywordImpl implements _HourlyKeyword {
  const _$HourlyKeywordImpl(
      {required this.time, final List<SimpleKeyword> keywords = const []})
      : _keywords = keywords;

  factory _$HourlyKeywordImpl.fromJson(Map<String, dynamic> json) =>
      _$$HourlyKeywordImplFromJson(json);

  @override
  final String time;
  final List<SimpleKeyword> _keywords;
  @override
  @JsonKey()
  List<SimpleKeyword> get keywords {
    if (_keywords is EqualUnmodifiableListView) return _keywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keywords);
  }

  @override
  String toString() {
    return 'HourlyKeyword(time: $time, keywords: $keywords)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HourlyKeywordImpl &&
            (identical(other.time, time) || other.time == time) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, time, const DeepCollectionEquality().hash(_keywords));

  /// Create a copy of HourlyKeyword
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HourlyKeywordImplCopyWith<_$HourlyKeywordImpl> get copyWith =>
      __$$HourlyKeywordImplCopyWithImpl<_$HourlyKeywordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HourlyKeywordImplToJson(
      this,
    );
  }
}

abstract class _HourlyKeyword implements HourlyKeyword {
  const factory _HourlyKeyword(
      {required final String time,
      final List<SimpleKeyword> keywords}) = _$HourlyKeywordImpl;

  factory _HourlyKeyword.fromJson(Map<String, dynamic> json) =
      _$HourlyKeywordImpl.fromJson;

  @override
  String get time;
  @override
  List<SimpleKeyword> get keywords;

  /// Create a copy of HourlyKeyword
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HourlyKeywordImplCopyWith<_$HourlyKeywordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SimpleKeyword _$SimpleKeywordFromJson(Map<String, dynamic> json) {
  return _SimpleKeyword.fromJson(json);
}

/// @nodoc
mixin _$SimpleKeyword {
  int get id => throw _privateConstructorUsedError;
  String get keyword => throw _privateConstructorUsedError;
  int get rank => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get type2 => throw _privateConstructorUsedError;

  /// Serializes this SimpleKeyword to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimpleKeyword
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimpleKeywordCopyWith<SimpleKeyword> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimpleKeywordCopyWith<$Res> {
  factory $SimpleKeywordCopyWith(
          SimpleKeyword value, $Res Function(SimpleKeyword) then) =
      _$SimpleKeywordCopyWithImpl<$Res, SimpleKeyword>;
  @useResult
  $Res call({int id, String keyword, int rank, String category, String? type2});
}

/// @nodoc
class _$SimpleKeywordCopyWithImpl<$Res, $Val extends SimpleKeyword>
    implements $SimpleKeywordCopyWith<$Res> {
  _$SimpleKeywordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimpleKeyword
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? keyword = null,
    Object? rank = null,
    Object? category = null,
    Object? type2 = freezed,
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
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      type2: freezed == type2
          ? _value.type2
          : type2 // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SimpleKeywordImplCopyWith<$Res>
    implements $SimpleKeywordCopyWith<$Res> {
  factory _$$SimpleKeywordImplCopyWith(
          _$SimpleKeywordImpl value, $Res Function(_$SimpleKeywordImpl) then) =
      __$$SimpleKeywordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String keyword, int rank, String category, String? type2});
}

/// @nodoc
class __$$SimpleKeywordImplCopyWithImpl<$Res>
    extends _$SimpleKeywordCopyWithImpl<$Res, _$SimpleKeywordImpl>
    implements _$$SimpleKeywordImplCopyWith<$Res> {
  __$$SimpleKeywordImplCopyWithImpl(
      _$SimpleKeywordImpl _value, $Res Function(_$SimpleKeywordImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimpleKeyword
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? keyword = null,
    Object? rank = null,
    Object? category = null,
    Object? type2 = freezed,
  }) {
    return _then(_$SimpleKeywordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      keyword: null == keyword
          ? _value.keyword
          : keyword // ignore: cast_nullable_to_non_nullable
              as String,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      type2: freezed == type2
          ? _value.type2
          : type2 // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SimpleKeywordImpl implements _SimpleKeyword {
  const _$SimpleKeywordImpl(
      {required this.id,
      required this.keyword,
      required this.rank,
      required this.category,
      this.type2});

  factory _$SimpleKeywordImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimpleKeywordImplFromJson(json);

  @override
  final int id;
  @override
  final String keyword;
  @override
  final int rank;
  @override
  final String category;
  @override
  final String? type2;

  @override
  String toString() {
    return 'SimpleKeyword(id: $id, keyword: $keyword, rank: $rank, category: $category, type2: $type2)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimpleKeywordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.keyword, keyword) || other.keyword == keyword) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.type2, type2) || other.type2 == type2));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, keyword, rank, category, type2);

  /// Create a copy of SimpleKeyword
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimpleKeywordImplCopyWith<_$SimpleKeywordImpl> get copyWith =>
      __$$SimpleKeywordImplCopyWithImpl<_$SimpleKeywordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimpleKeywordImplToJson(
      this,
    );
  }
}

abstract class _SimpleKeyword implements SimpleKeyword {
  const factory _SimpleKeyword(
      {required final int id,
      required final String keyword,
      required final int rank,
      required final String category,
      final String? type2}) = _$SimpleKeywordImpl;

  factory _SimpleKeyword.fromJson(Map<String, dynamic> json) =
      _$SimpleKeywordImpl.fromJson;

  @override
  int get id;
  @override
  String get keyword;
  @override
  int get rank;
  @override
  String get category;
  @override
  String? get type2;

  /// Create a copy of SimpleKeyword
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimpleKeywordImplCopyWith<_$SimpleKeywordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
