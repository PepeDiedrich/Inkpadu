import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';

/// Notifier verwaltet die in-memory Sammlung handschriftlicher Notizen.
/// Controller verwaltet eine Sammlung von [InkNote] Objekten im Speicher.
class InkNotesController extends ChangeNotifier {
  final List<InkNote> _notes = [];

  /// Unveränderliche Sicht auf alle Notizen.
  List<InkNote> get notes => List.unmodifiable(_notes);

  /// Legt eine neue leere Notiz an und gibt sie zurück.
  InkNote createEmpty({
    String? title,
    NotePaperStyle paperStyle = NotePaperStyle.plain,
  }) {
    final String? cleanedTitle = title?.trim();
    final note = InkNote.empty(
      title: (cleanedTitle?.isEmpty ?? true) ? null : cleanedTitle,
      paperStyle: paperStyle,
    );
    _notes.insert(0, note);
    _safelyNotifyListeners();
    return note;
  }

  /// Fügt eine Notiz ein oder aktualisiert sie anhand der ID.
  /// Fügt eine neue Notiz hinzu oder aktualisiert eine bestehende.
  void upsert(InkNote note) {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx == -1) {
      _notes.add(note);
    } else {
      _notes[idx] = note;
    }
    _safelyNotifyListeners();
  }

  /// Löscht die Notiz mit passender [id].
  void delete(String id) {
    _notes.removeWhere((n) => n.id == id);
    _safelyNotifyListeners();
  }

  void _safelyNotifyListeners() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }
}

/// InheritedWidget für einfachen Zugriff im Widget-Tree.
/// Inherited Scope für Zugriff auf [InkNotesController].
/// Ein [InheritedNotifier] zum Verwalten des Zustands von handschriftlichen Notizen.
class InkNotesScope extends InheritedNotifier<InkNotesController> {
  /// Erstellt eine neue [InkNotesScope].
  const InkNotesScope({
    super.key,
    required InkNotesController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Liefert den [InkNotesController] aus dem Kontext.
  static InkNotesController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<InkNotesScope>();
    assert(scope != null, 'InkNotesScope nicht im Widget-Tree gefunden');
    return scope!.notifier!;
  }

  @override
  @override
  bool updateShouldNotify(
    covariant InheritedNotifier<InkNotesController> oldWidget,
  ) => true;
}
