import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopp_app/models/user.dart';
import 'package:shopp_app/pages/post_card.dart';
import 'package:shopp_app/providers/user_provider.dart';

import '../resources/auth_method.dart';
import 'logIn.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the user instance from the UserProvider
    final User? user = Provider.of<UserProvider>(context).getUser;

    // Check if the user is null
    if (user == null) {
      return const Center(
        child: Text('No User'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        centerTitle: false,
        title: const Text("Saviour"),
        actions: [
          IconButton(
            onPressed: () {
              donor_auth_methhod().signOut(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => logIn(),
                ),
              );
            },
            icon: const Icon(Icons.back_hand),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collectionGroup(
                user.userType == 'Donor' ? 'ngoPosts' : 'donorPosts')
            .snapshots(),
        builder: (
          context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error occurred while loading posts.'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No posts available.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => PostCard(
              snap: snapshot.data!.docs[index].data(),
            ),
          );
        },
      ),
    );
  }
}
