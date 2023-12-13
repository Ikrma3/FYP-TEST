import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:shopp_app/pages/logIn.dart';
import 'package:shopp_app/pages/mobScreenLayout.dart';
import 'package:shopp_app/pages/responcive_layout.dart';
import 'package:shopp_app/pages/webScreenLayout.dart';
import 'package:shopp_app/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51NfJIeC8mN71SxJLcYPIKb5HVTRscUK3Rr4tO9BxWnVs3D7WDHkq3FrZNKP9GZCHwS9UiWnxZkbK7ZIdjDeWSBel00bQZSPvJv';
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAWxQIJUzEUX4aweshfcoVy6gYCXyHEL_0",
        appId: "1:58267036586:web:80520a9b172cbfa61699d3",
        messagingSenderId: "58267036586",
        projectId: "saviour-647da",
        storageBucket: "saviour-647da.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => UserProvider(),
          ),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Saviour",
            theme: ThemeData.dark(),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    return const responsiveLayout(
                        webScreenLayout: webScreenLayout(),
                        mobScreenLayout: mobScreenLayout());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('${snapshot.error}'),
                    );
                  }
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.amberAccent,
                    ),
                  );
                }

                return logIn();
              },
            )));
  }
}
