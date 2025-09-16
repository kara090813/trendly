import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'discussion_room_model.freezed.dart';
part 'discussion_room_model.g.dart';

@freezed
class DiscussionRoom with _$DiscussionRoom {
  const factory DiscussionRoom({
    required int id,
    required String keyword,
    required String category,
    @Default([]) List<int> keyword_id_list,
    @Default(false) bool is_closed,
    required DateTime created_at,
    DateTime? updated_at,
    DateTime? closed_at,
    int? comment_count,
    String? comment_summary,
    @Default(0) int positive_count,
    @Default(0) int neutral_count,
    @Default(0) int negative_count,
    @Default([]) List<SentimentSnapshot> sentiment_snapshot,
  }) = _DiscussionRoom;

  factory DiscussionRoom.fromJson(Map<String, dynamic> json) {
    // keyword_id_list에서 null이나 비정상 값 필터링
    if (json['keyword_id_list'] != null && json['keyword_id_list'] is List) {
      final List<int> filteredList = [];
      for (var item in json['keyword_id_list']) {
        if (item != null && item is num) {
          filteredList.add(item.toInt());
        }
      }
      json = Map<String, dynamic>.from(json);
      json['keyword_id_list'] = filteredList;
    }
    
    return _$DiscussionRoomFromJson(json);
  }
}

// 감정 스냅샷 모델 추가
@freezed
class SentimentSnapshot with _$SentimentSnapshot {
  const factory SentimentSnapshot({
    required String t,
    required int pos,
    required int neu,
    required int neg,
  }) = _SentimentSnapshot;

  factory SentimentSnapshot.fromJson(Map<String, dynamic> json) => _$SentimentSnapshotFromJson(json);
}

// 토론방 목록 변환 함수
List<DiscussionRoom> parseDiscussionRooms(String jsonString) {
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => DiscussionRoom.fromJson(json)).toList();
}