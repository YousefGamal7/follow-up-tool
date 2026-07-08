import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewerWidget extends StatelessWidget {
  final File imageFile;

  const ImageViewerWidget({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            imageFile,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
