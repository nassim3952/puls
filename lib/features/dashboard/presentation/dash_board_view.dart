import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/color.dart';
import '../../../core/shared_widget/default_view.dart';
import '../../../core/shared_widget/state_card.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Plus tard, tu récupéreras tes données ici :
    // final stats = ref.watch(statsProvider);

    return DefaultView(customWidget: StaggeredGrid.count(
      crossAxisCount: 6, // 6 colonnes pour le format Web/Desktop
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      children: [
        // Q1 - ISGPP / KPS
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 3,
          child: StatCard(
            title: "ISGPP",
            icon: Icons.speed,
            onMorePressed: () {},
            child: const Center(child: Text("Graphique Jauge")),
          ),
        ),

        // Q2 - NPS
        StaggeredGridTile.count(
          crossAxisCellCount: 4,
          mainAxisCellCount: 3,
          child: StatCard(
            title: "Alertes",
            icon: Icons.warning_amber_outlined,
            onMorePressed: () {},
            child: const Center(child: Text("Alerts")),
          ),
        ),

        // Q3-Q5 - Verbatims
        StaggeredGridTile.count(
          crossAxisCellCount: 3,
          mainAxisCellCount: 2,
          child: StatCard(
            title: "EMP",
            icon: Icons.graphic_eq,
            onMorePressed: () {},
            child: const Center(child: Text("Graphique en camembert")),
          ),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 3,
          mainAxisCellCount: 2,
          child: StatCard(
            title: "VQPS",
            icon: Icons.graphic_eq,
            onMorePressed: () {},
            child: const Center(child: Text("horizontal Bar Chart")),
          ),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 6,
          mainAxisCellCount: 2,
          child: StatCard(
            title: "IAR",
            icon: Icons.graphic_eq,
            onMorePressed: () {},
            child: const Center(child: Text("Diverging Bar Chart")),
          ),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 3,
          mainAxisCellCount: 2,
          child: StatCard(
            title: "MCR",
            icon: Icons.graphic_eq,
            onMorePressed: () {},
            child: const Center(child: Text("Diverging Bar Chart")),
          ),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 3,
          mainAxisCellCount: 2,
          child: StatCard(
            title: "MCR",
            icon: Icons.graphic_eq,
            onMorePressed: () {},
            child: const Center(child: Text("Diverging Bar Chart")),
          ),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 6,
          mainAxisCellCount: 2,
          child: StatCard(
            title: "Verbatimes récent",
            icon: Icons.chat_bubble_outline,
            onMorePressed: () {},
            child: const Center(child: Text("Diverging Bar Chart")),
          ),
        )


      ],
    ),);
  }
}
