import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/build_header.dart';

class DefaultView extends ConsumerWidget {
  final Widget? customWidget;

  const DefaultView({super.key, this.customWidget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          DashboardHeader(showResultChip: false,),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
            child: customWidget ?? const SizedBox(),
          ),
        ],
      ),
    );
  }
}
