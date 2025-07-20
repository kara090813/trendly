# API Specifications
## Keyword-related APIs
### K1. /api/keyword/now/
- 요청하면 가장 최근 키워드 인스턴스 10개를 리턴함
- 요청 방식: GET
- 응답 형식: JSON, [Keyword 10개]

### K2. /api/keyword/get/<int:keyword_id>/
- 키워드 ID를 요청하면 해당하는 키워드 인스턴스를 리턴함
- 요청 방식: GET
- 응답 형식: JSON, Keyword 1개

### K. /api/keyword/search/
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

### K. /api/keyword/get_keyword_many/
- id_list에 나열된 키워드 리스트를 리턴함
- 요청 방식: POST
- 요청 형식: JSON
```
{
  "id_list": [1, 2, 3, 4]
}
```
- 응답 형식: Keyword n개

### K. /api/keyword/time_machine/<str:time>/
- 요청하면 해당 시점에서 가장 가까운 랭크 1-10의 키워드 인스턴스 10개를 리턴함
- 시간 형식은 time.toUtc().toIso8601String()
- 요청 방식: GET
- 응답 형식: JSON, [Keyword 10개]

### K. /api/random_keyword_history/
- 요청하면 임의 키워드의 키워드 문자열과 순위를 리턴함
- 요청 방식: GET
- 응답 형식: JSON
```
{
  'keyword': random_keyword,
  'ranks': 해당 키워드의 순위를 담은 정수 리스트
}
```

### K. /api/keyword/history/
- 특정 키워드의 심플 버전 KeywordModel 인스턴스를 created_at 오름차순으로 반환 (없으면 404)
- 요청 방식: POST
- 요청 형식: JSON
```
{
  "keyword": "이재명"
}
```
- 응답 형식: JSON
```
[
  {
    "id": 1,
    "keyword": "이재명",
    "rank": 1,
    "created_at": "2025-05-16T13:15:32.123456Z",
    "current_discussion_room_id": 123
  }, 
  ...
]
```
### K. /api/keyword/random/<int:count>/
- 요청하면 지정된 갯수의 임의 키워드를 반환함
- 요청 방식: GET
- 응답 방식: JSON
- 응답 형식: [KeywordModel 리스트 n개]
### K. /api/keyword/history_simple/
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
### K. /api/keyword/date_groups/<str:datestr>/
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
### K. /api/keyword/daily_summary/<str:datestr>/
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

### D2. /api/discussion/<int:discussion_room_id>/sentiment/
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

### D3. /api/discussion/hot/
- 요청 방식: GET
- 활성 상태인 토론방 10개를 (긍정+중립+부정+댓글수) 내림차순 정렬하여 반환

### D4. /api/discussion/active
- 요청 방식: GET
- 요청 형식: ?sort=(new|pop)&page=N&category=all
- 응답 형식: [DiscussionRoom 20개]
- sort는 new, pop으로 각 갱신시각순, (댓글+긍정)순을 표현함
- page는 Paginator(page 내 항목 수는 20개)에 의한 페이지를 표현함
- category는 해당 토론방 키워드의 카테고리를 표현함

### D5. /api/discussion/category/
- 요청 방식: GET
- 응답 형식: 결과는 스트링 리스트
- active상태인 디스커션 모델 리스트에서 카테고리들 뭐있는지 리턴받음

### D6. /api/discussion/count
- 요청 방식: GET
- 요청 형식: ?isActive=(true|false)&category=all
- 응답 형식: 해당 카테고리에 속하는 활성 상태인 토론방 수(int)

### D. /api/discussion/now/
- 요청 방식: GET
- 응답 형식: JSON, [DiscussionRoom 10개]
- 요청하면 가장 최근 키워드 인스턴스 10개와 동일 키워드를 가진 토론방 10개 인스턴스를 리턴

### D. /api/discussion/all?page=N
- 요청 방식: GET
- 응답 형식: JSON, [DiscussionRoom n개]
- 요청하면 모든 토론방 인스턴스를 페이지 당 최대 10개씩 리턴함

### D. /api/discussion/
- 요청 방식: POST
- 요청 형식: JSON, {"keyword": "원하는 키워드"}
- 응답 형식: JSON, DiscussionRoom 1개
- 요청하면 해당 키워드를 가진 토론방 중 가장 최근 1개의 인스턴스를 리턴

<!-- ### D. /api/discussion/active/
- 요청 방식: GET
- 응답 형식: [DiscussionRoom n개]
- is_closed가 False인 토론방 리스트 반환 -->

### D. /api/discussion/get_random/<int:count>/<int:option>/
- 요청 방식: GET
- 응답 형식: [DiscussionRoom n개]
- 지정된 수의 임의로 선택된 DiscussionRoom 인스턴스 리스트를 반환함
  - No option: Any
  - Option 1: Any
  - Option 2: Open only
  - Option 3: Closed only
