import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/shared_widget/state_card.dart';
import '../../model/dashboard_item.dart';
import '../provider/card_expansion_provider.dart';

class DashboardTile extends ConsumerWidget {
  final DashboardItem item;
  final int crossAxisCount;
  final Widget? headerWidget;

  const DashboardTile({
    super.key,
    required this.item,
    required this.crossAxisCount,
    this.headerWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OPTIMISATION : On utilise .select pour ne reconstruire que SI l'état de CETTE carte change
    final isExpanded = ref.watch(cardExpansionProvider.select((s) => s.contains(item.title)));

    int responsiveCrossAxis = crossAxisCount <= 4 ? crossAxisCount : item.crossAxis;
    int responsiveMainAxis = item.mainAxis;

    if (isExpanded) {
      responsiveCrossAxis = (responsiveCrossAxis * 2).clamp(1, crossAxisCount);
      responsiveMainAxis = responsiveMainAxis * 2;
    }

    return StaggeredGridTile.count(
      crossAxisCellCount: responsiveCrossAxis,
      mainAxisCellCount: responsiveMainAxis,
      child: StatCard(
        title: item.title,
        headerWidget: headerWidget,
        fullName: item.fullName,
        icon: item.icon,
        isExpandable: item.isExpandable,
        secondaryChild: item.secondaryChild, // Transmission de la vue alternative
        onMorePressed: () {},
        child: item.builder != null
            ? item.builder!()
            : (item.child ?? const SizedBox()),
      ),
    );
  }
}

Widget buildTile(DashboardItem item, int crossAxisCount, Widget? headerWidget) {
  return DashboardTile(
    item: item,
    crossAxisCount: crossAxisCount,
    headerWidget: headerWidget,
  );
}
