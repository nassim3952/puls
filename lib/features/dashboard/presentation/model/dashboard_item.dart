import 'package:flutter/cupertino.dart';

class DashboardItem {
  final String title;
  final String fullName;
  final IconData icon;
  final int crossAxis;
  final int mainAxis;

  final Widget? child;
  final Widget Function()? builder;

  DashboardItem({
    required this.title,
    required this.fullName,
    required this.icon,
    required this.crossAxis,
    required this.mainAxis,
    this.child,
    this.builder,
  });
}