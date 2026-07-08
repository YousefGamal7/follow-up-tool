import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class CodeViewerWidget extends StatelessWidget {
  final String code;
  final String language;
  final List<String> syntaxErrors;

  const CodeViewerWidget({
    super.key,
    required this.code,
    this.language = 'dart',
    this.syntaxErrors = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (code.isEmpty) {
      return const Center(child: Text('Select a file to view its contents'));
    }

    return Column(
      children: [
        if (syntaxErrors.isNotEmpty)
          Container(
            color: Colors.red.shade900,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Syntax Errors Found:',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...syntaxErrors.map((e) => Text(
                      '• $e',
                      style: const TextStyle(color: Colors.white70),
                    )),
              ],
            ),
          ),
        Expanded(
          child: Container(
            width: double.infinity,
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
          ),
        ),
      ],
    );
  }
}
