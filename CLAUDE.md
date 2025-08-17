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
- `user_preference_provider.dart`: Manages user preferences, comment reactions, and sentiment selections
- `theme_provider.dart`: Handles theme switching (light/dark mode)

### Routing
Uses go_router for declarative routing. Routes are defined in `/lib/router.dart`:
- `/`: Main screen with trending keywords
- `/keyword/:id`: Keyword detail page
- `/discussion/:id`: Discussion room
- `/comment/:id`: Comment thread (for replies)

### Data Models
Models use Freezed for immutability and JSON serialization (`/lib/models/freezed/`):
- `keyword_model.dart`: Keyword data with trend information
  - Contains type1 (3-line summary as List), type2 (short text), type3 (long text)
  - References field for source URLs
  - Current discussion room reference
- `discussion_room_model.dart`: Discussion forum data
  - Sentiment counts (positive, neutral, negative)
  - Comment count and AI-generated summary
  - Sentiment snapshot for historical data
- `comment_model.dart`: Comment and reaction data
  - Support for sub-comments (replies)
  - Like/dislike counts
  - Password field for deletion

### API Integration
All API calls go through `/lib/services/api_service.dart` using the singleton pattern.
Base URL: `https://trendly.servehttp.com:10443/api`

**Headers**: 
- `Content-Type: application/json`
- `Accept: application/json`
- UTF-8 encoding is applied to all responses
- No authentication required (public API)

### API Endpoints Reference

#### Keyword APIs (Currently Implemented)

