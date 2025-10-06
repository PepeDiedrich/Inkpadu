import 'package:appwrite/models.dart' as appwrite_models;
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_page_codec.dart';

/// Data transfer object to convert between [InkNote] and Appwrite documents.
class InkNoteDto {
  /// Erstellt ein neues DTO mit den gegebenen Werten.
  const InkNoteDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.paperStyle,
    required this.pageData,
    required this.updatedAt,
  });

  /// Erzeugt ein neues DTO aus einem [InkNote]-Domänenobjekt.
  factory InkNoteDto.fromDomain(InkNote note, {required String userId}) =>
      InkNoteDto(
        id: note.id,
        userId: userId,
        title: note.title,
        paperStyle: note.paperStyle.name,
        pageData: InkNotePageCodec.encode(note.page),
        updatedAt: note.updatedAt.toUtc(),
      );

  /// Baut ein DTO aus einem Appwrite-[Document].
  factory InkNoteDto.fromDocument(appwrite_models.Document doc) => InkNoteDto(
    id: doc.$id,
    userId: doc.data['user_id'] as String,
    title: doc.data['title'] as String,
    paperStyle: doc.data['paper_style'] as String,
    pageData: doc.data['page_data'] as String,
    updatedAt: DateTime.parse(doc.data['updated_at'] as String).toUtc(),
  );

  /// Baut ein DTO aus einer Realtime-Payload.
  factory InkNoteDto.fromPayload(Map<String, dynamic> payload) => InkNoteDto(
    id: payload[r'$id'] as String,
    userId: payload['user_id'] as String,
    title: payload['title'] as String,
    paperStyle: payload['paper_style'] as String,
    pageData: payload['page_data'] as String,
    updatedAt: DateTime.parse(payload['updated_at'] as String).toUtc(),
  );

  /// Eindeutige Kennung der Notiz.
  final String id;

  /// Benutzerkennung, dem die Notiz gehört.
  final String userId;

  /// Titel der Notiz.
  final String title;

  /// Name des Papierstils.
  final String paperStyle;

  /// Serialisierte Zeicheninhalte als JSON-String.
  final String pageData;

  /// Zeitpunkt der letzten Änderung in UTC.
  final DateTime updatedAt;

  /// Wandelt das DTO zurück in ein [InkNote]-Domänenobjekt.
  InkNote toDomain() {
    NotePaperStyle resolvedStyle;
    try {
      resolvedStyle = NotePaperStyle.values.byName(paperStyle);
    } catch (_) {
      resolvedStyle = NotePaperStyle.plain;
    }

    return InkNote(
      id: id,
      title: title,
      updatedAt: updatedAt.toLocal(),
      page: InkNotePageCodec.decode(pageData),
      paperStyle: resolvedStyle,
    );
  }

  /// Gibt die Daten als Map zur Verwendung im Appwrite-SDK zurück.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'user_id': userId,
    'title': title,
    'paper_style': paperStyle,
    'page_data': pageData,
    'updated_at': updatedAt.toIso8601String(),
  };
}
