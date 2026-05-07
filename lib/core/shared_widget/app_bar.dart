import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

Widget _buildUserSection({bool showName = true}) {
  return Row(
    children: [
      if (showName) ...[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Dr. Marie Dubois",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Responsable qualité",
              style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(width: 10),
      ],
      CircleAvatar(radius: 18, child: const Icon(Icons.person)),
    ],
  );
}

AppBar appAppBar(BuildContext context) {
  // On utilise MediaQuery pour avoir la largeur totale de l'écran
  final double width = MediaQuery.of(context).size.width;
  final bool isMobile = width < 600;
  final bool isTablet = width >= 600 && width < 1024;

  return AppBar(
    elevation: 0,
    scrolledUnderElevation: 2,
    backgroundColor: AppColors.surface,
    foregroundColor: Colors.white,
    titleSpacing: 0,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    ),
    title: Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
      child: Row(
        children: [
          // LOGO : Large sur Desktop, icône sur Tablette, rien sur Mobile
          if (!isMobile)
            isTablet
                ? const Icon(
                    Icons.flash_on,
                    color: AppColors.primaryMenthe,
                    size: 32,
                  )
                : Image.asset('assets/logo.png', width: 200, height: 32),

          if (!isMobile) SizedBox(width: isTablet ? 20 : 40),

          // BARRE DE RECHERCHE : Elle prend tout l'espace restant
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[100], // Un fond léger pour la visibilité
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Recherche...',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.primaryMenthe,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),

          SizedBox(width: isMobile ? 10 : 20),

          // SECTION UTILISATEUR : On cache le nom sur mobile pour ne garder que l'avatar
          _buildUserSection(showName: !isMobile),

          if (!isMobile) ...[
            const SizedBox(width: 15),
            const Icon(Icons.settings_sharp, color: AppColors.textPrimary),
          ],

          const SizedBox(width: 15),

          // NOTIFICATIONS : Toujours présentes
          Badge(
            label: const Text('3', style: TextStyle(fontSize: 10)),
            child: const Icon(
              Icons.notifications_sharp,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),
    ),
  );
}
