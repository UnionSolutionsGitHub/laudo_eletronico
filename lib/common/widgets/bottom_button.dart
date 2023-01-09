import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';

class BottomButton extends StatelessWidget {
  final String stringsKey;
  final Function onClick;
  final bool isEnabled;

  BottomButton({
    this.stringsKey: "Unknown",
    this.onClick,
    this.isEnabled
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          color: AppColors.primary,
          textColor: Colors.white,
          disabledColor: AppColors.disabled,
          child: Text(
            GlobalizationStrings.of(context).value(this.stringsKey),
          ),
          onPressed: this.isEnabled == true ? this.onClick ?? (){} : null,
        ),
      ),
    );
  }
}

// class BottomButton extends StatefulWidget {
//   final String stringsKey;
//   final Function onClick;

//   BottomButton({
//     this.stringsKey: "Unknown",
//     this.onClick,
//   });

//   @override
//   _BottomButtonState createState() => _BottomButtonState();
// }

// class _BottomButtonState extends State<BottomButton> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.bottomCenter,
//       child: SizedBox(
//         width: double.infinity,
//         height: 60,
//         child: RaisedButton(
//           color: AppColors.primary,
//           textColor: Colors.white,
//           disabledColor: AppColors.disabled,
//           child: Text(
//             GlobalizationStrings.of(context).value(this.widget.stringsKey),
//           ),
//           onPressed: this.widget.onClick,
//         ),
//       ),
//     );
//   }
// }
