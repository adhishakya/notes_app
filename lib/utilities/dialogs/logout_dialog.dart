import 'package:flutter/widgets.dart';
import 'package:notes_app/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Logout?",
    content: "Are you sure you want to logout?",
    optionsBuilder: () => {
      "Confirm": true,
      "Cancel": false,
    },
  ).then((value) => value ?? false);
}
