import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'discussion_room_model.freezed.dart';
part 'discussion_room_model.g.dart';

@freezed
class DiscussionRoom with _$DiscussionRoom {
  const factory DiscussionRoom({
    required int id,
    required String keyword,
    @JsonKey(name: 'keyword_id_list') required List<int> keywordIdList,
    @JsonKey(name: 'is_closed') required bool isClosed,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'closed_at') DateTime? closedAt,
    @JsonKey(name: 'comment_count') int? commentCount,
    @JsonKey(name: 'comment_summary') String? commentSummary,
    // 새로 추가된 감정 반응 관련 필드
    @JsonKey(name: 'positive_count') int? positiveCount,
    @JsonKey(name: 'neutral_count') int? neutralCount,
    @JsonKey(name: 'negative_count') int? negativeCount,
    @JsonKey(name: 'sentiment_snapshot') List<SentimentSnapshot>? sentimentSnapshot,
  }) = _DiscussionRoom;

  factory DiscussionRoom.fromJson(Map<String, dynamic> json) => _$DiscussionRoomFromJson(json);
}

// 감정 스냅샷 모델 추가
@freezed
class SentimentSnapshot with _$SentimentSnapshot {
  const factory SentimentSnapshot({
    @JsonKey(name: 't') required String time,
    @JsonKey(name: 'pos') required int positive,
    @JsonKey(name: 'neu') required int neutral,
    @JsonKey(name: 'neg') required int negative,
  }) = _SentimentSnapshot;

  factory SentimentSnapshot.fromJson(Map<String, dynamic> json) => _$SentimentSnapshotFromJson(json);
}

// 토론방 목록 변환 함수
List<DiscussionRoom> parseDiscussionRooms(String jsonString) {
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => DiscussionRoom.fromJson(json)).toList();
}