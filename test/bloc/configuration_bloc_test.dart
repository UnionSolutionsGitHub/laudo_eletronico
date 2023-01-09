import 'package:flutter_test/flutter_test.dart';
import 'package:laudo_eletronico/bloc/configuration/configuration_bloc.dart';
import 'package:mockito/mockito.dart';

import '../mocks.dart';

main() {
  ConfigurationBloc bloc;
  LocalResourcesMock localResourcesMock;
  PackageInfoMock packageInfoMock;
  UserMock userMock;

  setUp(() {
    localResourcesMock = LocalResourcesMock();
    packageInfoMock = PackageInfoMock();
    userMock = UserMock();
    bloc = ConfigurationBloc(
      localResources: localResourcesMock,
      packageInfo: packageInfoMock,
      user: userMock,
    );
  });

  test('When switch is toggled, its state should be saved in LocalResources',
      () {
    //WHEN
    bloc.onSwitchToggled(true);

    //THEN
    verify(localResourcesMock.isNewFlowEnabled = true);
  });

  test(
      'When ConfigurationBloc is initiated, it should pull the value of the flowConfiguration from LocalResources',
      () {
    //GIVEN
    when(localResourcesMock.isNewFlowEnabled).thenReturn(true);

    //WHEN
    bloc = ConfigurationBloc(
      localResources: localResourcesMock,
      packageInfo: packageInfoMock,
      user: userMock,
    );

    //THEN
    verify(localResourcesMock.isNewFlowEnabled);
  });

  test(
      'When ConfigurationBloc is initiated, it should emit the value of the flowConfiguration from LocalResources',
      () {
    //GIVEN
    when(localResourcesMock.isNewFlowEnabled).thenReturn(true);

    //WHEN
    bloc = ConfigurationBloc(
      localResources: localResourcesMock,
      packageInfo: packageInfoMock,
      user: userMock,
    );

    //THEN
    expect(bloc.isNewFlowEnabled, emits(true));
  });

  test(
      'When ConfigurationBloc is initiated, if isNewFlowEnabled is null in LocalResources, it should be set to false',
      () {
    //GIVEN
    when(localResourcesMock.isNewFlowEnabled).thenReturn(null);

    //WHEN
    bloc = ConfigurationBloc(
      localResources: localResourcesMock,
      packageInfo: packageInfoMock,
      user: userMock,
    );

    //THEN
    verify(localResourcesMock.isNewFlowEnabled = false);
    expect(bloc.isNewFlowEnabled, emits(false));
  });

  test('When ConfigurationBloc is initiated, it should get the version number',
      () {
    //GIVEN
    String version = '1.0.0';
    when(packageInfoMock.version).thenReturn(version);

    //WHEN
    bloc = ConfigurationBloc(
      localResources: localResourcesMock,
      packageInfo: packageInfoMock,
      user: userMock,
    );

    //THEN
    verify(packageInfoMock.version);
    expect(bloc.version, emits(version));
  });

  test('When ConfigurationBloc is initiated, it should get the user name', () {
    //GIVEN
    String username = 'João';
    when(userMock.name).thenReturn(username);

    //WHEN
    bloc = ConfigurationBloc(
      localResources: localResourcesMock,
      packageInfo: packageInfoMock,
      user: userMock,
    );

    //THEN
    verify(userMock.name);
    expect(bloc.username, emits(username));
  });

  test('When logging out, token should be set to null', (){
    //WHEN
    bloc.logout();

    //THEN
    verify(localResourcesMock.token = null);
  });
}
