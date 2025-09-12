import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pgc_app/utilities/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final ValueChanged<List<String>> onImagesSelected;
  final String label;
  final double? latitude;
  final double? longitude;

  const ImagePickerWidget({
    super.key,
    required this.onImagesSelected,
    required this.label,
    this.latitude,
    this.longitude,
  });

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePickerBrain _imagePickerBrain = ImagePickerBrain();
  List<File> _selectedImages = [];
  static const int maxImages = 4;

  void _showImagePickerMenu() {
    if (_selectedImages.length >= maxImages) {
      _showLimitMessage();
      return;
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedCamera01),
                title: const Text("Take a Picture"),
                onTap: () async {
                  Navigator.pop(context);
                  if (_selectedImages.length >= maxImages) {
                    _showLimitMessage();
                    return;
                  }
                  XFile? image = await _imagePickerBrain.takePicture();
                  if (image != null) {
                    setState(() {
                      _selectedImages.add(File(image.path));
                    });
                    widget.onImagesSelected(
                      _selectedImages.map((e) => e.path).toList(),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedImage02),
                title: const Text("Pick from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final images = await _imagePickerBrain.pickMultipleImages();
                  if (images.isNotEmpty) {
                    final availableSlots = maxImages - _selectedImages.length;
                    final imagesToAdd =
                        images.take(availableSlots).map((e) => File(e.path));
                    setState(() {
                      _selectedImages.addAll(imagesToAdd);
                    });
                    widget.onImagesSelected(
                      _selectedImages.map((e) => e.path).toList(),
                    );
                    if (images.length > availableSlots) {
                      _showLimitMessage();
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showLimitMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Maximum of 4 photos allowed.")),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesSelected(_selectedImages.map((e) => e.path).toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final green = const Color(0xFF2F6E4E); // Kijani-ish accent

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label/title
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Card
        Material(
          color: Colors.white,
          elevation: 0,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: _showImagePickerMenu,
            borderRadius: BorderRadius.circular(16),
            child: _DashedBorder(
              radius: 16,
              dashWidth: 6,
              dashGap: 6,
              color: Colors.grey.withOpacity(0.6),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _selectedImages.isEmpty
                    ? _EmptyState(
                        green: green, hint: "Upload the attendance list photo")
                    : _GridPreview(
                        files: _selectedImages,
                        onRemove: _removeImage,
                        onAddMore: _showImagePickerMenu,
                        canAddMore: _selectedImages.length < maxImages,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------- UI pieces (no functionality change) ----------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.green, required this.hint});
  final Color green;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('empty'),
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              HugeIcons.strokeRoundedCloudUpload,
              size: 40,
              color: Colors.black.withOpacity(0.75),
            ),
            const SizedBox(height: 12),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPreview extends StatelessWidget {
  const _GridPreview({
    required this.files,
    required this.onRemove,
    required this.onAddMore,
    required this.canAddMore,
  });

  final List<File> files;
  final void Function(int index) onRemove;
  final VoidCallback onAddMore;
  final bool canAddMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('grid'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final entry in files.asMap().entries)
            _Thumb(
              file: entry.value,
              onRemove: () => onRemove(entry.key),
            ),
          if (canAddMore) _AddTile(onTap: onAddMore),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.file, required this.onRemove});
  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
          ),
        ),
        // Remove chip
        Positioned(
          top: 6,
          right: 6,
          child: Material(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF3F4F6),
          border: Border.all(color: Colors.black12),
        ),
        child: const Center(
          child: Icon(
            HugeIcons.strokeRoundedAddSquare,
            size: 26,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}

/// A simple dashed rounded border without external packages.
class _DashedBorder extends StatelessWidget {
  const _DashedBorder({
    required this.child,
    required this.radius,
    required this.dashWidth,
    required this.dashGap,
    required this.color,
  });

  final Widget child;
  final double radius;
  final double dashWidth;
  final double dashGap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        radius: radius,
        dashWidth: dashWidth,
        dashGap: dashGap,
        color: color,
        strokeWidth: 1.6,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.radius,
    required this.dashWidth,
    required this.dashGap,
    required this.color,
    required this.strokeWidth,
  });

  final double radius;
  final double dashWidth;
  final double dashGap;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    final path = Path()..addRRect(rrect);

    // Dash the path manually
    final PathMetrics pms = path.computeMetrics();
    for (final pm in pms) {
      double dist = 0.0;
      while (dist < pm.length) {
        final double next = dist + dashWidth;
        final Path extract = pm.extractPath(dist, next.clamp(0, pm.length));
        canvas.drawPath(extract, paint);
        dist = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
