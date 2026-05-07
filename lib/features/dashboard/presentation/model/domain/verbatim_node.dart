class VerbatimNode {
  final String label;
  final double? value; // La fréquence du verbatim
  final List<VerbatimNode>? children;

  VerbatimNode({required this.label, this.value, this.children});
}