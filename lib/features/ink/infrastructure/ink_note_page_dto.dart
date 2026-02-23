import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';

/// Data transfer object für einzelne Seiten einer handschriftlichen Notiz.
class InkNotePageDto {
	/// Erstellt ein neues DTO.
	const InkNotePageDto({
		required this.index,
		required this.strokes,
	});

	/// Reihenindex der Seite innerhalb der Notiz.
	final int index;

	/// Alle Striche, die auf der Seite gezeichnet wurden.
	final List<Stroke> strokes;

	/// Erstellt ein DTO aus einer Domänen-Seite.
	factory InkNotePageDto.fromDomain(NotePage page, {required int index}) =>
			InkNotePageDto(
				index: index,
				strokes: List<Stroke>.unmodifiable(page.strokes),
			);

	/// Wandelt das DTO in die Domänenrepräsentation zurück.
	NotePage toDomain() =>
			NotePage(strokes: List<Stroke>.unmodifiable(strokes));

	/// Serialisiert das DTO in eine JSON-Map.
	Map<String, dynamic> toJson() => <String, dynamic>{
		'index': index,
		'strokes': strokes.map((stroke) => stroke.toJson()).toList(growable: false),
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

		return InkNotePageDto(
			index: effectiveIndex,
			strokes: decodedStrokes,
		);
	}
}
