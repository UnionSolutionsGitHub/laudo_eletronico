import 'dart:io';

import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/dimens.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:laudo_eletronico/model/item_configuration_type.dart';
import 'package:laudo_eletronico/model/summary_item.dart';

/// Card element used in the new summary page (SummaryView)
class SummaryCard extends StatelessWidget {
  final SummaryItem item;
  final double width;
  final double height;
  final Function onTap;
  final String photoPath;
  final String description;
  final _ColorPalette palette;

  SummaryCard({
    @required this.item,
    @required this.width,
    @required this.height,
    @required this.onTap,
    @required this.description,
    this.photoPath,
  }) : palette = _ColorPalette(item.status);

  bool get _photoCanBeAdded =>
      item.itemConfigurations.any((itemConfiguration) =>
          itemConfiguration.type == ItemConfigurationType.FOTO);

  bool get _isMandatory => item.itemConfigurations
      .any((itemConfiguration) => itemConfiguration.isMandatory);

  //_ColorPalette get colorPalette =>

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: ContinuousRectangleBorder(),
          color: Colors.white,
          elevation: 3.0,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildColoredHeader(),
        _buildPhotoArea(),
        _buildDescriptionArea(),
        _buildFooter(),
      ],
    );
  }

  Align _buildColoredHeader() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 5,
        color: palette.headerColor,
      ),
    );
  }

  Expanded _buildPhotoArea() {
    final iconSize = width * 0.25;
    final greyIconSize = iconSize * 0.85;
    return Expanded(
      flex: 1,
      child: Container(
        width: width,
        child: photoPath != null
            ? Image.file(
                File(photoPath),
                fit: BoxFit.cover,
              )
            : Container(
                color: palette.photoBackgroundColor,
                child: Center(
                  child: _photoCanBeAdded
                      ? Icon(
                          Icons.add_a_photo,
                          color: Colors.blue,
                          size: iconSize,
                        )
                      : Image.asset(
                          'assets/images/icons/no_photo.png',
                          height: greyIconSize,
                          width: greyIconSize,
                        ),
                ),
              ),
      ),
    );
  }

  Expanded _buildDescriptionArea() {
    return Expanded(
      flex: 1,
      child: Container(
        color: palette.descriptionBackgroundColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: halfSpace),
          child: Center(
            child: AutoSizeText(
              description,
              textAlign: TextAlign.center,
              maxLines: 3,
              maxFontSize: 16.0,
              minFontSize: 10.0,
              wrapWords: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Align _buildFooter() {
    final footerHeight = height * 0.15;
    final iconSize = height * 0.12;
    final margin = footerHeight * 0.2;
    final smallMargin = footerHeight * 0.1;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: palette.descriptionBackgroundColor,
        height: footerHeight,
        child: Padding(
          padding: EdgeInsets.only(
            left: margin,
            right: margin,
            bottom: margin,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _isMandatory
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: smallMargin,
                        left: smallMargin,
                      ),
                      child: Text(
                        '*',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: iconSize,
                          color: AppColors.red,
                        ),
                      ),
                    )
                  : Container(),
              Spacer(),
              item.status == SummaryItemStatus.complete
                  ? Icon(
                      Icons.check_circle_outline,
                      size: iconSize,
                      color: Colors.green,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorPalette {
  final Color photoBackgroundColor = AppColors.lightGray;
  final Color headerColor;
  final Color descriptionBackgroundColor;

  _ColorPalette(SummaryItemStatus status)
      : headerColor = _headerColor(status),
        descriptionBackgroundColor = _descriptionBackgroundColor(status);

  static Color _headerColor(SummaryItemStatus status) {
    switch (status) {
      case SummaryItemStatus.notVisited:
        return AppColors.mediumGray;
      case SummaryItemStatus.incomplete:
        return AppColors.red;
      case SummaryItemStatus.acceptable:
      case SummaryItemStatus.complete:
        return AppColors.green;
      default:
        return AppColors.mediumGray;
    }
  }

  static Color _descriptionBackgroundColor(SummaryItemStatus status) {
    switch (status) {
      case SummaryItemStatus.complete:
      case SummaryItemStatus.acceptable:
        return AppColors.lightGreen;
      case SummaryItemStatus.incomplete:
        return AppColors.lightRed;
      case SummaryItemStatus.notVisited:
      default:
        return Colors.white;
    }
  }
}
