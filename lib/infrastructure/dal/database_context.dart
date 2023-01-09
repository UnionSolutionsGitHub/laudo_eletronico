import 'package:laudo_eletronico/infrastructure/dal/dao/additional_photo_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/agendamento_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_attachment_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/client_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/configuration_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/item_configuration_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_option_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/notes_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/user_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/database_helper.dart';

import 'dao/summary_item_dao.dart';
import 'dao/user_configuration_dao.dart';

class DatabaseContext {
  static Function _onDatabaseContextinitialized;

  DatabaseContext();

  DatabaseContext.setOnDatabaseContextinitializedListener(
      onDatabaseContextinitializedListener) {
    DatabaseContext._onDatabaseContextinitialized =
        onDatabaseContextinitializedListener;
  }

  init() async {
    await DatabaseManager("laudo_eletronico", 1, usesDocumentsDirectoryPath: false).init([
      UserDAO(),
      LaudoDAO(),
      ClientDAO(),
      ConfigurationDAO(),
      ItemConfigurationDAO(),
      AnswerDAO(),
      AdditionalPhotoDAO(),
      LaudoOptionDAO(),
      AnswerAttachmentDAO(),
      AgendamentoDAO(),
      NoteDAO(),
      SummaryItemDAO(),
      UserConfigurationDAO(),
    ]);

    while (_onDatabaseContextinitialized == null) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _onDatabaseContextinitialized();

    _onDatabaseContextinitialized = null;
  }
}
