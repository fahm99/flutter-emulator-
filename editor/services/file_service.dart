// Flutter IDE Mobile - File Service

import 'dart:async';
import '../../core/models/file_entity.dart';

/// Virtual File System Service
/// Manages the in-memory file system for the editor
class FileService {
  FileSystemTree _fileSystem;
  final _fileSystemController = StreamController<FileSystemTree>.broadcast();
  
  FileService() : _fileSystem = FileSystemTree.defaultProject() {
    _fileSystemController.add(_fileSystem);
  }

  /// Stream of file system changes
  Stream<FileSystemTree> get fileSystemStream => _fileSystemController.stream;

  /// Get current file system
  FileSystemTree get fileSystem => _fileSystem;

  /// Get file by path
  FileEntity? getFile(String path) => _fileSystem.findByPath(path);

  /// Get file by ID
  FileEntity? getFileById(String id) => _fileSystem.findById(id);

  /// Get all Dart files
  List<FileEntity> get dartFiles => _fileSystem.dartFiles;

  /// Create a new file
  Future<FileEntity> createFile({
    required String name,
    required String path,
    String content = '',
  }) async {
    final id = 'file_${DateTime.now().millisecondsSinceEpoch}';
    final file = FileEntity.file(
      id: id,
      name: name,
      path: path,
      content: content,
    );
    
    _fileSystem = _fileSystem.updateFile(file);
    _fileSystemController.add(_fileSystem);
    
    return file;
  }

  /// Create a new Dart file
  Future<FileEntity> createDartFile({
    required String name,
    required String path,
    String? className,
  }) async {
    final id = 'file_${DateTime.now().millisecondsSinceEpoch}';
    final file = FileEntity.dartFile(
      id: id,
      name: name,
      path: path,
      className: className,
    );
    
    _fileSystem = _fileSystem.updateFile(file);
    _fileSystemController.add(_fileSystem);
    
    return file;
  }

  /// Update file content
  Future<FileEntity> updateFileContent(String path, String content) async {
    final file = _fileSystem.findByPath(path);
    if (file == null) {
      throw Exception('File not found: $path');
    }
    
    final updatedFile = file.copyWith(
      content: content,
      isDirty: true,
      modifiedAt: DateTime.now(),
    );
    
    _fileSystem = _fileSystem.updateFile(updatedFile);
    _fileSystemController.add(_fileSystem);
    
    return updatedFile;
  }

  /// Save file (mark as not dirty)
  Future<FileEntity> saveFile(String path) async {
    final file = _fileSystem.findByPath(path);
    if (file == null) {
      throw Exception('File not found: $path');
    }
    
    final savedFile = file.copyWith(
      isDirty: false,
      modifiedAt: DateTime.now(),
    );
    
    _fileSystem = _fileSystem.updateFile(savedFile);
    _fileSystemController.add(_fileSystem);
    
    return savedFile;
  }

  /// Delete a file
  Future<void> deleteFile(String path) async {
    // For now, we just mark it as deleted by removing from map
    final newMap = Map<String, FileEntity>.from(_fileSystem.fileMap);
    newMap.remove(path);
    
    _fileSystem = FileSystemTree(
      roots: _fileSystem.roots,
      fileMap: newMap,
    );
    _fileSystemController.add(_fileSystem);
  }

  /// Create a new directory
  Future<FileEntity> createDirectory({
    required String name,
    required String path,
  }) async {
    final id = 'dir_${DateTime.now().millisecondsSinceEpoch}';
    final dir = FileEntity.directory(
      id: id,
      name: name,
      path: path,
    );
    
    // Add to file system (simplified - just add to roots for now)
    final newRoots = List<FileEntity>.from(_fileSystem.roots)..add(dir);
    final newMap = Map<String, FileEntity>.from(_fileSystem.fileMap);
    newMap[path] = dir;
    
    _fileSystem = FileSystemTree(roots: newRoots, fileMap: newMap);
    _fileSystemController.add(_fileSystem);
    
    return dir;
  }

  /// Mark all files as saved
  Future<void> saveAllFiles() async {
    final newMap = <String, FileEntity>{};
    
    for (final entry in _fileSystem.fileMap.entries) {
      if (entry.value.isDirty) {
        newMap[entry.key] = entry.value.copyWith(
          isDirty: false,
          modifiedAt: DateTime.now(),
        );
      } else {
        newMap[entry.key] = entry.value;
      }
    }
    
    _fileSystem = FileSystemTree(roots: _fileSystem.roots, fileMap: newMap);
    _fileSystemController.add(_fileSystem);
  }

  /// Dispose the service
  void dispose() {
    _fileSystemController.close();
  }
}

/// File change event
class FileChangeEvent {
  final FileEntity file;
  final FileChangeType type;

  const FileChangeEvent({
    required this.file,
    required this.type,
  });
}

/// File change types
enum FileChangeType {
  created,
  modified,
  saved,
  deleted,
}