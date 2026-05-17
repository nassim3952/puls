import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SoftBlob extends StatelessWidget {
  final Color color;
  final double size;
  const SoftBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
