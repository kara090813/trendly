# API Specifications
## Keyword-related APIs
### K1. /api/keyword/search/
- 요청하면 조건에 맞는 키워드들의 ID 목록을 리턴함
- 요청 방식: POST
- 요청 형식: JSON
```
{
  "keyword": "폭싹 속았수다",
  "start_time": "2025-04-05T00:00:00.000000Z",
  "end_time": "2025-04-08T12:30:00.000000Z"
}
```
- 응답 형식: JSON
```
{
  "id_list": [1, 2, 3, 4]
}
```

### K2. /api/keyword/get/<int:keyword_id>/
- 키워드 ID를 요청하면 해당하는 키워드 인스턴스를 리턴함
- 요청 방식: GET
- 응답 형식: JSON, Keyword 1개

### K3. /api/keyword/get_keyword_many/
- id_list에 나열된 키워드 리스트를 리턴함
- 요청 방식: POST
- 요청 형식: JSON
```
{
  "id_list": [1, 2, 3, 4]
}
```
- 응답 형식: Keyword n개

### K4. /api/keyword/now/
- 요청하면 가장 최근 키워드 인스턴스 10개를 리턴함
- 요청 방식: GET
- 응답 형식: JSON, [Keyword 10개]

### K5. /api/keyword/time_machine/<str:time>/
- 요청하면 해당 시점에서 가장 가까운 랭크 1-10의 키워드 인스턴스 10개를 리턴함
- 시간 형식은 time.toUtc().toIso8601String()
- 요청 방식: GET
- 응답 형식: JSON, [Keyword 10개]

### K6. /api/random_keyword_history/
- 요청하면 임의 키워드의 키워드 문자열과 순위를 리턴함
- 요청 방식: GET
- 응답 형식: JSON
```
{
  'keyword': random_keyword,
  'ranks': 해당 키워드의 순위를 담은 정수 리스트
}
```

### K7. /api/keyword/history/
- 요청하면 특정 keyword의 일부 필드만 가진 KeywordModel 리스트를 리턴함(없으면 404)
- 요청 방식: POST
- 요청 형식: JSON
```
{
  'keyword': '키워드명'
}
```
- 응답 형식: 
```
[
  {
    'id': 1,
    'keyword': '이재명',
    'rank': 1,
    'created_at': '2025-05-16T13:15:32.123456Z'
  }, 
  ...
]

```
### K8. /api/keyword/random/<int:count>/
- 요청하면 지정된 갯수의 임의 키워드를 반환함
- 요청 방식: GET
- 응답 방식: JSON
- 응답 형식: [KeywordModel 리스트 n개]
### K9. /api/keyword/history_simple/
- 특정 키워드의 간략화된 히스토리 정보 제공
- 요청 방식: POST
- 요청 형식: JSON
```
{
  "keyword": "포켓몬 우유",
  "period": "weekly"  // daily, weekly, monthly, all
}
```
- 응답 형식: JSON
```
{
  "keyword": "포켓몬 우유",
  "period": "weekly",
  "history": [[
    {
      "id": 123,
      "rank": 1,
      "created_at": "2025-02-13T21:30:00Z"
    },
    {
      "id": 124,
      "rank": 3,
      "created_at": "2025-02-10T14:20:00Z"
    }
  ]]
}
```
### K10. /api/keyword/date_groups/<str:datestr>/
- 특정 날짜에 생성된 키워드를 10개씩 묶어서 전체 반환
- 요청 방식: GET
- 요청 형식: YYYY-MM-DD (예: 2025-01-15)
- 응답 형식: JSON
```
{
  "date": "2025-01-15",
  "keyword_groups": [
    {
      "created_at": "2025-01-15T00:32:00Z",
      "keywords": [
        {"id": 1, "keyword": "포켓몬 우유", "rank": 1, "category": "연예"},
        {"id": 2, "keyword": "갤럭시 S25", "rank": 2, "category": "IT"}
        // ... 10개
      ]
    },
    {
      "created_at": "2025-01-15T01:30:00Z", 
      "keywords": [
        // ... 다음 10개
      ]
    }
  ],
  "total_groups": 24
}
```
### K11. /api/keyword/daily_summary/<str:datestr>/
- 특정 날짜의 일일 요약 리포트 제공
- 요청 방식: GET
- 요청 형식: YYYY-MM-DD (예: 2025-01-15)
- 응답 형식: JSON
```
{
  "date": "2025-01-15",
  "top_keyword": {
    "keyword": "천국보다 아름다운",
    "keyword_id": 123,
    "avg_rank": 2.5,
    "best_rank": 1
  },
  "top_category": {
    "category": "연예",
    "percentage": 40.0,
    "count": 4
  },
  "top_discussion_room": {
    "id": 456,
    "keyword": "갤럭시 S25",
    "comment_count": 1847,
    "positive_count": 1200,
    "neutral_count": 500,
    "negative_count": 591
  }
}
```

