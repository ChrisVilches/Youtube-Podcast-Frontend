import 'package:flutter/material.dart';

import 'weak_text.dart';

class LeftRightRow extends StatelessWidget {
  const LeftRightRow({
    super.key,
    required this.left,
    required this.right,
    this.leftSize = 100.0,
  });

  final String left;
  final String right;
  final double leftSize;

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: leftSize, // fixed width and height
        child: Align(
          alignment: Alignment.centerRight,
          child: WeakText(left),
        ),
      ),
      title: Text(right),
    );
  }
}
