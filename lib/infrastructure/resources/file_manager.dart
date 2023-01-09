import 'dart:io';

import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:laudo_eletronico/common/compress_imagem.dart';
import 'package:path_provider/path_provider.dart';

class FileManager {
  static Directory _directory;

  FileManager._internal();

  static final FileManager _instance = FileManager._internal();

  static final imageFormat = '.jpg';
  static final thumbnailSufix = "_thumbnail";

  static Future<FileManager> get instance async {
    _directory = await getApplicationDocumentsDirectory();
    return _instance;
  }

  String _getNewFilePath() => "${_directory.path}/${DateTime.now().toIso8601String()}$imageFormat";

  String getThumbnailPath(String imagePath) => "${imagePath.split(imageFormat).first}$thumbnailSufix$imageFormat";

  /// Used to compress an image, located in [originalImagePath] taken by the camera and generate
  /// its thumbnail. Returns the compressed image.
  Future<File> compressImageAndThumbnail(String originalImagePath) async {
    final photoProperties = await FlutterNativeImage.getImageProperties(originalImagePath);
    final photowidth = photoProperties.width > photoProperties.height ? 1024 : 768;
    final image = await CompressImage.compress(originalImagePath, width: photowidth);

    final newImagePath = _getNewFilePath();
    File(newImagePath).writeAsBytesSync(image.readAsBytesSync());

    final thumbnail = await CompressImage.compress(originalImagePath);
    File(getThumbnailPath(newImagePath)).writeAsBytesSync(thumbnail.readAsBytesSync());

    return File(newImagePath);
  }

  String thumbnailPath(String path) => path.replaceFirst(imageFormat, "$thumbnailSufix$imageFormat");
}