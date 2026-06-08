import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<T?> showAdaptiveSheet<T>(
    BuildContext context, {
      required Widget child,
      required double mobileHeight, // ex: 0.85
    }) async {
  final isMobile = MediaQuery.of(context).size.width < 768; // Breakpoint

  if (isMobile) {
    // Bottom sheet classique pour mobile
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  } else {
    // Dialog centré pour web/desktop
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: child,
        ),
      ),
    );
  }
}