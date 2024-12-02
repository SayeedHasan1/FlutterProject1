import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertest23/constants/routes.dart';
import 'package:fluttertest23/main.dart';
import 'package:fluttertest23/services/auth/auth_service.dart';
import 'package:fluttertest23/services/auth/bloc/auth_block.dart';
import 'package:fluttertest23/services/auth/bloc/auth_event.dart';

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
          const Text(
              "We've sent an email verification message.Please open it to veruify your account"),
          const Text(
              "If you havn't recieved the email yet, press the button below."),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthEventSendEmailVerification(),
                  );
            },
            child: const Text("Send Verification Email."),
          ),
          TextButton(
            onPressed: () async {
              context.read<AuthBloc>().add(
                    const AuthEventShouldRegister(),
                  );
            },
            child: const Text("Restart Registration"),
          ),
          TextButton(
            onPressed: () async {
              context.read<AuthBloc>().add(
                    const AuthEventLogOut(),
                  );
            },
            child: const Text("Authenticated Email? Click here to Log in"),
          )
        ],
      ),
    );
  }
}
