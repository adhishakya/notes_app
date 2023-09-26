import 'package:flutter/material.dart';
import 'package:notes_app/utilities/dialogs/generic_dialog.dart';

Future<void> showSuccessDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: "Done",
    content: text,
    optionsBuilder: () => {
      "Ok": null,
    },
  );
}
