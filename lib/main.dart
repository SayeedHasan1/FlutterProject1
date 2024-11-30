import 'package:flutter/material.dart';
import 'package:fluttertest23/Views/login_view.dart';
import 'package:fluttertest23/Views/notes/notes_view.dart';
import 'package:fluttertest23/Views/register_view.dart';
import 'package:fluttertest23/Views/verify_email_view.dart';
import 'package:fluttertest23/constants/routes.dart';
import 'package:fluttertest23/Views/notes/create_update_notes_view.dart';
import 'package:fluttertest23/services/auth/auth_service.dart';

//import 'dart:developer' as devtools show log;

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
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute: (context) => const CreateupdateNotesView()
      },
    ),
  );
}

class HomePgage extends StatelessWidget {
  const HomePgage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return LoginView();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
