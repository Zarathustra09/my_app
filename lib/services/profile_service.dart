import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileService {
  Future<String> uploadImage(File imageFile, String uid) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('gallery/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> addImageToGallery(String uid, String imageUrl) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'gallery': FieldValue.arrayUnion([imageUrl]),
    });
  }

  Future<void> deleteImageFromGallery(String uid, String imageUrl) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'gallery': FieldValue.arrayRemove([imageUrl]),
    });

    final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
    await storageRef.delete();
  }
}