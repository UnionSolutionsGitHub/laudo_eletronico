import 'dart:io';

import 'package:flutter_native_image/flutter_native_image.dart';

class CompressImage {
  static Future<File> compress(String path, {int width = 120}) async {
    final properties = await FlutterNativeImage.getImageProperties(path);

    return await FlutterNativeImage.compressImage(
      path,
      targetWidth: width,
      targetHeight: (properties.height * width / properties.width).round(),
      percentage: 30,
      quality: 70,
    );
  }
}
