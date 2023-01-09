import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:laudo_eletronico/common/widgets/search_text_result.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';

class VistoriasPendentesTextColumn extends StatelessWidget {
  final String carPlate, carName, searchText;
  final DateTime startReportDateTime;

  VistoriasPendentesTextColumn({
    @required this.carPlate,
    @required this.carName,
    @required this.startReportDateTime,
    @required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SearchTextResult(
          this.carPlate,
          this.searchText,
          textColor: AppColors.primary,
        ),
        Text(
          this.carName,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12.0,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(
          this.startReportDateTime != null ? DateFormat("dd/MM/yyyy HH:mm").format(this.startReportDateTime) : "",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        // Text(
        //   "17/03/2016 manhã",
        //   style: TextStyle(
        //     color: AppColors.primary,
        //     fontSize: 12.0,
        //   ),
        //   overflow: TextOverflow.ellipsis,
        //   maxLines: 1,
        // ),
        // Text(
        //   "Av. Nossa senhora dos navegantes, 500, Vila Velha, Espírito Santo",
        //   style: TextStyle(
        //     color: AppColors.primary,
        //     fontSize: 12.0,
        //   ),
        //   overflow: TextOverflow.ellipsis,
        //   maxLines: 2,
        // ),
      ],
    );
  }
}
