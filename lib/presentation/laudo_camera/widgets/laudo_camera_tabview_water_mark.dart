import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class LaudoCameraTabViewWaterMark extends StatelessWidget {
  final String _watermark;

  LaudoCameraTabViewWaterMark(this._watermark);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        child: StreamBuilder<NativeDeviceOrientation>(
          stream: NativeDeviceOrientationCommunicator(useSensor: true).onOrientationChanged,
          initialData: NativeDeviceOrientation.portraitUp,
          builder: (streamContext, AsyncSnapshot<NativeDeviceOrientation> snapshot) {
            if (snapshot.data == NativeDeviceOrientation.landscapeRight) {
              return RotationTransition(
                turns: AlwaysStoppedAnimation(-90 / 360),
                child: _loadImage(),
              );
            }

            if (snapshot.data == NativeDeviceOrientation.landscapeLeft) {
              return RotationTransition(
                turns: AlwaysStoppedAnimation(90 / 360),
                child: _loadImage(),
              );
            }
            
            return _loadImage();
          },
        ),
      ),
    );
  }

  Widget _loadImage() {
    try {
      return Image.asset(
        "./assets/images/water_marks/$_watermark.png",
        color: Colors.amber,
      );
    } catch (e) {
      return Container();
    }
  }
}
