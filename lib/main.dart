import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertest23/Views/login_view.dart';
import 'package:fluttertest23/Views/notes/notes_view.dart';
import 'package:fluttertest23/Views/register_view.dart';
import 'package:fluttertest23/Views/verify_email_view.dart';
import 'package:fluttertest23/constants/routes.dart';
import 'package:fluttertest23/Views/notes/create_update_notes_view.dart';
import 'package:fluttertest23/services/auth/bloc/auth_block.dart';
import 'package:fluttertest23/services/auth/bloc/auth_event.dart';
import 'package:fluttertest23/services/auth/bloc/auth_state.dart';
import 'package:fluttertest23/services/auth/firebase_auth_provider.dart';
//import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),

      //BlocProvider
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          print('logged in');
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
