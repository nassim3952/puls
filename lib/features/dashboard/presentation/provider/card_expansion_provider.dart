import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardExpansionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {};
  }

  void toggleExpansion(String title) {
    if (state.contains(title)) {
      state = {...state}..remove(title);
    } else {
      state = {...state, title};
    }
  }

  bool isExpanded(String title) => state.contains(title);
}

final cardExpansionProvider = NotifierProvider<CardExpansionNotifier, Set<String>>(() {
  return CardExpansionNotifier();
});