### D. /api/discussion/count/<str:option>
- 요청 방식: GET
- 요청 형식: all, open, close을 option으로 가질 수 있다.
- 응답 형식: 각각 all은 모든 토론방, open은 열린 토론방, close는 닫힌 토론방의 수를 반환함
### D. /api/discussion/paging
- 요청 방식: GET
- 요청 형식: ?option=N&sort=(new|pop)&page=N
- 응답 형식: [DiscussionRoom 10개]
- option은 0, 1, 2로 각 all, open, closed를 표현함
- sort는 new, pop으로 각 갱신시각순, (댓글+긍정)순을 표현함
- page는 Paginator(page 내 항목 수는 10개)에 의한 페이지를 표현함
- 예시: ?option=1&sort=pop&page=1은 열린 토론방을 인기순으로 정렬한 뒤 1~10위 항목을 반환함

## Comment-related APIs
### C1. /api/discussion/<int:discussion_room_id>/get_comment/
- 요청 방식: GET
- 요청 형식: 맨 뒤에 new를 붙이거나 생략이면 최신순, pop을 붙이면 추천순으로 리턴함
- 응답 형식: JSON, [Comment n개]
- 요청하면 해당 토론방의 댓글 인스턴스들을 subcomment 제외하고 new/pop에 따라 리턴함

### C2. /api/discussion/<int:discussion_room_id>/add_comment/
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

### C3. /api/discussion/<int:discussion_room_id>/del_comment/
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

### C4. /api/comment/<int:comment_id>/
- 요청 방식: GET
- 응답 형식: 댓글 인스턴스 1개

### C5. /api/comment/<int:comment_id>/like/
- 요청 방식: POST
- 요청 형식: JSON,
```
{
  "is_cancel": true/false
}
```
- 응답 형식: 성공 시 202, 실패 시 400
- 특정 댓글의 추천 +1 (is_cancel이 true이면 추천 취소)

### C6. /api/comment/<int:comment_id>/dislike/
- 요청 방식: POST
- 요청 형식: JSON,
```
{
  "is_cancel": true/false
}
```
- 응답 형식: 성공 시 202
- 특정 댓글의 비추천 +1 (is_cancel이 true이면 비추 취소)

### C7. /api/discussion/subcomment/<int:parent_comment_id>/new
- 요청 방식: GET
- 응답 형식: [Comment n개]
- 특정 부모 댓글의 서브 댓글을 모두 가져옴(최신순)

### C. /api/discussion/subcomment/<int:parent_comment_id>/pop
- 요청 방식: GET
- 응답 형식: [Comment n개]
- 특정 부모 댓글의 서브 댓글을 모두 가져옴(추천순)

## Capsule-related APIs
### CAP1. /api/capsule/<str:date_str>/
- 특정 날짜의 키워드 캡슐 데이터를 조회
- 요청 방식: GET
- 요청 형식: YYYY-MM-DD (예: 2025-01-15)
- 응답 형식: JSON, CapsuleModel 1개
- 오류 응답:
  - 404: 해당 날짜의 캡슐이 존재하지 않습니다.
  - 400: 올바른 날짜 형식이 아닙니다. (YYYY-MM-DD)

## SimpleKeyword-related APIs (자동완성 기능)
### SK1. /api/keywords/autocomplete/
- 키워드 자동완성 기능
- 요청 방식: GET
- 요청 파라미터:
  - q: 검색어 (필수, 최소 1글자)
  - limit: 반환할 결과 수 (선택, 기본값: 10)
- 응답 형식: JSON
```json
{
  "suggestions": [
    {
      "keyword": "삼성전자",
      "search_count": 1523
    },
    {
      "keyword": "삼성 갤럭시",
      "search_count": 892
    }
  ]
}
```
- 특징:
  - 검색 빈도(search_count)와 최신성(last_appeared) 기준 정렬
  - Redis 캐싱으로 빠른 응답 (< 50ms)
  - prefix 매칭 방식

### SK2. /api/keywords/popular/
- 인기 검색어 조회
- 요청 방식: GET
- 요청 파라미터:
  - limit: 반환할 결과 수 (선택, 기본값: 100, 최대: 100)
- 응답 형식: JSON
```json
{
  "keywords": [
    {
      "keyword": "갤럭시 S25",
      "search_count": 5234
    },
    {
      "keyword": "김연아",
      "search_count": 4821
    }
  ]
}
```
- 특징:
  - 검색 횟수 기준 내림차순 정렬
  - Top 100 캐싱 (30분 TTL)

### 참고사항
- SimpleKeyword는 중복 없는 고유 키워드만 저장
- /api/keyword/history/ 호출 시 자동으로 search_count 증가
- keyword_resolver.py가 1시간마다 새 키워드 자동 추가