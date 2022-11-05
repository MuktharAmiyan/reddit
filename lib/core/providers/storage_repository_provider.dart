import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/firebase_provider.dart';
import 'package:reddit/core/type_def.dart';

final storageRepositoryProvider = Provider((ref) {
  final storage = ref.read(storageProvider);
  return StorageRepository(firebaseStorage: storage);
});

class StorageRepository {
  final FirebaseStorage _firebaseStorage;
  StorageRepository({required FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  FutureEither<String> storeFile(String path, String id, File? file) async {
    try {
      Reference ref = _firebaseStorage.ref().child(path).child(id);
      UploadTask uploadTask = ref.putFile(file!);
      final snapshot = await uploadTask;
      return right(await snapshot.ref.getDownloadURL());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
