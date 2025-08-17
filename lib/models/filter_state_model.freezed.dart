// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filter_state_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HistoryFilterState _$HistoryFilterStateFromJson(Map<String, dynamic> json) {
  return _HistoryFilterState.fromJson(json);
}

/// @nodoc
mixin _$HistoryFilterState {
// 기존 필드들 (이전 호환성 유지)
  String get searchQuery => throw _privateConstructorUsedError;
  String get selectedCategory => throw _privateConstructorUsedError;
  String get sortOption => throw _privateConstructorUsedError;
  DateTime? get dateFrom => throw _privateConstructorUsedError;
  DateTime? get dateTo => throw _privateConstructorUsedError;
  int? get minComments => throw _privateConstructorUsedError;
  int? get maxComments => throw _privateConstructorUsedError;
  List<String> get categories => throw _privateConstructorUsedError;
  String get sentimentFilter => throw _privateConstructorUsedError;
  bool get isAdvancedMode =>
      throw _privateConstructorUsedError; // DiscussionRoom 모델 기반 새 필터들
// 날짜 범위 필터 (created_at, updated_at, closed_at 기준)
  DateTime? get dateFromCreated => throw _privateConstructorUsedError;
  DateTime? get dateToCreated => throw _privateConstructorUsedError;
  DateTime? get dateFromClosed => throw _privateConstructorUsedError;
  DateTime? get dateToClosed => throw _privateConstructorUsedError;
  DateTime? get dateFromUpdated => throw _privateConstructorUsedError;
  DateTime? get dateToUpdated => throw _privateConstructorUsedError;
  String get dateFilterType =>
      throw _privateConstructorUsedError; // 'created_at', 'updated_at', 'closed_at'
// 감정 반응 필터 (positive_count, neutral_count, negative_count)
  int? get minPositiveReactions => throw _privateConstructorUsedError;
  int? get maxPositiveReactions => throw _privateConstructorUsedError;
  int? get minNeutralReactions => throw _privateConstructorUsedError;
  int? get maxNeutralReactions => throw _privateConstructorUsedError;
  int? get minNegativeReactions => throw _privateConstructorUsedError;
  int? get maxNegativeReactions => throw _privateConstructorUsedError;
  int? get minTotalReactions => throw _privateConstructorUsedError;
  int? get maxTotalReactions => throw _privateConstructorUsedError;
  String get dominantSentiment =>
      throw _privateConstructorUsedError; // 'positive', 'neutral', 'negative', 'all'
// 토론방 상태 필터 (is_closed)
  String get roomStatus =>
      throw _privateConstructorUsedError; // 'all', 'closed', 'active'
// 키워드 관련 필터 (keyword_id_list)
  List<int> get relatedKeywordIds => throw _privateConstructorUsedError;
  bool get hasMultipleKeywords => throw _privateConstructorUsedError; // 기타 필터
  bool get hasSummary =>
      throw _privateConstructorUsedError; // comment_summary가 있는지
// 시간대별 필터
  String get timeOfDay =>
      throw _privateConstructorUsedError; // 'morning', 'afternoon', 'evening', 'night', 'all'
  String get dayOfWeek =>
      throw _privateConstructorUsedError; // 'monday', 'tuesday', ..., 'weekend', 'weekday', 'all'
// 활동 수준 필터
  String get activityLevel => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HistoryFilterStateCopyWith<HistoryFilterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoryFilterStateCopyWith<$Res> {
  factory $HistoryFilterStateCopyWith(
          HistoryFilterState value, $Res Function(HistoryFilterState) then) =
      _$HistoryFilterStateCopyWithImpl<$Res, HistoryFilterState>;
  @useResult
  $Res call(
      {String searchQuery,
      String selectedCategory,
      String sortOption,
      DateTime? dateFrom,
      DateTime? dateTo,
      int? minComments,
      int? maxComments,
      List<String> categories,
      String sentimentFilter,
      bool isAdvancedMode,
      DateTime? dateFromCreated,
      DateTime? dateToCreated,
      DateTime? dateFromClosed,
      DateTime? dateToClosed,
      DateTime? dateFromUpdated,
      DateTime? dateToUpdated,
      String dateFilterType,
      int? minPositiveReactions,
      int? maxPositiveReactions,
      int? minNeutralReactions,
      int? maxNeutralReactions,
      int? minNegativeReactions,
      int? maxNegativeReactions,
      int? minTotalReactions,
      int? maxTotalReactions,
      String dominantSentiment,
      String roomStatus,
      List<int> relatedKeywordIds,
      bool hasMultipleKeywords,
      bool hasSummary,
      String timeOfDay,
      String dayOfWeek,
      String activityLevel});
}

/// @nodoc
class _$HistoryFilterStateCopyWithImpl<$Res, $Val extends HistoryFilterState>
    implements $HistoryFilterStateCopyWith<$Res> {
  _$HistoryFilterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = null,
    Object? selectedCategory = null,
    Object? sortOption = null,
    Object? dateFrom = freezed,
    Object? dateTo = freezed,
    Object? minComments = freezed,
    Object? maxComments = freezed,
    Object? categories = null,
    Object? sentimentFilter = null,
    Object? isAdvancedMode = null,
    Object? dateFromCreated = freezed,
    Object? dateToCreated = freezed,
    Object? dateFromClosed = freezed,
    Object? dateToClosed = freezed,
    Object? dateFromUpdated = freezed,
    Object? dateToUpdated = freezed,
    Object? dateFilterType = null,
    Object? minPositiveReactions = freezed,
    Object? maxPositiveReactions = freezed,
    Object? minNeutralReactions = freezed,
    Object? maxNeutralReactions = freezed,
    Object? minNegativeReactions = freezed,
    Object? maxNegativeReactions = freezed,
    Object? minTotalReactions = freezed,
    Object? maxTotalReactions = freezed,
    Object? dominantSentiment = null,
    Object? roomStatus = null,
    Object? relatedKeywordIds = null,
    Object? hasMultipleKeywords = null,
    Object? hasSummary = null,
    Object? timeOfDay = null,
    Object? dayOfWeek = null,
    Object? activityLevel = null,
  }) {
    return _then(_value.copyWith(
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      selectedCategory: null == selectedCategory
          ? _value.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as String,
      sortOption: null == sortOption
          ? _value.sortOption
          : sortOption // ignore: cast_nullable_to_non_nullable
              as String,
      dateFrom: freezed == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateTo: freezed == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      minComments: freezed == minComments
          ? _value.minComments
          : minComments // ignore: cast_nullable_to_non_nullable
              as int?,
      maxComments: freezed == maxComments
          ? _value.maxComments
          : maxComments // ignore: cast_nullable_to_non_nullable
              as int?,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sentimentFilter: null == sentimentFilter
          ? _value.sentimentFilter
          : sentimentFilter // ignore: cast_nullable_to_non_nullable
              as String,
      isAdvancedMode: null == isAdvancedMode
          ? _value.isAdvancedMode
          : isAdvancedMode // ignore: cast_nullable_to_non_nullable
              as bool,
      dateFromCreated: freezed == dateFromCreated
          ? _value.dateFromCreated
          : dateFromCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateToCreated: freezed == dateToCreated
          ? _value.dateToCreated
          : dateToCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateFromClosed: freezed == dateFromClosed
          ? _value.dateFromClosed
          : dateFromClosed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateToClosed: freezed == dateToClosed
          ? _value.dateToClosed
          : dateToClosed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateFromUpdated: freezed == dateFromUpdated
          ? _value.dateFromUpdated
          : dateFromUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateToUpdated: freezed == dateToUpdated
          ? _value.dateToUpdated
          : dateToUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateFilterType: null == dateFilterType
          ? _value.dateFilterType
          : dateFilterType // ignore: cast_nullable_to_non_nullable
              as String,
      minPositiveReactions: freezed == minPositiveReactions
          ? _value.minPositiveReactions
          : minPositiveReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      maxPositiveReactions: freezed == maxPositiveReactions
          ? _value.maxPositiveReactions
          : maxPositiveReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      minNeutralReactions: freezed == minNeutralReactions
          ? _value.minNeutralReactions
          : minNeutralReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      maxNeutralReactions: freezed == maxNeutralReactions
          ? _value.maxNeutralReactions
          : maxNeutralReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      minNegativeReactions: freezed == minNegativeReactions
          ? _value.minNegativeReactions
          : minNegativeReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      maxNegativeReactions: freezed == maxNegativeReactions
          ? _value.maxNegativeReactions
          : maxNegativeReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      minTotalReactions: freezed == minTotalReactions
          ? _value.minTotalReactions
          : minTotalReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      maxTotalReactions: freezed == maxTotalReactions
          ? _value.maxTotalReactions
          : maxTotalReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      dominantSentiment: null == dominantSentiment
          ? _value.dominantSentiment
          : dominantSentiment // ignore: cast_nullable_to_non_nullable
              as String,
      roomStatus: null == roomStatus
          ? _value.roomStatus
          : roomStatus // ignore: cast_nullable_to_non_nullable
              as String,
      relatedKeywordIds: null == relatedKeywordIds
          ? _value.relatedKeywordIds
          : relatedKeywordIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      hasMultipleKeywords: null == hasMultipleKeywords
          ? _value.hasMultipleKeywords
          : hasMultipleKeywords // ignore: cast_nullable_to_non_nullable
              as bool,
      hasSummary: null == hasSummary
          ? _value.hasSummary
          : hasSummary // ignore: cast_nullable_to_non_nullable
              as bool,
      timeOfDay: null == timeOfDay
          ? _value.timeOfDay
          : timeOfDay // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String,
      activityLevel: null == activityLevel
          ? _value.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HistoryFilterStateImplCopyWith<$Res>
    implements $HistoryFilterStateCopyWith<$Res> {
  factory _$$HistoryFilterStateImplCopyWith(_$HistoryFilterStateImpl value,
          $Res Function(_$HistoryFilterStateImpl) then) =
      __$$HistoryFilterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String searchQuery,
      String selectedCategory,
      String sortOption,
      DateTime? dateFrom,
      DateTime? dateTo,
      int? minComments,
      int? maxComments,
      List<String> categories,
      String sentimentFilter,
      bool isAdvancedMode,
      DateTime? dateFromCreated,
      DateTime? dateToCreated,
      DateTime? dateFromClosed,
      DateTime? dateToClosed,
      DateTime? dateFromUpdated,
      DateTime? dateToUpdated,
      String dateFilterType,
      int? minPositiveReactions,
      int? maxPositiveReactions,
      int? minNeutralReactions,
      int? maxNeutralReactions,
      int? minNegativeReactions,
      int? maxNegativeReactions,
      int? minTotalReactions,
      int? maxTotalReactions,
      String dominantSentiment,
      String roomStatus,
      List<int> relatedKeywordIds,
      bool hasMultipleKeywords,
      bool hasSummary,
      String timeOfDay,
      String dayOfWeek,
      String activityLevel});
}

/// @nodoc
class __$$HistoryFilterStateImplCopyWithImpl<$Res>
    extends _$HistoryFilterStateCopyWithImpl<$Res, _$HistoryFilterStateImpl>
    implements _$$HistoryFilterStateImplCopyWith<$Res> {
  __$$HistoryFilterStateImplCopyWithImpl(_$HistoryFilterStateImpl _value,
      $Res Function(_$HistoryFilterStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = null,
    Object? selectedCategory = null,
    Object? sortOption = null,
    Object? dateFrom = freezed,
    Object? dateTo = freezed,
    Object? minComments = freezed,
    Object? maxComments = freezed,
    Object? categories = null,
    Object? sentimentFilter = null,
    Object? isAdvancedMode = null,
    Object? dateFromCreated = freezed,
    Object? dateToCreated = freezed,
    Object? dateFromClosed = freezed,
    Object? dateToClosed = freezed,
    Object? dateFromUpdated = freezed,
    Object? dateToUpdated = freezed,
    Object? dateFilterType = null,
    Object? minPositiveReactions = freezed,
    Object? maxPositiveReactions = freezed,
    Object? minNeutralReactions = freezed,
    Object? maxNeutralReactions = freezed,
    Object? minNegativeReactions = freezed,
    Object? maxNegativeReactions = freezed,
    Object? minTotalReactions = freezed,
    Object? maxTotalReactions = freezed,
    Object? dominantSentiment = null,
    Object? roomStatus = null,
    Object? relatedKeywordIds = null,
    Object? hasMultipleKeywords = null,
    Object? hasSummary = null,
    Object? timeOfDay = null,
    Object? dayOfWeek = null,
    Object? activityLevel = null,
  }) {
    return _then(_$HistoryFilterStateImpl(
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      selectedCategory: null == selectedCategory
          ? _value.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as String,
      sortOption: null == sortOption
          ? _value.sortOption
          : sortOption // ignore: cast_nullable_to_non_nullable
              as String,
      dateFrom: freezed == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateTo: freezed == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      minComments: freezed == minComments
          ? _value.minComments
          : minComments // ignore: cast_nullable_to_non_nullable
              as int?,
      maxComments: freezed == maxComments
          ? _value.maxComments
          : maxComments // ignore: cast_nullable_to_non_nullable
              as int?,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sentimentFilter: null == sentimentFilter
          ? _value.sentimentFilter
          : sentimentFilter // ignore: cast_nullable_to_non_nullable
              as String,
      isAdvancedMode: null == isAdvancedMode
          ? _value.isAdvancedMode
          : isAdvancedMode // ignore: cast_nullable_to_non_nullable
              as bool,
      dateFromCreated: freezed == dateFromCreated
          ? _value.dateFromCreated
          : dateFromCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateToCreated: freezed == dateToCreated
          ? _value.dateToCreated
          : dateToCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateFromClosed: freezed == dateFromClosed
          ? _value.dateFromClosed
          : dateFromClosed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateToClosed: freezed == dateToClosed
          ? _value.dateToClosed
          : dateToClosed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateFromUpdated: freezed == dateFromUpdated
          ? _value.dateFromUpdated
          : dateFromUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateToUpdated: freezed == dateToUpdated
          ? _value.dateToUpdated
          : dateToUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateFilterType: null == dateFilterType
          ? _value.dateFilterType
          : dateFilterType // ignore: cast_nullable_to_non_nullable
              as String,
      minPositiveReactions: freezed == minPositiveReactions
          ? _value.minPositiveReactions
          : minPositiveReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      maxPositiveReactions: freezed == maxPositiveReactions
          ? _value.maxPositiveReactions
          : maxPositiveReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      minNeutralReactions: freezed == minNeutralReactions
          ? _value.minNeutralReactions
          : minNeutralReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      maxNeutralReactions: freezed == maxNeutralReactions
          ? _value.maxNeutralReactions
          : maxNeutralReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      minNegativeReactions: freezed == minNegativeReactions
          ? _value.minNegativeReactions
          : minNegativeReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      maxNegativeReactions: freezed == maxNegativeReactions
          ? _value.maxNegativeReactions
          : maxNegativeReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      minTotalReactions: freezed == minTotalReactions
          ? _value.minTotalReactions
          : minTotalReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      maxTotalReactions: freezed == maxTotalReactions
          ? _value.maxTotalReactions
          : maxTotalReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      dominantSentiment: null == dominantSentiment
          ? _value.dominantSentiment
          : dominantSentiment // ignore: cast_nullable_to_non_nullable
              as String,
      roomStatus: null == roomStatus
          ? _value.roomStatus
          : roomStatus // ignore: cast_nullable_to_non_nullable
              as String,
      relatedKeywordIds: null == relatedKeywordIds
          ? _value._relatedKeywordIds
          : relatedKeywordIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      hasMultipleKeywords: null == hasMultipleKeywords
          ? _value.hasMultipleKeywords
          : hasMultipleKeywords // ignore: cast_nullable_to_non_nullable
              as bool,
      hasSummary: null == hasSummary
          ? _value.hasSummary
          : hasSummary // ignore: cast_nullable_to_non_nullable
              as bool,
      timeOfDay: null == timeOfDay
          ? _value.timeOfDay
          : timeOfDay // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String,
      activityLevel: null == activityLevel
          ? _value.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HistoryFilterStateImpl implements _HistoryFilterState {
  const _$HistoryFilterStateImpl(
      {this.searchQuery = '',
      this.selectedCategory = '전체',
      this.sortOption = 'newest',
      this.dateFrom,
      this.dateTo,
      this.minComments,
      this.maxComments,
      final List<String> categories = const [],
      this.sentimentFilter = 'all',
      this.isAdvancedMode = false,
      this.dateFromCreated,
      this.dateToCreated,
      this.dateFromClosed,
      this.dateToClosed,
      this.dateFromUpdated,
      this.dateToUpdated,
      this.dateFilterType = 'created_at',
      this.minPositiveReactions,
      this.maxPositiveReactions,
      this.minNeutralReactions,
      this.maxNeutralReactions,
      this.minNegativeReactions,
      this.maxNegativeReactions,
      this.minTotalReactions,
      this.maxTotalReactions,
      this.dominantSentiment = 'all',
      this.roomStatus = 'all',
      final List<int> relatedKeywordIds = const [],
      this.hasMultipleKeywords = false,
      this.hasSummary = false,
      this.timeOfDay = 'all',
      this.dayOfWeek = 'all',
      this.activityLevel = 'all'})
      : _categories = categories,
        _relatedKeywordIds = relatedKeywordIds;

  factory _$HistoryFilterStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$HistoryFilterStateImplFromJson(json);

// 기존 필드들 (이전 호환성 유지)
  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final String selectedCategory;
  @override
  @JsonKey()
  final String sortOption;
  @override
  final DateTime? dateFrom;
  @override
  final DateTime? dateTo;
  @override
  final int? minComments;
  @override
  final int? maxComments;
  final List<String> _categories;
  @override
  @JsonKey()
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  @JsonKey()
  final String sentimentFilter;
  @override
  @JsonKey()
  final bool isAdvancedMode;
// DiscussionRoom 모델 기반 새 필터들
// 날짜 범위 필터 (created_at, updated_at, closed_at 기준)
  @override
  final DateTime? dateFromCreated;
  @override
  final DateTime? dateToCreated;
  @override
  final DateTime? dateFromClosed;
  @override
  final DateTime? dateToClosed;
  @override
  final DateTime? dateFromUpdated;
  @override
  final DateTime? dateToUpdated;
  @override
  @JsonKey()
  final String dateFilterType;
// 'created_at', 'updated_at', 'closed_at'
// 감정 반응 필터 (positive_count, neutral_count, negative_count)
  @override
  final int? minPositiveReactions;
  @override
  final int? maxPositiveReactions;
  @override
  final int? minNeutralReactions;
  @override
  final int? maxNeutralReactions;
  @override
  final int? minNegativeReactions;
  @override
  final int? maxNegativeReactions;
  @override
  final int? minTotalReactions;
  @override
  final int? maxTotalReactions;
  @override
  @JsonKey()
  final String dominantSentiment;
// 'positive', 'neutral', 'negative', 'all'
// 토론방 상태 필터 (is_closed)
  @override
  @JsonKey()
  final String roomStatus;
// 'all', 'closed', 'active'
// 키워드 관련 필터 (keyword_id_list)
  final List<int> _relatedKeywordIds;
// 'all', 'closed', 'active'
// 키워드 관련 필터 (keyword_id_list)
  @override
  @JsonKey()
  List<int> get relatedKeywordIds {
    if (_relatedKeywordIds is EqualUnmodifiableListView)
      return _relatedKeywordIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relatedKeywordIds);
  }

  @override
  @JsonKey()
  final bool hasMultipleKeywords;
// 기타 필터
  @override
  @JsonKey()
  final bool hasSummary;
// comment_summary가 있는지
// 시간대별 필터
  @override
  @JsonKey()
  final String timeOfDay;
// 'morning', 'afternoon', 'evening', 'night', 'all'
  @override
  @JsonKey()
  final String dayOfWeek;
// 'monday', 'tuesday', ..., 'weekend', 'weekday', 'all'
// 활동 수준 필터
  @override
  @JsonKey()
  final String activityLevel;

  @override
  String toString() {
    return 'HistoryFilterState(searchQuery: $searchQuery, selectedCategory: $selectedCategory, sortOption: $sortOption, dateFrom: $dateFrom, dateTo: $dateTo, minComments: $minComments, maxComments: $maxComments, categories: $categories, sentimentFilter: $sentimentFilter, isAdvancedMode: $isAdvancedMode, dateFromCreated: $dateFromCreated, dateToCreated: $dateToCreated, dateFromClosed: $dateFromClosed, dateToClosed: $dateToClosed, dateFromUpdated: $dateFromUpdated, dateToUpdated: $dateToUpdated, dateFilterType: $dateFilterType, minPositiveReactions: $minPositiveReactions, maxPositiveReactions: $maxPositiveReactions, minNeutralReactions: $minNeutralReactions, maxNeutralReactions: $maxNeutralReactions, minNegativeReactions: $minNegativeReactions, maxNegativeReactions: $maxNegativeReactions, minTotalReactions: $minTotalReactions, maxTotalReactions: $maxTotalReactions, dominantSentiment: $dominantSentiment, roomStatus: $roomStatus, relatedKeywordIds: $relatedKeywordIds, hasMultipleKeywords: $hasMultipleKeywords, hasSummary: $hasSummary, timeOfDay: $timeOfDay, dayOfWeek: $dayOfWeek, activityLevel: $activityLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryFilterStateImpl &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            (identical(other.sortOption, sortOption) ||
                other.sortOption == sortOption) &&
            (identical(other.dateFrom, dateFrom) ||
                other.dateFrom == dateFrom) &&
            (identical(other.dateTo, dateTo) || other.dateTo == dateTo) &&
            (identical(other.minComments, minComments) ||
                other.minComments == minComments) &&
            (identical(other.maxComments, maxComments) ||
                other.maxComments == maxComments) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            (identical(other.sentimentFilter, sentimentFilter) ||
                other.sentimentFilter == sentimentFilter) &&
            (identical(other.isAdvancedMode, isAdvancedMode) ||
                other.isAdvancedMode == isAdvancedMode) &&
            (identical(other.dateFromCreated, dateFromCreated) ||
                other.dateFromCreated == dateFromCreated) &&
            (identical(other.dateToCreated, dateToCreated) ||
                other.dateToCreated == dateToCreated) &&
            (identical(other.dateFromClosed, dateFromClosed) ||
                other.dateFromClosed == dateFromClosed) &&
            (identical(other.dateToClosed, dateToClosed) ||
                other.dateToClosed == dateToClosed) &&
            (identical(other.dateFromUpdated, dateFromUpdated) ||
                other.dateFromUpdated == dateFromUpdated) &&
            (identical(other.dateToUpdated, dateToUpdated) ||
                other.dateToUpdated == dateToUpdated) &&
            (identical(other.dateFilterType, dateFilterType) ||
                other.dateFilterType == dateFilterType) &&
            (identical(other.minPositiveReactions, minPositiveReactions) ||
                other.minPositiveReactions == minPositiveReactions) &&
            (identical(other.maxPositiveReactions, maxPositiveReactions) ||
                other.maxPositiveReactions == maxPositiveReactions) &&
            (identical(other.minNeutralReactions, minNeutralReactions) ||
                other.minNeutralReactions == minNeutralReactions) &&
            (identical(other.maxNeutralReactions, maxNeutralReactions) ||
                other.maxNeutralReactions == maxNeutralReactions) &&
            (identical(other.minNegativeReactions, minNegativeReactions) ||
                other.minNegativeReactions == minNegativeReactions) &&
            (identical(other.maxNegativeReactions, maxNegativeReactions) ||
                other.maxNegativeReactions == maxNegativeReactions) &&
            (identical(other.minTotalReactions, minTotalReactions) ||
                other.minTotalReactions == minTotalReactions) &&
            (identical(other.maxTotalReactions, maxTotalReactions) ||
                other.maxTotalReactions == maxTotalReactions) &&
            (identical(other.dominantSentiment, dominantSentiment) ||
                other.dominantSentiment == dominantSentiment) &&
            (identical(other.roomStatus, roomStatus) ||
                other.roomStatus == roomStatus) &&
            const DeepCollectionEquality()
                .equals(other._relatedKeywordIds, _relatedKeywordIds) &&
            (identical(other.hasMultipleKeywords, hasMultipleKeywords) ||
                other.hasMultipleKeywords == hasMultipleKeywords) &&
            (identical(other.hasSummary, hasSummary) ||
                other.hasSummary == hasSummary) &&
            (identical(other.timeOfDay, timeOfDay) ||
                other.timeOfDay == timeOfDay) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.activityLevel, activityLevel) ||
                other.activityLevel == activityLevel));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        searchQuery,
        selectedCategory,
        sortOption,
        dateFrom,
        dateTo,
        minComments,
        maxComments,
        const DeepCollectionEquality().hash(_categories),
        sentimentFilter,
        isAdvancedMode,
        dateFromCreated,
        dateToCreated,
        dateFromClosed,
        dateToClosed,
        dateFromUpdated,
        dateToUpdated,
        dateFilterType,
        minPositiveReactions,
        maxPositiveReactions,
        minNeutralReactions,
        maxNeutralReactions,
        minNegativeReactions,
        maxNegativeReactions,
        minTotalReactions,
        maxTotalReactions,
        dominantSentiment,
        roomStatus,
        const DeepCollectionEquality().hash(_relatedKeywordIds),
        hasMultipleKeywords,
        hasSummary,
        timeOfDay,
        dayOfWeek,
        activityLevel
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryFilterStateImplCopyWith<_$HistoryFilterStateImpl> get copyWith =>
      __$$HistoryFilterStateImplCopyWithImpl<_$HistoryFilterStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HistoryFilterStateImplToJson(
      this,
    );
  }
}

