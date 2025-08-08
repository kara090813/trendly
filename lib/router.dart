import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/_screens.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  late final router = GoRouter(
    navigatorKey: navigatorKey,
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
      GoRoute(
        path: '/comment/:id',
        name: 'commentRoom',
        builder: (context, state) {
          final int commentRoomId = int.parse(state.pathParameters['id']!);
          return CommentRoomScreen(commentRoomId: commentRoomId);
        },
      ),
    ],
    debugLogDiagnostics: true,
  );
}