## DiscussionRoom-related APIs
### D1. /api/discussion/get/<int:discussion_room_id>/
- 요청 방식: GET
- 응답 형식: JSON, DiscussionRoom 1개
- 요청하면 해당 토론방 인스턴스를 리턴
### D2. /api/discussion/get-latest-keyword-by-room-id/<int:discussion_room_id>/
- 요청 방식: GET
- 응답 형식: JSON, Keyword 1개
- 요청하면 해당 토론방과 동일한 키워드를 가진 가장 최신 키워드 인스턴스를 리턴
### D3. /api/discussion/now/
- 요청 방식: GET
- 응답 형식: JSON, [DiscussionRoom 10개]
- 요청하면 가장 최근 키워드 인스턴스 10개와 동일 키워드를 가진 토론방 10개 인스턴스를 리턴
### D4. /api/discussion/all?page=N
- 요청 방식: GET
- 응답 형식: JSON, [DiscussionRoom n개]
- 요청하면 모든 토론방 인스턴스를 페이지 당 최대 10개씩 리턴함
### D5. /api/discussion/
- 요청 방식: POST
- 요청 형식: JSON, {"keyword": "원하는 키워드"}
- 응답 형식: JSON, DiscussionRoom 1개
- 요청하면 해당 키워드를 가진 토론방 중 가장 최근 1개의 인스턴스를 리턴
### D6. /api/discussion/<int:discussion_room_id>/sentiment/
- 요청 방식: POST
- 요청 형식: JSON,
```
{
  "positive": "1",
  "neutral": "0",
  "negative": "0"
}
```
- 응답 형식: 성공 시 202, 실패 시 400
- 해당 토론방의 반응 조정
### D7. /api/discussion/active/
- 요청 방식: GET
- 응답 형식: [DiscussionRoom n개]
- is_closed가 False인 토론방 리스트 반환
### D8. /api/discussion/get_random/<int:count>/<int:option>/
- 요청 방식: GET
- 응답 형식: [DiscussionRoom n개]
- 지정된 수의 임의로 선택된 DiscussionRoom 인스턴스 리스트를 반환함
  - No option: Any
  - Option 1: Any
  - Option 2: Open only
  - Option 3: Closed only
### D9. /api/discussion/count/<str:option>
- 요청 방식: GET
- 요청 형식: all, open, close을 option으로 가질 수 있다.
- 응답 형식: 각각 all은 모든 토론방, open은 열린 토론방, close는 닫힌 토론방의 수를 반환함
### D10. /api/discussion/paging
- 요청 방식: GET
- 요청 형식: ?option=N&sort=(new|pop)&page=N
- 응답 형식: [DiscussionRoom 10개]
- option은 0, 1, 2로 각 all, open, closed를 표현함
- sort는 new, pop으로 각 갱신시각순, (댓글+긍정)순을 표현함
- page는 Paginator(page 내 항목 수는 10개)에 의한 페이지를 표현함
- 예시: ?option=1&sort=pop&page=1은 열린 토론방을 인기순으로 정렬한 뒤 1~10위 항목을 반환함

## Comment-related APIs
### C1. /api/comment/<int:comment_id>/
- 요청 방식: GET
- 응답 형식: 댓글 인스턴스 1개
### C2. /api/comment/<int:comment_id>/like/
- 요청 방식: POST
- 요청 형식: JSON,
```
{
  "is_cancel": true/false
}
```
- 응답 형식: 성공 시 202, 실패 시 400
- 특정 댓글의 추천 +1 (is_cancel이 true이면 추천 취소)
### C3. /api/comment/<int:comment_id>/dislike/
- 요청 방식: POST
- 요청 형식: JSON,
```
{
  "is_cancel": true/false
}
```
- 응답 형식: 성공 시 202
- 특정 댓글의 비추천 +1 (is_cancel이 true이면 비추 취소)
### C4. /api/discussion/<int:discussion_room_id>/comment/
- 요청 방식: GET
- 응답 형식: JSON, [Comment n개]
- 요청하면 해당 토론방 내 모든 댓글 인스턴스를 리턴함
### C5. /api/discussion/<int:discussion_room_id>/get_comment/
- 동의어: discussion/<int:discussion_room_id>/get_comment/new
- 요청 방식: GET
- 응답 형식: JSON, [Comment n개]
- 요청하면 해당 토론방의 댓글 인스턴스들을 subcomment 제외하고 최신순으로 리턴함
### C6. /api/discussion/<int:discussion_room_id>/get_comment/pop
- 요청 방식: GET
- 응답 형식: JSON, [Comment n개]
- 요청하면 해당 토론방의 댓글 인스턴스들을 subcomment 제외하고 추천순으로 리턴함
### C7. /api/discussion/<int:discussion_room_id>/add_comment/
- 요청 방식: POST
- 요청 형식: JSON, 
```
{
  "discussion_room": 토론방_ID (정수),
  "user": "사용자 ID",
  "password": "비밀번호",
  "nick": "닉네임",
  "comment": "댓글 내용",
  "is_sub_comment": true/false,
  "parent": 부모_댓글_ID (대댓글인 경우만, 정수)
}
```
- 응답 형식: 성공 시 HTTP 201 + 생성된 댓글 데이터
- 주의사항: 
  - ip_addr은 서버에서 자동으로 HTTP 헤더에서 추출하여 설정
  - 토론방 댓글 수가 자동으로 +1 됨
  - 대댓글인 경우 부모 댓글의 sub_comment_count가 자동으로 +1 됨
### C8. /api/discussion/<int:discussion_room_id>/del_comment/
- 요청 방식: POST
- 요청 형식: JSON, 
```
{
  "comment_id": "댓글 ID",
  "password": "비밀번호"
}
```
- 응답 형식: 성공 시 HTTP 204
- 요청하면 해당 댓글을 삭제하고 토론방 댓글 수를 -1
### C9. /api/discussion/subcomment/<int:parent_comment_id>/new
- 요청 방식: GET
- 응답 형식: [Comment n개]
- 특정 부모 댓글의 서브 댓글을 모두 가져옴(최신순)
### C10. /api/discussion/subcomment/<int:parent_comment_id>/pop
- 요청 방식: GET
- 응답 형식: [Comment n개]
- 특정 부모 댓글의 서브 댓글을 모두 가져옴(추천순)