import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:otp/otp.dart';
import 'package:password_hash_plus/password_hash_plus.dart';
import 'package:shopp_app/pages/utils.dart';
import 'package:shopp_app/pages/widgets.dart';
import 'package:shopp_app/resources/auth_method.dart';

import 'logIn.dart';

class ngoSignUP extends StatefulWidget {
  ngoSignUP({Key? key}) : super(key: key);

  @override
  State<ngoSignUP> createState() => _ngoSignUPState();
}

class _ngoSignUPState extends State<ngoSignUP> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _NgoName = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _BankAccountNumber = TextEditingController();
  Uint8List? _image;
  Uint8List? pdf;
  late String filepath;
  bool _isLoading = false;
  late String _generatedOTP;
  late UserType _userType = UserType.ngo; // Default user type is NGO

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _NgoName.dispose();
    _city.dispose();
    _BankAccountNumber.dispose();
    _otpController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void selectpdf() async {
    FilePickerResult? pf = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
  }

  Future<Uint8List?> pickPDFFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.single;
      filepath = file.path!;
      Uint8List? fileData = await File(filepath).readAsBytes();
      return fileData;
    } else {
      // User canceled the file picking
      return null;
    }
  }

  void signUpNgo() async {
    String email = _emailController.text;
    String name = _NgoName.text;
    String rpas;
    var r = Random();
    rpas =
        String.fromCharCodes(List.generate(8, (index) => r.nextInt(33) + 89));
    var generator = new PBKDF2();
    const salt = "ThisIsMyFixedSaltValue";
    var nPassword = generator.generateKey(rpas, salt, 1000, 32).toString();

    String password = nPassword;
    String city = _city.text;
    String account = _BankAccountNumber.text;

    if (email.isEmpty || name.isEmpty || city.isEmpty || account.isEmpty) {
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

    String res = await AuthMethods().signUpNgo(
      email: email,
      userName: name,
      password: password,
      account: account,
      city: city,
      file1: _image!,
      userType: _userType == UserType.ngo ? 'ngo' : 'donor',
      rPas: rpas,
      document: pdf,
    );
    setState(() {
      _isLoading = false;
    });

    if (res != 'Success') {
      showSnackBar(res, context);
    } else {
      showSnackBar(res, context);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => logIn(),
        ),
      );
    }
  }

  void _generateOTP() {
    setState(() {
      _generatedOTP = OTP.generateTOTPCodeString(
        'YourSecretKey',
        DateTime.now().millisecondsSinceEpoch,
        length: 6,
      );
    });

    _sendOTPEmail();
  }

  Future<void> _sendOTPEmail() async {
    String email = _emailController.text.trim();
    String senderEmail = 'f190231@nu.edu.pk';
    String senderName = 'Saviour';

    final smtpServer = gmail('f190231@nu.edu.pk', 'hnztaqhxluldmepp');

    final message = Message()
      ..from = Address(senderEmail, senderName)
      ..recipients.add(email)
      ..subject = 'OTP Verification'
      ..text = 'Your OTP is: $_generatedOTP';

    try {
      final sendReport = await send(message, smtpServer);
    } catch (e) {
      print('Error occurred while sending email: $e');
    }
  }

  void _verifyOTP() {
    String enteredOTP = _otpController.text.trim();

    if (enteredOTP == _generatedOTP) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Email Verification'),
              content: Text('Email verified successfully.'),
              actions: [
                InkWell(
                  onTap: signUpNgo,
                  child: Container(
                    child: const Text("Sign Up"),
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
              ]);
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Email Verification'),
            content: Text('Invalid OTP. Please try again.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
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
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //  Flexible(child: Container(), flex: 2),
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
                              icon: const Icon(Icons.add_a_photo)))
                    ],
                  ),
                  const SizedBox(height: 54),
                  TextFieldWidget(
                    hintText: "Enter Your Email",
                    textInputType: TextInputType.emailAddress,
                    textEditingController: _emailController,
                  ),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    hintText: "Enter Your Ngo Name",
                    textInputType: TextInputType.text,
                    textEditingController: _NgoName,
                  ),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    hintText: "Enter City",
                    textInputType: TextInputType.text,
                    textEditingController: _city,
                  ),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    hintText: "NGO Bank ACCOUNT Number",
                    textInputType: TextInputType.text,
                    textEditingController: _BankAccountNumber,
                  ),
                  TextButton(
                    onPressed: () async {
                      pdf = (await pickPDFFile());
                      if (filepath.isNotEmpty) {
                        // Do something with the picked PDF file
                        print('Picked file path: $filepath');
                      } else {
                        print('File picking canceled');
                      }
                    },
                    child: Text('Pick PDF REgistrationn File'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Add Radio buttons to select user type
                      Row(
                        children: [
                          Radio(
                            value: UserType.ngo,
                            groupValue: _userType,
                            onChanged: (UserType? value) {
                              setState(() {
                                _userType = UserType.ngo;
                              });
                            },
                          ),
                          Text('NGO'),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: UserType.donor,
                            groupValue: _userType,
                            onChanged: (UserType? value) {
                              setState(() {
                                _userType = UserType.donor;
                              });
                            },
                          ),
                          Text('Donor'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    child: Text('Send OTP'),
                    onPressed: () {
                      String email = _emailController.text.trim();
                      if (EmailValidator.validate(email)) {
                        _generateOTP();
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Invalid Email'),
                              content:
                                  Text('Please enter a valid email address.'),
                              actions: [
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: 'OTP',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    child: Text('Verify OTP'),
                    onPressed: _verifyOTP,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: const Text("Already have an account?"),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      GestureDetector(
                        child: Container(
                          child: const Text(
                            "Sign In.",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum UserType {
  ngo,
  donor,
}
