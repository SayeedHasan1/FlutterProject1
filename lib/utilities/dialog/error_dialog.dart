import 'package:flutter/material.dart';
import 'package:fluttertest23/utilities/dialog/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context,
    title: 'An error ocurred',
    content: text,
    optionBuilder: () => {
      'OK': null,
    },
  );
}
