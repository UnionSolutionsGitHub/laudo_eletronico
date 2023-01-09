import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:laudo_eletronico/infrastructure/injector.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/local_resources.dart';
import 'package:laudo_eletronico/view/tutorial/custom_slide.dart';

class NewFlowTutorialView extends StatelessWidget {
  final List<Slide> slides = [];

  NewFlowTutorialView();

  List<Widget> _buildSlides(BuildContext context) {
    final customSlides = <Widget>[];

    final tab1 = CustomSlide(
      upperWidget: Image.asset(
        'assets/images/tutorial/tutorial1.png',
      ),
      lowerWidget: Text(
        'O aplicativo está com melhorias!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.tutorialBackgroundBlue,
    );
    customSlides.add(tab1);

    final tab2 = CustomSlide(
      upperWidget: Image.asset(
        'assets/images/tutorial/tutorial2.png',
        fit: BoxFit.fitWidth,
      ),
      lowerWidget: Text(
        'Agora, os itens do laudo podem ser agrupados pelas partes do veículo.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: AppColors.darkBlue,
        ),
      ),
      backgroundColor: AppColors.tutorialBackgroundGray,
    );
    customSlides.add(tab2);

    final tab3 = CustomSlide(
      upperWidget: Image.asset(
        'assets/images/tutorial/tutorial3.png',
        fit: BoxFit.fitWidth,
      ),
      lowerWidget: AutoSizeText(
        'Por exemplo: selecionando "Para-choque dianteiro", serão mostradas todas as informações referentes a este item.',
        textAlign: TextAlign.center,
        maxFontSize: 16.0,
        minFontSize: 10.0,
        style: TextStyle(
          fontSize: 20,
          color: AppColors.darkBlue,
        ),
      ),
      backgroundColor: AppColors.tutorialBackgroundGray,
    );
    customSlides.add(tab3);

    final tab4 = CustomSlide(
      upperWidget: Image.asset(
        'assets/images/tutorial/tutorial4.png',
        fit: BoxFit.fitWidth,
      ),
      lowerWidget: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: AutoSizeText(
              'Além disso, o status do item será indicado por cores:',
              maxFontSize: 20,
              minFontSize: 8,
              textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.darkBlue,
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      color: AppColors.green,
                      height: 10,
                      width: 10,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Itens obrigatórios preenchidos',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      color: AppColors.red,
                      height: 10,
                      width: 10,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Ainda restam itens a preencher',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      color: AppColors.mediumGray,
                      height: 10,
                      width: 10,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Cartão ainda não foi acessado',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      backgroundColor: AppColors.tutorialBackgroundGray,
    );
    customSlides.add(tab4);

    final tab5 = CustomSlide(
      upperWidget: Image.asset(
        'assets/images/tutorial/tutorial5.png',
        fit: BoxFit.fitWidth,
      ),
      lowerWidget: AutoSizeText(
        'Você pode ativar/desativar a vistoria por partes do veículo nas configurações do aplicativo.',
        maxFontSize: 16,
        minFontSize: 10,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: AppColors.darkBlue,
        ),
      ),
      backgroundColor: AppColors.tutorialBackgroundGray,
    );
    customSlides.add(tab5);

    for (var _ in customSlides) {
      slides.add(Slide());
    }

    return customSlides;
  }

  @override
  Widget build(BuildContext context) {
    final localResources = injector<LocalResources>();
    localResources.tutorialCompleted = true;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    final tabs = _buildSlides(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: IntroSlider(
        slides: slides,
        listCustomTabs: tabs,
        nameNextBtn: 'PRÓXIMO',
        nameDoneBtn: 'FIM',
        nameSkipBtn: 'PULAR',
        isShowSkipBtn: true,
        isShowPrevBtn: true,
        widthDoneBtn: 100,
        widthPrevBtn: 100,
        widthSkipBtn: 100,
        colorSkipBtn: AppColors.transparentBlack,
        colorDoneBtn: AppColors.transparentBlack,
        onDonePress: () {
          Navigator.of(context).pop();
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
          ]);
        },
      ),
    );
  }
}
