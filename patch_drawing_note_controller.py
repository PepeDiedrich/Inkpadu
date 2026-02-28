import re

filepath = "lib/features/ink/application/drawing_note_controller.dart"
with open(filepath, "r") as f:
    content = f.read()

# Replace _note with __note and add setter
content = content.replace("late InkNote _note;", "late InkNote __note;\n  List<NotePage>? _cachedPages;\n\n  InkNote get _note => __note;\n  set _note(InkNote value) {\n    __note = value;\n    _cachedPages = null;\n  }")

# Add _cachedTools
content = content.replace("List<DrawingTool> _tools = const [];", "List<DrawingTool> _tools = const [];\n  List<DrawingTool>? _cachedTools;")

# Update getters
content = content.replace("List<NotePage> get pages => List<NotePage>.unmodifiable(_note.pages);", "List<NotePage> get pages => _cachedPages ??= List<NotePage>.unmodifiable(_note.pages);")
content = content.replace("List<DrawingTool> get tools => List.unmodifiable(_tools);", "List<DrawingTool> get tools => _cachedTools ??= List.unmodifiable(_tools);")

# Find occurrences of _tools assignments and invalidate cache
content = content.replace("_tools = List<DrawingTool>.of(_defaultTools);", "_tools = List<DrawingTool>.of(_defaultTools);\n    _cachedTools = null;")
content = content.replace("_tools = persisted;", "_tools = persisted;\n    _cachedTools = null;")
content = content.replace("_tools = _tools\n        .map((tool) => tool.id == updatedTool.id ? updatedTool : tool)\n        .toList(growable: false);", "_tools = _tools\n        .map((tool) => tool.id == updatedTool.id ? updatedTool : tool)\n        .toList(growable: false);\n    _cachedTools = null;")


with open(filepath, "w") as f:
    f.write(content)
