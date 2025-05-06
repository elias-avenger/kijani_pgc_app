import 'dart:io';

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
      builder: (context) {
        return SafeArea(
          child: Wrap(
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
                        _selectedImages.map((e) => e.path).toList());
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
                        _selectedImages.map((e) => e.path).toList());
                    if (images.length > availableSlots) {
                      _showLimitMessage();
                    }
                  }
                },
              ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showImagePickerMenu,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _selectedImages.isEmpty
                    ? Column(
                        children: [
                          const Icon(Icons.camera_alt,
                              size: 40, color: Colors.black54),
                          const SizedBox(height: 8),
                          Text(widget.label,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54)),
                        ],
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._selectedImages.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;

                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    file,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          if (_selectedImages.length < maxImages)
                            GestureDetector(
                              onTap: _showImagePickerMenu,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black26),
                                ),
                                child: const Icon(Icons.add_a_photo,
                                    color: Colors.black54),
                              ),
                            ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
