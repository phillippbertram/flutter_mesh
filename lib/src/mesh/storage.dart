import 'dart:io';
import 'dart:async';
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:path_provider/path_provider.dart';

abstract class Storage {
  Future<String?> load();
  Future<bool> save(String data);
}

class LocalStorage implements Storage {
  final String fileName;

  LocalStorage({this.fileName = "MeshNetwork.json"});

  @override
  Future<String?> load() async {
    try {
      final file = await _getStorageFile();
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      logger.e("Error loading file: $e");
    }
    return null;
  }

  @override
  Future<bool> save(String data) async {
    try {
      final file = await _getStorageFile();
      await file.writeAsString(data);
      return true;
    } catch (e) {
      logger.e("Error saving file: $e");
      return false;
    }
  }

  Future<File> _getStorageFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }
}
