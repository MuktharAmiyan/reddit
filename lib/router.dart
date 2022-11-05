import 'package:flutter/material.dart';
import 'package:reddit/features/auth/screen/login_screen.dart';
import 'package:reddit/features/community/screen/add_mod_screen.dart';
import 'package:reddit/features/community/screen/community_screen.dart';
import 'package:reddit/features/community/screen/create_community_screen.dart';
import 'package:reddit/features/community/screen/edit_community_screen.dart';
import 'package:reddit/features/community/screen/mod_tool_screen.dart';
import 'package:reddit/features/home/screen/home_screen.dart';
import 'package:reddit/features/post/screen/add_post_screen.dart';
import 'package:reddit/features/post/screen/add_post_type_screen.dart';
import 'package:reddit/features/post/screen/comment_screen.dart';
import 'package:reddit/features/user_profile/screen/edit_profile_screnn.dart';
import 'package:reddit/features/user_profile/screen/user_profile_screen.dart';
import 'package:routemaster/routemaster.dart';

// logged Out

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(
        child: LoginScreen(),
      ),
});

//logged In
final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(
        child: HomeScreen(),
      ),
  '/create-community': (_) =>
      const MaterialPage(child: CreateCommunityScreen()),
  '/r/:name': (route) => MaterialPage(
          child: CommunityScreen(
        name: route.pathParameters['name']!,
      )),
  '/mod-tools/:name': (route) => MaterialPage(
        child: ModToolsScreen(
          name: route.pathParameters['name']!,
        ),
      ),
  '/edit-community/:name': (route) => MaterialPage(
        child: EditCommunityScreen(
          name: route.pathParameters['name']!,
        ),
      ),
  '/add-mod/:name': (route) => MaterialPage(
        child: AddModScreen(name: route.pathParameters['name']!),
      ),
  '/u/:uid': (route) =>
      MaterialPage(child: UserProfileScreen(uid: route.pathParameters['uid']!)),
  '/edit-profile/:uid': (route) => MaterialPage(
      child: EditProfileScreeen(uid: route.pathParameters['uid']!)),
  '/add-post/:type': (route) => MaterialPage(
      child: AddPostTypeScreen(type: route.pathParameters["type"]!)),
  '/post/:postId/comments': (route) => MaterialPage(
      child: CommentScreen(postId: route.pathParameters['postId']!)),
  '/add-post': (route) => const MaterialPage(child: AddPostScreen()),
});
