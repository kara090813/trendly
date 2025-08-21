import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 0)
class UserPreferences extends HiveObject {
  @HiveField(0)
  String? nickname;

  @HiveField(1)
  String? password;

  @HiveField(2)
  bool? isDarkMode; // null means follow system theme

  @HiveField(3)
  List<int> commentedRooms;

  @HiveField(4)
  List<int> commentIds;

  @HiveField(5)
  Map<int, String> roomSentiments;

  @HiveField(6)
  Map<int, String> commentReactions;

  @HiveField(7)
  DateTime? lastUpdated;

  @HiveField(8)
  DateTime? installDate;

  @HiveField(9)
  bool isPushNotificationEnabled;

  @HiveField(10)
  int discussionHomeLastTabIndex;

  @HiveField(11)
  int historyHomeLastTabIndex;

  UserPreferences({
    this.nickname,
    this.password,
    this.isDarkMode, // null means follow system theme
    List<int>? commentedRooms,
    List<int>? commentIds,
    Map<int, String>? roomSentiments,
    Map<int, String>? commentReactions,
    this.lastUpdated,
    this.installDate,
    this.isPushNotificationEnabled = true,
    this.discussionHomeLastTabIndex = 0,
    this.historyHomeLastTabIndex = 0,
  })  : commentedRooms = commentedRooms ?? [],
        commentIds = commentIds ?? [],
        roomSentiments = roomSentiments ?? {},
        commentReactions = commentReactions ?? {};

  // 팩토리 메서드 - 빈 preferences 생성
  factory UserPreferences.empty() {
    final now = DateTime.now();
    return UserPreferences(
      isDarkMode: null, // Follow system theme by default
      commentedRooms: [],
      commentIds: [],
      roomSentiments: {},
      commentReactions: {},
      lastUpdated: now,
      installDate: now, // 첫 생성 시가 설치일
      isPushNotificationEnabled: true,
      discussionHomeLastTabIndex: 0,
      historyHomeLastTabIndex: 0,
    );
  }

  // 댓글 작성한 토론방 추가
  void addCommentedRoom(int roomId) {
    if (!commentedRooms.contains(roomId)) {
      commentedRooms.add(roomId);
      lastUpdated = DateTime.now();
      save();
    }
  }

  // 댓글 ID 추가
  void addCommentId(int commentId) {
    if (!commentIds.contains(commentId)) {
      commentIds.add(commentId);
      lastUpdated = DateTime.now();
      save();
    }
  }

  // 토론방 감정 설정
  void setRoomSentiment(int roomId, String sentiment) {
    roomSentiments[roomId] = sentiment;
    lastUpdated = DateTime.now();
    save();
  }

  // 토론방 감정 제거
  void removeRoomSentiment(int roomId) {
    roomSentiments.remove(roomId);
    lastUpdated = DateTime.now();
    save();
  }

  // 댓글 반응 설정
  void setCommentReaction(int commentId, String reaction) {
    commentReactions[commentId] = reaction;
    lastUpdated = DateTime.now();
    save();
  }

  // 댓글 반응 제거
  void removeCommentReaction(int commentId) {
    commentReactions.remove(commentId);
    lastUpdated = DateTime.now();
    save();
  }

  // 좋아요한 댓글 목록
  List<int> getLikedComments() {
    return commentReactions.entries
        .where((entry) => entry.value == 'like')
        .map((entry) => entry.key)
        .toList();
  }

  // 싫어요한 댓글 목록
  List<int> getDislikedComments() {
    return commentReactions.entries
        .where((entry) => entry.value == 'dislike')
        .map((entry) => entry.key)
        .toList();
  }

  // 특정 감정의 토론방 목록
  List<int> getRoomsBySentiment(String sentiment) {
    return roomSentiments.entries
        .where((entry) => entry.value == sentiment)
        .map((entry) => entry.key)
        .toList();
  }

  // 내 댓글인지 확인
  bool isMyComment(int commentId) {
    return commentIds.contains(commentId);
  }

  // 참여한 토론방인지 확인
  bool hasParticipatedInRoom(int roomId) {
    return commentedRooms.contains(roomId);
  }

  // 모든 데이터 초기화
  void clearAllData() {
    nickname = null;
    password = null;
    commentedRooms.clear();
    commentIds.clear();
    roomSentiments.clear();
    commentReactions.clear();
    lastUpdated = DateTime.now();
    save();
  }

  // 참여 통계
  Map<String, int> getParticipationStats() {
    return {
      'roomCount': commentedRooms.length,
      'commentCount': commentIds.length,
      'sentimentCount': roomSentiments.length,
      'likeCount': getLikedComments().length,
      'dislikeCount': getDislikedComments().length,
    };
  }

  // 토론방 홈 탭 인덱스 설정
  void setDiscussionHomeTabIndex(int index) {
    discussionHomeLastTabIndex = index;
    lastUpdated = DateTime.now();
    save();
  }

  // 히스토리 홈 탭 인덱스 설정
  void setHistoryHomeTabIndex(int index) {
    historyHomeLastTabIndex = index;
    lastUpdated = DateTime.now();
    save();
  }
}