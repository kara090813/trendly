# Models
## Keyword
- keyword: 실시간 유행 키워드 (문자열)
- rank: 검색어의 순위 (정수)
- created_at: 해당 키워드가 생성된 시간 (시간)
- type1: 3줄 요약 (문자열)
- type2: 짧은글 (문자열)
- type3: 긴 글 (문자열)
- category: 카테고리 (문자열)
- references: 출처 URL들 (JSON)
- current_discussion_room: 해당 키워드의 토론방 ID (정수)

## DiscussionRoom
- keyword: 실시간 유행 키워드 (문자열)
- keyword_id_list: 관련 키워드 식별자 목록 (정수 리스트)
- is_closed: 토론방 폐쇄 여부 (불린)
- created_at: 해당 토론방이 생성된 시간 (시간) 
- updated_at: 해당 토론방이 갱신된 시간 (시간) 
- closed_at: 해당 토론방이 폐쇄된 시간 (시간) 
- comment_count: 해당 토론방의 댓글 수 (정수)
- comment_summary: 해당 토론방의 댓글 요약 (문자열)
- positive_count: 긍정 평가 (정수)
- neutral_count: 중립 평가 (정수)
- negative_count: 부정 평가 (정수)
- sentiment_snapshot: 
  - 특정 시점의 긍정, 중립, 부정 평가 목록 (JSON 리스트)
```
[
  {
    "t": "2025-04-09T11:54:42.045532Z", 
    "pos": 3,
    "neu": 0,
    "neg": 0
  } 
]
```

## Comment
- discussion_room: 해당 댓글이 속하는 토론방의 ID (정수)
- ip_addr: 서버에서 인식한 IP 주소 (문자열)
  - 시리얼라이저를 통해 앞 두 옥텟만 반환됨
- user: 사용자의 식별자 (문자열)
- password: 비로그인 댓글의 수정/삭제 비밀번호 (문자열)
- nick: 사용자의 닉네임 (문자열)
- comment: 댓글 내용 (문자열)
- sub_comment_count: 해당 댓글의 subcomment 갯수 (정수)
- is_sub_comment: 해당 댓글의 subcomment 여부 (불린)
- parent: 해당 댓글이 subcomment인 경우, 부모 댓글의 ID (정수)
- created_at: 해당 댓글이 생성된 시간 (시간)
- like_count: 추천 수 (정수)
- dislike_count: 비추천 수 (정수)