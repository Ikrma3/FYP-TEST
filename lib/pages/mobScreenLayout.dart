import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopp_app/pages/colors.dart';
import 'package:shopp_app/pages/global_variable.dart';
import 'package:shopp_app/pages/profile.dart';

class mobScreenLayout extends StatefulWidget {
  const mobScreenLayout({Key? key}) : super(key: key);

  @override
  State<mobScreenLayout> createState() => _mobScreenLayoutState();
}

class _mobScreenLayoutState extends State<mobScreenLayout> {
  int _page = 0;
  late PageController pageController;
  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: homeScreenItems,
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _page == 0 ? Colors.lightBlue : Colors.grey,
            ),
            label: '',
            backgroundColor: mobileBackgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.message_rounded,
              color: _page == 1 ? Colors.lightBlue : Colors.grey,
            ),
            label: '',
            backgroundColor: mobileBackgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: _page == 2 ? Colors.lightBlue : Colors.grey,
            ),
            label: '',
            backgroundColor: mobileBackgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle,
              color: _page == 3 ? Colors.lightBlue : Colors.grey,
            ),
            label: '',
            backgroundColor: mobileBackgroundColor,
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                icon: Icon(
                  Icons.person,
                  color: _page == 4 ? Colors.lightBlue : Colors.grey,
                ),
                onPressed: (() {
                  var user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    var UID = user.uid;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => profilePage(uid: UID),
                      ),
                    );
                  }
                })),
          ),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}
