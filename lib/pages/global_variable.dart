import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopp_app/pages/add_post.dart';
import 'package:shopp_app/pages/feed.dart';
import 'package:shopp_app/pages/profile.dart';
import 'package:shopp_app/pages/search_screen.dart';

import 'chat.dart';

const webScreenSize = 600;
List<Widget> homeScreenItems = [
  FeedScreen(),
  HomeScreen(),
  searchScreen(),
  AddPost(),
  profilePage(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
