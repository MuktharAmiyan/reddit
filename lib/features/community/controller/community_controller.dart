import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/storage_repository_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/repository/community_repository.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';
import 'package:routemaster/routemaster.dart';

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>(
  (ref) => CommunityController(
    communityRepository: ref.watch(communityRepositoryProvider),
    ref: ref,
    storageRepository: ref.watch(storageRepositoryProvider),
  ),
);

final getCommunityPostProvider =
    StreamProvider.family((ref, String communityName) {
  final postController = ref.watch(communityControllerProvider.notifier);
  return postController.fetchCommunityPost(communityName);
});

final userCommunityProvider = StreamProvider.family((ref, String uid) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities(uid);
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getCommunityByName(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.searchCommunity(query);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController(
      {required CommunityRepository communityRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    Community community = Community(
      id: name.replaceAll(' ', ''),
      name: name.replaceAll(' ', ''),
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );
    final res = await _communityRepository.createCommunity(community);
    state = false;

    res.fold((l) => showSnakBar(context, l.message), (r) {
      showSnakBar(context, 'Community created successfully');
      Routemaster.of(context).pop();
    });
  }

  void joinCommunity(Community community, BuildContext context) async {
    final user = _ref.read(userProvider)!;
    Either<Failure, void> res;
    if (community.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRepository.joinCommunity(community.name, user.uid);
    }
    res.fold((l) => showSnakBar(context, l.message), (r) {
      if (community.members.contains(user.uid)) {
        showSnakBar(context, "Community left Succsessfully");
      } else {
        showSnakBar(context, "Community joined Succsessfully");
      }
    });
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communityRepository.getUserCommunity(uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity(
      {required BuildContext context,
      required Community community,
      required File? bannerFile,
      required File? avatarFile}) async {
    state = true;
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
          'community/banner', community.name, bannerFile);
      res.fold((l) => showSnakBar(context, l.message),
          (r) => community = community.copyWith(banner: r));
    }

    if (avatarFile != null) {
      final res = await _storageRepository.storeFile(
          'community/avatar', community.name, avatarFile);
      res.fold((l) => showSnakBar(context, l.message),
          (r) => community = community.copyWith(avatar: r));
    }
    final result = await _communityRepository.editCommunity(community);
    state = false;
    result.fold((l) => showSnakBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void addMods(
      List<String> uids, String communityname, BuildContext context) async {
    final res = await _communityRepository.addMods(uids, communityname);
    res.fold(
      (l) => showSnakBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<Post>> fetchCommunityPost(String communtyName) {
    return _communityRepository.fetchCommunityPosts(communtyName);
  }
}
