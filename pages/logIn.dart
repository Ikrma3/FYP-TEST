import 'package:flutter/material.dart';
import 'package:password_hash_plus/password_hash_plus.dart';
import 'package:shopp_app/pages/admin_scree.dart';
import 'package:shopp_app/pages/donor_signup.dart';
import 'package:shopp_app/pages/responcive_layout.dart';
import 'package:shopp_app/pages/utils.dart';
import 'package:shopp_app/pages/webScreenLayout.dart';
import 'package:shopp_app/pages/widgets.dart';
import 'package:shopp_app/resources/auth_method.dart';

import 'mobScreenLayout.dart';

class logIn extends StatefulWidget {
  logIn({Key? key}) : super(key: key);

  @override
  State<logIn> createState() => _logInState();
}

class _logInState extends State<logIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void logInUser() async {
    setState(() {
      _isLoading = true;
    });

    if (_emailController.text == 'admin' &&
        _passwordController.text == 'adminisgood') {
      // Navigate to the admin screen directly
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => adminScreen(),
        ),
      );
    } else {
      const salt = "ThisIsMyFixedSaltValue";
      var generator = new PBKDF2();
      var nPassword = generator
          .generateKey(_passwordController.text, salt, 1000, 32)
          .toString();
      String res = await AuthMethods()
          .login(email: _emailController.text, password: nPassword);

      if (mounted) {
        if (res == "Success") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const responsiveLayout(
                webScreenLayout: webScreenLayout(),
                mobScreenLayout: mobScreenLayout(),
              ),
            ),
          );
        } else {
          showSnackBar(res, context);
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void navigateSignupDonor() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const donor_signup(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/login.png'), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
            child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(
              'Saviour',
              style: TextStyle(
                color: Color(0xFFEAECEA),
                fontSize: 33,
                fontWeight: FontWeight.bold,
              ),
            ),
            Flexible(child: Container(), flex: 2),
            const SizedBox(height: 64),
            TextFieldWidget(
              hintText: "Enter Your Email",
              textInputType: TextInputType.emailAddress,
              textEditingController: _emailController,
            ),
            const SizedBox(height: 20),
            TextFieldWidget(
              hintText: "Enter Your Password",
              textInputType: TextInputType.text,
              textEditingController: _passwordController,
              isPass: true,
            ),
            const SizedBox(height: 34),
            InkWell(
              onTap: logInUser,
              child: Container(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.green,
                        ),
                      )
                    : const Text("Log In"),
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  color: Colors.blue,
                ),
              ),
            ),
            Flexible(child: Container(), flex: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: navigateSignupDonor,
                  child: Container(
                    child: const Text(
                      "Sign Up.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ],
            )
          ]),
        )),
      ),
    );
  }
}
