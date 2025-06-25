# Models
## KeywordModel
- keyword: 실시간 유행 키워드 (문자열, max_length=30)
- rank: 검색어의 순위 (SmallInteger)
- created_at: 해당 키워드가 생성된 시간 (DateTime, auto_now_add=True)
- type1: 3줄 요약 (JSON 필드)
- type2: 짧은글 (문자열, max_length=1200)
- type3: 긴 글 (문자열, max_length=2000)
- category: 카테고리 (문자열, max_length=30)
- references: 출처 URL들 (JSON 필드, null=True, default=None)
- current_discussion_room: 해당 키워드의 토론방 (ForeignKey to DiscussionRoomModel, on_delete=SET_NULL, null=True, default=None)

### 인덱스
- keyword 필드에 인덱스 설정

## DiscussionRoomModel
- keyword: 실시간 유행 키워드 (문자열, max_length=30)
- keyword_id_list: 관련 키워드 식별자 목록 (JSON 필드, default=list, null=True)
- is_closed: 토론방 폐쇄 여부 (Boolean, default=False)
- created_at: 해당 토론방이 생성된 시간 (DateTime, auto_now_add=True) 
- updated_at: 해당 토론방이 갱신된 시간 (DateTime, null=True, default=None) 
- closed_at: 해당 토론방이 폐쇄된 시간 (DateTime, null=True, default=None) 
- comment_count: 해당 토론방의 댓글 수 (Integer, default=0, null=True)
- comment_summary: 해당 토론방의 댓글 요약 (문자열, max_length=400, null=True, default=None)
- positive_count: 긍정 평가 (Integer, default=0)
- neutral_count: 중립 평가 (Integer, default=0)
- negative_count: 부정 평가 (Integer, default=0)
- sentiment_snapshot: 특정 시점의 긍정, 중립, 부정 평가 목록 (JSON 필드, default=list, null=True)
### sentiment_snapshot 예시 형식:
```json
[
  {
    "t": "2025-04-09T11:54:42.045532Z", 
    "pos": 3,
    "neu": 0,
    "neg": 0
  } 
]
```

## CommentModel
- discussion_room: 해당 댓글이 속하는 토론방 (ForeignKey to DiscussionRoomModel, on_delete=CASCADE)
- ip_addr: 서버에서 인식한 IP 주소 (문자열, max_length=40, null=True, default=None)
  - 시리얼라이저를 통해 앞 두 옥텟만 반환됨
- user: 사용자의 식별자 (문자열, max_length=40)
- password: 비로그인 댓글의 수정/삭제 비밀번호 (문자열, max_length=40)
- nick: 사용자의 닉네임 (문자열, max_length=40)
- comment: 댓글 내용 (문자열, max_length=400)
- sub_comment_count: 해당 댓글의 subcomment 갯수 (Integer, default=0)
- is_sub_comment: 해당 댓글의 subcomment 여부 (Boolean)
- parent: 해당 댓글이 subcomment인 경우, 부모 댓글 (ForeignKey to self, on_delete=CASCADE, null=True, default=None)
- created_at: 해당 댓글이 생성된 시간 (DateTime, auto_now_add=True)
- like_count: 추천 수 (Integer, default=0)
- dislike_count: 비추천 수 (Integer, default=0)