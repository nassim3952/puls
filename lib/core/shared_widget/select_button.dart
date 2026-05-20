import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

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
