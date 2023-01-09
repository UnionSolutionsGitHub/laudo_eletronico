import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';

class AddDescriptionBloc extends BlocBase {
  final _description = BehaviorSubject<String>();
  final _takingPhoto = BehaviorSubject.seeded(false);

  final ImageSource source;

  final Future Function(ImageSource source, {String description})
      _takeNewAdditionalPhoto;

  ///
  /// Inputs
  ///
  Function get onDescriptionChanged => _description.sink.add;

  ///
  /// Outputs
  ///
  IconData get buttonIcon => source == ImageSource.camera
      ? Icons.add_a_photo
      : Icons.add_photo_alternate;
  
  Stream<bool> get takingPhoto => _takingPhoto.stream;

  AddDescriptionBloc(this._takeNewAdditionalPhoto, {@required this.source});

  Future takePicture() async {
    _takingPhoto.sink.add(true);
    return _takeNewAdditionalPhoto(
      source,
      description: _description.value,
    );
  }

  @override
  void dispose() {
    _description.close();
    _takingPhoto.close();
    super.dispose();
  }
}
