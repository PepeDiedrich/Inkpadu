import 'package:appwrite/models.dart' as appwrite_models;
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_page_codec.dart';

/// Data transfer object to convert between [InkNote] and Appwrite documents.
class InkNoteDto {
  /// Erstellt ein neues DTO mit den gegebenen Werten.
  InkNoteDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.paperStyle,
    required this.pageData,
    required this.lastOpenedPageIndex,
    required List<NotePage> pages,
    required this.updatedAt,
    this.createdAt,
  }) : pages = List<NotePage>.unmodifiable(pages);

  /// Erzeugt ein neues DTO aus einem [InkNote]-Domänenobjekt.
  factory InkNoteDto.fromDomain(InkNote note, {required String userId}) =>
      InkNoteDto(
        id: note.id,
        userId: userId,
        title: note.title,
        paperStyle: note.paperStyle.name,
        pageData: InkNotePageCodec.encode(
          note.pages,
          lastOpenedPageIndex: note.lastOpenedPageIndex,
        ),
        // Intern 0-basiert, Appwrite soll 1-basiert anzeigen. Im DTO
        // behalten wir 0-basiert und wandeln erst in toMap() um.
        lastOpenedPageIndex: note.lastOpenedPageIndex,
        pages: note.pages,
        updatedAt: note.updatedAt.toUtc(),
        createdAt: note.updatedAt.toUtc(),
      );

  /// Baut ein DTO aus einem Appwrite-[Document].
  factory InkNoteDto.fromDocument(appwrite_models.Document doc) {
    final String rawPageData = doc.data['page_data'] as String? ?? '';
    final InkNotePageBundle bundle = InkNotePageCodec.decode(rawPageData);

    final int resolvedIndex = _parseFlexiblePageIndex(
      doc.data['last_opened_page'],
      pagesLength: bundle.pages.length,
      fallback: bundle.lastOpenedPageIndex,
    );

    return InkNoteDto(
      id: doc.$id,
      userId: doc.data['user_id'] as String,
      title: doc.data['title'] as String,
      paperStyle: doc.data['paper_style'] as String,
      pageData: rawPageData,
      lastOpenedPageIndex: resolvedIndex,
      pages: bundle.pages,
      updatedAt: DateTime.parse(doc.data['updated_at'] as String).toUtc(),
      createdAt: _parseCreatedAt(
        doc.data['created_at'],
        fallback: doc.$createdAt,
      ),
    );
  }

  /// Baut ein DTO aus einer Realtime-Payload.
  factory InkNoteDto.fromPayload(Map<String, dynamic> payload) {
    final String rawPageData = payload['page_data'] as String? ?? '';
    final InkNotePageBundle bundle = InkNotePageCodec.decode(rawPageData);

    final int resolvedIndex = _parseFlexiblePageIndex(
      payload['last_opened_page'],
      pagesLength: bundle.pages.length,
      fallback: bundle.lastOpenedPageIndex,
    );

    return InkNoteDto(
      id: payload[r'$id'] as String,
      userId: payload['user_id'] as String,
      title: payload['title'] as String,
      paperStyle: payload['paper_style'] as String,
      pageData: rawPageData,
      lastOpenedPageIndex: resolvedIndex,
      pages: bundle.pages,
      updatedAt: DateTime.parse(payload['updated_at'] as String).toUtc(),
      createdAt: _parseCreatedAt(payload['created_at']),
    );
  }

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

  /// Index der Seite, die zuletzt geöffnet wurde.
  final int lastOpenedPageIndex;

  /// Dekodierte Seitenliste.
  final List<NotePage> pages;

  /// Zeitpunkt der letzten Änderung in UTC.
  final DateTime updatedAt;

  /// Zeitpunkt der Erstellung in UTC.
  final DateTime? createdAt;

  /// Wandelt das DTO zurück in ein [InkNote]-Domänenobjekt.
  InkNote toDomain() {
    NotePaperStyle resolvedStyle;
    try {
      resolvedStyle = NotePaperStyle.values.byName(paperStyle);
    } catch (_) {
      resolvedStyle = NotePaperStyle.plain;
    }

  final List<NotePage> effectivePages = pages.isEmpty
    ? <NotePage>[NotePage(strokes: const <Stroke>[])]
        : pages;
  final int normalizedIndex = effectivePages.isEmpty
    ? 0
    : lastOpenedPageIndex
      .clamp(0, effectivePages.length - 1)
      .toInt();

    return InkNote(
      id: id,
      title: title,
      updatedAt: updatedAt.toLocal(),
      pages: effectivePages,
      lastOpenedPageIndex: normalizedIndex,
      paperStyle: resolvedStyle,
    );
  }

  /// Gibt die Daten als Map zur Verwendung im Appwrite-SDK zurück.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'user_id': userId,
    'title': title,
    'paper_style': paperStyle,
    'page_data': pageData,
    // Appwrite soll die „menschliche“ Seitennummer sehen (1-basiert).
    'last_opened_page': lastOpenedPageIndex + 1,
    'updated_at': updatedAt.toIso8601String(),
    'created_at': (createdAt ?? updatedAt).toIso8601String(),
  };

  static DateTime? _parseCreatedAt(
    Object? value, {
    Object? fallback,
  }) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    if (value is DateTime) {
      return value.toUtc();
    }
    if (fallback is String && fallback.isNotEmpty) {
      return DateTime.tryParse(fallback)?.toUtc();
    }
    if (fallback is DateTime) {
      return fallback.toUtc();
    }
    return null;
  }

  /// Akzeptiert 0- oder 1-basierte Eingaben und normalisiert auf 0-basiert.
  static int _parseFlexiblePageIndex(
    Object? raw, {
    required int pagesLength,
    required int fallback,
  }) {
    int? value;
    if (raw is int) {
      value = raw;
    } else if (raw is num) {
      value = raw.toInt();
    } else if (raw is String) {
      value = int.tryParse(raw);
    }

    if (value == null) {
      return fallback;
    }

    // Beides unterstützen. Zuerst 0-basiert (Bestand), dann 1-basiert (neu):
    // - 0..pagesLength-1 => 0-basiert (alt)
    // - 1..pagesLength  => 1-basiert (neu) => minus 1
    if (pagesLength > 0 && value >= 0 && value < pagesLength) {
      return value;
    }
    if (pagesLength > 0 && value >= 1 && value <= pagesLength) {
      return value - 1;
    }

    // Außerhalb des Bereichs: clampen.
    if (pagesLength <= 0) return 0;
    return value.clamp(0, pagesLength - 1).toInt();
  }
}
