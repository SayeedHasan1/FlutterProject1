import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;
import 'package:fluttertest23/constants/routes.dart';
import 'package:fluttertest23/services/auth/auth_exceptions.dart';
import 'package:fluttertest23/services/auth/auth_service.dart';
import 'package:fluttertest23/utilities/showerrordialogue.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Enter your E-mail'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Enter your Password'),
          ),
          TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  await AuthService.firebase()
                      .logIn(email: email, password: password);
                  final user = AuthService.firebase().currentUser;
                  if (user?.isEmailVerified ?? false) {
                    //Email Verified
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesroute,
                      (route) => false,
                    );
                  } else {
                    //Email not verified
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyemailroute,
                      (route) => false,
                    );
                  }
                } on UserNotFoundAuthException {
                  await showErrorDialogue(
                    context,
                    'User not found',
                  );
                } on WrongPasswordAuthException {
                  await showErrorDialogue(
                    context,
                    'Wrong Password',
                  );
                } on GenericAuthException {
                  await showErrorDialogue(
                    context,
                    "Authentication Error",
                  );
                }
              },
              child: Text('Log In')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerroute,
                  (route) => false,
                );
              },
              child: const Text('Not Registered?   Click on this to register'))
        ],
      ),
    );
  }
}
