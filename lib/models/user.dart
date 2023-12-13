import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String userName;
  final String photoUrl;
  final List following;
  final String password;
  final String userType;

  const User(
      {required this.email,
      required this.uid,
      required this.following,
      required this.password,
      required this.photoUrl,
      required this.userName,
      required this.userType,
      Uint8List? document});
  Map<String, dynamic> toJson() => {
        "userName": userName,
        "uid": uid,
        "email": email,
        "followig": following,
        "photoUrl": photoUrl,
        "password": password,
        "userType": userType,
      };
  static User fromSnap(DocumentSnapshot? snap) {
    if (snap == null || !snap.exists || snap.data() == null) {
      return User(
        userName: '',
        uid: '',
        email: '',
        following: [],
        photoUrl: '',
        password: '',
        userType: '',
      );
    }
    var snapshot = snap.data() as Map<String, dynamic>;
    List<String> following = List<String>.from(snapshot['following'] ?? []);
    return User(
      userName: snapshot['userName'] ?? '',
      uid: snapshot['uid'] ?? '',
      email: snapshot['email'] ?? '',
      following: following,
      photoUrl: snapshot['photoUrl'] ?? '',
      password: snapshot['password'] ?? '',
      userType: snapshot['userType'] ?? '',
    );
  }
}
