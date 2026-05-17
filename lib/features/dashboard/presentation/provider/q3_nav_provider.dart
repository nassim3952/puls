import 'package:flutter_riverpod/legacy.dart';

// 1. On définit ce qu'on stocke : la classe choisie et la sous-classe choisie
class TreemapNavigation {
  final String? selectedClasse;
  final String? selectedSousClasse;

  TreemapNavigation({this.selectedClasse, this.selectedSousClasse});
}

// 2. Le StateProvider qui garde en mémoire où on est dans l'arborescence
// Par défaut, tout est à "null" (on est à la racine)
final treemapNavProvider = StateProvider<TreemapNavigation>((ref) => TreemapNavigation());