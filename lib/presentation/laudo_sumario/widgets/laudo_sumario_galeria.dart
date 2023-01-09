import 'dart:io';

import 'package:flutter/material.dart';

//import 'dart:io' as Io;
//import 'package:image/image.dart' as img;

class LaudoSumarioGaleriaFotos extends StatelessWidget {
  //final List<File> _images;
  final List<String> _images;
  final bool isFotoAdicional;
  final Function(int, bool) onTapPhotoListener;

  LaudoSumarioGaleriaFotos(
    this._images, {
    @required this.onTapPhotoListener,
    this.isFotoAdicional = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: _images.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) {
        return _images.length > 0
            ? Container(
                margin: EdgeInsets.all(5),
                child: Card(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      this.onTapPhotoListener(index, this.isFotoAdicional);
                    },
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Image.file(File(_images[index])),
                      ),
                    ),
                  ),
                ),
              )
            : Container();
      },
    );
  }
}
