import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/build_header.dart';
import 'package:puls/core/shared_widget/widgets.dart';

class DefaultView extends ConsumerWidget {
  final Widget? customWidget;

  const DefaultView({super.key, this.customWidget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          appBuildHeader(),
          Padding(
            padding: const EdgeInsets.all(32),
            child: customWidget ?? const SizedBox(),
          ),
        ],
      ),
    );
  }
}
