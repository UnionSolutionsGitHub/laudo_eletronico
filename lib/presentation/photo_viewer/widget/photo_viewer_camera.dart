import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/presentation/photo_viewer/photo_viewer_contract.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PhotoViewerCamera extends StatelessWidget {
  final BuildContext _context;
  final PhotoViewerPresenterContract _presenter;
  final Function _flashlight;

  PhotoViewerCamera(this._presenter, this._context, this._flashlight);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
		resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          GlobalizationStrings.of(_context)?.value("foto_adcional_appbar_title"),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(_context).pop();
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: TextField(
              controller: _presenter.controller.txfdPhotoDescriptionController,
              decoration: new InputDecoration(
                prefixIcon: Icon(MdiIcons.messageTextOutline),
                labelText: GlobalizationStrings.of(_context).value("foto_adcional_txfd_photo_description"),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  child: CameraPreview(_presenter.controller.cameraController),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(bottom: 20),
                  width: double.infinity,
                  child: Container(
                    height: 80,
                    child: new RawMaterialButton(
                      shape: new CircleBorder(
                          side: BorderSide(
                        width: 5,
                        color: AppColors.primary,
                      )),
                      elevation: 1.0,
                      onPressed: _presenter.onBtnTakePictureClickListener,
                    ),
                  ),
                ),
               /* Container(
                  alignment: Alignment.bottomRight,
                  margin: EdgeInsets.only(right: 15),
                  width: double.infinity,
                  child: Container(
                    height: 80,
                    child: new IconButton(
                      icon: !_presenter.controller.cameraController.isFlashOn
                          ? Icon(Icons.flash_off, color: Colors.white,)
                          : Icon(Icons.flash_on, color: Colors.white,),
                      onPressed: () => _flashlight(),
                    ),
                  ),
                ),*/
				Container(
					alignment: Alignment.bottomLeft,
					margin: EdgeInsets.only(left: 15),
					width: double.infinity,
					child: Container(
						height: 80,
						child: new IconButton(
							icon: Icon(Icons.photo_library, color: Colors.white,),
							onPressed: () => _presenter.addFromGallery(),
						),
					),
				),
				Row(
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
											//_presenter.controller.cameraController.zoon(_presenter.zoon);
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
