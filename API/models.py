from django.db import models # type: ignore


class KeywordModel(models.Model):
    keyword = models.CharField(max_length=30)
    rank = models.SmallIntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    type1 = models.JSONField()
    type2 = models.CharField(max_length=1200)
    type3 = models.CharField(max_length=2000)
    category = models.CharField(max_length=30)
    references = models.JSONField(default=None, null=True)
    current_discussion_room = models.ForeignKey('DiscussionRoomModel', on_delete=models.SET_NULL, default=None, null=True)
    class Meta:
        indexes = [
            models.Index(fields=['keyword']),
        ]


class DiscussionRoomModel(models.Model):
    keyword = models.CharField(max_length=30)
    keyword_id_list = models.JSONField(default=list, null=True)
    is_closed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(default=None, null=True)
    closed_at = models.DateTimeField(default=None, null=True)
    comment_count = models.IntegerField(default=0, null=True)
    comment_summary = models.CharField(max_length=400, default=None, null=True)
    positive_count = models.IntegerField(default=0)
    neutral_count = models.IntegerField(default=0)
    negative_count = models.IntegerField(default=0)
    sentiment_snapshot = models.JSONField(default=list, null=True)


class CommentModel(models.Model):
    discussion_room = models.ForeignKey(DiscussionRoomModel, on_delete=models.CASCADE)
    ip_addr = models.CharField(max_length=40, default=None, null=True)
    user = models.CharField(max_length=40)
    password = models.CharField(max_length=40)
    nick = models.CharField(max_length=40)
    comment = models.CharField(max_length=400)
    sub_comment_count = models.IntegerField(default=0)
    is_sub_comment = models.BooleanField()
    parent = models.ForeignKey('self', on_delete=models.CASCADE, default=None, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    like_count = models.IntegerField(default=0)
    dislike_count = models.IntegerField(default=0)