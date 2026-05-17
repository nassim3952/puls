import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';


//TODO: a supprimé si le code n'est plus utilisé
// class FilterSelectButtons extends StatelessWidget {
//   final String label;
//   final String? value;
//   final List<String> options;
//   final Function(String) onSelected;
//
//   const FilterSelectButtons({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.options,
//     required this.onSelected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Si la valeur est null ou vide, on n'a pas de sélection active
//     final bool hasSelection = value != null && value!.isNotEmpty;
//
//     return PopupMenuButton<String>(
//       onSelected: onSelected,
//       offset: const Offset(0, 45),
//       itemBuilder: (context) => options
//           .map((opt) => PopupMenuItem(value: opt, child: Text(opt)))
//           .toList(),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           border: Border.all(
//               color: hasSelection
//                   ? AppColors.textPrimary.withValues(alpha: 0.6)
//                   : AppColors.primaryMentheNeutral.withValues(alpha: 0.3)
//           ),
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               // CRITIQUE : Si pas de sélection, on affiche le label (ex: "Service")
//               hasSelection ? value! : label,
//               style: TextStyle(
//                 color: AppColors.textPrimary,
//                 fontSize: 14,
//                 fontWeight: hasSelection ? FontWeight.w600 : FontWeight.w500,
//               ),
//             ),
//             const SizedBox(width: 4),
//             const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary, size: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }


class FilterSelectButton extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final void Function(String?) onSelected;

  const FilterSelectButton({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) =>
      SizedBox(
        height: 38,
        child: DropdownButtonHideUnderline(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: value != null ? MintTheme.mint400 : MintTheme.border,
                width: value != null ? 1.5 : 1,
              ),
            ),
            child: DropdownButton<String>(
              hint: Text(label, style: const TextStyle(
                  fontSize: 13, color: MintTheme.textSecondary)),
              value: value,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18,
                  color: MintTheme.mint600),
              style: const TextStyle(
                  fontSize: 13, color: MintTheme.textPrimary),
              onChanged: onSelected,
              items: [
                DropdownMenuItem<String>(
                    value: '', child: Text('Tous — $label')),
                ...options.map((s) =>
                    DropdownMenuItem<String>(value: s, child: Text(s))),
              ],
            ),
          ),
        ),
      );
}
