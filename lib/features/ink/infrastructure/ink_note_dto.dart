import 'package:inkpadu/features/drawing/domain/note_page.dart';
import 'package:inkpadu/features/drawing/domain/stroke.dart';
import 'package:inkpadu/features/ink/domain/ink_note.dart';
import 'package:inkpadu/features/ink/domain/note_paper_style.dart';
import 'package:inkpadu/features/ink/infrastructure/ink_page_codec.dart';

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
    this.pdfBackgroundPath,
    this.pdfFileId,
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
        pdfBackgroundPath: note.pdfBackgroundPath,
        pdfFileId: note.pdfFileId,
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

  /// Index der Seite, die zuletzt geöffnet wurde.
  final int lastOpenedPageIndex;

  /// Dekodierte Seitenliste.
  final List<NotePage> pages;

  /// Zeitpunkt der letzten Änderung in UTC.
  final DateTime updatedAt;

  /// Zeitpunkt der Erstellung in UTC.
  final DateTime? createdAt;

  /// Optionaler lokaler Pfad zum PDF-Hintergrund.
  final String? pdfBackgroundPath;

  /// Optionale Appwrite Storage Datei-ID des PDFs.
  final String? pdfFileId;

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
      pdfBackgroundPath: pdfBackgroundPath,
      pdfFileId: pdfFileId,
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

}
