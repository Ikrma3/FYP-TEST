import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String userName;
  final String postId;
  final datePublished;
  final String postUrl;
  final String profImage;
  final String userType;
  final likes;
  final String email;
  final bool isActive;

  const Post({
    required this.description,
    required this.uid,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.userName,
    required this.profImage,
    required this.likes,
    required this.userType,
    required this.email,
    required this.isActive,
  });
  Map<String, dynamic> toJson() => {
        "userName": userName,
        "uid": uid,
        "description": description,
        "postId": postId,
        "datePublished": datePublished,
        "profImage": profImage,
        "postUrl": postUrl,
        "likes": likes,
        "userType": userType,
        "email": email,
        'Status': isActive,
      };
  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    List<String> following = List<String>.from(snapshot['following'] ?? []);
    return Post(
      userName: snapshot['userName'] ?? '',
      uid: snapshot['uid'] ?? '',
      description: snapshot['description'] ?? '',
      postId: snapshot['postId'] ?? '',
      datePublished: snapshot['datePublished'] ?? '',
      profImage: snapshot['profImage'] ?? '',
      likes: snapshot['likes'] ?? '',
      postUrl: snapshot['postUrl'] ?? '',
      userType: snapshot['userType'] ?? '',
      email: snapshot['email'] ?? '',
      isActive: snapshot['status'] ?? '',
    );
  }
}
