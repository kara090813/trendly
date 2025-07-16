import 'package:freezed_annotation/freezed_annotation.dart';

part 'capsule_model.freezed.dart';
part 'capsule_model.g.dart';

@freezed
class CapsuleModel with _$CapsuleModel {
  const factory CapsuleModel({
    required String date,
    @JsonKey(name: 'top3_keywords') @Default([]) List<Top3Keyword> top3Keywords,
    @JsonKey(name: 'hourly_keywords') @Default([]) List<HourlyKeyword> hourlyKeywords,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _CapsuleModel;

  factory CapsuleModel.fromJson(Map<String, dynamic> json) => _$CapsuleModelFromJson(json);
}

@freezed
class Top3Keyword with _$Top3Keyword {
  const factory Top3Keyword({
    required String keyword,
    required double score,
    @JsonKey(name: 'appearance_count') required int appearanceCount,
    @JsonKey(name: 'avg_rank') required double avgRank,
    @JsonKey(name: 'last_keyword_id') int? lastKeywordId,
  }) = _Top3Keyword;

  factory Top3Keyword.fromJson(Map<String, dynamic> json) => _$Top3KeywordFromJson(json);
}

@freezed
class HourlyKeyword with _$HourlyKeyword {
  const factory HourlyKeyword({
    required String time,
    @Default([]) List<SimpleKeyword> keywords,
  }) = _HourlyKeyword;

  factory HourlyKeyword.fromJson(Map<String, dynamic> json) => _$HourlyKeywordFromJson(json);
}

@freezed
class SimpleKeyword with _$SimpleKeyword {
  const factory SimpleKeyword({
    required int id,
    required String keyword,
    required int rank,
    required String category,
    String? type2,
  }) = _SimpleKeyword;

  factory SimpleKeyword.fromJson(Map<String, dynamic> json) => _$SimpleKeywordFromJson(json);
}