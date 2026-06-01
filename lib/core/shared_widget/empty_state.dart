import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

enum EmptyStateReason { noData, noResults }

class EmptyState extends StatelessWidget {
  final EmptyStateReason reason;

  const EmptyState({
    super.key,
    this.reason = EmptyStateReason.noResults,
  });

  @override
  Widget build(BuildContext context) {
    final isNoData = reason == EmptyStateReason.noData;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLighter,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNoData
                  ? Icons.inbox_outlined
                  : Icons.search_off_rounded,
              size: 40,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isNoData
                ? 'Aucune donnée disponible'
                : 'Aucun résultat',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isNoData
                ? 'Les données apparaîtront ici\ndès qu\'un patient complète un formulaire.'
                : 'Aucun patient ne correspond\naux filtres sélectionnés.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.kTextSub,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}