import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/enums/enum.dart';
import 'package:reddit/core/providers/storage_repository_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/post/repository/post_repository.dart';
import 'package:reddit/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit/models/comment_model.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider = StateNotifierProvider<PostController, bool>(
  (ref) => PostController(
      postRepository: ref.watch(postRepositoryProvider),
      storageRepository: ref.watch(storageRepositoryProvider),
      ref: ref),
);

final getUserFeedPostProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchFeedPost(communities);
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fecthPostComments(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;

  PostController(
      {required PostRepository postRepository,
      required StorageRepository storageRepository,
      required Ref ref})
      : _postRepository = postRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required Community community,
    required String title,
    required String description,
  }) async {
    state = true;
    final id = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    Post post = Post(
        id: id,
        title: title,
        type: 'text',
        communityName: community.name,
        communityProfile: community.avatar,
        upVotes: [],
        downVotes: [],
        commentCount: 0,
        userName: user.name,
        uid: user.uid,
        createdAt: DateTime.now(),
        awards: [],
        description: description);
    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showSnakBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  void shareLinkPost({
    required BuildContext context,
    required Community community,
    required String title,
    required String link,
  }) async {
    state = true;
    final id = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    Post post = Post(
        id: id,
        title: title,
        type: 'link',
        communityName: community.name,
        communityProfile: community.avatar,
        upVotes: [],
        downVotes: [],
        commentCount: 0,
        userName: user.name,
        uid: user.uid,
        createdAt: DateTime.now(),
        awards: [],
        link: link);
    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    state = false;
    res.fold((l) => showSnakBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  void shareImagePost({
    required BuildContext context,
    required Community community,
    required String title,
    required File? image,
  }) async {
    state = true;
    final id = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final res = await _storageRepository.storeFile(
        'posts/${community.name}', id, image);
    state = false;
    res.fold((l) => showSnakBar(context, l.message), (r) async {
      state = true;
      Post post = Post(
          id: id,
          title: title,
          type: 'image',
          communityName: community.name,
          communityProfile: community.avatar,
          upVotes: [],
          downVotes: [],
          commentCount: 0,
          userName: user.name,
          uid: user.uid,
          createdAt: DateTime.now(),
          awards: [],
          link: r);
      final res = await _postRepository.addPost(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      state = false;
      res.fold((l) => showSnakBar(context, l.message),
          (r) => Routemaster.of(context).pop());
    });
  }

  Stream<List<Post>> fetchFeedPost(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchFeedPosts(communities);
    }
    return Stream.value([]);
  }

  void deletePost(Post post) async {
    final res = await _postRepository.deletePost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);
    res.fold((l) => null, (r) => null);
  }

  void upVote(Post post) {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upVote(post, uid);
  }

  void downVote(Post post) {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downVote(post, uid);
  }

  Stream<Post> getPostById(String id) {
    return _postRepository.getPostById(id);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
  }) async {
    final user = _ref.read(userProvider)!;
    final id = const Uuid().v1();
    final comment = Comment(
        id: id,
        text: text,
        createdAt: DateTime.now(),
        postId: post.id,
        userName: user.name,
        profilePic: user.profilePic);
    final res = await _postRepository.addComment(comment);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);
    res.fold((l) => showSnakBar(context, l.message), (r) => null);
  }

  Stream<List<Comment>> fecthPostComments(String postId) {
    return _postRepository.getCommentsPost(postId);
  }

  void awardPost(
      {required Post post,
      required String award,
      required BuildContext context}) async {
    final user = _ref.read(userProvider)!;
    final res = await _postRepository.awardPost(post, award, user.uid);
    res.fold((l) => null, (r) {
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }
}
