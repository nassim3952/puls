import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import '../../features/historique/historique_screen.dart';

// On utilise ConsumerWidget pour avoir accès à "ref"
class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1024;

    // Récupération des données du provider
    final filters = ref.watch(historiqueFilterProvider);

    // Pour le contrôleur, dans un ConsumerWidget, on préfère souvent
    // ne pas le recréer ici. Une solution simple est d'utiliser un HookWidget
    // ou de le gérer via le provider directement.
    // Ici, on l'initialise avec la valeur actuelle du store.
    final TextEditingController searchCtrl = TextEditingController(
      text: filters.searchQuery,
    );
    searchCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: searchCtrl.text.length),
    );

    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4), // Ombre portée vers le bas
            ),
          ],
        ),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
        child: Row(
          children: [
            if (!isMobile)
              isTablet
                  ? const Icon(
                      Icons.flash_on,
                      color: AppColors.primaryMenthe,
                      size: 32,
                    )
                  : Image.asset('assets/logo.png', width: 200, height: 32),

            if (!isMobile) SizedBox(width: isTablet ? 20 : 40),

            // BARRE DE RECHERCHE
            SizedBox(
              width: 380,
              height: 38,
              child: TextField(
                controller: searchCtrl,
                onChanged: (v) =>

                    ref.read(historiqueFilterProvider.notifier).setSearch(v),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Rechercher nom, IPP…',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppColors.primaryMenthe,
                  ),
                  suffixIcon: filters.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          onPressed: () {
                            searchCtrl.clear();
                            ref
                                .read(historiqueFilterProvider.notifier)
                                .setSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: searchCtrl.text.isNotEmpty // ✅ ICI : utilise le controller
                          ? AppColors.primaryMenthe
                          : MintTheme.border,
                        width: searchCtrl.text.isNotEmpty ? 1.5 : 1
                    ), // Vérifie si AppColors.border existe
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primaryMenthe,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            _buildUserSection(showName: !isMobile),

            if (!isMobile) ...[
              const SizedBox(width: 15),
              const Icon(Icons.settings_sharp, color: AppColors.textPrimary),
            ],

            const SizedBox(width: 15),

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
        const CircleAvatar(radius: 18, child: Icon(Icons.person)),
      ],
    );
  }
}
