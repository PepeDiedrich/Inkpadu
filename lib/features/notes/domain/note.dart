import 'package:flutter/foundation.dart';

/// Simple data model representing a text based note.
@immutable
class Note {
  /// Creates a new [Note].
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  /// Unique identifier for the note.
  final String id;

  /// Display title.
  final String title;

  /// Full note body text.
  final String content;

  /// Timestamp of the last modification.
  final DateTime updatedAt;

  /// Returns a new [Note] with updated values.
  Note copyWith({String? title, String? content, DateTime? updatedAt}) => Note(
    id: id,
    title: title ?? this.title,
    content: content ?? this.content,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  /// Helper creating an empty note template with unique id.
  factory Note.empty() {
    final now = DateTime.now();
    return Note(
      id: now.microsecondsSinceEpoch.toString(),
      title: '',
      content: '',
      updatedAt: now,
    );
  }

  /// Derived title that always contains a readable default.
  String get displayTitle =>
      title.trim().isEmpty ? 'Unbenannte Notiz' : title.trim();

  /// First line to use as preview subtitle.
  String get preview => content.trim().isEmpty
      ? 'Noch keine Inhalte'
      : content.trim().split('\n').first;
}
