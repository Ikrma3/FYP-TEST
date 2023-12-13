import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String currentUserEmail = '';

  @override
  void initState() {
    super.initState();
    currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
    print("Email= $currentUserEmail");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Chats').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<String> chatRoomIDs = [];

          for (QueryDocumentSnapshot doc in snapshot.data!.docs) {
            String docID = doc.id;
            if (docID.contains(currentUserEmail)) {
              chatRoomIDs.add(docID);
            }
          }

          return ListView.builder(
            itemCount: chatRoomIDs.length,
            itemBuilder: (context, index) {
              String chatRoomID = chatRoomIDs[index];
              List<String> users = chatRoomID.split('-');
              users.remove(currentUserEmail);
              String otherUserEmail = users.first;

              return ListTile(
                title: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('DonorData')
                      .where('email', isEqualTo: otherUserEmail)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      print('No user data found for $otherUserEmail');
                      return Text(otherUserEmail); // Display email temporarily
                    }

                    Map<String, dynamic>? userData =
                        snapshot.data!.docs[0].data() as Map<String, dynamic>?;

                    if (userData == null) {
                      print('User data is null for $otherUserEmail');
                      return Text(otherUserEmail); // Display email temporarily
                    }

                    String userName = userData['userName'];
                    String photoUrl = userData['photoUrl'];

                    print(
                        'Displaying user data for $otherUserEmail: $userName, $photoUrl');

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(photoUrl),
                      ),
                      title: Text(
                          userName), // Display the user's userName as the title
                    );
                  },
                ),
                onTap: () async {
                  String chatRoomID = await getChatRoomID(
                    currentUserEmail,
                    otherUserEmail,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessageScreen(
                        currentUserID: currentUserEmail,
                        otherUserID: otherUserEmail,
                        chatRoomID: chatRoomID,
                      ),
                    ),
                  );
                },
              );
            },
          ); //
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(),
            ),
          );
        },
        child: Icon(Icons.search),
      ),
    );
  }
}

class Message {
  final String message;
  final String sender;
  final DateTime timestamp;

  Message({
    required this.message,
    required this.sender,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      message: map['message'] ?? '',
      sender: map['sender'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class MessageScreen extends StatefulWidget {
  final String currentUserID;
  final String otherUserID;
  final String chatRoomID;

  MessageScreen({
    required this.currentUserID,
    required this.otherUserID,
    required this.chatRoomID,
  });

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserID),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Chats')
                  .doc(widget.chatRoomID)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<Message> messages = [];
                messages.addAll((snapshot.data!.docs).map(
                  (doc) => Message.fromMap(doc.data() as Map<String, dynamic>),
                ));

                messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final Message message = messages[index];
                    bool isCurrentUserMessage =
                        message.sender == widget.currentUserID;

                    return Align(
                      alignment: isCurrentUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        margin: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color:
                              isCurrentUserMessage ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          message.message,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(
                      widget.currentUserID,
                      widget.otherUserID,
                      widget.chatRoomID,
                      _messageController.text,
                    );
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void sendMessage(
    String senderID, String receiverID, String chatRoomID, String message) {
  if (message.trim().isEmpty) {
    // Don't send empty messages
    return;
  }

  try {
    final Map<String, dynamic> messageData = {
      'message': message,
      'sender': senderID,
      'timestamp': FieldValue.serverTimestamp(),
    };

    FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatRoomID)
        .collection('messages')
        .add(messageData);
  } catch (e) {
    print('Error sending message: $e');
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';
  List<UserData> searchResults = [];

  void searchUsers(String query) {
    setState(() {
      searchQuery = query;
    });

    FirebaseFirestore.instance
        .collection('DonorData')
        .where('userName', isEqualTo: query)
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<UserData> results = [];
      querySnapshot.docs.forEach((doc) {
        UserData userData = UserData(
          email: doc['email'],
          profilePic: doc['photoUrl'],
          userName: doc[
              'userName'], // Assuming 'profilePic' field is present in Firestore
        );
        results.add(userData);
      });
      setState(() {
        searchResults = results;
      });
    }).catchError((error) {
      print('Error searching users: $error');
    });
  }

  Future<void> _navigateToMessageScreen(String otherUserEmail) async {
    final chatRoomID = await getChatRoomID(
      FirebaseAuth.instance.currentUser!.email!,
      otherUserEmail,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessageScreen(
            currentUserID: FirebaseAuth.instance.currentUser!.email!,
            otherUserID: otherUserEmail,
            chatRoomID: chatRoomID,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter user email...',
            ),
            onChanged: searchUsers,
          ),
          ElevatedButton(
            onPressed: () {
              // Do nothing, as the searchUsers function is already called with onChanged
            },
            child: Text('Search'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                UserData userData = searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userData.profilePic),
                  ),
                  title: Text(userData.userName),
                  onTap: () => _navigateToMessageScreen(userData.email),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserData {
  final String email;
  final String profilePic;
  final String userName;

  UserData(
      {required this.email, required this.profilePic, required this.userName});
}

Future<String> getChatRoomID(String user1, String user2) async {
  String chatRoomIDOption1 = '$user1-$user2';
  String chatRoomIDOption2 = '$user2-$user1';

  // Check for an existing document
  final docSnapshot1 = await FirebaseFirestore.instance
      .collection('Chats')
      .doc(chatRoomIDOption1)
      .get();

  if (docSnapshot1.exists) {
    print('Document $chatRoomIDOption1 exists.');
    return chatRoomIDOption1;
  }

  final docSnapshot2 = await FirebaseFirestore.instance
      .collection('Chats')
      .doc(chatRoomIDOption2)
      .get();

  if (docSnapshot2.exists) {
    print('Document $chatRoomIDOption2 exists.');
    return chatRoomIDOption2;
  }

  // If no existing document found, create a new one
  try {
    await FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatRoomIDOption1)
        .set({}); // Create an empty document
    print('Created new document $chatRoomIDOption1');
    return chatRoomIDOption1;
  } catch (e) {
    print('Error creating document: $e');
    return ''; // Return an empty string on error
  }
}

class ChatByButton {
  final String otherUser;

  ChatByButton(this.otherUser);

  Future<void> chatId(BuildContext context) async {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
    final chatRoomID = await getChatRoomID(currentUserEmail, otherUser);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageScreen(
          currentUserID: FirebaseAuth.instance.currentUser!.email!,
          otherUserID: otherUser,
          chatRoomID: chatRoomID,
        ),
      ),
    );
  }
}
