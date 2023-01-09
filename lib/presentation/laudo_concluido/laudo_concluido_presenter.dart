import 'dart:async';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_attachment_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/notes_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/summary_item_dao.dart';
import 'package:laudo_eletronico/infrastructure/resources/local_resources.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';
import 'package:laudo_eletronico/model/answer_attachment.dart';
import 'package:laudo_eletronico/model/item_configuration_type.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/user.dart';
import 'package:laudo_eletronico/presentation/laudo_concluido/laudo_concluido_contract.dart';

class LaudoConcluidoPresenter implements LaudoConcluidoPresenterContract {
  LaudoConcluidoViewContract _view;
  Laudo _laudo;
  bool _isSyncing = true;
  String _mensage = "";

  final service = UnionSolutionsService();

  LaudoConcluidoPresenter(this._view, this._laudo) {
    _init();
  }

  _init() async {
    try {
      final dao = NoteDAO();
	  _laudo.notes = await dao.get(
		  args: {
			  dao.columnLaudoId: _laudo.id,
		  },
	  );

      await _sendAttaches();
      await _sendAdditionalAttaches();
      await service.sendLaudo(_laudo);

      final laudoDao = LaudoDAO();
      laudoDao.deleteWithAnswers(_laudo);

      final summaryDao = SummaryItemDAO();

      summaryDao.delete({summaryDao.columnLaudoId: _laudo.id});

      _isSyncing = false;
      _mensage = "";
      _view.notifyDataChanged();
    } on TimeoutException catch (_) {
      _view.showErrorMessage(erroMessage: "laudo_concluido_alert_erro_timeout");
    } catch (e) {
      _view.showErrorMessage();
    }
  }

  @override
  bool get isSyncing => _isSyncing;

  @override
  String get mensage => _mensage;

  Future _sendAttaches() async {
    final attachementDao = AnswerAttachmentDAO();
    final answerDao = AnswerDAO();

    final photos = _laudo.answers.where((answer) => answer.item.type == ItemConfigurationType.FOTO).toList();

    for (int i = 0; i < photos.length; i++) {
      _mensage = "Enviando anexos ${i + 1} de ${photos.length}";
      _view.notifyDataChanged();

      if (photos[i]?.attachment != null && photos[i]?.attachment?.url?.isNotEmpty == true) {
        photos[i].value = photos[i].attachment.url;
        //await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      final url = await service.uploadImage(photos[i].value);

      if (url.isEmpty) {
        continue;
      }

      photos[i].attachment = AnswerAttachment(
        answer: photos[i],
        path: photos[i].value,
        url: url,
      );
      photos[i].value = url;

      await attachementDao.insert(photos[i].attachment);
      await answerDao.update(photos[i]);
    }
  }

  Future _sendAdditionalAttaches() async {
    final photos = _laudo.additionalPhotos.where((photo) => photo.url?.isNotEmpty != true || photo.url != "null").toList();

    for (int i = 0; i < photos.length; i++) {
      _mensage = "Enviando fotos adicionais ${i + 1} de ${photos.length}";
      _view.notifyDataChanged();

      if (photos[i]?.url?.isNotEmpty == true) {
        //await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      photos[i].url = await service.uploadImage(photos[i].path);
    }
  }

  @override
  checkRedirectToView() async {
    LocalResources localResources = await LocalResources().instance();
    final user = User.fromToken(localResources?.token);

    if (await LaudoDAO().arePending(user)) {
      _view.navigateToPendentes();
      return;
    }

    _view.naviteToNovaVistoria();
  }
}
