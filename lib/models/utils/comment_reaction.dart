class CommentReaction {
  String? reactionType; // 'like' 또는 'dislike'
  int likeCount;
  int dislikeCount;

  CommentReaction({
    this.reactionType,
    required this.likeCount,
    required this.dislikeCount,
  });
}