abstract class _HistoryFilterState implements HistoryFilterState {
  const factory _HistoryFilterState(
      {final String searchQuery,
      final String selectedCategory,
      final String sortOption,
      final DateTime? dateFrom,
      final DateTime? dateTo,
      final int? minComments,
      final int? maxComments,
      final List<String> categories,
      final String sentimentFilter,
      final bool isAdvancedMode,
      final DateTime? dateFromCreated,
      final DateTime? dateToCreated,
      final DateTime? dateFromClosed,
      final DateTime? dateToClosed,
      final DateTime? dateFromUpdated,
      final DateTime? dateToUpdated,
      final String dateFilterType,
      final int? minPositiveReactions,
      final int? maxPositiveReactions,
      final int? minNeutralReactions,
      final int? maxNeutralReactions,
      final int? minNegativeReactions,
      final int? maxNegativeReactions,
      final int? minTotalReactions,
      final int? maxTotalReactions,
      final String dominantSentiment,
      final String roomStatus,
      final List<int> relatedKeywordIds,
      final bool hasMultipleKeywords,
      final bool hasSummary,
      final String timeOfDay,
      final String dayOfWeek,
      final String activityLevel}) = _$HistoryFilterStateImpl;

  factory _HistoryFilterState.fromJson(Map<String, dynamic> json) =
      _$HistoryFilterStateImpl.fromJson;

