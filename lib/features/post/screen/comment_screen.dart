import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/features/post/widgets/comment_card.dart';
import 'package:reddit/models/post_model.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final commentController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post) {
    if (commentController.text.trim().isNotEmpty) {
      ref.read(postControllerProvider.notifier).addComment(
          context: context, text: commentController.text.trim(), post: post);
      commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (post) {
              return Column(
                children: [
                  PostCard(post),
                  TextField(
                    controller: commentController,
                    onSubmitted: (value) => addComment(post),
                    decoration: const InputDecoration(
                        filled: true,
                        hintText: 'what are your thoughts ?',
                        border: InputBorder.none),
                  ),
                  ref.watch(getPostCommentsProvider(widget.postId)).when(
                        data: (comments) => Expanded(
                          child: ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return CommentCard(comment: comment);
                              }),
                        ),
                        error: ((error, stackTrace) =>
                            ErrorText(error: error.toString())),
                        loading: () => const Loader(),
                      ),
                ],
              );
            },
            error: ((error, stackTrace) => ErrorText(error: error.toString())),
            loading: () => const Loader(),
          ),
    );
  }
}
