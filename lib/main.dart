import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertest23/Views/login_view.dart';
import 'package:fluttertest23/Views/register_view.dart';
import 'package:fluttertest23/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePgage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      },
    ),
  );
}

class HomePgage extends StatelessWidget {
  const HomePgage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            // final user = FirebaseAuth.instance.currentUser;
            // print(user);
            // if (user?.emailVerified ?? false) {
            //   print("Verified.");
            //   return const Text("Done .Logged in with verified account.");
            // } else {
            //   return const VerifyEmailView();
            // }
            return LoginView();

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your Email'),
      ),
      body: Column(
        children: [
          Text('Please verify your email address:'),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            },
            child: const Text("Send Verification Email."),
          )
        ],
      ),
    );
  }
}
