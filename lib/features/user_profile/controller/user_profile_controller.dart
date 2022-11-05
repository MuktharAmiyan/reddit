import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/enums/enum.dart';
import 'package:reddit/core/providers/storage_repository_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/user_profile/repository/user_profile_repository.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>(
  (ref) => UserProfileController(
    userProfileRepository: ref.watch(userProfileRepositoryProvider),
    ref: ref,
    storageRepository: ref.watch(storageRepositoryProvider),
  ),
);

final getProfilePostProvider = StreamProvider.family((ref, String uid) {
  final postController = ref.watch(userProfileControllerProvider.notifier);
  return postController.fetchProfilePost(uid);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  UserProfileController(
      {required UserProfileRepository userProfileRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _userProfileRepository = userProfileRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void editProfile({
    required BuildContext context,
    required UserModel userModel,
    required File? bannerFile,
    required File? avatarFile,
    required String name,
  }) async {
    state = true;
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
          'user/banner', userModel.uid, bannerFile);
      res.fold((l) => showSnakBar(context, l.message),
          (r) => userModel = userModel.copyWith(banner: r));
    }

    if (avatarFile != null) {
      final res = await _storageRepository.storeFile(
          'user/avatar', userModel.uid, avatarFile);
      res.fold((l) => showSnakBar(context, l.message),
          (r) => userModel = userModel.copyWith(profilePic: r));
    }
    if (name.isNotEmpty) {
      userModel = userModel.copyWith(name: name);
    }
    final result = await _userProfileRepository.editProfile(userModel);
    state = false;
    result.fold((l) => showSnakBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  Stream<List<Post>> fetchProfilePost(String uid) {
    return _userProfileRepository.fetchProfilePosts(uid);
  }

  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);
    final res = await _userProfileRepository.updateKarma(user);
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }
}
