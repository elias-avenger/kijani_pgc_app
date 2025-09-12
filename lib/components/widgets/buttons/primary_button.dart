import 'dart:async';
import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.isLoading, // external loading (optional)
    this.enabled = true, // external enable/disable
    this.width, // null => expand to max width
    this.height = 50,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.textStyle = const TextStyle(color: Colors.white),
    this.leading, // optional left icon/widget
    this.trailing, // optional right icon/widget
    this.onLongPress,
    this.onError, // error hook
    this.debounce = const Duration(milliseconds: 500),
    this.semanticsLabel,
  });

  final String text;
  final FutureOr<void> Function() onPressed;
  final Color? backgroundColor;

  // Reusability extras
  final bool? isLoading; // if null, button manages its own loading
  final bool enabled;
  final double? width;
  final double height;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onLongPress;
  final void Function(Object error, StackTrace stack)? onError;
  final Duration debounce;
  final String? semanticsLabel;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _internalLoading = false;
  DateTime? _lastPressedAt;

  bool get _isLoading => widget.isLoading ?? _internalLoading;

  Future<void> _handlePress() async {
    if (!widget.enabled || _isLoading) return;

    // Debounce
    final now = DateTime.now();
    if (_lastPressedAt != null &&
        now.difference(_lastPressedAt!) < widget.debounce) {
      return;
    }
    _lastPressedAt = now;

    // If parent isn't controlling loading, manage it internally
    if (widget.isLoading == null) setState(() => _internalLoading = true);

    try {
      await Future.sync(widget.onPressed);
    } catch (e, st) {
      widget.onError?.call(e, st);
      // Optional: rethrow if you want upstream error handling
      // rethrow;
    } finally {
      if (mounted && widget.isLoading == null) {
        setState(() => _internalLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.backgroundColor ?? const Color(0xFF2F613F); // unchanged
    final disabledBg = bgColor.withOpacity(0.7);

    final buttonChild = _isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.text,
                  overflow: TextOverflow.ellipsis,
                  style: widget.textStyle, // keep white by default
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: 8),
                widget.trailing!,
              ],
            ],
          );

    return Semantics(
      button: true,
      label: widget.semanticsLabel ?? widget.text,
      enabled: widget.enabled && !_isLoading,
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: ElevatedButton(
          onPressed: (widget.enabled && !_isLoading) ? _handlePress : null,
          onLongPress:
              (widget.enabled && !_isLoading) ? widget.onLongPress : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            disabledBackgroundColor: disabledBg,
            shape: RoundedRectangleBorder(borderRadius: widget.borderRadius),
            padding: widget.padding,
            elevation: 0,
          ),
          child: buttonChild,
        ),
      ),
    );
  }
}
