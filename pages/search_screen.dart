import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopp_app/pages/colors.dart';
import 'package:shopp_app/pages/profile.dart';

class searchScreen extends StatefulWidget {
  const searchScreen({super.key});

  @override
  State<searchScreen> createState() => _searchScreenState();
}

class _searchScreenState extends State<searchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUser = false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(labelText: 'Search'),
          onFieldSubmitted: (String sUser) {
            setState(() {
              isShowUser = true;
            });
          },
        ),
      ),
      body: isShowUser
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('DonorData')
                  .where(
                    'userName',
                    isEqualTo: searchController.text,
                  )
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        QuerySnapshot Qsnap = await FirebaseFirestore.instance
                            .collection('DonorData')
                            .where('userName', isEqualTo: searchController.text)
                            .limit(1)
                            .get();
                        var UID;
                        if (Qsnap.docs.isNotEmpty) {
                          UID = Qsnap.docs.first.id;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => profilePage(uid: UID),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              (snapshot.data! as dynamic).docs[index]
                                  ['photoUrl']),
                        ),
                        title: Text(
                          (snapshot.data! as dynamic).docs[index]['userName'],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : Text(''),
    );
  }
}
