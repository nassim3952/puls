import 'package:flutter/material.dart';

/// Affiche un sheet adaptatif : bottom sheet sur mobile, dialog centré sur web/desktop
Future<T?> showAdaptiveSheet<T>(
    BuildContext context, {
      required Widget child,
      bool barrierDismissible = true,
    }) async {
  final isMobile = MediaQuery.of(context).size.width < 768;

  if (isMobile) {
    // Bottom sheet pour mobile
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => child,
    );
  } else {
    // Dialog centré pour web/desktop
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 800,
          ),
          child: child,
        ),
      ),
    );
  }
}