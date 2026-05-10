import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../color.dart';
import '../text.dart';
import '../provider/card_expansion_provider.dart';

class StatCard extends ConsumerWidget {
  final String title;
  final Widget child;
  final Widget? headerWidget;
  final VoidCallback? onMorePressed;
  final IconData? icon;
  final String fullName;
  final bool isTitleCentred;
  final bool isExpandable;

  const StatCard({
    super.key,
    required this.fullName,
    required this.title,
    required this.child,
    this.onMorePressed,
    this.icon,
    this.isTitleCentred = false,
    this.headerWidget,
    this.isExpandable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OPTIMISATION CRITIQUE : Ne rebuild que si CETTE carte change d'état
    final isExpanded = ref.watch(cardExpansionProvider.select((s) => s.contains(title)));

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Tooltip(
                          message: fullName,
                          child: Text(
                            title,
                            style: AppTextStyles.cardTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (headerWidget != null) ...[
                      headerWidget!,
                      const SizedBox(width: 8),
                    ],
                    if (isExpandable)
                      IconButton(
                        icon: Icon(
                          isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          ref.read(cardExpansionProvider.notifier).toggleExpansion(title);
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
