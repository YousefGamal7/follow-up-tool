import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:path/path.dart' as p;
import 'package:analyzer/dart/analysis/utilities.dart';
import '../../services/archive_service.dart';
import 'widgets/file_tree_widget.dart';
import 'widgets/code_viewer_widget.dart';
import 'widgets/image_viewer_widget.dart';
import 'widgets/video_viewer_widget.dart';

enum SelectedFileType { none, code, image, video }

class ProjectViewerScreen extends StatefulWidget {
  const ProjectViewerScreen({super.key});

  @override
  State<ProjectViewerScreen> createState() => _ProjectViewerScreenState();
}

class _ProjectViewerScreenState extends State<ProjectViewerScreen> {
  bool _isDragging = false;
  bool _isExtracting = false;
  Directory? _projectDirectory;
  
  SelectedFileType _selectedFileType = SelectedFileType.none;
  File? _selectedFile;
  String _selectedFileCode = '';
  String _selectedFileLanguage = 'dart';
  List<String> _syntaxErrors = [];

  final ArchiveService _archiveService = ArchiveService();

  Future<void> _handleDrop(DropDoneDetails details) async {
    if (details.files.isEmpty) return;
    
    final file = File(details.files.first.path);
    final ext = p.extension(file.path).toLowerCase();
    
    if (ext != '.zip' && ext != '.rar') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please drop a valid .zip or .rar file')),
      );
      return;
    }

    setState(() {
      _isExtracting = true;
      _selectedFileType = SelectedFileType.none;
      _selectedFile = null;
      _selectedFileCode = '';
      _syntaxErrors = [];
    });

    try {
      final destDir = await _archiveService.extractArchiveToTemp(file);
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
    final ext = p.extension(file.path).toLowerCase().replaceAll('.', '');
    
    final imageExts = ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'];
    final videoExts = ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv'];
    
    if (imageExts.contains(ext)) {
      setState(() {
        _selectedFileType = SelectedFileType.image;
        _selectedFile = file;
      });
      return;
    }
    
    if (videoExts.contains(ext)) {
      setState(() {
        _selectedFileType = SelectedFileType.video;
        _selectedFile = file;
      });
      return;
    }

    // Default to code/text viewer
    try {
      final code = await file.readAsString();
      List<String> errors = [];
      
      if (ext == 'dart') {
        try {
          final result = parseString(content: code, throwIfDiagnostics: false);
          for (final error in result.errors) {
            final location = result.lineInfo.getLocation(error.offset);
            errors.add('Line ${location.lineNumber}: ${error.message}');
          }
        } catch (_) {
          // Parsing failed completely
        }
      }

      setState(() {
        _selectedFileType = SelectedFileType.code;
        _selectedFile = file;
        _selectedFileCode = code;
        _syntaxErrors = errors;
        _selectedFileLanguage = ext == 'yaml' ? 'yaml' : 
                                ext == 'json' ? 'json' : 
                                ext == 'xml' ? 'xml' : 
                                ext == 'html' ? 'html' : 'dart';
      });
    } catch (e) {
      setState(() {
        _selectedFileType = SelectedFileType.code;
        _selectedFile = file;
        _selectedFileCode = 'Error reading file: $e\nThis might be a binary file format.';
        _selectedFileLanguage = 'plaintext';
        _syntaxErrors = [];
      });
    }
  }

  Widget _buildMainContent() {
    switch (_selectedFileType) {
      case SelectedFileType.none:
        return const Center(child: Text('Select a file to view its contents'));
      case SelectedFileType.image:
        return ImageViewerWidget(imageFile: _selectedFile!);
      case SelectedFileType.video:
        return VideoViewerWidget(videoFile: _selectedFile!);
      case SelectedFileType.code:
        return CodeViewerWidget(
          code: _selectedFileCode,
          language: _selectedFileLanguage,
          syntaxErrors: _syntaxErrors,
        );
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
                            'Drag & Drop a Flutter .zip or .rar project here',
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
                            child: _buildMainContent(),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
