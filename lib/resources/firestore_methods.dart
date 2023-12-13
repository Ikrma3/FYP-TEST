import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopp_app/models/posts.dart';
import 'package:shopp_app/resources/storage_method.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String userName,
    String profImage,
    String userType,
    String email,
    bool isActive,
  ) async {
    String res = "Some error occurred";

    try {
      String postId = const Uuid().v1();
      String photoUrl = await StorageMethods().uploadImageToStorage(
        'posts',
        file,
        true,
      );

      Post post = Post(
        description: description,
        uid: uid,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        userName: userName,
        profImage: profImage,
        likes: [],
        userType: userType,
        email: email,
        isActive: isActive,
      );

      // Store the post in the respective collection based on userType
      if (userType == 'Donor') {
        await _firestore.collection('donorPosts').doc(postId).set(
              post.toJson(),
            );
      } else if (userType == 'ngo') {
        await _firestore.collection('ngoPosts').doc(postId).set(
              post.toJson(),
            );
      }

      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Deleting post
  Future<void> deletePost(String postId) async {
    try {
      // Delete the post from both donorPosts and ngoPosts collections
      await _firestore.collection('donorPosts').doc(postId).delete();
      await _firestore.collection('ngoPosts').doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> postComment(String postId, String userType, String text,
      String uid, String name, String profilepic) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        if (userType == 'Donor') {
          await _firestore
              .collection('donorPosts')
              .doc(postId)
              .collection('comments')
              .doc(commentId)
              .set({
            'profilePic': profilepic,
            'name': name,
            'uid': uid,
            'text': text,
            'commentId': commentId,
            'userType': userType,
            'datePublished': DateTime.now(),
          });
        } else if (userType == 'ngo') {
          await _firestore
              .collection('ngoPosts')
              .doc(postId)
              .collection('comments')
              .doc(commentId)
              .set({
            'profilePic': profilepic,
            'name': name,
            'uid': uid,
            'text': text,
            'commentId': commentId,
            'userType': userType,
            'datePublished': DateTime.now(),
          });
        }
      } else {
        print('Text Is Empty');
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }
}
