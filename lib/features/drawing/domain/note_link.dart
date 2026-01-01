import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Repräsentiert einen Link zu einer anderen Notiz auf dem Canvas.
@immutable
class NoteLink {
  /// Erstellt einen neuen Link.
  const NoteLink({
    required this.targetNoteId,
    required this.label,
    required this.position,
  });

  /// Die ID der Ziel-Notiz.
  final String targetNoteId;

  /// Der angezeigte Text des Links.
  final String label;

  /// Die Position des Links auf dem Canvas.
  final Offset position;

  /// Erstellt eine Kopie dieses Links mit den gegebenen Änderungen.
  NoteLink copyWith({
    String? targetNoteId,
    String? label,
    Offset? position,
  }) =>
      NoteLink(
        targetNoteId: targetNoteId ?? this.targetNoteId,
        label: label ?? this.label,
        position: position ?? this.position,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteLink &&
          runtimeType == other.runtimeType &&
          targetNoteId == other.targetNoteId &&
          label == other.label &&
          position == other.position;

  @override
  int get hashCode => Object.hash(targetNoteId, label, position);

  /// Konvertiert diesen Link in eine JSON-Map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'target_note_id': targetNoteId,
        'label': label,
        'position_dx': position.dx,
        'position_dy': position.dy,
      };

  /// Erstellt einen Link aus einer JSON-Map.
  factory NoteLink.fromJson(Map<String, dynamic> json) => NoteLink(
        targetNoteId: json['target_note_id'] as String,
        label: json['label'] as String,
        position: Offset(
          (json['position_dx'] as num).toDouble(),
          (json['position_dy'] as num).toDouble(),
        ),
      );
}
