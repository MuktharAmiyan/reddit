import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/firebase_provider.dart';
import 'package:reddit/core/type_def.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';

final communityRepositoryProvider = Provider(
  (ref) => CommunityRepository(
    firebaseFirestore: ref.watch(firestoreProvider),
  ),
);

class CommunityRepository {
  final FirebaseFirestore _firebaseFirestore;
  CommunityRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _community =>
      _firebaseFirestore.collection(FirebaseConstants.communitiesCollection);
  CollectionReference get _post =>
      _firebaseFirestore.collection(FirebaseConstants.postsCollection);

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _community.doc(community.name).get();
      if (communityDoc.exists) {
        throw 'Community with the same name already exists';
      }
      return right(
        _community.doc(community.name).set(
              community.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityName, String uid) async {
    try {
      return right(
        _community.doc(communityName).update(
          {
            'members': FieldValue.arrayUnion(
              [uid],
            ),
          },
        ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String uid) async {
    try {
      return right(
        _community.doc(communityName).update(
          {
            'members': FieldValue.arrayRemove(
              [uid],
            ),
          },
        ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunity(String uid) {
    return _community
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var community in event.docs) {
        communities.add(
          Community.fromMap(community.data() as Map<String, dynamic>),
        );
      }
      return communities;
    });
  }

  Stream<Community> getCommunityByName(String name) {
    return _community.doc(name).snapshots().map(
          (event) => Community.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(
        _community.doc(community.name).update(
              community.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _community
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var community in event.docs) {
        communities
            .add(Community.fromMap(community.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  FutureVoid addMods(List<String> uids, String communityname) async {
    try {
      return right(_community.doc(communityname).update({'mods': uids}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchCommunityPosts(String communityName) {
    return _post
        .where('communityName', isEqualTo: communityName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }
}
