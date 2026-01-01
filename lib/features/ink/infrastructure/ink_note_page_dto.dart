import 'package:ai_handwriting_app/features/drawing/domain/assistant_message.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_link.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';

/// Data transfer object für einzelne Seiten einer handschriftlichen Notiz.
class InkNotePageDto {
  /// Erstellt ein neues DTO.
  const InkNotePageDto({
    required this.index,
    required this.strokes,
    this.assistantHistory = const <AssistantMessage>[],
    this.links = const <NoteLink>[],
    this.cachedVisionDescription,
    this.cachedVisionSignature,
  });

  /// Reihenindex der Seite innerhalb der Notiz.
  final int index;

  /// Alle Striche, die auf der Seite gezeichnet wurden.
  final List<Stroke> strokes;

  /// Gespeicherte Konversation mit dem Assistenten.
  final List<AssistantMessage> assistantHistory;

  /// Links zu anderen Notizen.
  final List<NoteLink> links;

  /// Optional zwischengespeicherte Bildbeschreibung.
  final String? cachedVisionDescription;

  /// Signatur der Bounding-Box-Konstellation für die Beschreibung.
  final String? cachedVisionSignature;

  /// Erstellt ein DTO aus einer Domänen-Seite.
  factory InkNotePageDto.fromDomain(NotePage page, {required int index}) =>
      InkNotePageDto(
        index: index,
        strokes: List<Stroke>.unmodifiable(page.strokes),
        assistantHistory:
            List<AssistantMessage>.unmodifiable(page.assistantHistory),
        links: List<NoteLink>.unmodifiable(page.links),
        cachedVisionDescription: page.cachedVisionDescription,
        cachedVisionSignature: page.cachedVisionSignature,
      );

  /// Wandelt das DTO in die Domänenrepräsentation zurück.
  NotePage toDomain() => NotePage(
        strokes: List<Stroke>.unmodifiable(strokes),
        assistantHistory: assistantHistory,
        links: links,
        cachedVisionDescription: cachedVisionDescription,
        cachedVisionSignature: cachedVisionSignature,
      );

  /// Serialisiert das DTO in eine JSON-Map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'index': index,
        'strokes':
            strokes.map((stroke) => stroke.toJson()).toList(growable: false),
        'assistant_history':
            assistantHistory.map((msg) => msg.toJson()).toList(growable: false),
        'links': links.map((link) => link.toJson()).toList(growable: false),
        'cached_vision_description': cachedVisionDescription,
        'cached_vision_signature': cachedVisionSignature,
      };

  /// Erstellt ein DTO aus einer JSON-Map.
  factory InkNotePageDto.fromJson(Map<String, dynamic> json) {
    final rawIndex = json['index'];
    final effectiveIndex = rawIndex is num ? rawIndex.toInt() : 0;
    final rawStrokes = json['strokes'];
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

    final Object? rawLinks = json['links'];
    final List<NoteLink> decodedLinks = rawLinks is List
        ? rawLinks
            .whereType<Map<String, dynamic>>()
            .map(NoteLink.fromJson)
            .toList(growable: false)
        : const <NoteLink>[];

    final Object? rawDescription = json['cached_vision_description'];
    final String? cachedDescription = rawDescription is String
        ? (rawDescription.trim().isEmpty ? null : rawDescription.trim())
        : null;

    final Object? rawSignature = json['cached_vision_signature'];
    final String? cachedSignature = rawSignature is String
        ? (rawSignature.trim().isEmpty ? null : rawSignature.trim())
        : null;

    return InkNotePageDto(
      index: effectiveIndex,
      strokes: decodedStrokes,
      assistantHistory: history,
      links: decodedLinks,
      cachedVisionDescription: cachedDescription,
      cachedVisionSignature: cachedSignature,
    );
  }
}
