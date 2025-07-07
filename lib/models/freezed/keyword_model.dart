import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'keyword_model.freezed.dart';
part 'keyword_model.g.dart';

@freezed
class Keyword with _$Keyword {
  const factory Keyword({
    required int id,
    required String keyword,
    required int rank,
    required DateTime created_at,
    @Default([]) dynamic type1,
    required String type2,
    required String type3,
    required String category,
    dynamic references,
    int? current_discussion_room,
  }) = _Keyword;

  factory Keyword.fromJson(Map<String, dynamic> json) => _$KeywordFromJson(json);
}

@freezed
class Reference with _$Reference {
  const factory Reference({
    required String type,
    required String title,
    required String link,
    required String date,
    String? thumbnail,
  }) = _Reference;

  factory Reference.fromJson(Map<String, dynamic> json) => _$ReferenceFromJson(json);
}

// 키워드 리스트 변환 함수
List<Keyword> parseKeywords(String jsonString) {
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => Keyword.fromJson(json)).toList();
}