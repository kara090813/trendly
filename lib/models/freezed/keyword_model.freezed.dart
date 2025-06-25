// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keyword_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Keyword _$KeywordFromJson(Map<String, dynamic> json) {
  return _Keyword.fromJson(json);
}

/// @nodoc
mixin _$Keyword {
  int get id => throw _privateConstructorUsedError;
  String get keyword => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get rank => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // type1을 dynamic으로 변경하여 List<String>과 Map<String, dynamic> 모두 지원
  dynamic get type1 => throw _privateConstructorUsedError;
  String get type2 => throw _privateConstructorUsedError;
  String get type3 =>
      throw _privateConstructorUsedError; // references도 dynamic으로 변경하여 호환성 유지
  dynamic get references =>
      throw _privateConstructorUsedError; // 필드명을 API 응답에 맞게 수정 (null 가능하도록 변경)
  @JsonKey(name: 'current_discussion_room')
  int? get currentDiscussionRoomId => throw _privateConstructorUsedError;

  /// Serializes this Keyword to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Keyword
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KeywordCopyWith<Keyword> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeywordCopyWith<$Res> {
  factory $KeywordCopyWith(Keyword value, $Res Function(Keyword) then) =
      _$KeywordCopyWithImpl<$Res, Keyword>;
  @useResult
  $Res call(
      {int id,
      String keyword,
      String category,
      int rank,
      @JsonKey(name: 'created_at') DateTime createdAt,
      dynamic type1,
      String type2,
      String type3,
      dynamic references,
      @JsonKey(name: 'current_discussion_room') int? currentDiscussionRoomId});
}

/// @nodoc
class _$KeywordCopyWithImpl<$Res, $Val extends Keyword>
    implements $KeywordCopyWith<$Res> {
  _$KeywordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Keyword
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? keyword = null,
    Object? category = null,
    Object? rank = null,
    Object? createdAt = null,
    Object? type1 = freezed,
    Object? type2 = null,
    Object? type3 = null,
    Object? references = freezed,
    Object? currentDiscussionRoomId = freezed,
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
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type1: freezed == type1
          ? _value.type1
          : type1 // ignore: cast_nullable_to_non_nullable
              as dynamic,
      type2: null == type2
          ? _value.type2
          : type2 // ignore: cast_nullable_to_non_nullable
              as String,
      type3: null == type3
          ? _value.type3
          : type3 // ignore: cast_nullable_to_non_nullable
              as String,
      references: freezed == references
          ? _value.references
          : references // ignore: cast_nullable_to_non_nullable
              as dynamic,
      currentDiscussionRoomId: freezed == currentDiscussionRoomId
          ? _value.currentDiscussionRoomId
          : currentDiscussionRoomId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KeywordImplCopyWith<$Res> implements $KeywordCopyWith<$Res> {
  factory _$$KeywordImplCopyWith(
          _$KeywordImpl value, $Res Function(_$KeywordImpl) then) =
      __$$KeywordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String keyword,
      String category,
      int rank,
      @JsonKey(name: 'created_at') DateTime createdAt,
      dynamic type1,
      String type2,
      String type3,
      dynamic references,
      @JsonKey(name: 'current_discussion_room') int? currentDiscussionRoomId});
}

