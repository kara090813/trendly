import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'keyword_model.freezed.dart';
part 'keyword_model.g.dart';

@freezed
class Keyword with _$Keyword {
  const factory Keyword({
    required int id,
    required String keyword,
    required String category,
    required int rank,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default([]) List<String> type1,
    required String type2,
    required String type3,
    @Default([]) List<Reference> references,
    // 필드명을 API 응답에 맞게 수정
    @JsonKey(name: 'current_discussion_room') @Default(0) int currentDiscussionRoomId,
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