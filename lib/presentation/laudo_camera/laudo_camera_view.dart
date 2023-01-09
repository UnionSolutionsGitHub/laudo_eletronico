import 'dart:ui';

//import 'package:camera/torch.dart';
import 'package:fab_menu/fab_menu.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:laudo_eletronico/common/widgets/configuration_menu_button.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/main.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/presentation/vistorias_pendentes/vistorias_pendentes_view.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import './laudo_camera_contract.dart';
import './laudo_camera_presenter.dart';
import './widgets/laudo_camera_tabview.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class LaudoCameraView extends StatefulWidget {
  final Laudo _laudo;
  final bool _popToRoot;
  final ItemConfiguration photo;

  LaudoCameraView(this._laudo, this._popToRoot, {this.photo});

  @override
  _LaudoCameraViewState createState() => _LaudoCameraViewState();
}

class _LaudoCameraViewState extends State<LaudoCameraView> with SingleTickerProviderStateMixin, RouteAware, WidgetsBindingObserver implements LaudoCameraViewContract {
  LaudoCameraPresenterContract _presenter;
  bool _isCameraChanging = false;

  @override
  void initState() {
    _presenter = LaudoCameraPresenter(
      this,
      this.widget._laudo,
      photo: this.widget.photo,
    );

    loadCamera();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    routeObserver.unsubscribe(this);
    _presenter.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        _presenter.onAppEnterBackground();
        break;
      case AppLifecycleState.resumed:
        _presenter.resumeFromBackground();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.suspending:
        break;
    }
  }

  @override
  void didPopNext() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _presenter.resumeFromBackground();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didPushNext() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _presenter.cameraCancelTimeout();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future loadCamera() async {
    if (_isCameraChanging) {
      return;
    }

    await _presenter?.cameraController?.dispose();

    _isCameraChanging = true;
    var cameras = await availableCameras();
    //final flash = _presenter?.cameraController?.isFlashOn ?? false;
    final flash = false;
    _presenter.cameraController = CameraController(
      cameras.firstWhere((camera) {
        final lensDirection = _presenter.isCameraTimedOut == true || _presenter.cameraDisposed == true && _presenter?.cameraController?.description != null
            ? _presenter.cameraController.description.lensDirection
            : _presenter.cameraController?.description?.lensDirection != CameraLensDirection.back ? CameraLensDirection.back : CameraLensDirection.front;

        return camera.lensDirection == lensDirection;
      }),
      ResolutionPreset.high,
    );

   // _presenter.cameraController.isFlashOn = flash;

    _presenter?.cameraController?.initialize()?.then((_) {
      if (!mounted) {
        return;
      }

      this.setState(() {
       // _presenter.cameraController.zoon(_presenter.zoon);
        SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        _isCameraChanging = false;
        _presenter.isCameraTimedOut = false;
      });
    })?.whenComplete(() async {
      _presenter.cameraStartTimeout();
    });
  }

  Future<bool> _onBackPressed() async {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            GlobalizationStrings.of(this.context).value("alert_title_warning"),
          ),
          content: Text(
            GlobalizationStrings.of(this.context).value("laudo_camera_alert_laudo_will_popback"),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                GlobalizationStrings.of(this.context).value("alert_button_negative"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                GlobalizationStrings.of(this.context).value("alert_button_positive"),
              ),
              onPressed: () {
                Navigator.of(context).pop();

                if (!this.widget._popToRoot) {
                  Navigator.of(context).pop();
                  return;
                }

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (BuildContext context) => VistoriasPendentesView(
                          configMenu: ConfigurationMenuButton(),
                        ),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_presenter.cameraController?.value?.isInitialized != true) {
      return Container();
    }

    final size = MediaQuery.of(context).size;

    if (_presenter.isLoading) {
      return MaterialApp(
        home: Stack(
          children: <Widget>[
            _camera(size),
            CircularProgressIndicator(),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: OrientationBuilder(builder: (ctx, orientation) {
        return GestureDetector(
          /*onTapUp: (TapUpDetails details) async {
            await _presenter?.cameraController?.focus(details.globalPosition.dx, details.globalPosition.dy);
          },*/
          onTap: () {
            _presenter.cameraRenewTimeout();
          },
          child: MaterialApp(
            home: DefaultTabController(
              length: _presenter.items.length,
              child: Stack(
                children: <Widget>[
                  _camera(size),
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                    alignment: Alignment(-1, -1),
                    child: Icon(
                      _presenter.cameraController.description.lensDirection == CameraLensDirection.back ? Icons.camera_front : Icons.camera_rear,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.only(bottom: 75),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 80,
                            child: new RawMaterialButton(
                              shape: new CircleBorder(
                                side: BorderSide(
                                  width: 5,
                                  color: AppColors.primary,
                                ),
                              ),
                              elevation: 1.0,
                              onPressed: null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  LaudoCameraTabView(
                    size,
                    _presenter,
                    loadCamera,
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: RaisedButton(
                        color: AppColors.primary,
                        textColor: Colors.white,
                        disabledColor: AppColors.disabled,
                        child: Text(
                          GlobalizationStrings.of(context).value("btn_next_step"),
                        ),
                        onPressed: _presenter.onBtnNextStepClickListener,
                      ),
                    ),
                  ),
                  _presenter.isCameraTimedOut == true
                      ? SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: RaisedButton(
                            child: Text(
                              GlobalizationStrings.of(context).value("laudo_camera_label_reactive_camera"),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: this.loadCamera,
                            color: Colors.transparent,
                          ),
                        )
                      : Container(),
                  _presenter.showMenu ?? false
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(),
                            ),
                            Column(
                              children: <Widget>[
                                Expanded(
                                  child: Container(),
                                ),
                                Expanded(
                                  child: FlutterSlider(
                                    tooltip: FlutterSliderTooltip(disabled: true),
                                    values: [_presenter.zoon.toDouble()],
                                    max: 40,
                                    min: 0,
                                    rtl: true,
                                    axis: Axis.vertical,
                                    onDragging: (handlerIndex, lowerValue, upperValue) {
                                      _presenter.zoon = lowerValue.round();
                                     // _presenter.cameraController.zoon(_presenter.zoon);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: Container(),
                                ),
                              ],
                            )
                          ],
                        )
                      : Container(),
                  _presenter.showMenu ?? false
                      ? Container(
                          alignment: Alignment.bottomRight,
                          margin: EdgeInsets.only(bottom: 15),
                          child: FabMenu(
                            mainIcon: Icons.menu,
                            maskColor: Colors.transparent,
                            labelBackgroundColor: Colors.black38,
                            labelTextColor: Colors.white,
                            menuButtonColor: Colors.white,
                            menuButtonBackgroundColor: Color.fromRGBO(232, 98, 23, 1.0),
                            mainButtonBackgroundColor: Color.fromRGBO(232, 98, 23, 1.0),
                            menus: [
                             /* MenuData(
                                _presenter.cameraController.isFlashOn ? Icons.flash_on : Icons.flash_off,
                                (c, m) => this.setState(
                                      () => _presenter.cameraController.isFlashOn = !_presenter.cameraController.isFlashOn,
                                    ),
                                labelText: "Flash",
                              ),*/
                              MenuData(
                                Icons.add,
                                (c, m) => _presenter.additionalPhotos ? _presenter.onBttnAddPhotoClickListener() : null,
                                labelText: GlobalizationStrings.of(context).value("laudo_camera_label_menu_additional_photo"),
                              ),
                              MenuData(
                                _presenter.isShowingWatermark ? MdiIcons.waterOff : MdiIcons.water,
                                (c, m) => _presenter.onBttnWatermarkClickListener(),
                                labelText: GlobalizationStrings.of(context).value("laudo_camera_label_menu_watermark"),
                              ),
                              MenuData(
                                Icons.photo_library,
                                (c, m) => _presenter.addFromGallery(),
                                labelText: GlobalizationStrings.of(context).value("Buscar Imagem"),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _camera(Size size) {
    final deviceRatio = size.width / (size.height - 60);

    return Container(
      alignment: Alignment.topCenter,
      height: size.height - 60,
      child: Transform.scale(
        scale: _presenter.cameraController.value.aspectRatio / deviceRatio,
        child: Center(
          child: AspectRatio(
            aspectRatio: _presenter.cameraController.value.aspectRatio,
            child: CameraPreview(_presenter.cameraController),
          ),
        ),
      ),
    );
  }

  @override
  showAlertLaudoFinished() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            GlobalizationStrings.of(this.context).value("laudo_camera_alert_laudo_finished_title"),
          ),
          content: Text(
            GlobalizationStrings.of(this.context).value("laudo_camera_alert_laudo_finished"),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                GlobalizationStrings.of(this.context).value("laudo_camera_alert_laudo_finished_btn_next"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _presenter.goNextStep();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  navigatorPush(MaterialPageRoute route) {
    Navigator.push(context, route);
  }

  @override
  notifyDataChanged() {
    this.setState(() {});
  }

  @override
  showAlertWannaFinish() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            GlobalizationStrings.of(this.context).value("alert_title_warning"),
          ),
          content: Text(
            GlobalizationStrings.of(this.context).value("laudo_camera_alert_laudo_finished"),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                GlobalizationStrings.of(this.context).value("laudo_camera_alert_laudo_finished_btn_next"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _presenter.goNextStep();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  showAlertCantGoNextStep() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            GlobalizationStrings.of(this.context).value("alert_title_warning"),
          ),
          content: Text(
            GlobalizationStrings.of(this.context).value("laudo_camera_alert_cant_go_next_step"),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                GlobalizationStrings.of(this.context).value("alert_button_ok"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
