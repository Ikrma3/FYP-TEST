import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shopp_app/models/user.dart' as model;
import 'package:shopp_app/pages/chat.dart';
import 'package:shopp_app/pages/colors.dart';
import 'package:shopp_app/pages/comment_screen.dart';
import 'package:shopp_app/pages/profile.dart';
import 'package:shopp_app/resources/firestore_methods.dart';

import '../resources/auth_method.dart';

class PostCard extends StatefulWidget {
  final snap;

  PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  Map<String, dynamic>? paymentIntentData;
  bool _showDonateAmountField = false;
  TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<model.User>(
        future: AuthMethods().getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            model.User user = snapshot.data!;
            bool isDonor = user.userType == 'Donor';
            String collectionName = 'DonorData';

            return Container(
              color: mobileBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                            .copyWith(right: 0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            widget.snap['profImage'] ?? '',
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextButton(
                                    child: Text(widget.snap['userName'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () async {
                                      QuerySnapshot Qsnap =
                                          await FirebaseFirestore.instance
                                              .collection('DonorData')
                                              .where('userName',
                                                  isEqualTo:
                                                      widget.snap['userName'])
                                              .limit(1)
                                              .get();
                                      var UID;
                                      if (Qsnap.docs.isNotEmpty) {
                                        UID = Qsnap.docs.first.id;
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              profilePage(uid: UID),
                                        ),
                                      );
                                    },
                                  ),
                                ]),
                          ),
                        ),
                        FirebaseAuth.instance.currentUser?.uid ==
                                widget.snap['uid']
                            ? IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: ((context) => Dialog(
                                            child: ListView(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 16,
                                                ),
                                                shrinkWrap: true,
                                                children: [
                                                  'Delete',
                                                ]
                                                    .map(
                                                      (e) => InkWell(
                                                        onTap: () async {
                                                          String userType = widget
                                                                  .snap[
                                                              'usertype']; // Get the userType from userData
                                                          FirestoreMethods()
                                                              .deletePost(
                                                            widget
                                                                .snap['postId'],
                                                          ); // Pass both postId and userType
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 12,
                                                                  horizontal:
                                                                      16),
                                                          child: Text(e),
                                                        ),
                                                      ),
                                                    )
                                                    .toList()),
                                          )));
                                },
                                icon: const Icon(Icons.more_horiz),
                              )
                            : Text(''),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    child: Image.network(
                      widget.snap['postUrl'] ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => CommentScreen(
                                    snap: widget.snap,
                                  )),
                        ),
                        icon: const Icon(Icons.comment_outlined),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Builder(
                            builder: (context) {
                              if (widget.snap['userType'] == "Donor") {
                                if (widget.snap['Status'] == true) {
                                  return IconButton(
                                    icon: const Icon(Icons.messenger_outline),
                                    onPressed: () {
                                      ChatByButton(widget.snap['email'])
                                          .chatId(context);
                                    },
                                  );
                                } else {
                                  return Text('Project Complete');
                                }
                              } else {
                                return IconButton(
                                  icon: const Icon(Icons.messenger_outline),
                                  onPressed: () {
                                    ChatByButton(widget.snap['email'])
                                        .chatId(context);
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextStyle(
                          style:
                              Theme.of(context).textTheme.subtitle2!.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                          child: Text(
                            ' ',
                            style: const TextStyle(
                                fontSize: 16, color: secondaryColor),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: 8,
                          ),
                          child: RichText(
                            text: TextSpan(
                                style: const TextStyle(color: primaryColor),
                                children: [
                                  TextSpan(
                                    text: widget.snap['userName'] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text:
                                        ' ${widget.snap['description'] ?? ''}',
                                    style: const TextStyle(
                                        fontSize: 18, color: primaryColor),
                                  ),
                                ]),
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            child: Text(
                              DateFormat.yMMMd()
                                  .format(
                                    widget.snap['datePublished']?.toDate() ??
                                        DateTime.now(),
                                  )
                                  .toString(),
                              style: const TextStyle(
                                  fontSize: 16, color: secondaryColor),
                            ),
                          ),
                        ),
                        !isDonor
                            ? Text('')
                            : widget.snap['Status'] == true
                                ? Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _showDonateAmountField = true;
                                          });
                                        },
                                        child: Container(
                                          child: Text("Donate"),
                                        ),
                                      ),
                                      if (isDonor && _showDonateAmountField)
                                        Column(
                                          children: [
                                            TextField(
                                              controller: _amountController,
                                              decoration: InputDecoration(
                                                labelText: 'Enter Amount',
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                await makePayment(
                                                    _amountController.text);
                                              },
                                              child: Text("Confirm Donation"),
                                            ),
                                          ],
                                        ),
                                    ],
                                  )
                                : Text('Project Complete')
                      ],
                    ),
                  )
                ],
              ),
            );
          }

          return Container();
        });
  }

  Future<void> makePayment(String _amount) async {
    try {
      paymentIntentData = await createPaymentIntent(_amount, 'USD');

      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentData!['client_secret'],
            style: ThemeMode.dark,
            merchantDisplayName: 'Ikrma',
          ),
        );
        displayPaymentSheet();
      } else {
        print('Payment intent data is null. Unable to proceed with payment.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Payment intent creation failed. Try again later.')),
        );
      }
      setState(() {
        _showDonateAmountField = false;
      });
    } catch (e) {
      print("Error in makePayment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred while creating payment intent')),
      );
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      if (paymentIntentData != null) {
        await Stripe.instance.presentPaymentSheet();
        setState(() {
          paymentIntentData = null;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Donation Successful")));
      } else {
        print('Payment intent data is null. Unable to display payment sheet.');
      }
    } on StripeException catch (e) {
      print("Stripe Exception in displayPaymentSheet: $e");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text("Payment Canceled"),
        ),
      );
    } catch (e) {
      print("Error in displayPaymentSheet: $e");
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(
    String amount,
    String currency,
  ) async {
    var sc;
    var uuid = widget.snap['uid'];
    var snapshot2 = await FirebaseFirestore.instance
        .collection('DonorData')
        .where('uid', isEqualTo: uuid)
        .get();
    if (snapshot2.docs.isNotEmpty) {
      // Access the 'Account' field value
      sc = snapshot2.docs.first.get('Account');
      print('Account value: $sc');
    } else {
      print('No matching documents found.');
    }
    print('uid=$uuid');
    Map<String, dynamic> body = {
      'amount': calculateAmount(amount),
      'currency': currency,
      'payment_method_types[]': 'card',
    };

    try {
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer $sc', // Your Stripe secret key
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            'Failed to create payment intent. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print("Exception during payment intent creation: $e");
      return null;
    }
  }

  calculateAmount(amount) {
    final price = int.parse(amount) * 100;
    return price.toString();
  }
}
