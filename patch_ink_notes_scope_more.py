import re

filepath = "lib/features/ink/application/ink_notes_scope.dart"
with open(filepath, "r") as f:
    content = f.read()

# Lines 48-51
content = content.replace("""          _notes
            ..clear()
            ..addAll(await _repository.getLocalNotes())
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));""", """          _notes
            ..clear()
            ..addAll(await _repository.getLocalNotes())
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          _cachedNotes = null;""")

# Lines 354-357
content = content.replace("""      _notes
        ..clear()
        ..addAll(await _repository.getLocalNotes())
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));""", """      _notes
        ..clear()
        ..addAll(await _repository.getLocalNotes())
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _cachedNotes = null;""")


with open(filepath, "w") as f:
    f.write(content)
