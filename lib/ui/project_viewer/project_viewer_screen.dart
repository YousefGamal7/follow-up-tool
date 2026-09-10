import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path/path.dart' as p;
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:send_message/theme/obsidian_theme.dart';
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
      backgroundColor: ObsidianTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: ObsidianTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Text('Project Viewer', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ObsidianTheme.surfaceRecessed,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: ObsidianTheme.borderWhite),
                  ),
                  child: const Text('Dart 3.2', style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 10)),
                ),
                const SizedBox(width: 12),
                const Text('Assignment #04', style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Assignment_Facebook', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11)),
                const Icon(LucideIcons.chevronRight, size: 14, color: ObsidianTheme.textMuted),
                const Text('lib', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11)),
                const Icon(LucideIcons.chevronRight, size: 14, color: ObsidianTheme.textMuted),
                const Text('core', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11)),
                const Icon(LucideIcons.chevronRight, size: 14, color: ObsidianTheme.textMuted),
                Text(
                  _selectedFile != null ? p.basename(_selectedFile!.path) : 'app_colors.dart',
                  style: const TextStyle(color: ObsidianTheme.primaryHover, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.downloadCloud, size: 16),
            label: const Text('Download ZIP'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ObsidianTheme.textPrimary,
              side: const BorderSide(color: ObsidianTheme.borderWhite),
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.play, color: ObsidianTheme.textSecondary, size: 16),
            label: const Text('Run Code', style: TextStyle(color: ObsidianTheme.textPrimary)),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.checkCircle, size: 16),
            label: const Text('Commit & Grade ∨'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ObsidianTheme.primary.withOpacity(0.15),
              foregroundColor: ObsidianTheme.primary,
              side: BorderSide(color: ObsidianTheme.primary.withOpacity(0.5)),
            ),
          ),
          const SizedBox(width: 24),
        ],
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
                          Icon(LucideIcons.uploadCloud, size: 100, color: ObsidianTheme.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text('Drag & Drop a Flutter .zip or .rar project here', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 16)),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Header Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: ObsidianTheme.primary,
                                    child: Text('MT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text('Mazen Tarek', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: ObsidianTheme.surfaceRecessed,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: ObsidianTheme.borderWhite),
                                            ),
                                            child: const Text('Flutter Batch #14', style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 11)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      const Text('Submitted: Yesterday, 11:42 PM (On Time)', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      _buildInfoChip(LucideIcons.gitBranch, 'Branch:', 'feature/facebook-auth-ui'),
                                      const SizedBox(width: 8),
                                      _buildInfoChip(LucideIcons.hash, 'Hash:', '8f9e2b1'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _syntaxErrors.isEmpty ? ObsidianTheme.success.withOpacity(0.1) : ObsidianTheme.warning.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: _syntaxErrors.isEmpty ? ObsidianTheme.success.withOpacity(0.3) : ObsidianTheme.warning.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(LucideIcons.checkCircle, size: 14, color: _syntaxErrors.isEmpty ? ObsidianTheme.success : ObsidianTheme.warning),
                                        const SizedBox(width: 6),
                                        Text('Static Analysis: ${_syntaxErrors.length} Errors / 0 Warnings', style: TextStyle(color: _syntaxErrors.isEmpty ? ObsidianTheme.textPrimary : ObsidianTheme.warningBadgeText, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Main Content Area
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left Sidebar: File Explorer
                                SizedBox(
                                  width: 250,
                                  child: Container(
                                    decoration: ObsidianTheme.cardDecoration,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: const [
                                              Text('EXPLORER', style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                              Icon(LucideIcons.moreVertical, size: 14, color: ObsidianTheme.textMuted),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: FileTreeWidget(
                                            projectDirectory: _projectDirectory!,
                                            onFileSelected: _handleFileSelected,
                                          ),
                                        ),
                                        const Divider(color: ObsidianTheme.borderWhite, height: 1),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: const [
                                                  Text('Target\nArchitecture', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11)),
                                                  Text('Clean\nArchitecture', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Container(
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: ObsidianTheme.primary,
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: const [
                                                  Text('Files Evaluated', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11)),
                                                  Text('5 / 6', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Main Content: Code Editor Area
                                Expanded(
                                  child: Container(
                                    decoration: ObsidianTheme.cardDecoration,
                                    child: Column(
                                      children: [
                                        // Tabs
                                        Container(
                                          padding: const EdgeInsets.only(top: 8, left: 8),
                                          decoration: const BoxDecoration(
                                            border: Border(bottom: BorderSide(color: ObsidianTheme.borderWhite)),
                                          ),
                                          child: Row(
                                            children: [
                                              _buildCodeTab('app_colors.dart', true),
                                              _buildCodeTab('login_screen.dart', false),
                                            ],
                                          ),
                                        ),
                                        // Code Editor
                                        Expanded(
                                          child: _buildMainContent(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Student UI Screenshot Reference
                          Container(
                            decoration: ObsidianTheme.cardDecoration,
                            child: ExpansionTile(
                              collapsedIconColor: ObsidianTheme.textSecondary,
                              iconColor: ObsidianTheme.textPrimary,
                              title: Row(
                                children: const [
                                  Icon(LucideIcons.image, size: 16, color: ObsidianTheme.textSecondary),
                                  SizedBox(width: 8),
                                  Text('Student UI Screenshot Reference', style: TextStyle(color: ObsidianTheme.textPrimary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              trailing: const Text('Artifact ID: #REF-7091', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11)),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Image.asset(
                                    'assets/images/placeholder_screenshot.png', // Or wherever the screenshot comes from
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceRecessed,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ObsidianTheme.borderWhite),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: ObsidianTheme.textMuted),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 11)),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildCodeTab(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? ObsidianTheme.background : ObsidianTheme.surfaceCard,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        border: Border(
          top: BorderSide(color: isActive ? ObsidianTheme.primary : ObsidianTheme.borderWhite),
          left: const BorderSide(color: ObsidianTheme.borderWhite),
          right: const BorderSide(color: ObsidianTheme.borderWhite),
          bottom: BorderSide(color: isActive ? ObsidianTheme.background : ObsidianTheme.borderWhite),
        ),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.fileCode, size: 14, color: isActive ? ObsidianTheme.primary : ObsidianTheme.textMuted),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: isActive ? ObsidianTheme.textPrimary : ObsidianTheme.textSecondary, fontSize: 13)),
          const SizedBox(width: 12),
          Icon(LucideIcons.x, size: 12, color: ObsidianTheme.textMuted),
        ],
      ),
    );
  }
}
