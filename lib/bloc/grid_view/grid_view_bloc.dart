import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:laudo_eletronico/infrastructure/resources/dimens.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// Bloc that controls some aspects of Album like screens, that use GridViews.
abstract class GridViewBloc extends BlocBase {
  final cardSpacing = halfSpace;

  final cardsPerRow = 3;

  @protected
  final screenWidthController = BehaviorSubject<double>();

  //
  // Inputs
  //
  Function(double) get onWidthDefined => screenWidthController.sink.add;

  //
  // Outputs
  //
  double get cardWidth =>
      (screenWidthController.value / cardsPerRow) - (cardSpacing * 2);

  double get cardHeight => cardWidth * 1.11;

  double get cardAspectRatio => cardWidth / (cardHeight + 60);

  @override
  void dispose() {
    screenWidthController.close();
    super.dispose();
  }
}
