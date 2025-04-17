import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'screens/_screens.dart';

class AppRouter {
  late final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          return MainScreen();
        },
      ),
      GoRoute(
        path: '/keyword/:id',
        name: 'keywordDetail',
        builder: (context, state) {
          final int keywordId = int.parse(state.pathParameters['id']!);
          return KeywordDetailScreen(keywordId: keywordId);
        },
      ),
      // 토론방 라우트 추가
      GoRoute(
        path: '/discussion/:id',
        name: 'discussionRoom',
        builder: (context, state) {
          final int discussionRoomId = int.parse(state.pathParameters['id']!);
          return DiscussionRoomScreen(discussionRoomId: discussionRoomId);
        },
      ),
    ],
    debugLogDiagnostics: true,
  );
}