1. **GET /api/keyword/now/** - Get current top 10 trending keywords
   - Response: List of 10 Keyword objects with rank 1-10
   - **Status: ✅ Implemented**

2. **GET /api/keyword/get/{keyword_id}/** - Get keyword details by ID
   - Path param: keyword_id (int)
   - Response: Single Keyword object
   - **Status: ✅ Implemented**

3. **POST /api/keyword/get_keyword_many/** - Get multiple keywords by IDs
   - Body: `{"id_list": [1, 2, 3, 4]}`
   - Response: List of Keyword objects
   - **Status: ⚠️ Stub (returns empty list)**

4. **GET /api/keyword/get-latest-keyword-by-room-id/{discussion_room_id}/** - Get latest keyword for discussion room
   - Path param: discussion_room_id (int)
   - Response: Single Keyword object
   - **Status: ⚠️ Stub (returns error)**

Other keyword endpoints listed in the original spec are not yet implemented in the service layer.

#### Discussion Room APIs (Currently Implemented)

1. **GET /api/discussion/get/{discussion_room_id}/** - Get discussion room details
   - Path param: discussion_room_id (int)
   - Response: Single DiscussionRoom object
   - **Status: ✅ Implemented**

2. **POST /api/discussion/{discussion_room_id}/sentiment/** - Update sentiment
   - Path param: discussion_room_id (int)
   - Body: `{"positive": "1", "neutral": "0", "negative": "0"}`
   - Response: 202 on success, 400 on failure
   - **Status: ✅ Implemented**

3. **GET /api/discussion/active/** - Get active (not closed) discussion rooms
   - Response: List of DiscussionRooms where is_closed=False
   - **Status: ⚠️ Stub (returns empty list)**

4. **GET /api/discussion/now/** - Get current top 10 active discussion rooms
   - Response: List of 10 DiscussionRoom objects
   - **Status: ⚠️ Stub (returns empty list)**

Other discussion room endpoints are not yet implemented in the service layer.

#### Comment APIs (Currently Implemented)

1. **GET /api/discussion/{discussion_room_id}/get_comment/** - Get comments (newest, excluding subcomments)
   - Path param: discussion_room_id (int)
   - Response: List of Comments sorted by newest
   - **Status: ✅ Implemented**

2. **GET /api/discussion/{discussion_room_id}/get_comment/pop** - Get comments (popular, excluding subcomments)
   - Path param: discussion_room_id (int)
   - Response: List of Comments sorted by likes
   - **Status: ✅ Implemented**

3. **POST /api/discussion/{discussion_room_id}/add_comment/** - Add new comment
   - Path param: discussion_room_id (int)
   - Body: `{"discussion_room": int, "user": "string", "password": "string", "nick": "string", "comment": "string", "is_sub_comment": bool, "parent": int (optional)}`
   - Response: 201 on success
   - **Status: ✅ Implemented**

4. **POST /api/discussion/{discussion_room_id}/del_comment/** - Delete comment
   - Path param: discussion_room_id (int)
   - Body: `{"comment_id": int, "password": "string"}`
   - Response: 204 on success
   - **Status: ✅ Implemented**

5. **GET /api/comment/{comment_id}/** - Get comment details
   - Path param: comment_id (int)
   - Response: Single Comment object
   - **Status: ⚠️ Stub (returns error)**

6. **POST /api/comment/{comment_id}/like/** - Toggle like on comment
   - Path param: comment_id (int)
   - Body: `{"is_cancel": true/false}`
   - Response: 202 on success, 400 on failure
   - **Status: ⚠️ Stub (returns false)**

7. **POST /api/comment/{comment_id}/dislike/** - Toggle dislike on comment
   - Path param: comment_id (int)
   - Body: `{"is_cancel": true/false}`
   - Response: 202 on success
   - **Status: ⚠️ Stub (returns false)**

8. **GET /api/discussion/subcomment/{parent_comment_id}/new** - Get subcomments (newest)
   - Path param: parent_comment_id (int)
   - Response: List of subcomments sorted by newest
   - **Status: ⚠️ Stub (returns empty list)**

9. **GET /api/discussion/subcomment/{parent_comment_id}/pop** - Get subcomments (popular)
   - Path param: parent_comment_id (int)
   - Response: List of subcomments sorted by likes
   - **Status: ⚠️ Stub (returns empty list)**

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

#### Main Screens (`/lib/screens/`)
- `main_screen.dart`: Home screen with trending keywords
- `keywordDetail_screen.dart`: Keyword detail page with trend information
- `discussionRoom_screen.dart`: Discussion room with comments and reactions
  - Features tabs for "토론" (Discussion) and "요약" (Summary)
  - Sentiment selection (positive/neutral/negative)
  - Real-time countdown timer for discussion closure
- `commentRoom_screen.dart`: Comment thread for replies (sub-comments)

#### Components (`/lib/components/`)
- `discussionHotTab_component.dart`: Hot discussion rooms with swipeable top 3
- `discussionLiveTab_component.dart`: Live/active discussion rooms
- `discussionHistoryTab_component.dart`: Closed discussion rooms history
- `mypageHome_component.dart`: **NEW** My page with user profile, statistics, and settings

#### Key Widgets (`/lib/widgets/`)
- `discussionReaction_widget.dart`: Displays discussion sentiment statistics
  - Progress bar visualization for positive/neutral/negative reactions
  - Opinion summary cards
- `commentList_widget.dart`: Reusable comment list with sorting
- `circleButton_widget.dart`: Neumorphic circular button component
- `sortPopup_widget.dart`: Sort options for comments (newest/popular)

### Key Features

1. **Discussion Room Features**
   - Real-time sentiment tracking (positive/neutral/negative)
   - 24-hour discussion timer with automatic closure
   - Comment sorting (newest/popular)
   - Sub-comments (replies) support
   - Anonymous commenting with password-based deletion

2. **User Preferences & My Page**
   - **NEW** Comprehensive user profile management
   - Nickname and password editing with inline controls
   - App install date tracking and display
   - Activity statistics dashboard (rooms, comments, likes, sentiments)
   - Activity history sections:
     - Participated discussion rooms
     - Written comments list
     - Liked/disliked comments
   - Settings management (theme, notifications, data reset)
   - Anonymous user data with local storage

3. **Theme Support**
   - Dark/Light mode toggle with smooth transitions
   - Neumorphic design elements throughout
   - Consistent color scheme through AppTheme
   - Real-time theme switching with haptic feedback

## Key Development Patterns

1. **Freezed Models**: Always run `flutter pub run build_runner build` after modifying model files
2. **API Calls**: Use the ApiService singleton for all API interactions
3. **Responsive Design**: Use ScreenUtil for responsive dimensions (`.w`, `.h`, `.sp`)
4. **Theme Support**: Access theme through `AppTheme.isDark(context)` and related methods
5. **Error Handling**: Use `StylishToast` for user-friendly error messages
6. **Animations**: Use flutter_animate package for smooth transitions

## Local Storage

The app uses Hive (NoSQL database) for structured data management:
- **Primary**: Hive with automatic SharedPreferences migration
- **Legacy**: SharedPreferences (automatically migrated on first run)

**Hive Storage Structure**:
- `UserPreferences` model: All user data in single structured object
  - User nickname and password
  - Comment IDs (to identify user's own comments) 
  - Comment reactions (like/dislike states)
  - Room sentiment selections
  - Participated room history
  - Activity statistics and preferences

**Migration**: Existing SharedPreferences data is automatically migrated to Hive on app startup without data loss.

**Key Files**:
- `/lib/models/hive/user_preferences.dart`: Hive data model
- `/lib/services/hive_service.dart`: Hive database service
- `/lib/providers/user_preference_provider.dart`: Updated to use Hive

## Testing Approach

Tests should be placed in the `/test` directory following the same structure as `/lib`. Use `flutter test` to run all tests.

## Backend Models (Django)

Located in `/API/models.py`:
- `KeywordModel`: Stores keyword trends with AI-generated summaries
- `DiscussionRoomModel`: Manages discussion forums with sentiment tracking
- `CommentModel`: Handles comments with nested reply support