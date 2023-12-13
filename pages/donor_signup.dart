import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:password_hash_plus/password_hash_plus.dart';
import 'package:shopp_app/pages/responcive_layout.dart';
import 'package:shopp_app/pages/utils.dart';
import 'package:shopp_app/pages/webScreenLayout.dart';

import '../resources/auth_method.dart';
import 'logIn.dart';
import 'mobScreenLayout.dart';
import 'ngoSignup.dart';

enum UserType { Donor, NGO }

class donor_signup extends StatefulWidget {
  const donor_signup({Key? key}) : super(key: key);

  @override
  State<donor_signup> createState() => _donor_signupState();
}

class _donor_signupState extends State<donor_signup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  UserType _userType = UserType.Donor;
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
  }

  void selectImage() async {
    final Uint8List? image = await pickImage(ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void signUpUser() async {
    final String email = _emailController.text;
    final String name = _nameController.text;
    final String password = _passwordController.text;

    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Please fill in all fields."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String userType = '';
    switch (_userType) {
      case UserType.Donor:
        userType = 'Donor';
        break;
      case UserType.NGO:
        userType = 'ngo';
        break;
    }
    var generator = new PBKDF2();
    const salt = "ThisIsMyFixedSaltValue";
    var nPassword = generator.generateKey(password, salt, 1000, 32).toString();

    String res = await donor_auth_methhod().signUpUser(
      email: email,
      name: name,
      password: nPassword,
      file: _image!,
      userType: userType,
    );
    setState(() {
      _isLoading = false;
    });

    if (res != 'Success') {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const responsiveLayout(
              webScreenLayout: webScreenLayout(),
              mobScreenLayout: mobScreenLayout()),
        ),
      );
    }
  }

  void navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => logIn(),
      ),
    );
  }

  void navigateToSignupNGO() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ngoSignUP(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/login.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 64),
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                            )
                          : const CircleAvatar(
                              radius: 64,
                              backgroundImage: NetworkImage(
                                'https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg',
                              ),
                            ),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Enter Your Email",
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Enter Your Name",
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 34),
                  ElevatedButton(
                    onPressed: signUpUser,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.green)
                        : const Text("Sign Up"),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: navigateToLogin,
                        child: const Text(
                          "Sign In.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        " or ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: navigateToSignupNGO,
                        child: const Text(
                          "Sign Up as NGO.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 4, 250, 12),
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
