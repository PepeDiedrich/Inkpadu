import re

filepath = "lib/features/ink/application/ink_notes_scope.dart"
with open(filepath, "r") as f:
    content = f.read()

# Add _cachedNotes
content = content.replace("final List<InkNote> _notes = [];", "final List<InkNote> _notes = [];\n  List<InkNote>? _cachedNotes;")

# Update getter
content = content.replace("List<InkNote> get notes => List.unmodifiable(_notes);", "List<InkNote> get notes => _cachedNotes ??= List.unmodifiable(_notes);")

# Update all places where _notes is mutated to invalidate _cachedNotes
# 1. _notes.insert(0, note);
content = content.replace("_notes.insert(0, note);", "_notes.insert(0, note);\n    _cachedNotes = null;")
# 2. _notes.add(note);
content = content.replace("_notes.add(note);", "_notes.add(note);\n      _cachedNotes = null;")
# 3. _notes[idx] = note;
content = content.replace("_notes[idx] = note;", "_notes[idx] = note;\n      _cachedNotes = null;")
# 4. _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
content = content.replace("_notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));", "_notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));\n    _cachedNotes = null;")
# 5. _notes.removeWhere((n) => n.id == id);
content = content.replace("_notes.removeWhere((n) => n.id == id);", "_notes.removeWhere((n) => n.id == id);\n    _cachedNotes = null;")
# 6. _notes..clear()..addAll(await _repository.getLocalNotes())..sort(...)
content = content.replace("_notes\n      ..clear()\n      ..addAll(await _repository.getLocalNotes())\n      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));", "_notes\n      ..clear()\n      ..addAll(await _repository.getLocalNotes())\n      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));\n    _cachedNotes = null;")


with open(filepath, "w") as f:
    f.write(content)
