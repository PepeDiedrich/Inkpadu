import 'package:flutter/material.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';

/// Notifier verwaltet die in-memory Sammlung handschriftlicher Notizen.
/// Controller verwaltet eine Sammlung von [InkNote] Objekten im Speicher.
class InkNotesController extends ChangeNotifier {
  final List<InkNote> _notes = [];

  /// Unveränderliche Sicht auf alle Notizen.
  List<InkNote> get notes => List.unmodifiable(_notes);

  /// Legt eine neue leere Notiz an und gibt sie zurück.
  InkNote createEmpty() {
    final note = InkNote.empty();
    _notes.insert(0, note);
    notifyListeners();
    return note;
  }

  /// Fügt eine Notiz ein oder aktualisiert sie anhand der ID.
  void upsert(InkNote note) {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      _notes[idx] = note;
    } else {
      _notes.insert(0, note);
    }
    notifyListeners();
  }

  /// Löscht die Notiz mit passender [id].
  void delete(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}

/// InheritedWidget für einfachen Zugriff im Widget-Tree.
/// Inherited Scope für Zugriff auf [InkNotesController].
class InkNotesScope extends InheritedNotifier<InkNotesController> {
  const InkNotesScope({
    super.key,
    required InkNotesController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

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
