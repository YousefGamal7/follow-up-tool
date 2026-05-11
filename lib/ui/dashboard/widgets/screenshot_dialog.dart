import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/student.dart';

class ScreenshotDialog extends StatefulWidget {
  final Student student;
  final List<String> assignments;

  const ScreenshotDialog({
    super.key,
    required this.student,
    required this.assignments,
  });

  @override
  State<ScreenshotDialog> createState() => _ScreenshotDialogState();
}

class _ScreenshotDialogState extends State<ScreenshotDialog> {
  final GlobalKey _globalKey = GlobalKey();
  Uint8List? _capturedImage;
  bool _isCapturing = false;

  Future<void> _capture() async {
    setState(() => _isCapturing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        setState(() {
          _capturedImage = byteData.buffer.asUint8List();
        });
      }
    } catch (e) {
      print("Error capturing image: $e");
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _saveImageDirectly() async {
    if (_capturedImage == null) return;

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Student Report',
      fileName: '${widget.student.name}_report.png',
      type: FileType.image,
    );

    if (outputFile != null) {
      try {
        if (!outputFile.toLowerCase().endsWith('.png')) {
          outputFile += '.png';
        }

        File file = File(outputFile);
        await file.writeAsBytes(_capturedImage!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved successfully: $outputFile'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_capturedImage != null) {
      return AlertDialog(
        title: const Text(
          "Image Captured Successfully 📸",
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "You can now save this directly to your computer.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: Image.memory(_capturedImage!),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton.icon(
            onPressed: _saveImageDirectly,
            icon: const Icon(Icons.download),
            label: const Text("Save to PC"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Student Report: ${widget.student.name}"),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: RepaintBoundary(
          key: _globalKey,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Student: ${widget.student.name}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("Group: ${widget.student.group}"),
                Text("Total Missed: ${widget.student.missedCount}"),
                const SizedBox(height: 20),
                const Text(
                  "Assignments Breakdown:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Table(
                  border: TableBorder.all(color: Theme.of(context).dividerColor),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Assignment",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Grade/Status",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...widget.assignments.map((assignment) {
                      String grade = widget.student.allGrades[assignment] ?? "";
                      bool isMissing = grade.isEmpty;
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(assignment),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              isMissing ? "Not Submitted" : grade,
                              style: TextStyle(
                                color: isMissing
                                    ? Colors.red
                                    : (grade.contains('late')
                                        ? Colors.orange
                                        : Colors.green),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (_isCapturing) const CircularProgressIndicator(),
        if (!_isCapturing)
          ElevatedButton.icon(
            onPressed: _capture,
            icon: const Icon(Icons.camera),
            label: const Text("Capture Image"),
          ),
      ],
    );
  }
}
