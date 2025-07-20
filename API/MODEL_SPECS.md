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

## CapsuleModel
- date: 캡슐 생성 날짜 (DateField, unique=True)
- top3_keywords: 해당 날짜의 상위 3개 키워드 정보 (JSON 필드, default=list)
- hourly_keywords: 5분 단위로 그룹화된 키워드 목록 (JSON 필드, default=list)
- created_at: 캡슐이 생성된 시간 (DateTime, auto_now_add=True)

### 인덱스
- date 필드에 인덱스 설정

### top3_keywords 예시 형식:
```json
[
  {
    "keyword": "포켓몬 우유",
    "score": 85.5,
    "appearance_count": 12,
    "average_rank": 2.5
  },
  {
    "keyword": "갤럭시 S25",
    "score": 78.0,
    "appearance_count": 10,
    "average_rank": 3.2
  },
  {
    "keyword": "천국보다 아름다운",
    "score": 72.3,
    "appearance_count": 8,
    "average_rank": 4.1
  }
]
```

### hourly_keywords 예시 형식:
```json
[
  {
    "time": "00:00",
    "keywords": ["포켓몬 우유", "갤럭시 S25", "이재명", "...]
  },
  {
    "time": "00:05",
    "keywords": ["천국보다 아름다운", "포켓몬 우유", "...]
  }
]
```

### 주요 특징:
- 하루 단위로 키워드 데이터를 집계하여 저장
- 점수는 출현 빈도(appearance_count)와 평균 순위(average_rank)를 기반으로 계산
- 5분 단위로 키워드를 그룹화하여 시간대별 트렌드 파악 가능
- daily_capsule_cron.py를 통해 매일 자정에 자동 생성

## SimpleKeywordModel
- keyword: 고유한 키워드 (문자열, max_length=30, unique=True)
- search_count: 사용자 검색 횟수 (Integer, default=0)
- last_searched: 마지막 검색 시간 (DateTime, null=True, blank=True)
- last_appeared: 크롤링에서 마지막 출현 시간 (DateTime, auto_now=True)

### 인덱스
- keyword 필드에 인덱스 설정
- search_count 필드에 내림차순 인덱스 설정 (인기 검색어 정렬용)
- keyword, search_count 복합 인덱스 설정 (자동완성 정렬용)

### 테이블명
- simple_keywords

### 주요 특징:
- 중복 없는 고유 키워드만 저장 (검색 및 자동완성 전용)
- KeywordModel과 달리 시간별 중복 저장하지 않음
- /api/keyword/history/ 호출 시 search_count 자동 증가
- keyword_resolver.py가 1시간마다 새 키워드 자동 추가/업데이트
- 자동완성 및 인기 검색어 API에서 사용
- Redis 캐싱으로 빠른 응답 속도 보장