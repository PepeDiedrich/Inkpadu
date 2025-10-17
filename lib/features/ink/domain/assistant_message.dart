import 'package:flutter/foundation.dart';

/// Speichert eine einzelne Interaktion mit dem KI-Assistenten.
@immutable
class AssistantMessage {
  /// Erstellt eine neue Assistenten-Nachricht.
  const AssistantMessage({
    required this.question,
    required this.answer,
    this.visionDescription,
    required this.createdAt,
    this.reusedCachedDescription = false,
  });

  /// Nutzerfrage, die zur Antwort führte.
  final String question;

  /// Antwort des Assistenten.
  final String answer;

  /// Optionale Kurzbeschreibung des Seiteninhalts.
  final String? visionDescription;

  /// Zeitpunkt der Erstellung (lokale Zeit).
  final DateTime createdAt;

  /// Ob die Antwort eine bereits zwischengespeicherte Beschreibung benutzt hat.
  final bool reusedCachedDescription;

  /// Erstellt eine modifizierte Kopie der Nachricht.
  AssistantMessage copyWith({
    String? question,
    String? answer,
    Object? visionDescription = _sentinel,
    DateTime? createdAt,
    bool? reusedCachedDescription,
  }) => AssistantMessage(
        question: question ?? this.question,
        answer: answer ?? this.answer,
        visionDescription: visionDescription == _sentinel
            ? this.visionDescription
            : visionDescription as String?,
        createdAt: createdAt ?? this.createdAt,
        reusedCachedDescription:
            reusedCachedDescription ?? this.reusedCachedDescription,
      );

  /// Serialisiert die Nachricht in eine JSON-kompatible Map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'question': question,
        'answer': answer,
        'vision_description': visionDescription,
        'created_at': createdAt.toIso8601String(),
        'reused_cached_description': reusedCachedDescription,
      };

  /// Erzeugt eine Nachricht aus einer JSON-Repräsentation.
  factory AssistantMessage.fromJson(Map<String, dynamic> json) {
    final Object? rawQuestion = json['question'];
    final Object? rawAnswer = json['answer'];
    final Object? rawDescription = json['vision_description'];
    final Object? rawCreatedAt = json['created_at'];
    final Object? rawReused = json['reused_cached_description'];

    final String question = (rawQuestion is String && rawQuestion.isNotEmpty)
        ? rawQuestion
        : '';
    final String answer = (rawAnswer is String && rawAnswer.isNotEmpty)
        ? rawAnswer
        : '';
    final String? description = rawDescription is String
        ? (rawDescription.trim().isEmpty ? null : rawDescription.trim())
        : null;
    final bool reused = rawReused is bool
        ? rawReused
        : rawReused is num
            ? rawReused != 0
            : false;

    DateTime createdAt;
    if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt)?.toLocal() ?? DateTime.now();
    } else if (rawCreatedAt is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt,
          isUtc: true).toLocal();
    } else {
      createdAt = DateTime.now();
    }

    return AssistantMessage(
      question: question,
      answer: answer,
      visionDescription: description,
      createdAt: createdAt,
      reusedCachedDescription: reused,
    );
  }

  static const Object _sentinel = Object();
}
