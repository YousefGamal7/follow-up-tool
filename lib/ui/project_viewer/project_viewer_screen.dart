import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:path/path.dart' as p;
import '../../services/archive_service.dart';
import 'widgets/file_tree_widget.dart';
import 'widgets/code_viewer_widget.dart';

class ProjectViewerScreen extends StatefulWidget {
  const ProjectViewerScreen({super.key});

  @override
  State<ProjectViewerScreen> createState() => _ProjectViewerScreenState();
}

class _ProjectViewerScreenState extends State<ProjectViewerScreen> {
  bool _isDragging = false;
  bool _isExtracting = false;
  Directory? _projectDirectory;
  String _selectedFileCode = '';
  String _selectedFileLanguage = 'dart';
  final ArchiveService _archiveService = ArchiveService();

  Future<void> _handleDrop(DropDoneDetails details) async {
    if (details.files.isEmpty) return;
    
    final file = File(details.files.first.path);
    if (p.extension(file.path).toLowerCase() != '.zip') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please drop a valid .zip file')),
      );
      return;
    }

    setState(() {
      _isExtracting = true;
      _selectedFileCode = '';
    });

    try {
      final destDir = await _archiveService.extractZipToTemp(file);
      setState(() {
        _projectDirectory = destDir;
        _isExtracting = false;
      });
    } catch (e) {
      setState(() {
        _isExtracting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to extract: $e')),
        );
      }
    }
  }

  Future<void> _handleFileSelected(File file) async {
    try {
      final ext = p.extension(file.path).toLowerCase().replaceAll('.', '');
      final code = await file.readAsString();
      setState(() {
        _selectedFileCode = code;
        _selectedFileLanguage = ext == 'yaml' ? 'yaml' : 
                                ext == 'json' ? 'json' : 
                                ext == 'xml' ? 'xml' : 
                                ext == 'html' ? 'html' : 'dart';
      });
    } catch (e) {
      setState(() {
        _selectedFileCode = 'Error reading file: $e';
        _selectedFileLanguage = 'plaintext';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Viewer'),
      ),
      body: DropTarget(
        onDragEntered: (details) => setState(() => _isDragging = true),
        onDragExited: (details) => setState(() => _isDragging = false),
        onDragDone: _handleDrop,
        child: Container(
          color: _isDragging ? Colors.blue.withOpacity(0.1) : null,
          child: _isExtracting
              ? const Center(child: CircularProgressIndicator())
              : _projectDirectory == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 100,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Drag & Drop a Flutter .zip project here',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        // Sidebar
                        SizedBox(
                          width: 300,
                          child: Card(
                            margin: const EdgeInsets.all(8.0),
                            child: FileTreeWidget(
                              projectDirectory: _projectDirectory!,
                              onFileSelected: _handleFileSelected,
                            ),
                          ),
                        ),
                        // Main Content
                        Expanded(
                          child: Card(
                            margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                            clipBehavior: Clip.antiAlias,
                            child: CodeViewerWidget(
                              code: _selectedFileCode,
                              language: _selectedFileLanguage,
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
