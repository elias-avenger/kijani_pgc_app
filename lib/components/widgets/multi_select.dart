import 'package:flutter/material.dart';

/// Reusable searchable multi-select dropdown (no packages).
/// - Generic over T (use `labelFor` to render the main text).
/// - Optional subtitle per item via `subtitleFor`.
/// - Accent color default: #265E3C (Kijani green).
/// - No "Select All". No initial selection by default.
/// - Returns selection on Apply via `onChanged`.
class MultiSelectDropdown<T> extends StatefulWidget {
  const MultiSelectDropdown({
    super.key,
    required this.items,
    required this.labelFor,
    required this.onChanged,
    this.subtitleFor, // optional subtitle renderer
    this.initialSelected = const [],
    this.placeholder = 'Select…',
    this.searchHint = 'Search…',
    this.maxPopupHeight = 420,
    this.enabled = true,
    this.borderRadius = 16,
    this.accentColor = const Color(0xFF265E3C), // NEW: accent color
  });

  final List<T> items;
  final List<T> initialSelected;
  final String Function(T value) labelFor;
  final String? Function(T value)? subtitleFor; // NEW: subtitle
  final ValueChanged<List<T>> onChanged;

  final String placeholder;
  final String searchHint;
  final double
      maxPopupHeight; // (kept, but not used to constrain panel anymore)
  final bool enabled;
  final double borderRadius;
  final Color accentColor;

  @override
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.initialSelected);
  }

  @override
  void didUpdateWidget(covariant MultiSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelected != widget.initialSelected) {
      _selected = List<T>.from(widget.initialSelected);
    }
  }

  void _clear() {
    setState(() => _selected.clear());
    widget.onChanged(_selected);
  }

  void _openPicker() async {
    if (!widget.enabled) return;

    final result = await showModalBottomSheet<List<T>>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(widget.borderRadius)),
      ),
      builder: (sheetContext) {
        List<T> localSelected = List<T>.from(_selected);
        String q = '';
        final controller = TextEditingController();

        List<T> filtered() {
          if (q.isEmpty) return widget.items;
          return widget.items
              .where((e) =>
                  widget.labelFor(e).toLowerCase().contains(q.toLowerCase()))
              .toList();
        }

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              minChildSize: 0.45,
              maxChildSize: 0.95,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    // Header: Search + count pill (fixed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search,
                                      size: 20, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: controller,
                                      onChanged: (v) {
                                        q = v;
                                        setModalState(() {});
                                      },
                                      decoration: InputDecoration(
                                        hintText: widget.searchHint,
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _CountPill(
                            count: localSelected.length,
                            color: widget.accentColor,
                            onClear: localSelected.isEmpty
                                ? null
                                : () {
                                    localSelected.clear();
                                    setModalState(() {});
                                  },
                          ),
                        ],
                      ),
                    ),

                    // PANEL (now Expanded so it fills remaining height and lets the footer stay pinned)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: Colors.white,
                        child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.zero,
                          itemCount: filtered().length,
                          itemBuilder: (_, i) {
                            final item = filtered()[i];
                            final label = widget.labelFor(item);
                            final subtitle = widget.subtitleFor?.call(item);
                            final isChecked = localSelected.contains(item);

                            return _ListRow(
                              leading: _Check(
                                checked: isChecked,
                                accentColor: widget.accentColor,
                              ),
                              title: label,
                              subtitle: subtitle,
                              onTap: () {
                                if (isChecked) {
                                  localSelected.remove(item);
                                } else {
                                  localSelected.add(item);
                                }
                                setModalState(() {});
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // Footer (PINNED at the bottom)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(widget.borderRadius),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                                foregroundColor: Colors.black87,
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.pop(sheetContext, localSelected),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: widget.accentColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _selected = result);
      widget.onChanged(_selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(widget.borderRadius);
    final enabled = widget.enabled;

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: InkWell(
        onTap: enabled ? _openPicker : null,
        borderRadius: border,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: border,
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selected.isEmpty
                      ? widget.placeholder
                      : _selected
                          .map((e) => widget.labelFor(e))
                          .take(1)
                          .join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _selected.isEmpty ? Colors.black45 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CountPill(
                count: _selected.length,
                color: widget.accentColor,
                onClear: _selected.isEmpty ? null : _clear,
              ),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.black87),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- UI helpers ----------

class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.count,
    required this.color,
    this.onClear,
  });

  final int count;
  final Color color;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final has = count > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          if (has) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.leading,
    required this.title,
    this.subtitle, // optional
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = (subtitle != null && subtitle!.trim().isNotEmpty);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: hasSubtitle
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({
    required this.checked,
    required this.accentColor,
  });

  final bool checked;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? accentColor : Colors.black54,
          width: 1.6,
        ),
        color: checked ? accentColor : Colors.transparent,
      ),
      child: checked
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}
