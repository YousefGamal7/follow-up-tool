import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class CodeViewerWidget extends StatelessWidget {
  final String code;
  final String language;

  const CodeViewerWidget({
    super.key,
    required this.code,
    this.language = 'dart',
  });

  @override
  Widget build(BuildContext context) {
    if (code.isEmpty) {
      return const Center(child: Text('Select a file to view its contents'));
    }

    return Container(
      color: monokaiSublimeTheme['root']?.backgroundColor ?? const Color(0xff23241f),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: HighlightView(
              code,
              language: language,
              theme: monokaiSublimeTheme,
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
