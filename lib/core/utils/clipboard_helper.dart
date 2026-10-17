import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Copies [text] and reports the outcome with a snackbar.
///
/// Browsers only expose the clipboard in secure contexts (HTTPS/localhost)
/// and after a user gesture, so failures are reported instead of thrown.
Future<bool> copyWithFeedback(
  BuildContext context,
  String text, {
  required String successMessage,
}) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  try {
    await Clipboard.setData(ClipboardData(text: text));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(successMessage)));
    return true;
  } on Exception {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Panoya kopyalamaq mümkün olmadı. Mətni əl ilə seçin.'),
        ),
      );
    return false;
  }
}
