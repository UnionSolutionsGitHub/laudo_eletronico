import 'package:flutter/material.dart';
import 'package:laudo_eletronico/bloc/additional_photos/add_description_bloc.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/dimens.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';

class AddDescriptionView extends StatelessWidget {
  final AddDescriptionBloc bloc;

  AddDescriptionView({@required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<bool>(
          stream: bloc.takingPhoto,
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.all(defaultMargin),
                        child: TextField(
                          onChanged: bloc.onDescriptionChanged,
                          decoration: InputDecoration(
                            hintText: GlobalizationStrings.of(context).value("foto_adcional_txfd_photo_description"),
                          ),
                        ),
                      ),
                    ),
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
                        child: Icon(bloc.buttonIcon, color: Colors.white,),
                        onPressed: () => bloc.takePicture().then(
                              (val) {
                                Navigator.of(context).pop();
                              },
                            ),
                      ),
                    ),
                  ),
                ],
              );
          }),
    );
  }
}
