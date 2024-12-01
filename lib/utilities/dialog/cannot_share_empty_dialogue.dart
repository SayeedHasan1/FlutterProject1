import 'package:flutter/material.dart';
import 'package:fluttertest23/utilities/dialog/generic_dialog.dart';

Future<void> showCannotShareEmptyDialogue(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Sharing',
      content: 'Cannot share empty note',
      optionBuilder: () => {
            'OK': null,
          });
}
