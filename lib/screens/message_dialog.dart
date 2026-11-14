import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows copyable plain text in a dialog, for fee receipts and
/// guardian messages. The app only prepares the text; it does not
/// send messages itself.
Future<void> showCopyableMessage(
  BuildContext context, {
  required String title,
  required String text,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: SelectableText(text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: text));
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            }
          },
          child: const Text('Copy text'),
        ),
      ],
    ),
  );
}
