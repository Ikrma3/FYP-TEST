import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:password_hash_plus/password_hash_plus.dart';
import 'package:shopp_app/pages/colors.dart';
import 'package:shopp_app/pages/edit_profile.dart';
import 'package:shopp_app/pages/logIn.dart';
import 'package:shopp_app/pages/utils.dart';
import 'package:shopp_app/resources/auth_method.dart';

import '../resources/firestore_methods.dart';
import 'comment_screen.dart';

class profilePage extends StatefulWidget {
  final String uid;
  const profilePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<profilePage> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  var userData = {};
  bool isLoading = false;
  int postLen = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('DonorData')
          .doc(widget.uid)
          .get();

      var postSnap = await FirebaseFirestore.instance
          .collection(
              userData['userType'] == 'Donor' ? 'donorPosts' : 'ngoPosts')
          .get();
      postLen = postSnap.docs.length;

      userData = userSnap.data()! as Map<String, dynamic>;
      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              backgroundColor: appBarColor,
              title: userData.containsKey('userName')
                  ? Text(userData['userName'])
                  : null,
              centerTitle: false,
            ),
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: mobileBackgroundColor,
                                backgroundImage:
                                    NetworkImage(userData['photoUrl']),
                                radius: 40,
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        FirebaseAuth.instance.currentUser!
                                                    .uid ==
                                                widget.uid
                                            ? Column(
                                                children: [
                                                  EditProfile(
                                                    backgroundColor:
                                                        mobileBackgroundColor,
                                                    text: "Change Password",
                                                    textColor: primaryColor,
                                                    borderColor: Colors.grey,
                                                    function: () {
                                                      _showChangePasswordDialog(
                                                          context);
                                                    },
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          16), // Adding some spacing between the buttons
                                                  EditProfile(
                                                    backgroundColor:
                                                        mobileBackgroundColor,
                                                    text: "Sign Out",
                                                    textColor: primaryColor,
                                                    borderColor: Colors.grey,
                                                    function: () async {
                                                      await donor_auth_methhod()
                                                          .signOut(context);
                                                      Navigator.of(context)
                                                          .pushReplacement(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              logIn(),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              )
                                            : Text(" "),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(top: 15),
                            child: Text(
                              userData['userName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    postLen != 0
                        ? Container(
                            color: mobileBackgroundColor,
                            child: Column(
                              children: [
                                const Divider(),
                                FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection(
                                          userData['userType'] == 'Donor'
                                              ? 'donorPosts'
                                              : 'ngoPosts')
                                      .where('uid', isEqualTo: widget.uid)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: (snapshot.data! as dynamic)
                                          .docs
                                          .length,
                                      itemBuilder: (context, index) {
                                        DocumentSnapshot snap =
                                            (snapshot.data! as dynamic)
                                                .docs[index];
                                        return Container(
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                                width: double.infinity,
                                                child: Image.network(
                                                  snap['postUrl'],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),

                                              // Chat and Comment Section
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CommentScreen(
                                                                  snap: snap)),
                                                    ),
                                                    icon: const Icon(
                                                        Icons.comment_outlined),
                                                  ),
                                                  if (FirebaseAuth.instance
                                                          .currentUser!.uid ==
                                                      widget.uid) ...[
                                                    Column(
                                                      children: [
                                                        IconButton(
                                                          onPressed: () async {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      Dialog(
                                                                child: ListView(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    vertical:
                                                                        16,
                                                                  ),
                                                                  shrinkWrap:
                                                                      true,
                                                                  children: [
                                                                    InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        FirestoreMethods()
                                                                            .deletePost(snap['postId']);
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              12,
                                                                          horizontal:
                                                                              16,
                                                                        ),
                                                                        child: Text(
                                                                            'Delete'),
                                                                      ),
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        var cond =
                                                                            snap['Status'];
                                                                        if (cond ==
                                                                            true) {
                                                                          cond =
                                                                              false;
                                                                        } else {
                                                                          cond =
                                                                              true;
                                                                        }
                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection(userData['userType'] == 'Donor'
                                                                                ? 'donorPosts'
                                                                                : 'ngoPosts')
                                                                            .doc(snap['postId'])
                                                                            .update({
                                                                          'Status':
                                                                              cond,
                                                                        });

                                                                        print(
                                                                            cond);
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              12,
                                                                          horizontal:
                                                                              16,
                                                                        ),
                                                                        child: Text(
                                                                            'Active/Deactive'),
                                                                      ),
                                                                    ),
                                                                    // Add more InkWell widgets for additional buttons as needed
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          icon: const Icon(
                                                              Icons.more_horiz),
                                                        ),
                                                      ],
                                                    ),
                                                  ] else ...[
                                                    const Text(" "),
                                                  ],
                                                ],
                                              ),

                                              // Description of Post
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    DefaultTextStyle(
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                      child: const Text(
                                                        '',
                                                        style: TextStyle(
                                                          fontSize: 1,
                                                          color: secondaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 8,
                                                      ),
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style:
                                                              const TextStyle(
                                                            color: primaryColor,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  ' ${snap['description']}' ??
                                                                      '',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 18,
                                                                color:
                                                                    primaryColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: Colors.black,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        : const Text('No Post'),
                  ],
                ),
              ),
            ),
          );
  }

  void _showChangePasswordDialog(BuildContext context) {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Old Password"),
              ),
              SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "New Password"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Perform the password change here
                String oldPassword = oldPasswordController.text;
                String newPassword = newPasswordController.text;
                // Call a method to change the password in the database
                // Replace the following line with your actual method call
                _changePasswordInDatabase(oldPassword, newPassword);

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Submit"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _changePasswordInDatabase(String oldPassword, String nePassword) async {
    const salt = "ThisIsMyFixedSaltValue";
    var generator = new PBKDF2();
    var nPassword =
        generator.generateKey(oldPassword, salt, 1000, 32).toString();
    var generator1 = new PBKDF2();
    var newPassword =
        generator1.generateKey(nePassword, salt, 1000, 32).toString();

    // Retrieve the current user's document from Firestore
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDocument =
        await FirebaseFirestore.instance.collection('DonorData').doc(uid).get();

    if (userDocument.exists) {
      String storedPassword = 'abc';
      final data = userDocument.data();
      if (data != null) {
        final data =
            userDocument.data() as Map<String, dynamic>?; // Cast to Map
        if (data != null) {
          if (data.containsKey('Password')) {
            storedPassword = data['Password'];
          } else if (data.containsKey('password')) {
            // 'Password' field doesn't exist, but 'code' field exists
            storedPassword = data['password'];
            // Do something with storedCode
          }
        }

        // Compare the stored password with the newly provided password
        if (nPassword == storedPassword) {
          // Passwords match, update the password in the database
          User? user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            AuthCredential credential = EmailAuthProvider.credential(
              email: user.email!,
              password: nPassword,
            );
            try {
              await user.reauthenticateWithCredential(credential);
              await user.updatePassword(newPassword);
              // Update the new password in Firestore as well
              await FirebaseFirestore.instance
                  .collection('DonorData')
                  .doc(uid)
                  .update({'Password': newPassword});
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Alert"),
                    content: Text('Password Changed'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text("OK"),
                      ),
                    ],
                  );
                },
              );

              // Close the dialog or show a success message
            } catch (error) {
              print('Error updating password: $error');
              // Handle password update error
            }
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Alert"),
                content: Text('Old Password is Incorrect'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
          // Incorrect old password, show an error message
        }
      } else {
        print('User document not found');
        // User document not found, handle accordingly
      }
    }

    Column buildStatColumn(int num, String label) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            num.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 3),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      );
    }
  }
}
