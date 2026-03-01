import 'package:flutter/material.dart';

class SectionCredits extends StatelessWidget {
  final String text;

  const SectionCredits({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.normal,
          letterSpacing: 1.2,
        ),
        maxLines: 10,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
