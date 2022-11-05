import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/firebase_provider.dart';
import 'package:reddit/core/type_def.dart';
import 'package:reddit/models/comment_model.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';

final postRepositoryProvider = Provider(
  (ref) => PostRepository(
    firebaseFirestore: ref.watch(firestoreProvider),
  ),
);

class PostRepository {
  final FirebaseFirestore _firebaseFirestore;
  PostRepository({
    required FirebaseFirestore firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore;
  CollectionReference get _post =>
      _firebaseFirestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _comments =>
      _firebaseFirestore.collection(FirebaseConstants.commentsCollection);
  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstants.userCollection);

  FutureVoid addPost(Post post) async {
    try {
      return right(_post.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchFeedPosts(List<Community> communities) {
    return _post
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_post.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void upVote(Post post, String uid) {
    if (post.downVotes.contains(uid)) {
      _post.doc(post.id).update({
        'downVotes': FieldValue.arrayRemove([uid])
      });
    }
    if (post.upVotes.contains(uid)) {
      _post.doc(post.id).update({
        'upVotes': FieldValue.arrayRemove([uid])
      });
    } else {
      _post.doc(post.id).update({
        'upVotes': FieldValue.arrayUnion([uid])
      });
    }
  }

  void downVote(Post post, String uid) {
    if (post.upVotes.contains(uid)) {
      _post.doc(post.id).update({
        'upVotes': FieldValue.arrayRemove([uid])
      });
    }
    if (post.downVotes.contains(uid)) {
      _post.doc(post.id).update({
        'downVotes': FieldValue.arrayRemove([uid])
      });
    } else {
      _post.doc(post.id).update({
        'downVotes': FieldValue.arrayUnion([uid])
      });
    }
  }

  Stream<Post> getPostById(String id) {
    return _post.doc(id).snapshots().map(
          (event) => Post.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());
      return right(_post
          .doc(comment.postId)
          .update({'commentCount': FieldValue.increment(1)}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>> getCommentsPost(String postId) {
    return _comments.where('postId', isEqualTo: postId).snapshots().map(
          (event) => event.docs
              .map((e) => Comment.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  FutureVoid awardPost(Post post, String award, String senderId) async {
    try {
      _post.doc(post.id).update({
        'awards': FieldValue.arrayUnion([award])
      });
      _users.doc(senderId).update({
        'awards': FieldValue.arrayRemove([award])
      });
      return right(_users.doc(post.uid).update({
        'awards': FieldValue.arrayUnion([award])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
