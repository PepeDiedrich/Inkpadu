import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';

/// Ergebnis des PDF-Auswahl-Dialogs.
class PdfPickerResult {
  /// Erstellt ein neues Auswahl-Ergebnis.
  const PdfPickerResult({
    required this.pdfBytes,
    required this.pageCount,
    required this.fileName,
  });

  /// Die Bytes der ausgewählten PDF-Datei.
  final Uint8List pdfBytes;

  /// Die Anzahl der Seiten in der PDF.
  final int pageCount;

  /// Der Dateiname der PDF.
  final String fileName;
}

/// Einfacher Dialog zum Auswählen einer PDF-Datei.
///
/// Gibt die PDF-Bytes und Seitenzahl zurück, ohne die Verarbeitung zu starten.
/// Die eigentliche Textextraktion erfolgt im Hintergrund nach dem Öffnen der Notiz.
class PdfPickerDialog extends StatefulWidget {
  /// Erstellt einen neuen PDF-Picker-Dialog.
  const PdfPickerDialog({super.key});

  /// Zeigt den Dialog an und gibt das Ergebnis zurück.
  static Future<PdfPickerResult?> show(BuildContext context) =>
      showDialog<PdfPickerResult>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const PdfPickerDialog(),
      );

  @override
  State<PdfPickerDialog> createState() => _PdfPickerDialogState();
}

class _PdfPickerDialogState extends State<PdfPickerDialog> {
  _PickerState _state = _PickerState.picking;
  String? _errorMessage;
  String? _fileName;
  int? _pageCount;

  @override
  void initState() {
    super.initState();
    _pickPdf();
  }

  Future<void> _pickPdf() async {
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
          _state = _PickerState.error;
          _errorMessage = 'Die PDF-Datei konnte nicht gelesen werden.';
        });
        return;
      }

      setState(() {
        _state = _PickerState.analyzing;
        _fileName = file.name;
      });

      // PDF öffnen um Seitenzahl zu ermitteln
      final PdfDocument document = await PdfDocument.openData(bytes);
      final int pageCount = document.pagesCount;
      await document.close();

      if (!mounted) return;

      setState(() {
        _state = _PickerState.ready;
        _pageCount = pageCount;
      });

      // Kurz warten, dann automatisch bestätigen
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (mounted && _state == _PickerState.ready) {
        Navigator.of(context).pop(PdfPickerResult(
          pdfBytes: bytes,
          pageCount: pageCount,
          fileName: file.name,
        ));
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _state = _PickerState.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _state == _PickerState.error
                ? Icons.error_outline
                : Icons.picture_as_pdf,
            color: _state == _PickerState.error
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
        width: 300,
        child: _buildContent(theme, colorScheme),
      ),
      actions: _buildActions(),
    );
  }

  String _getTitle() {
    switch (_state) {
      case _PickerState.picking:
        return 'PDF auswählen';
      case _PickerState.analyzing:
        return 'PDF analysieren';
      case _PickerState.ready:
        return 'Bereit';
      case _PickerState.error:
        return 'Fehler';
    }
  }

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
    switch (_state) {
      case _PickerState.picking:
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

      case _PickerState.analyzing:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            if (_fileName != null) ...[
              Text(
                _fileName!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'PDF wird analysiert...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        );

      case _PickerState.ready:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: colorScheme.primary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '${_pageCount ?? 0} Seite${_pageCount == 1 ? '' : 'n'} gefunden',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Textextraktion erfolgt im Hintergrund.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );

      case _PickerState.error:
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

  List<Widget> _buildActions() {
    switch (_state) {
      case _PickerState.picking:
      case _PickerState.analyzing:
      case _PickerState.ready:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
        ];

      case _PickerState.error:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Schließen'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _state = _PickerState.picking;
                _errorMessage = null;
              });
              _pickPdf();
            },
            child: const Text('Erneut versuchen'),
          ),
        ];
    }
  }
}

enum _PickerState {
  picking,
  analyzing,
  ready,
  error,
}
