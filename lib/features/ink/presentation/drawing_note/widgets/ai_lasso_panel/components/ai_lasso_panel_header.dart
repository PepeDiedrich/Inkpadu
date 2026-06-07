// ignore_for_file: public_member_api_docs

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:inkpadu/i18n/translations.g.dart';

class AiLassoPanelHeader extends StatelessWidget {
  final VoidCallback onClose;
  final ValueChanged<Offset> onPositionUpdate;

  const AiLassoPanelHeader({
    super.key,
    required this.onClose,
    required this.onPositionUpdate,
  });

  @override
  Widget build(BuildContext context) => RawGestureDetector(
    gestures: <Type, GestureRecognizerFactory>{
      _EagerPanGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<_EagerPanGestureRecognizer>(
            _EagerPanGestureRecognizer.new,
            (instance) =>
                instance.onUpdate = (details) =>
                    onPositionUpdate(details.delta),
          ),
    },
    child: Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.t.ai.helpMeTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Icon(
            Icons.drag_indicator,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClose,
            child: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ],
      ),
    ),
  );
}

class _EagerPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
