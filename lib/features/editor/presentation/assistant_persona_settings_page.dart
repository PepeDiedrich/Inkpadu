import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_persona.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Seite zur Konfiguration der KI-Assistenten-Persona.
class AssistantPersonaSettingsPage extends StatefulWidget {
  /// Erstellt eine neue [AssistantPersonaSettingsPage].
  const AssistantPersonaSettingsPage({super.key});

  @override
  State<AssistantPersonaSettingsPage> createState() =>
      _AssistantPersonaSettingsPageState();
}

class _AssistantPersonaSettingsPageState
    extends State<AssistantPersonaSettingsPage> {
  late TextEditingController _customPromptController;

  @override
  void initState() {
    super.initState();
    _customPromptController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = EditorSettingsScope.of(context);
    _customPromptController.text = settings.customAssistantPrompt ?? '';
  }

  @override
  void dispose() {
    _customPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final settings = EditorSettingsScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.t.editor.aiPersona)),
      body: AnimatedBuilder(
        animation: settings,
        builder: (context, _) {
          final currentType = settings.assistantPersonaType;
          final isCustom = currentType == AssistantPersonaType.custom;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                context.t.editor.choosePersonaStyle,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                context.t.editor.personaStyleHint,
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              _PersonaOption(
                type: AssistantPersonaType.critical,
                title: context.t.editor.strictTrainer,
                subtitle: context.t.editor.strictTrainerHint,
                icon: Icons.fitness_center,
                isSelected: currentType == AssistantPersonaType.critical,
                onSelected: () => settings.update(
                  assistantPersonaType: AssistantPersonaType.critical,
                ),
              ),
              const SizedBox(height: 12),
              _PersonaOption(
                type: AssistantPersonaType.praising,
                title: context.t.editor.encouragingMentor,
                subtitle: context.t.editor.encouragingMentorHint,
                icon: Icons.thumb_up_alt_outlined,
                isSelected: currentType == AssistantPersonaType.praising,
                onSelected: () => settings.update(
                  assistantPersonaType: AssistantPersonaType.praising,
                ),
              ),
              const SizedBox(height: 12),
              _PersonaOption(
                type: AssistantPersonaType.custom,
                title: context.t.editor.customPersona,
                subtitle: context.t.editor.customPersonaHint,
                icon: Icons.edit_note,
                isSelected: currentType == AssistantPersonaType.custom,
                onSelected: () => settings.update(
                  assistantPersonaType: AssistantPersonaType.custom,
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: isCustom
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t.editor.yourSystemPrompt,
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _customPromptController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: context.t.editor.systemPromptPlaceholder,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerLow,
                        ),
                        onChanged: (value) {
                          settings.update(customAssistantPrompt: value);
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.t.editor.systemPromptHint,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.primaryContainer),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.t.editor.currentStyle,
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPersonaDescription(currentType),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getPersonaDescription(AssistantPersonaType type) {
    switch (type) {
      case AssistantPersonaType.critical:
        return context.t.editor.strictTrainerDescription;
      case AssistantPersonaType.praising:
        return context.t.editor.encouragingMentorDescription;
      case AssistantPersonaType.custom:
        return context.t.editor.customPersonaDescription;
    }
  }
}

class _PersonaOption extends StatelessWidget {
  const _PersonaOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  final AssistantPersonaType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.8,
                              )
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
