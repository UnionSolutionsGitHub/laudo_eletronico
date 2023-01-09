import 'package:laudo_eletronico/infrastructure/dal/dao/notes_dao.dart';
import 'package:laudo_eletronico/model/note.dart';
import 'package:laudo_eletronico/presentation/laudo_observacoes/laudo_observacoes_contract.dart';
import 'package:laudo_eletronico/presentation/laudo_observacoes/laudo_observacoes_controller.dart';

class LaudoObservacoesPresenter implements LaudoObservacoesPresenterContract {
  final LaudoObservacoesViewContract _view;
  final _controller = LaudoObservacoesController();
  final dao = NoteDAO();
  Note _note;

  LaudoObservacoesPresenter(this._view, String laudoType, int id) {
    dao.get(
      args: {
        dao.columnLaudoType: laudoType,
        dao.columnLaudoId: id,
      },
    ).then((result) {
      final notes = result as List<Note>;

      _note = notes.length > 0 ? notes.first : Note(laudoId: id, itemType: laudoType);
      _controller.noteTextController.text = _note.note;
    });
  }

  @override
  LaudoObservacoesController get controller => _controller;

  @override
  Future saveNotes() async {
    _note.note = _controller.noteTextController.text;

    this.dao.exists(args: {
      this.dao.columnLaudoType: _note.itemType,
      this.dao.columnLaudoId: _note.laudoId,
    }).then((exists) {
      if (exists) {
        this.dao.update(_note);
        return;
      }

      this.dao.insert(_note);
    });
  }
}
