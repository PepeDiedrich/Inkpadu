// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:inkpadu/i18n/translations.g.dart';

class AiLassoInputArea extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final bool isLoading;

  const AiLassoInputArea({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: context.t.ai.askFollowUp,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                onSubmit(val.trim());
                controller.clear();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            final text = controller.text.trim();
            if (text.isNotEmpty) {
              onSubmit(text);
              controller.clear();
            }
          },
        ),
      ],
    );
  }
}
