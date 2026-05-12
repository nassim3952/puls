import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/app_bar.dart';
import 'package:puls/features/patienListScreen.dart';

// Importe tes nouvelles vues ici
import '../core/provider/navigation_provider.dart';
import '../core/provider/side_bar_provider.dart';
import '../core/shared_widget/side_bar.dart';
import 'alertsView/presentation/alerts_view.dart';
import 'dashboard/presentation/dash_board_view.dart';

class MainDashboardScreen extends ConsumerWidget {
  const MainDashboardScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. On surveille l'index sélectionné dans la Sidebar
    final currentIndex = ref.watch(navigationProvider);
    final isSidebarOpen = ref.watch(sidebarProvider);

    // 2. On choisit quelle vue afficher au centre
    Widget currentView;
    switch (currentIndex) {
      case 0:
        currentView = const DashboardView(); // La grille de KPIs
        break;
      case 1:
        currentView = const AlertsView(); // La liste des alertes
        break;
      case 2:
        currentView = const PatientListScreen(); // La liste des patients
        break;
      default:
        currentView = const DashboardView();
    }

    return Scaffold(

      appBar: appAppBar(context),
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
                        // AJOUTE CECI :
                        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                          return Stack(
                            alignment: Alignment.topLeft, // Force l'alignement en haut à gauche
                            children: [
                              ...previousChildren,
                              ?currentChild,
                            ],
                          );
                        },
                        child: currentView,
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
