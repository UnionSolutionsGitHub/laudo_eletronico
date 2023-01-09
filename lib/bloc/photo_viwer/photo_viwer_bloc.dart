import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class PhotoViwerBloc extends BlocBase {
  final _fileDescription = BehaviorSubject<String>();
  final _file = BehaviorSubject<File>();

  Function(String) _onDeleted;

  PhotoViwerBloc({
    fileDescription,
    @required filePath,
    @required Function(String) onDeleted,
  }): assert(filePath != null && filePath != "" && onDeleted != null) {
    _fileDescription.add(fileDescription);

    final file = File.fromUri(Uri.file(filePath));
    _file.add(file);

    _onDeleted = onDeleted;
  }

  Stream<String> get fileDescriptionStream => _fileDescription.stream;
  Stream<File> get fileStream => _file.stream;

  Future deletePhoto() async {
    final fileName = _file.value.path.split('/').last;
    
    try {
      _file.value.delete();
      await _onDeleted(fileName);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void dispose() {
    _fileDescription.close();
    _file.close();

    super.dispose();
  }
}