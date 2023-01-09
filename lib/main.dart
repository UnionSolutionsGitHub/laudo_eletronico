import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:laudo_eletronico/bll/agendamento_bo.dart';
import 'package:laudo_eletronico/common/widgets/configuration_menu_button.dart';
import 'package:laudo_eletronico/infrastructure/dal/database_context.dart';
import 'package:laudo_eletronico/infrastructure/injector.dart';
import 'package:laudo_eletronico/infrastructure/resources/local_resources.dart';
import 'package:laudo_eletronico/model/user.dart';
import 'package:laudo_eletronico/view/configuration/configuration_view.dart';
import 'package:laudo_eletronico/view/tutorial/new_flow_tutorial_view.dart';

import './presentation/splash_screen/splash_screen_view.dart';
import './presentation/login/login_view.dart';
import './presentation/nova_vistoria/nova_vistoria_view.dart';
import './presentation/vistorias_pendentes/vistorias_pendentes_view.dart';
import './infrastructure/resources/colors.dart';
import './infrastructure/resources/globalization_strings_delegates.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'bloc/configuration/configuration_bloc.dart';
import 'common/widgets/laudo_error_widget.dart';

void main() async {
  //debugPaintSizeEnabled = true;
  await setupInjector();
  runApp(LaudoEletronico());
}

final routes = {
  Routes.MAIN: (context) => SplashScreenView(),
  Routes.LOGIN: (context) => LoginView(),
  Routes.NOVA_VISTORIA: (context) => NovaVistoriaView(
        configMenu: ConfigurationMenuButton(),
      ),
  Routes.VISTORIAS_PENDENTES: (context) => VistoriasPendentesView(
        configMenu: ConfigurationMenuButton(),
      ),
  Routes.CONFIGURATION: (context) =>
      ConfigurationView(bloc: injector<ConfigurationBloc>()),
  Routes.TUTORIAL: (context) => NewFlowTutorialView(),
};

final suportedLocales = [const Locale('pt', 'BR'), const Locale('en', 'US')];
final RouteObserver<PageRoute> routeObserver = new RouteObserver<PageRoute>();

class LaudoEletronico extends StatelessWidget {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  LaudoEletronico() {
    DatabaseContext().init();
  }

  _configureErrorWidget() {
    ErrorWidget.builder = (error) {
      return LaudoErrorWidget();
    };
  }

  @override
  Widget build(BuildContext context) {
    _configureErrorWidget();

    firebaseMessaging.configure(onMessage: (map) async {
      LocalResources localResources = await LocalResources().instance();
      final user = User.fromToken(localResources?.token);

      AgendamentoBO().checkAgendamentos(user);

      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          new FlutterLocalNotificationsPlugin();
      var initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: (s) {});

      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          'CHANNEL_ID', 'CHANNEL_NAME', 'CHANNEL_DESCRIPTION',
          importance: Importance.Max, priority: Priority.High);
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      var platformChannelSpecifics = new NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          0,
          map["notification"]["title"],
          map["notification"]["body"],
          platformChannelSpecifics);
    });

    return MaterialApp(
      title: "Laudo Eletrônico",
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Color.fromARGB(255, 240, 240, 240),
      ),
      routes: routes,
      navigatorObservers: <NavigatorObserver>[routeObserver],
      supportedLocales: suportedLocales,
      localizationsDelegates: [
        const LocalizationStringsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      localeResolutionCallback:
          (Locale locale, Iterable<Locale> supportedLocales) {
        for (Locale supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode ||
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}

class Routes {
  static const String MAIN = "/";
  static const String LOGIN = "/login";
  static const String NOVA_VISTORIA = "/nova_vistoria";
  static const String CONFIGURATION = "/configuration";
  static const String TUTORIAL = "/tutorial";
  static const String VISTORIAS_PENDENTES = "/vistorias_pendentes";
}
