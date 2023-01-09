import 'package:flutter/material.dart';
import 'package:laudo_eletronico/common/widgets/quarter_circle.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';

class GalleryCornerButton extends StatelessWidget {
  final double radius;
  final IconData icon;
  final Function onPressed;

  GalleryCornerButton({
    @required this.radius,
    @required this.icon,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RawMaterialButton(
        splashColor: Colors.transparent,
        onPressed: onPressed,
        child: Stack(
          children: <Widget>[
            QuarterCircle(
              color: AppColors.offwhiteBackground,
              circleAlignment: CircleAlignment.bottomRight,
            ),
            Container(
              margin: EdgeInsets.all(radius / 4),
              child: Icon(icon, size: radius / 1.5, color: AppColors.offwhiteIcon,),
            ),
          ],
        ),
      ),
    );
  }
}
