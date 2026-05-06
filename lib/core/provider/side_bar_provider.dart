


import 'package:flutter_riverpod/flutter_riverpod.dart';

class SidebarNotifier extends Notifier<bool> {
  @override
  bool build() => true; // État initial

  void toggle() {
    state = !state;
  }
}

final sidebarProvider = NotifierProvider<SidebarNotifier, bool>(() {
  return SidebarNotifier();
});