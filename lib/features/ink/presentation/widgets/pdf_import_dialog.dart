import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:ai_handwriting_app/features/ink/application/pdf/pdf_import_service.dart';

/// Ergebnis des PDF-Import-Dialogs.
class PdfImportResult {
  /// Erstellt ein neues Import-Ergebnis.
  const PdfImportResult({
    required this.extractedTexts,
    required this.pageCount,
  });

  /// Die extrahierten Texte pro Seite.
  final List<String> extractedTexts;

  /// Die Anzahl der importierten Seiten.
  final int pageCount;

  /// Kombinierter Text aller Seiten.
  String get combinedText => extractedTexts
      .asMap()
      .entries
      .map((e) => '--- Seite ${e.key + 1} ---\n${e.value}')
      .join('\n\n');
}

/// Dialog für den PDF-Import mit Fortschrittsanzeige.
///
/// Zeigt eine Dateiauswahl, dann den Fortschritt der Verarbeitung,
/// und gibt die extrahierten Texte zurück.
class PdfImportDialog extends StatefulWidget {
  /// Erstellt einen neuen PDF-Import-Dialog.
  const PdfImportDialog({
    super.key,
    required this.pdfImportService,
  });

  /// Der Service für den PDF-Import.
  final PdfImportService pdfImportService;

  /// Zeigt den Dialog an und gibt das Ergebnis zurück.
  static Future<PdfImportResult?> show({
    required BuildContext context,
    required PdfImportService pdfImportService,
  }) =>
      showDialog<PdfImportResult>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PdfImportDialog(
          pdfImportService: pdfImportService,
        ),
      );

  @override
  State<PdfImportDialog> createState() => _PdfImportDialogState();
}

class _PdfImportDialogState extends State<PdfImportDialog> {
  _ImportState _state = _ImportState.idle;
  PdfImportProgress? _progress;
  String? _errorMessage;
  List<PdfPageExtractionResult>? _results;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _pickAndImport();
  }

  Future<void> _pickAndImport() async {
    setState(() {
      _state = _ImportState.picking;
    });

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (!mounted) return;

      if (result == null || result.files.isEmpty) {
        Navigator.of(context).pop();
        return;
      }

      final PlatformFile file = result.files.first;
      final Uint8List? bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        setState(() {
          _state = _ImportState.error;
          _errorMessage = 'Die PDF-Datei konnte nicht gelesen werden.';
        });
        return;
      }

      _fileName = file.name;
      
      setState(() {
        _state = _ImportState.processing;
      });

      final List<PdfPageExtractionResult> results =
          await widget.pdfImportService.importPdf(
        pdfBytes: bytes,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _progress = progress;
            });
          }
        },
      );

      if (!mounted) return;

      setState(() {
        _state = _ImportState.done;
        _results = results;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _state = _ImportState.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _confirm() {
    if (_results == null) return;

    Navigator.of(context).pop(PdfImportResult(
      extractedTexts: _results!.map((r) => r.extractedText).toList(),
      pageCount: _results!.length,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _state == _ImportState.error
                ? Icons.error_outline
                : Icons.picture_as_pdf,
            color: _state == _ImportState.error
                ? colorScheme.error
                : colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getTitle(),
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: _buildContent(theme, colorScheme),
      ),
      actions: _buildActions(colorScheme),
    );
  }

  String _getTitle() {
    switch (_state) {
      case _ImportState.idle:
      case _ImportState.picking:
        return 'PDF auswählen';
      case _ImportState.processing:
        return 'PDF verarbeiten';
      case _ImportState.done:
        return 'Import abgeschlossen';
      case _ImportState.error:
        return 'Fehler';
    }
  }

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
    switch (_state) {
      case _ImportState.idle:
      case _ImportState.picking:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Bitte wähle eine PDF-Datei aus...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        );

      case _ImportState.processing:
        final progress = _progress;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_fileName != null) ...[
              Text(
                _fileName!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
            ],
            LinearProgressIndicator(
              value: progress?.progress,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 12),
            if (progress != null)
              Text(
                _getProgressText(progress),
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),
            Text(
              'Die Textextraktion kann einige Sekunden pro Seite dauern.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );

      case _ImportState.done:
        final results = _results ?? [];
        final totalChars = results.fold<int>(
          0,
          (sum, r) => sum + r.extractedText.length,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${results.length} Seite${results.length == 1 ? '' : 'n'} importiert',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '~${(totalChars / 1000).toStringAsFixed(1)}k Zeichen extrahiert',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Der extrahierte Text wird als Kontext für den KI-Assistenten verwendet.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );

      case _ImportState.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Ein unbekannter Fehler ist aufgetreten.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
    }
  }

  String _getProgressText(PdfImportProgress progress) {
    switch (progress.stage) {
      case PdfImportStage.rendering:
        return 'Rendere Seite ${progress.currentPage} von ${progress.totalPages}...';
      case PdfImportStage.extracting:
        return 'Extrahiere Text von Seite ${progress.currentPage} von ${progress.totalPages}...';
      case PdfImportStage.parsingTasks:
        return 'Erkenne Aufgaben...';
    }
  }

  List<Widget> _buildActions(ColorScheme colorScheme) {
    switch (_state) {
      case _ImportState.idle:
      case _ImportState.picking:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
        ];

      case _ImportState.processing:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
        ];

      case _ImportState.done:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton.icon(
            onPressed: _confirm,
            icon: const Icon(Icons.check),
            label: const Text('Übernehmen'),
          ),
        ];

      case _ImportState.error:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Schließen'),
          ),
          FilledButton(
            onPressed: _pickAndImport,
            child: const Text('Erneut versuchen'),
          ),
        ];
    }
  }
}

enum _ImportState {
  idle,
  picking,
  processing,
  done,
  error,
}
