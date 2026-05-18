import 'package:flutter/cupertino.dart';

class DashboardItem {
  final String title;
  final String fullName;
  final IconData? icon;
  final int crossAxis;
  final int mainAxis;
  final Widget? headerWidget;
  final bool isExpandable;
  final Widget? child;
  final Widget? secondaryChild; // Ajout d'une vue alternative
  final Widget Function()? builder;

  DashboardItem({
    required this.title,
    required this.fullName,
    this.icon,
    required this.crossAxis,
    required this.mainAxis,
    this.headerWidget,
    this.isExpandable = false,
    this.child,
    this.secondaryChild,
    this.builder,
  });
}