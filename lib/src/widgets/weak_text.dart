import 'package:flutter/material.dart';

class WeakText extends StatelessWidget {
  const WeakText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 12,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
