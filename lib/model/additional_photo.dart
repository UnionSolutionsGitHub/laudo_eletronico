import 'package:laudo_eletronico/model/laudo.dart';

class AdditionalPhoto {
  int id;
  String description, path, url;
  Laudo laudo;

  AdditionalPhoto({
    this.id,
    this.description,
    this.path,
    this.url,
    this.laudo,
  });
}