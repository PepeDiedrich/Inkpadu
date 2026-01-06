import 'package:ai_handwriting_app/app/theme/app_colors.dart';
import 'package:ai_handwriting_app/features/drawing/domain/assistant_message.dart';
// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note_page.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/math_rich_text.dart';

/// Stellt den Gesprächsverlauf des Assistenten inklusive Statusmeldungen dar.
class AssistantConversationSliver extends StatelessWidget {
  /// Erstellt eine Gesprächssektion für das KI-Panel.
  const AssistantConversationSliver({
    super.key,
    required this.statusMessage,
    required this.isLoading,
    required this.messages,
    required this.debugModeEnabled,
    this.pendingMessage,
    this.isStreaming = false,
    this.streamingAnswerListenable,
    this.importedPdfText,
    this.currentNoteId,
  });

  /// Optionale Statusmeldung oberhalb der Historie.
  final String? statusMessage;
  /// Zeigt an, ob gerade eine Anfrage gesendet wird.
  final bool isLoading;
  /// Historie der bereits beantworteten Fragen.
  final List<AssistantMessage> messages;
  /// Ob der Debug-Modus aktiv ist (steuert die Beschreibung).
  final bool debugModeEnabled;
  /// Optionale ausstehende Nachricht, die ggf. noch generiert wird.
  final AssistantMessage? pendingMessage;
  /// Ob gerade eine Antwort gestreamt wird.
  final bool isStreaming;
  /// Live-Antwort, die während des Streamings aktualisiert wird.
  final ValueListenable<String>? streamingAnswerListenable;
  /// Importierter PDF-Text für diese Seite (wird als Kontext angezeigt).
  final String? importedPdfText;
  /// ID der aktuellen Notiz (für Sub-Notes).
  final String? currentNoteId;

  @override
  Widget build(BuildContext context) {
    final List<Object> items = <Object>[];

    // PDF-Text als Kontext anzeigen (falls vorhanden)
    final String? pdfText = importedPdfText?.trim();
    if (pdfText != null && pdfText.isNotEmpty) {
      items.add(_PdfContextBanner(pdfText: pdfText));
    }

    if (statusMessage != null) {
      if (items.isNotEmpty) items.add(const SizedBox(height: 12));
      items.add(_AssistantStatusBanner(
        message: statusMessage!,
        isLoading: isLoading,
      ));
    }

    if (messages.isEmpty) {
      if (items.isNotEmpty) items.add(const SizedBox(height: 16));
      items.add(const _AssistantEmptyPlaceholder());
    } else {
      for (int index = 0; index < messages.length; index++) {
        if (items.isNotEmpty) {
          items.add(const SizedBox(height: 16));
        }
        items.add(messages[index]);
      }
    }

    if (pendingMessage != null) {
      if (items.isNotEmpty) items.add(const SizedBox(height: 16));
      items.add(_PendingMessageWrapper(pendingMessage!));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final Object item = items[index];
          if (item is Widget) {
            return item;
          }
          if (item is AssistantMessage) {
            return _AssistantMessageGroup(
              message: item,
              debugModeEnabled: debugModeEnabled,
              currentNoteId: currentNoteId,
            );
          }
          if (item is _PendingMessageWrapper) {
            return _AssistantMessageGroup(
              message: item.message,
              debugModeEnabled: debugModeEnabled,
              isPending: isStreaming,
              streamingAnswerListenable: streamingAnswerListenable,
              currentNoteId: currentNoteId,
            );
          }
          return const SizedBox.shrink();
        },
        childCount: items.length,
      ),
    );
  }
}

class _PendingMessageWrapper {
  const _PendingMessageWrapper(this.message);
  final AssistantMessage message;
}

class _PdfContextBanner extends StatefulWidget {
  const _PdfContextBanner({required this.pdfText});

  final String pdfText;

  @override
  State<_PdfContextBanner> createState() => _PdfContextBannerState();
}

