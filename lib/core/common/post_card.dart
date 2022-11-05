import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/responsive/responsive.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard(this.post, {super.key});
  void upVote(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).upVote(post);
  }

  void downVote(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).downVote(post);
  }

  void deletePost(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).deletePost(post);
  }

  void navigateToUserProfile(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComment(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) {
    ref
        .read(postControllerProvider.notifier)
        .awardPost(post: post, award: award, context: context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isImageType = post.type == 'image';
    final isTextType = post.type == 'text';
    final isLinkType = post.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    return Responsive(
      child: Column(
        children: [
          Container(
            decoration:
                BoxDecoration(color: currentTheme.drawerTheme.backgroundColor),
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16)
                            .copyWith(right: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => navigateToCommunity(context),
                                      child: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(post.communityProfile),
                                        radius: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () =>
                                                navigateToCommunity(context),
                                            child: Text(
                                              "r/${post.communityName}",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () =>
                                                navigateToUserProfile(context),
                                            child: Text(
                                              "u/${post.userName}",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                if (post.uid == user.uid)
                                  IconButton(
                                      onPressed: () => deletePost(ref),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Pallete.redColor,
                                      )),
                              ],
                            ),
                            if (post.awards.isNotEmpty) ...[
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                height: 25,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: post.awards.length,
                                    itemBuilder: (_, index) {
                                      final award = post.awards[index];
                                      return Image.asset(
                                        Constants.awards[award]!,
                                        height: 23,
                                      );
                                    }),
                              )
                            ],
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                post.title,
                                style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isImageType)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .35,
                                width: double.infinity,
                                child: Image.network(
                                  post.link!,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if (isLinkType)
                              AnyLinkPreview(
                                displayDirection:
                                    UIDirection.uiDirectionHorizontal,
                                link: post.link!,
                              ),
                            if (isTextType)
                              Container(
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Text(
                                  post.description!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => upVote(ref),
                                      icon: Icon(
                                        Constants.up,
                                        size: 30,
                                        color: post.upVotes.contains(user.uid)
                                            ? Pallete.redColor
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      "${post.upVotes.length - post.downVotes.length == 0 ? 'vote' : post.upVotes.length - post.downVotes.length}",
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    IconButton(
                                      onPressed: () => downVote(ref),
                                      icon: Icon(
                                        Constants.down,
                                        size: 30,
                                        color: post.downVotes.contains(user.uid)
                                            ? Pallete.blueColor
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          navigateToComment(context),
                                      icon: const Icon(
                                        Icons.comment,
                                        size: 30,
                                      ),
                                    ),
                                    Text(
                                      "${post.commentCount == 0 ? 'Comment' : post.commentCount}",
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                                ref
                                    .watch(getCommunityByNameProvider(
                                        post.communityName))
                                    .when(
                                      data: (community) {
                                        if (community.mods.contains(user.uid)) {
                                          return IconButton(
                                            onPressed: () => deletePost(ref),
                                            icon: const Icon(
                                                Icons.admin_panel_settings),
                                          );
                                        } else {
                                          return const SizedBox();
                                        }
                                      },
                                      error: (error, stackTrace) =>
                                          ErrorText(error: error.toString()),
                                      loading: () => const Loader(),
                                    ),
                                IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: GridView.builder(
                                                      shrinkWrap: true,
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount:
                                                                  3),
                                                      itemCount:
                                                          user.awards.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final award =
                                                            user.awards[index];

                                                        return GestureDetector(
                                                          onTap: () =>
                                                              awardPost(
                                                                  ref,
                                                                  award,
                                                                  context),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Image.asset(
                                                                Constants
                                                                        .awards[
                                                                    award]!),
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ));
                                    },
                                    icon: const Icon(Icons.card_giftcard))
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
