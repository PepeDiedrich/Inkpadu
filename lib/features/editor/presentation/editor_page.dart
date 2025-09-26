import 'package:flutter/material.dart';

/// Placeholder screen representing the handwriting editor canvas.
class EditorPage extends StatelessWidget {
  /// Creates a new [EditorPage].
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Notiz bearbeiten'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.undo),
              tooltip: 'Rückgängig',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.redo),
              tooltip: 'Wiederholen',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.ios_share),
              tooltip: 'Teilen',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _ToolPalette(),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: _CanvasPlaceholderLabel(),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const _BottomToolbar(),
      );
}

class _CanvasPlaceholderLabel extends StatelessWidget {
  const _CanvasPlaceholderLabel();

  @override
  Widget build(BuildContext context) => Text(
        'Handschriftliche Fläche',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      );
}

class _ToolPalette extends StatelessWidget {
  const _ToolPalette();

  static const List<_ToolAction> _tools = [
    _ToolAction(icon: Icons.brush, label: 'Stift'),
    _ToolAction(icon: Icons.create, label: 'Füller'),
    _ToolAction(icon: Icons.format_paint, label: 'Marker'),
    _ToolAction(icon: Icons.highlight, label: 'Textmarker'),
    _ToolAction(icon: Icons.pan_tool_alt, label: 'Radierer'),
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _tools.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final tool = _tools[index];
            return Container(
              width: 90,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(tool.icon,
                      size: 32, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    tool.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        ),
      );
}

class _ToolAction {
  const _ToolAction({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class _BottomToolbar extends StatelessWidget {
  const _BottomToolbar();

  @override
  Widget build(BuildContext context) => BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ToolbarButton(icon: Icons.edit_note, label: 'Seiten'),
              _ToolbarButton(icon: Icons.layers_clear, label: 'Ebenen'),
              _ToolbarButton(icon: Icons.color_lens, label: 'Farben'),
              _ToolbarButton(icon: Icons.settings, label: 'Werkzeuge'),
            ],
          ),
        ),
      );
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      );
}
