import 'package:flutter/material.dart';
import 'package:laudo_eletronico/common/widgets/gallery_corner_button.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/dimens.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AlbumCard extends StatelessWidget {
  final Widget child;
  final Widget emptyBackground;
  final Function onCornerButtonPressed;
  final Function onTap;
  final double width;
  final double height;
  final bool isMandatory;

  /// Texto abaixo do cartão
  final String text;

  AlbumCard({
    this.child,
    this.emptyBackground,
    this.onCornerButtonPressed,
    this.onTap,
    this.text,
    @required this.width,
    @required this.height,
    this.isMandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Container(
            height: height,
            width: width,
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              color: Colors.white,
              elevation: 3.0,
              child: child != null ? child : _buildContent(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(halfSpace),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text ?? '',
                style: TextStyle(color: AppColors.darkBlue),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    double radius = (width / 2) * 0.9;
    return Stack(
      children: <Widget>[
        isMandatory
            ? Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(halfSpace),
                  child: Icon(
                    MdiIcons.alertCircleOutline,
                    color: Colors.red,
                  ),
                ),
              )
            : Container(),
        Center(
          child: emptyBackground != null
              ? Center(child: emptyBackground)
              : _buildAddPhotoButton(),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            height: radius,
            width: radius,
            child: GalleryCornerButton(
              icon: Icons.add_photo_alternate,
              radius: radius,
              onPressed: onCornerButtonPressed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    final addPhotoButtonSize = 0.5 * this.width;

    return Padding(
      padding: EdgeInsets.only(bottom: this.width * 0.2),
      child: Container(
        child: Icon(
          Icons.add_a_photo,
          color: Colors.white,
          size: addPhotoButtonSize * 0.6,
        ),
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          shape: BoxShape.circle,
        ),
        width: addPhotoButtonSize,
        height: addPhotoButtonSize,
      ),
    );
  }
}
