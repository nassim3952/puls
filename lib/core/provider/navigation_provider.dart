import 'package:riverpod/riverpod.dart';

final navigationProvider = NotifierProvider<NavigationIndexNotifier, int>(() {
  return NavigationIndexNotifier();
});

class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}