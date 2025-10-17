import 'package:ai_handwriting_app/app/theme/app_colors.dart';
import 'package:ai_handwriting_app/features/drawing/domain/assistant_message.dart';
import 'package:flutter/material.dart';

/// Stellt den Gesprächsverlauf des Assistenten inklusive Statusmeldungen dar.
class AssistantConversationSection extends StatelessWidget {
  /// Erstellt eine Gesprächssektion für das KI-Panel.
  const AssistantConversationSection({
    super.key,
    required this.statusMessage,
    required this.isLoading,
    required this.messages,
    required this.debugModeEnabled,
  });

  /// Optionale Statusmeldung oberhalb der Historie.
  final String? statusMessage;
  /// Zeigt an, ob gerade eine Anfrage gesendet wird.
  final bool isLoading;
  /// Historie der bereits beantworteten Fragen.
  final List<AssistantMessage> messages;
  /// Ob der Debug-Modus aktiv ist (steuert die Beschreibung).
  final bool debugModeEnabled;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    if (statusMessage != null) {
      children.add(_AssistantStatusBanner(
        message: statusMessage!,
        isLoading: isLoading,
      ));
    }

    if (messages.isEmpty) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 16));
      }
      children.add(const _AssistantEmptyPlaceholder());
    } else {
      for (int index = 0; index < messages.length; index++) {
        if (children.isNotEmpty) {
          children.add(const SizedBox(height: 16));
        }
        children.add(
          _AssistantMessageGroup(
            message: messages[index],
            debugModeEnabled: debugModeEnabled,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _AssistantStatusBanner extends StatelessWidget {
  const _AssistantStatusBanner({
    required this.message,
    required this.isLoading,
  });

  final String message;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            isLoading ? Icons.sync : Icons.info_outline,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantMessageGroup extends StatelessWidget {
  const _AssistantMessageGroup({
    required this.message,
    required this.debugModeEnabled,
  });

  final AssistantMessage message;
  final bool debugModeEnabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    final TimeOfDay timeOfDay = TimeOfDay.fromDateTime(message.createdAt);
    final String timestamp =
        '${localizations.formatMediumDate(message.createdAt)} · '
        '${localizations.formatTimeOfDay(timeOfDay, alwaysUse24HourFormat: true)}';

    final String? description = message.visionDescription;
    final bool showDescription =
        debugModeEnabled && (description?.isNotEmpty ?? false);
    final Brightness accentBrightness =
        ThemeData.estimateBrightnessForColor(AppColors.primaryAccent);
    final Color questionForeground =
        accentBrightness == Brightness.dark ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: _AssistantBubble(
            backgroundColor: AppColors.primaryAccent,
            foregroundColor: questionForeground,
            label: 'Frage',
            content: message.question,
          ),
        ),
        if (showDescription) ...<Widget>[
          const SizedBox(height: 10),
          Align(
            child: _AssistantBubble(
              backgroundColor: colorScheme.surfaceContainerLow,
              foregroundColor: colorScheme.onSurfaceVariant,
              label: message.reusedCachedDescription
                  ? 'Beschreibung (Cache)'
                  : 'Beschreibung',
              content: description!,
              italic: true,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: _AssistantBubble(
            backgroundColor: colorScheme.surfaceContainerHigh,
            foregroundColor: colorScheme.onSurface,
            borderColor: colorScheme.outlineVariant,
            label: 'Antwort',
            content: message.answer,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          timestamp,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.label,
    required this.content,
    this.borderColor,
    this.italic = false,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final String label;
  final String content;
  final Color? borderColor;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: foregroundColor.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                content,
                style: textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontStyle: italic ? FontStyle.italic : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantEmptyPlaceholder extends StatelessWidget {
  const _AssistantEmptyPlaceholder();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        'Noch keine Unterhaltung. Stelle eine Frage, um zu beginnen.',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
