import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class FileTreeWidget extends StatefulWidget {
  final Directory projectDirectory;
  final Function(File) onFileSelected;

  const FileTreeWidget({
    super.key,
    required this.projectDirectory,
    required this.onFileSelected,
  });

  @override
  State<FileTreeWidget> createState() => _FileTreeWidgetState();
}

class _FileTreeWidgetState extends State<FileTreeWidget> {
  @override
  Widget build(BuildContext context) {
    return _DirectoryNode(
      directory: widget.projectDirectory,
      onFileSelected: widget.onFileSelected,
      isRoot: true,
    );
  }
}

class _DirectoryNode extends StatefulWidget {
  final Directory directory;
  final Function(File) onFileSelected;
  final bool isRoot;

  const _DirectoryNode({
    required this.directory,
    required this.onFileSelected,
    this.isRoot = false,
  });

  @override
  State<_DirectoryNode> createState() => _DirectoryNodeState();
}

class _DirectoryNodeState extends State<_DirectoryNode> {
  List<FileSystemEntity> _entities = [];
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.isRoot) {
      _isExpanded = true;
      _loadDirectory();
    }
  }

  void _loadDirectory() {
    if (!widget.directory.existsSync()) return;

    final items = widget.directory.listSync();
    items.sort((a, b) {
      if (a is Directory && b is File) return -1;
      if (a is File && b is Directory) return 1;
      return a.path.compareTo(b.path);
    });

    setState(() {
      _entities = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRoot) {
      return ListView.builder(
        itemCount: _entities.length,
        itemBuilder: (context, index) {
          return _buildEntity(_entities[index]);
        },
      );
    }

    final name = p.basename(widget.directory.path);
    final isImportant = name == 'lib' || name == 'assets' || name == 'pubspec.yaml';
    final textStyle = TextStyle(
      fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
    );

    return ExpansionTile(
      leading: Icon(Icons.folder, color: isImportant ? Colors.blueAccent : Colors.amber),
      title: Text(name, style: textStyle),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
          if (expanded && _entities.isEmpty) {
            _loadDirectory();
          }
        });
      },
      children: _entities.map(_buildEntity).toList(),
    );
  }

  Widget _buildEntity(FileSystemEntity entity) {
    if (entity is Directory) {
      return _DirectoryNode(
        directory: entity,
        onFileSelected: widget.onFileSelected,
      );
    } else {
      final name = p.basename(entity.path);
      final isImportant = name == 'pubspec.yaml';
      final textStyle = TextStyle(
        fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
      );

      return ListTile(
        contentPadding: EdgeInsets.only(left: widget.isRoot ? 16.0 : 32.0),
        leading: Icon(
          Icons.insert_drive_file,
          color: name.endsWith('.dart') ? Colors.blue : Colors.grey,
        ),
        title: Text(name, style: textStyle),
        onTap: () => widget.onFileSelected(entity as File),
      );
    }
  }
}
