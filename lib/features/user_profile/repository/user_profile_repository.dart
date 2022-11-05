import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/enums/enum.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/firebase_provider.dart';
import 'package:reddit/core/type_def.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/models/user_model.dart';

final userProfileRepositoryProvider = Provider(
  (ref) => UserProfileRepository(
    firebaseFirestore: ref.watch(firestoreProvider),
  ),
);

class UserProfileRepository {
  final FirebaseFirestore _firebaseFirestore;
  UserProfileRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;
  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstants.userCollection);
  CollectionReference get _post =>
      _firebaseFirestore.collection(FirebaseConstants.postsCollection);

  FutureVoid editProfile(UserModel userModel) async {
    try {
      return right(
        _users.doc(userModel.uid).update(
              userModel.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchProfilePosts(String uid) {
    return _post
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  FutureVoid updateKarma(UserModel userModel) async {
    try {
      return right(
          _users.doc(userModel.uid).update({'karma': userModel.karma}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
