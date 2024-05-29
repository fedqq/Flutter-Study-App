import "package:flutter/material.dart";

void simpleSnackBar(BuildContext context, String s) async {
  ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Text(s)));
}
