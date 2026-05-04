import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/app_bar.dart';

// Importe tes nouvelles vues ici
import '../core/color.dart';
import '../core/provider/navigation_provider.dart';
import '../core/shared_widget/build_header.dart';
import '../core/shared_widget/side_bar.dart';
import 'alertsView/presentation/alertsView.dart';
import 'dashboard/presentation/dash_board_view.dart';

class MainDashboardScreen extends ConsumerWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. On surveille l'index sélectionné dans la Sidebar
    final currentIndex = ref.watch(navigationProvider);

    // 2. On choisit quelle vue afficher au centre
    Widget currentView;
    switch (currentIndex) {
      case 0:
        currentView = const DashboardView(); // La grille de KPIs
        break;
      case 1:
        currentView = const AlertsView(); // La liste des alertes
        break;
      default:
        currentView = const DashboardView();
    }

    return Scaffold(
      appBar: AppAppbar(),
      body: Row(
        children: [
          // La Sidebar reste fixe à gauche
          const SideBar(),

          // La partie droite change selon la sélection
          Expanded(
            child: Column(
              children: [

                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAFB),
                    // Fond gris très léger pour faire ressortir les cartes
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child:
                          currentView, // Le contenu change ici avec un effet de fondu
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
