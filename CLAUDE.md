# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Trendly is a Flutter mobile application that provides real-time trend insights by aggregating data from news, social media, and community platforms. It uses AI to analyze trends and provides discussion forums for users.

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run the application
flutter run

# Run tests
flutter test

# Generate Freezed models after modifying model files
flutter pub run build_runner build

# Build for production
flutter build apk     # Android
flutter build ios     # iOS
flutter build web     # Web
```

## Architecture Overview

### State Management
The app uses Provider for state management. Main providers are located in `/lib/providers/`:
- `keyword_provider.dart`: Manages keyword data and API calls
- `theme_provider.dart`: Handles theme switching

### Routing
Uses go_router for declarative routing. Routes are defined in `/lib/router.dart`:
- `/`: Main screen with trending keywords
- `/keyword/:id`: Keyword detail page
- `/discussion/:roomId`: Discussion room
- `/discussion/:roomId/comments/:commentId`: Comment thread

### Data Models
Models use Freezed for immutability and JSON serialization (`/lib/models/`):
- `keyword.dart`: Keyword data with trend information
- `discussion_room.dart`: Discussion forum data
- `comment.dart`: Comment and reaction data

### API Integration
All API calls go through `/lib/services/api_service.dart` using the singleton pattern.
Base URL: `https://trendly.servehttp.com:10443/api`

**Headers**: 
- `Content-Type: application/json`
- `Accept: application/json`
- UTF-8 encoding is applied to all responses
- No authentication required (public API)

### API Endpoints Reference

#### Keyword APIs