/// @nodoc
class __$$KeywordImplCopyWithImpl<$Res>
    extends _$KeywordCopyWithImpl<$Res, _$KeywordImpl>
    implements _$$KeywordImplCopyWith<$Res> {
  __$$KeywordImplCopyWithImpl(
      _$KeywordImpl _value, $Res Function(_$KeywordImpl) _then)
      : super(_value, _then);

  /// Create a copy of Keyword
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? keyword = null,
    Object? category = null,
    Object? rank = null,
    Object? createdAt = null,
    Object? type1 = freezed,
    Object? type2 = null,
    Object? type3 = null,
    Object? references = freezed,
    Object? currentDiscussionRoomId = freezed,
  }) {
    return _then(_$KeywordImpl(
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
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type1: freezed == type1
          ? _value.type1
          : type1 // ignore: cast_nullable_to_non_nullable
              as dynamic,
      type2: null == type2
          ? _value.type2
          : type2 // ignore: cast_nullable_to_non_nullable
              as String,
      type3: null == type3
          ? _value.type3
          : type3 // ignore: cast_nullable_to_non_nullable
              as String,
      references: freezed == references
          ? _value.references
          : references // ignore: cast_nullable_to_non_nullable
              as dynamic,
      currentDiscussionRoomId: freezed == currentDiscussionRoomId
          ? _value.currentDiscussionRoomId
          : currentDiscussionRoomId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$KeywordImpl implements _Keyword {
  const _$KeywordImpl(
      {required this.id,
      required this.keyword,
      required this.category,
      required this.rank,
      @JsonKey(name: 'created_at') required this.createdAt,
      this.type1 = const [],
      required this.type2,
      required this.type3,
      this.references = const [],
      @JsonKey(name: 'current_discussion_room') this.currentDiscussionRoomId});

  factory _$KeywordImpl.fromJson(Map<String, dynamic> json) =>
      _$$KeywordImplFromJson(json);

  @override
  final int id;
  @override
  final String keyword;
  @override
  final String category;
  @override
  final int rank;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
// type1을 dynamic으로 변경하여 List<String>과 Map<String, dynamic> 모두 지원
  @override
  @JsonKey()
  final dynamic type1;
  @override
  final String type2;
  @override
  final String type3;
// references도 dynamic으로 변경하여 호환성 유지
  @override
  @JsonKey()
  final dynamic references;
// 필드명을 API 응답에 맞게 수정 (null 가능하도록 변경)
  @override
  @JsonKey(name: 'current_discussion_room')
  final int? currentDiscussionRoomId;

  @override
  String toString() {
    return 'Keyword(id: $id, keyword: $keyword, category: $category, rank: $rank, createdAt: $createdAt, type1: $type1, type2: $type2, type3: $type3, references: $references, currentDiscussionRoomId: $currentDiscussionRoomId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeywordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.keyword, keyword) || other.keyword == keyword) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other.type1, type1) &&
            (identical(other.type2, type2) || other.type2 == type2) &&
            (identical(other.type3, type3) || other.type3 == type3) &&
            const DeepCollectionEquality()
                .equals(other.references, references) &&
            (identical(
                    other.currentDiscussionRoomId, currentDiscussionRoomId) ||
                other.currentDiscussionRoomId == currentDiscussionRoomId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      keyword,
      category,
      rank,
      createdAt,
      const DeepCollectionEquality().hash(type1),
      type2,
      type3,
      const DeepCollectionEquality().hash(references),
      currentDiscussionRoomId);

  /// Create a copy of Keyword
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KeywordImplCopyWith<_$KeywordImpl> get copyWith =>
      __$$KeywordImplCopyWithImpl<_$KeywordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KeywordImplToJson(
      this,
    );
  }
}

abstract class _Keyword implements Keyword {
  const factory _Keyword(
      {required final int id,
      required final String keyword,
      required final String category,
      required final int rank,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      final dynamic type1,
      required final String type2,
      required final String type3,
      final dynamic references,
      @JsonKey(name: 'current_discussion_room')
      final int? currentDiscussionRoomId}) = _$KeywordImpl;

  factory _Keyword.fromJson(Map<String, dynamic> json) = _$KeywordImpl.fromJson;

  @override
  int get id;
  @override
  String get keyword;
  @override
  String get category;
  @override
  int get rank;
  @override
  @JsonKey(name: 'created_at')
  DateTime
      get createdAt; // type1을 dynamic으로 변경하여 List<String>과 Map<String, dynamic> 모두 지원
  @override
  dynamic get type1;
  @override
  String get type2;
  @override
  String get type3; // references도 dynamic으로 변경하여 호환성 유지
  @override
  dynamic get references; // 필드명을 API 응답에 맞게 수정 (null 가능하도록 변경)
  @override
  @JsonKey(name: 'current_discussion_room')
  int? get currentDiscussionRoomId;

  /// Create a copy of Keyword
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KeywordImplCopyWith<_$KeywordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Reference _$ReferenceFromJson(Map<String, dynamic> json) {
  return _Reference.fromJson(json);
}

/// @nodoc
mixin _$Reference {
  String get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get link => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  String? get thumbnail => throw _privateConstructorUsedError;

  /// Serializes this Reference to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferenceCopyWith<Reference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferenceCopyWith<$Res> {
  factory $ReferenceCopyWith(Reference value, $Res Function(Reference) then) =
      _$ReferenceCopyWithImpl<$Res, Reference>;
  @useResult
  $Res call(
      {String type, String title, String link, String date, String? thumbnail});
}

/// @nodoc
class _$ReferenceCopyWithImpl<$Res, $Val extends Reference>
    implements $ReferenceCopyWith<$Res> {
  _$ReferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? link = null,
    Object? date = null,
    Object? thumbnail = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferenceImplCopyWith<$Res>
    implements $ReferenceCopyWith<$Res> {
  factory _$$ReferenceImplCopyWith(
          _$ReferenceImpl value, $Res Function(_$ReferenceImpl) then) =
      __$$ReferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type, String title, String link, String date, String? thumbnail});
}

/// @nodoc
class __$$ReferenceImplCopyWithImpl<$Res>
    extends _$ReferenceCopyWithImpl<$Res, _$ReferenceImpl>
    implements _$$ReferenceImplCopyWith<$Res> {
  __$$ReferenceImplCopyWithImpl(
      _$ReferenceImpl _value, $Res Function(_$ReferenceImpl) _then)
      : super(_value, _then);

  /// Create a copy of Reference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? link = null,
    Object? date = null,
    Object? thumbnail = freezed,
  }) {
    return _then(_$ReferenceImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferenceImpl implements _Reference {
  const _$ReferenceImpl(
      {required this.type,
      required this.title,
      required this.link,
      required this.date,
      this.thumbnail});

  factory _$ReferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferenceImplFromJson(json);

  @override
  final String type;
  @override
  final String title;
  @override
  final String link;
  @override
  final String date;
  @override
  final String? thumbnail;

  @override
  String toString() {
    return 'Reference(type: $type, title: $title, link: $link, date: $date, thumbnail: $thumbnail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferenceImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, title, link, date, thumbnail);

  /// Create a copy of Reference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferenceImplCopyWith<_$ReferenceImpl> get copyWith =>
      __$$ReferenceImplCopyWithImpl<_$ReferenceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferenceImplToJson(
      this,
    );
  }
}

abstract class _Reference implements Reference {
  const factory _Reference(
      {required final String type,
      required final String title,
      required final String link,
      required final String date,
      final String? thumbnail}) = _$ReferenceImpl;

  factory _Reference.fromJson(Map<String, dynamic> json) =
      _$ReferenceImpl.fromJson;

  @override
  String get type;
  @override
  String get title;
  @override
  String get link;
  @override
  String get date;
  @override
  String? get thumbnail;

  /// Create a copy of Reference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferenceImplCopyWith<_$ReferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
