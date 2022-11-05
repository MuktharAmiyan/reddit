import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/theme/pallete.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  File? bannerImage;
  //List<Community> communities = [];
  Community? selectedCommunity;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerImage = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (widget.type == 'image' &&
        bannerImage != null &&
        titleController.text.trim().isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
          context: context,
          community: selectedCommunity!,
          title: titleController.text.trim(),
          image: bannerImage);
    } else if (widget.type == 'text' &&
        titleController.text.trim().isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
          context: context,
          community: selectedCommunity!,
          title: titleController.text.trim(),
          description: descriptionController.text.trim());
    } else if (widget.type == 'link' &&
        titleController.text.trim().isNotEmpty &&
        linkController.text.trim().isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
          context: context,
          community: selectedCommunity!,
          title: titleController.text.trim(),
          link: linkController.text.trim());
    } else {
      showSnakBar(context, 'Enter all the field');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(postControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isImageType = widget.type == 'image';
    final isTextType = widget.type == 'text';
    final isLinkType = widget.type == 'link';
    return Scaffold(
      appBar: AppBar(
        title: Text('Post ${widget.type}'),
        actions: [
          TextButton(onPressed: sharePost, child: const Text('Share')),
        ],
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Enter title here',
                      filled: true,
                    ),
                    maxLength: 21,
                  ),
                  const SizedBox(height: 10),
                  if (isImageType)
                    GestureDetector(
                      onTap: selectBannerImage,
                      child: DottedBorder(
                        radius: const Radius.circular(10),
                        dashPattern: const [10, 4],
                        strokeCap: StrokeCap.round,
                        color: currentTheme.textTheme.bodyText2!.color!,
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
                                : const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                  )),
                      ),
                    ),
                  if (isTextType)
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Description here',
                        filled: true,
                      ),
                      maxLines: 7,
                    ),
                  if (isLinkType)
                    TextField(
                      controller: linkController,
                      decoration: const InputDecoration(
                        hintText: 'Enter link here',
                        filled: true,
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Select Community'),
                  ),
                  ref.watch(userCommunityProvider(user.uid)).when(
                        data: (data) {
                          //communities = data;
                          //selectedCommunity = data[0];
                          if (data.isEmpty) {
                            return const SizedBox();
                          }
                          return DropdownButton(
                              value: selectedCommunity ?? data[0],
                              items: data
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCommunity = value;
                                });
                              });
                        },
                        error: ((error, stackTrace) =>
                            ErrorText(error: error.toString())),
                        loading: () => const Loader(),
                      ),
                ],
              ),
            ),
    );
  }
}
