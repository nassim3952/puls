import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardViewNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() {
    return {};
  }

  void toggleView(String title) {
    final currentView = state[title] ?? 0;
    state = {
      ...state,
      title: currentView == 0 ? 1 : 0,
    };
  }

  int getViewIndex(String title) => state[title] ?? 0;
}

final cardViewProvider = NotifierProvider<CardViewNotifier, Map<String, int>>(() {
  return CardViewNotifier();
});
