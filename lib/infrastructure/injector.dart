import 'package:get_it/get_it.dart';
import 'package:laudo_eletronico/bloc/configuration/configuration_bloc.dart';
import 'package:laudo_eletronico/infrastructure/resources/local_resources.dart';
import 'package:laudo_eletronico/model/user.dart';
import 'package:package_info/package_info.dart';

GetIt injector = GetIt();

setupInjector() async {
  //
  // Dependencies
  //
  final localResources = await LocalResources().instance();
  injector.registerSingleton(localResources);

  final packageInfo = await PackageInfo.fromPlatform();
  injector.registerSingleton(packageInfo);

  injector.registerFactory(() => User.fromToken(localResources.token));

  //
  // Blocs
  //
  injector.registerFactory(() => ConfigurationBloc(
        localResources: injector<LocalResources>(),
        packageInfo: injector<PackageInfo>(),
        user: injector<User>(),
      ));
}