  @override // 기존 필드들 (이전 호환성 유지)
  String get searchQuery;
  @override
  String get selectedCategory;
  @override
  String get sortOption;
  @override
  DateTime? get dateFrom;
  @override
  DateTime? get dateTo;
  @override
  int? get minComments;
  @override
  int? get maxComments;
  @override
  List<String> get categories;
  @override
  String get sentimentFilter;
  @override
  bool get isAdvancedMode;
  @override // DiscussionRoom 모델 기반 새 필터들
// 날짜 범위 필터 (created_at, updated_at, closed_at 기준)
  DateTime? get dateFromCreated;
  @override
  DateTime? get dateToCreated;
  @override
  DateTime? get dateFromClosed;
  @override
  DateTime? get dateToClosed;
  @override
  DateTime? get dateFromUpdated;
  @override
  DateTime? get dateToUpdated;
  @override
  String get dateFilterType;
  @override // 'created_at', 'updated_at', 'closed_at'
// 감정 반응 필터 (positive_count, neutral_count, negative_count)
  int? get minPositiveReactions;
  @override
  int? get maxPositiveReactions;
  @override
  int? get minNeutralReactions;
  @override
  int? get maxNeutralReactions;
  @override
  int? get minNegativeReactions;
  @override
  int? get maxNegativeReactions;
  @override
  int? get minTotalReactions;
  @override
  int? get maxTotalReactions;
  @override
  String get dominantSentiment;
  @override // 'positive', 'neutral', 'negative', 'all'
// 토론방 상태 필터 (is_closed)
  String get roomStatus;
  @override // 'all', 'closed', 'active'
// 키워드 관련 필터 (keyword_id_list)
  List<int> get relatedKeywordIds;
  @override
  bool get hasMultipleKeywords;
  @override // 기타 필터
  bool get hasSummary;
  @override // comment_summary가 있는지
// 시간대별 필터
  String get timeOfDay;
  @override // 'morning', 'afternoon', 'evening', 'night', 'all'
  String get dayOfWeek;
  @override // 'monday', 'tuesday', ..., 'weekend', 'weekday', 'all'
// 활동 수준 필터
  String get activityLevel;
  @override
  @JsonKey(ignore: true)
  _$$HistoryFilterStateImplCopyWith<_$HistoryFilterStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
