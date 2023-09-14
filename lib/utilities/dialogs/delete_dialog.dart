import 'package:flutter/material.dart';
import 'package:notes_app/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Delete Note?",
    content: "Are you sure you want to delete this note?",
    optionsBuilder: () => {
      "Yes": true,
      "No": false,
    },
  ).then((value) => value ?? false);
}
