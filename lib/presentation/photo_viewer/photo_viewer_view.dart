import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/model/additional_photo.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/presentation/photo_viewer/photo_viewer_contract.dart';
import 'package:laudo_eletronico/presentation/photo_viewer/photo_viewer_presenter.dart';
import 'package:laudo_eletronico/presentation/photo_viewer/widget/photo_viewer_tabview_item.dart';

class PhotoViewerView extends StatefulWidget {
  final Laudo _laudo;
  final AdditionalPhoto photo;

  PhotoViewerView(this._laudo, {this.photo});

  @override
  _PhotoViewerViewState createState() => _PhotoViewerViewState();
}

class _PhotoViewerViewState extends State<PhotoViewerView> with SingleTickerProviderStateMixin, WidgetsBindingObserver implements PhotoViewerViewContract {
  PhotoViewerPresenterContract _presenter;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _presenter = PhotoViewerPresenter(this, this, this.widget._laudo, photo: this.widget.photo);
    _loadCamera();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _presenter.controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        await _presenter.controller?.cameraController?.dispose();
        break;
      case AppLifecycleState.resumed:
        await _loadCamera();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.suspending:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_presenter?.controller?.cameraController?.value?.isInitialized != true) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            GlobalizationStrings.of(context).value("foto_adcional_appbar_title"),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MaterialApp(
      home: DefaultTabController(
        length: _presenter.photosLength,
        child: PhotoViewerTabviewItem(
          _presenter,
          context,
          () => {}
              /*this.setState(
                () => _presenter.controller.cameraController.isFlashOn = !_presenter.controller.cameraController.isFlashOn,
              ),*/
        ),
      ),
    );
  }

  @override
  notifyDataChanged() {
    this.setState(() {});
  }

  Future _loadCamera() async {
    await _presenter.controller?.cameraController?.dispose();

    var cameras = await availableCameras();
    _presenter.controller.cameraController = CameraController(
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back),
      ResolutionPreset.high,
    );
    //_presenter.controller.cameraController.isFlashOn = false;

    _presenter.controller.cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }

      this.setState(() {});
    });
  }
}
