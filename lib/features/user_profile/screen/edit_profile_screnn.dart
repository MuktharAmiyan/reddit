import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit/models/user_model.dart';
import 'package:reddit/theme/pallete.dart';

class EditProfileScreeen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreeen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreeenState();
}

class _EditProfileScreeenState extends ConsumerState<EditProfileScreeen> {
  File? avatharImage;
  File? bannerImage;
  late TextEditingController nameController;

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerImage = File(res.files.first.path!);
      });
    }
  }

  void selectAvathaImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        avatharImage = File(res.files.first.path!);
      });
    }
  }

  void save(UserModel userModel) {
    ref.read(userProfileControllerProvider.notifier).editProfile(
        context: context,
        userModel: userModel,
        bannerFile: bannerImage,
        avatarFile: avatharImage,
        name: nameController.text.trim());
  }

  @override
  void initState() {
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
        data: (user) => Scaffold(
              backgroundColor: currentTheme.backgroundColor,
              appBar: AppBar(
                title: const Text("Edit Profile"),
                centerTitle: false,
                actions: [
                  TextButton(
                    onPressed: () => save(user),
                    child: const Text('Save'),
                  ),
                ],
              ),
              body: isLoading
                  ? const Loader()
                  : Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: selectBannerImage,
                                  child: DottedBorder(
                                    radius: const Radius.circular(10),
                                    dashPattern: const [10, 4],
                                    strokeCap: StrokeCap.round,
                                    color: currentTheme
                                        .textTheme.bodyText2!.color!,
                                    borderType: BorderType.RRect,
                                    child: Container(
                                      height: 150,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: bannerImage != null
                                          ? Image.file(
                                              bannerImage!,
                                              fit: BoxFit.cover,
                                            )
                                          : user.banner.isEmpty ||
                                                  user.banner ==
                                                      Constants.bannerDefault
                                              ? const Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 40,
                                                )
                                              : Image.network(
                                                  user.banner,
                                                  fit: BoxFit.cover,
                                                ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: GestureDetector(
                                    onTap: selectAvathaImage,
                                    child: avatharImage != null
                                        ? CircleAvatar(
                                            backgroundImage:
                                                FileImage(avatharImage!),
                                            radius: 32,
                                          )
                                        : CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(user.profilePic),
                                            radius: 32,
                                          ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Name',
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            maxLength: 21,
                          ),
                        ],
                      ),
                    ),
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
