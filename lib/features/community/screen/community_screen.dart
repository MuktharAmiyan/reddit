import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({super.key, required this.name});

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$name');
  }

  void joinCommunity(WidgetRef ref, BuildContext context, Community community) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
            data: (community) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    expandedHeight: 150,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            community.banner,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                              radius: 35,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "r/${community.name}",
                                style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                              community.mods.contains(user.uid)
                                  ? OutlinedButton(
                                      onPressed: () =>
                                          navigateToModTools(context),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                      ),
                                      child: const Text("Mod Tools"),
                                    )
                                  : OutlinedButton(
                                      onPressed: () => joinCommunity(
                                          ref, context, community),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                      ),
                                      child: Text(
                                          community.members.contains(user.uid)
                                              ? "Leave"
                                              : "Join"),
                                    ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text("${community.members.length} members"),
                          ),
                        ],
                      ),
                    ),
                  )
                ];
              },
              body: ref.watch(getCommunityPostProvider(name)).when(
                    data: (posts) => ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return PostCard(post);
                        }),
                    error: (error, stackTrace) =>
                        ErrorText(error: error.toString()),
                    loading: () => const Loader(),
                  ),
            ),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
