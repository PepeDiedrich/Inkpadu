import 'package:ai_handwriting_app/features/drawing/domain/assistant_message.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';

/// Repräsentiert eine einzelne Notizenseite, die eine Sammlung von Strichen enthält.
class NotePage {
  /// Erstellt eine neue Notizenseite.
  NotePage({
    required this.strokes,
    List<AssistantMessage>? assistantHistory,
    this.cachedVisionDescription,
    this.cachedVisionSignature,
    this.importedPdfText,
  }) : assistantHistory = List<AssistantMessage>.unmodifiable(
          assistantHistory ?? const <AssistantMessage>[],
        );

  /// Die Liste aller Striche auf dieser Seite.
  final List<Stroke> strokes;

  /// Historie der Interaktionen mit dem KI-Assistenten.
  final List<AssistantMessage> assistantHistory;

  /// Zwischengespeicherte Kurzbeschreibung der Seite, die von der KI erzeugt wurde.
  final String? cachedVisionDescription;

  /// Fingerabdruck der Bounding-Boxen zum Zeitpunkt der Beschreibung.
  final String? cachedVisionSignature;

  /// Text, der aus einer importierten PDF-Seite extrahiert wurde.
  final String? importedPdfText;

  static const Object _sentinel = Object();

  /// Erstellt eine Kopie der Seite mit optional geänderten Werten.
  NotePage copyWith({
    List<Stroke>? strokes,
    List<AssistantMessage>? assistantHistory,
    Object? cachedVisionDescription = _sentinel,
    Object? cachedVisionSignature = _sentinel,
    Object? importedPdfText = _sentinel,
  }) =>
      NotePage(
        strokes: strokes ?? this.strokes,
        assistantHistory: assistantHistory ?? this.assistantHistory,
        cachedVisionDescription: cachedVisionDescription == _sentinel
            ? this.cachedVisionDescription
            : cachedVisionDescription as String?,
        cachedVisionSignature: cachedVisionSignature == _sentinel
            ? this.cachedVisionSignature
            : cachedVisionSignature as String?,
        importedPdfText: importedPdfText == _sentinel
            ? this.importedPdfText
            : importedPdfText as String?,
      );

  /// Wandelt das Objekt in eine JSON-Map um.
  Map<String, dynamic> toJson() => {
        'strokes': strokes.map((s) => s.toJson()).toList(),
        'assistant_history':
            assistantHistory.map((m) => m.toJson()).toList(growable: false),
    'cached_vision_description': cachedVisionDescription,
    'cached_vision_signature': cachedVisionSignature,
    'imported_pdf_text': importedPdfText,
  };

  /// Erstellt ein [NotePage]-Objekt aus einer JSON-Map.
  factory NotePage.fromJson(Map<String, dynamic> json) {
    final Object? rawStrokes = json['strokes'];
    final List<Stroke> decodedStrokes = rawStrokes is List
        ? rawStrokes
            .whereType<Map<String, dynamic>>()
            .map(Stroke.fromJson)
            .toList(growable: false)
        : const <Stroke>[];

    final Object? rawHistory = json['assistant_history'];
    final List<AssistantMessage> history = rawHistory is List
        ? rawHistory
            .whereType<Map<String, dynamic>>()
            .map(AssistantMessage.fromJson)
            .toList(growable: false)
        : const <AssistantMessage>[];

    final Object? rawDescription = json['cached_vision_description'];
    final String? cachedVisionDescription = rawDescription is String
        ? (rawDescription.trim().isEmpty ? null : rawDescription.trim())
        : null;

    final Object? rawSignature = json['cached_vision_signature'];
    final String? cachedVisionSignature = rawSignature is String
        ? (rawSignature.trim().isEmpty ? null : rawSignature.trim())
        : null;

    final Object? rawPdfText = json['imported_pdf_text'];
    final String? importedPdfText = rawPdfText is String
        ? (rawPdfText.trim().isEmpty ? null : rawPdfText.trim())
        : null;

    return NotePage(
      strokes: decodedStrokes,
      assistantHistory: history,
      cachedVisionDescription: cachedVisionDescription,
      cachedVisionSignature: cachedVisionSignature,
      importedPdfText: importedPdfText,
    );
  }
}
