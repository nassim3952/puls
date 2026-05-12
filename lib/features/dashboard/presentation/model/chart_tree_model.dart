class ChartTreeNode {
  final String name;
  final List<ChartTreeNode>? children;
  final double? value; // La taille de la part

  ChartTreeNode({required this.name, this.children, this.value});
}