class _PdfContextBannerState extends State<_PdfContextBanner> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    // Vorschau: Erste 150 Zeichen oder bis zum ersten Zeilenumbruch
    final String preview = widget.pdfText.length > 150
        ? '${widget.pdfText.substring(0, 150).replaceAll('\n', ' ')}...'
        : widget.pdfText.replaceAll('\n', ' ');

    final int charCount = widget.pdfText.length;
    final String charLabel = charCount > 1000
        ? '~${(charCount / 1000).toStringAsFixed(1)}k Zeichen'
        : '$charCount Zeichen';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: colorScheme.tertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PDF-Kontext',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          charLabel,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onTertiaryContainer
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: colorScheme.onTertiaryContainer.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
          // Content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(
                preview,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            secondChild: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  widget.pdfText,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
    this.isPending = false,
    this.streamingAnswerListenable,
    this.currentNoteId,
  });

  final AssistantMessage message;
  final bool debugModeEnabled;
  final bool isPending;
  final ValueListenable<String>? streamingAnswerListenable;
  final String? currentNoteId;

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
        '${localizations.formatTimeOfDay(
          timeOfDay,
          alwaysUse24HourFormat: true,
        )}';
    final String displayTimestamp = isPending
        ? 'Antwort wird gerade generiert…'
        : timestamp;

    final bool answerIsEmpty = message.answer.trim().isEmpty;
    final String displayAnswer = answerIsEmpty && isPending
        ? 'Antwort wird generiert…'
        : message.answer;

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
          child: streamingAnswerListenable != null
              ? ValueListenableBuilder<String>(
                  valueListenable: streamingAnswerListenable!,
                  builder:
                      (BuildContext context, String streamedAnswer, _) {
                    final String trimmedStream = streamedAnswer.trim();
                    final bool hasStreamContent = trimmedStream.isNotEmpty;
                    final String effectiveAnswer = hasStreamContent
                        ? streamedAnswer
                        : (answerIsEmpty && isPending
                            ? 'Antwort wird generiert…'
                            : message.answer);

                    return _AssistantBubble(
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      foregroundColor: colorScheme.onSurface,
                      borderColor: colorScheme.outlineVariant,
                      label: 'Antwort',
                      content: effectiveAnswer,
                      renderMath: !isPending,
                      showSpinner: isPending,
                      currentNoteId: currentNoteId,
                    );
                  },
                )
              : _AssistantBubble(
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  foregroundColor: colorScheme.onSurface,
                  borderColor: colorScheme.outlineVariant,
                  label: 'Antwort',
                  content: displayAnswer,
                  renderMath: !isPending,
                  showSpinner: isPending,
                  currentNoteId: currentNoteId,
                ),
        ),
        const SizedBox(height: 8),
        Text(
          displayTimestamp,
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
    this.renderMath = false,
    this.showSpinner = false,
    this.currentNoteId,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final String label;
  final String content;
  final Color? borderColor;
  final bool italic;
  final bool renderMath;
  final bool showSpinner;
  final String? currentNoteId;

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
              renderMath
                  ? MathRichText(
                      text: content,
                      style: textTheme.bodyMedium?.copyWith(
                        color: foregroundColor,
                        fontStyle: italic ? FontStyle.italic : null,
                      ),
                      onMathTap: (String math) {
                        final String cleanedTitle = math.trim();
                        if (cleanedTitle.isEmpty) return;

                        final InkNotesController notesController =
                            InkNotesScope.of(context);
                        
                        final InkNote? parentNote = notesController.notes
                            .where((n) => n.id == currentNoteId)
                            .firstOrNull;

                        final InkNote note = notesController.notes.firstWhere(
                          (InkNote n) =>
                              n.parentId == currentNoteId &&
                              n.title == cleanedTitle,
                          orElse: () => notesController.createEmpty(
                            title: cleanedTitle,
                            parentId: currentNoteId,
                            paperStyle: parentNote?.paperStyle ?? NotePaperStyle.plain,
                          ),
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => DrawingNotePage(
                              noteId: note.id,
                              isSubNote: true,
                            ),
                          ),
                        );
                      },
                      onTermTap: (String term) {
                        final String cleanedTitle = term.trim();
                        if (cleanedTitle.isEmpty) return;

                        final InkNotesController notesController =
                            InkNotesScope.of(context);

                        final InkNote? parentNote = notesController.notes
                            .where((n) => n.id == currentNoteId)
                            .firstOrNull;

                        final InkNote note = notesController.notes.firstWhere(
                          (InkNote n) =>
                              n.parentId == currentNoteId &&
                              n.title == cleanedTitle,
                          orElse: () => notesController.createEmpty(
                            title: cleanedTitle,
                            parentId: currentNoteId,
                            paperStyle: parentNote?.paperStyle ?? NotePaperStyle.plain,
                          ),
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => DrawingNotePage(
                              noteId: note.id,
                              isSubNote: true,
                            ),
                          ),
                        );
                      },
                    )
                  : SelectableText(
                      content,
                      style: textTheme.bodyMedium?.copyWith(
                        color: foregroundColor,
                        fontStyle: italic ? FontStyle.italic : null,
                      ),
                    ),
              if (showSpinner) ...<Widget>[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                    ),
                  ),
                ),
              ],
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
        'Noch keine Unterhaltung. Tippe auf Tipp, Hilfe oder Überprüfen, um zu starten.',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
