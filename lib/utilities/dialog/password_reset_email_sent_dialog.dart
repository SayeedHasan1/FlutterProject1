import 'package:flutter/material.dart';
import 'package:fluttertest23/utilities/dialog/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content:
        'We have now sent you a password reset email.Please check your email',
    optionBuilder: () => {
      'OK': null,
    },
  );
}
