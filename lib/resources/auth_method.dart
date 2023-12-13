import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:shopp_app/models/user.dart' as model;
import 'package:shopp_app/resources/storage_method.dart';

import '../pages/logIn.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance; //for authentication
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; //for storing in database
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection("DonorData").doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  Future<String> signUpNgo({
    required String email,
    required String userName,
    required String password,
    required String account,
    required String city,
    required Uint8List? file1,
    required String userType,
    required String rPas,
    required Uint8List? document,
  }) async {
    String res = "Some Error Occurred";
    try {
      if (email.isNotEmpty || userName.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String photoUrl = await StorageMethods().uploadImageToStorage(
          'profilePics',
          file1!,
          false,
        );

        // Store PDF file in Firebase Storage
        String name = 'Registration';
        String pdfDownloadUrl = await uploadFileToStorage(name, document!);

        // Add user and document data to Firestore
        String collectionName =
            userType == 'UserType.ngo' ? 'DonorData' : 'DonorData';
        await _firestore.collection(collectionName).doc(cred.user!.uid).set({
          'email': email,
          'userName': userName,
          'uid': cred.user!.uid,
          'password': password,
          'city': city,
          'Account': account,
          'userType': userType,
          'photoUrl': photoUrl,
          'rPasword': rPas,
          'documentUrl': pdfDownloadUrl, // Store the download URL of the PDF
        });

        res = "Success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadFileToStorage(
      String fileName, Uint8List fileData) async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('registration')
        .child(fileName);

    try {
      await ref.putData(fileData);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return '';
    }
  }

  Future<String> login(
      {required String email, required String password}) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        UserCredential credential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        User? user = credential.user;

        if (user != null) {
          String userType = await getUserType(user.uid);

          if (userType == 'ngo') {
            res = "Success";
          } else if (userType == 'Donor') {
            res = "Success";
          } else {
            res = "User type not found";
          }
        } else {
          res = "User not found";
        }
      } else {
        res = "Please fill all fields";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = "User not found";
      } else if (e.code == 'wrong-password') {
        res = "Wrong password";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> getUserType(String uid) async {
    String userType = '';

    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('DonorData').doc(uid).get();
      if (snapshot.exists) {
        userType = snapshot.get('userType');
      }
    } catch (err) {
      print(err.toString());
    }

    return userType;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
// Donor AUTHENTICATION

class donor_auth_methhod {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUpUser({
    required String email,
    required String name,
    required String password,
    required Uint8List? file,
    required String userType,
  }) async {
    String res = "Some Error Occur";
    try {
      if (email.isNotEmpty && name.isNotEmpty && password.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file!, false);

        model.User user = model.User(
          email: email,
          userName: name,
          uid: cred.user!.uid,
          password: password,
          following: [],
          photoUrl: photoUrl,
          userType: userType,
        );

        // Update based on user type
        String collectionName = '';
        if (userType == 'Donor') {
          collectionName = 'DonorData';
        } else if (userType == 'ngo') {
          collectionName = 'DonorData';
        }

        await _firestore.collection(collectionName).doc(cred.user!.uid).set(
              user.toJson(),
            );

        res = "Success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Perform any additional clean-up or reset operations here

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => logIn()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