1. **POST /api/keyword/search/** - Search keywords by name and time range
   - Body: `{"keyword": "폭싹 속았수다", "start_time": "2025-04-05T00:00:00.000000Z", "end_time": "2025-04-08T12:30:00.000000Z"}`
   - Response: `{"id_list": [1, 2, 3, 4]}`

2. **GET /api/keyword/get/{keyword_id}/** - Get keyword details by ID
   - Path param: keyword_id (int)
   - Response: Single Keyword object

3. **POST /api/keyword/get_keyword_many/** - Get multiple keywords by IDs
   - Body: `{"id_list": [1, 2, 3, 4]}`
   - Response: List of Keyword objects

4. **GET /api/keyword/now/** - Get current top 10 trending keywords
   - Response: List of 10 Keyword objects with rank 1-10

5. **GET /api/keyword/time_machine/{time}/** - Get keywords at specific time
   - Path param: time (ISO8601 format: `time.toUtc().toIso8601String()`)
   - Response: List of 10 Keywords at that time

6. **GET /api/random_keyword_history/** - Get random keyword with rank history
   - Response: `{"keyword": "키워드명", "ranks": [1, 3, 2, 5, ...]}`

7. **POST /api/keyword/history/** - Get keyword history (404 if not found)
   - Body: `{"keyword": "키워드명"}`
   - Response: List of `{"id": 1, "keyword": "이재명", "rank": 1, "created_at": "2025-05-16T13:15:32.123456Z"}`

8. **GET /api/keyword/random/{count}/** - Get random keywords
   - Path param: count (int)
   - Response: List of random Keywords

9. **POST /api/keyword/history_simple/** - Get simplified keyword history
   - Body: `{"keyword": "포켓몬 우유", "period": "weekly"}` // period: daily, weekly, monthly, all
   - Response: `{"keyword": "포켓몬 우유", "period": "weekly", "history": [{"id": 123, "rank": 1, "created_at": "2025-02-13T21:30:00Z"}]}`

10. **GET /api/keyword/date_groups/{datestr}/** - Get all keywords for a specific date grouped by time
    - Path param: datestr (format: YYYY-MM-DD, e.g., 2025-01-15)
    - Response: `{"date": "2025-01-15", "keyword_groups": [{"created_at": "2025-01-15T00:32:00Z", "keywords": [10 keywords]}], "total_groups": 24}`

11. **GET /api/keyword/daily_summary/{datestr}/** - Get AI-generated daily summary
    - Path param: datestr (format: YYYY-MM-DD)
    - Response: `{"date": "2025-01-15", "top_keyword": {...}, "top_category": {...}, "top_discussion": {...}}`

#### Discussion Room APIs

1. **GET /api/discussion/get/{discussion_room_id}/** - Get discussion room details
   - Path param: discussion_room_id (int)
   - Response: Single DiscussionRoom object

2. **GET /api/discussion/get-latest-keyword-by-room-id/{discussion_room_id}/** - Get latest keyword for discussion room
   - Path param: discussion_room_id (int)
   - Response: Single Keyword object

3. **GET /api/discussion/now/** - Get current top 10 active discussion rooms
   - Response: List of 10 DiscussionRoom objects

4. **GET /api/discussion/all?page={N}** - Get all discussion rooms (paginated)
   - Query param: page (int, default 1, max 10 per page)
   - Response: List of DiscussionRooms

5. **POST /api/discussion/** - Get/create discussion room by keyword
   - Body: `{"keyword": "원하는 키워드"}`
   - Response: DiscussionRoom object (most recent for keyword)

6. **POST /api/discussion/{discussion_room_id}/sentiment/** - Update sentiment
   - Path param: discussion_room_id (int)
   - Body: `{"positive": "1", "neutral": "0", "negative": "0"}`
   - Response: 202 on success, 400 on failure

7. **GET /api/discussion/active/** - Get active (not closed) discussion rooms
   - Response: List of DiscussionRooms where is_closed=False

8. **GET /api/discussion/get_random/{count}/{option}/** - Get random discussion rooms
   - Path params: count (int), option (int: 1=Any, 2=Open only, 3=Closed only)
   - Response: List of random DiscussionRooms

#### Comment APIs

1. **GET /api/comment/{comment_id}/** - Get comment details
   - Path param: comment_id (int)
   - Response: Single Comment object

2. **POST /api/comment/{comment_id}/like/** - Toggle like on comment
   - Path param: comment_id (int)
   - Body: `{"is_cancel": true/false}`
   - Response: 202 on success, 400 on failure

3. **POST /api/comment/{comment_id}/dislike/** - Toggle dislike on comment
   - Path param: comment_id (int)
   - Body: `{"is_cancel": true/false}`
   - Response: 202 on success

4. **GET /api/discussion/{discussion_room_id}/comment/** - Get all comments for discussion
   - Path param: discussion_room_id (int)
   - Response: List of all Comment objects

5. **GET /api/discussion/{discussion_room_id}/get_comment/** - Get comments (newest, excluding subcomments)
   - Alias: `/api/discussion/{discussion_room_id}/get_comment/new`
   - Path param: discussion_room_id (int)
   - Response: List of Comments sorted by newest

6. **GET /api/discussion/{discussion_room_id}/get_comment/pop** - Get comments (popular, excluding subcomments)
   - Path param: discussion_room_id (int)
   - Response: List of Comments sorted by likes

7. **POST /api/discussion/{discussion_room_id}/add_comment/** - Add new comment
   - Path param: discussion_room_id (int)
   - Body: `{"discussion_room_id": "토론방 ID", "user": "사용자 ID", "password": "비밀번호", "nick": "닉네임", "comment": "댓글 내용", "is_sub_comment": true/false, "parent_id": "부모 댓글 ID (서브댓글인 경우)"}`
   - Response: 201 on success

8. **POST /api/discussion/{discussion_room_id}/del_comment/** - Delete comment
   - Path param: discussion_room_id (int)
   - Body: `{"comment_id": "댓글 ID", "password": "비밀번호"}`
   - Response: 204 on success

9. **GET /api/discussion/subcomment/{parent_comment_id}/new** - Get subcomments (newest)
   - Path param: parent_comment_id (int)
   - Response: List of subcomments sorted by newest

10. **GET /api/discussion/subcomment/{parent_comment_id}/pop** - Get subcomments (popular)
    - Path param: parent_comment_id (int)
    - Response: List of subcomments sorted by likes

### Data Models

#### Keyword
```dart
{
  "id": int,
  "keyword": String,              // Trend keyword name
  "rank": int,                    // 1-10 ranking
  "created_at": DateTime,         // ISO8601 UTC
  "type1": String,               // 3-line summary
  "type2": String,               // Short description
  "type3": String,               // Long detailed text
  "category": String,            // Category classification
  "references": Map<String, dynamic>, // Source URLs
  "current_discussion_room": int? // Active discussion room ID
}
```

#### DiscussionRoom
```dart
{
  "id": int,
  "keyword": String,             // Discussion topic
  "keyword_id_list": List<int>,  // Related keyword IDs
  "is_closed": bool,             // Room status
  "created_at": DateTime,
  "updated_at": DateTime,
  "closed_at": DateTime?,
  "comment_count": int,
  "comment_summary": String,     // AI-generated summary
  "positive_count": int,         // Sentiment counts
  "neutral_count": int,
  "negative_count": int,
  "sentiment_snapshot": List     // Historical sentiment data
}
```

#### Comment
```dart
{
  "id": int,
  "discussion_room": int,        // Parent room ID
  "ip_addr": String,            // Masked IP (first 2 octets)
  "user": String,               // User identifier
  "password": String,           // For edit/delete
  "nick": String,               // Display nickname
  "comment": String,            // Comment content
  "sub_comment_count": int,     // Reply count
  "is_sub_comment": bool,       // Is this a reply?
  "parent": int?,               // Parent comment ID if reply
  "created_at": DateTime,
  "like_count": int,
  "dislike_count": int
}
```

### Error Handling
- 200/202: Success
- 201: Created successfully
- 204: Deleted successfully
- 400: Bad request (invalid parameters)
- 404: Resource not found
- Other codes: Specific API failures

### UI Structure
- `/lib/screens/`: Main application screens
- `/lib/components/`: Page-level components (KeywordCard, DiscussionCard, etc.)
- `/lib/widgets/`: Reusable UI widgets (AnimatedLogo, GradientText, etc.)

## Key Development Patterns

1. **Freezed Models**: Always run `flutter pub run build_runner build` after modifying model files
2. **API Calls**: Use the ApiService singleton for all API interactions
3. **Responsive Design**: Use ScreenUtil for responsive dimensions
4. **Theme Support**: Access theme through `context.read<ThemeProvider>()`
5. **Error Handling**: API service includes built-in error handling with user-friendly messages

## Testing Approach

Tests should be placed in the `/test` directory following the same structure as `/lib`. Use `flutter test` to run all tests.