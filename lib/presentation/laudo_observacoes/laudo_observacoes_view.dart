import 'package:flutter/material.dart';
import 'package:laudo_eletronico/common/widgets/listview_header.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/presentation/laudo_observacoes/laudo_observacoes_contract.dart';
import 'package:laudo_eletronico/presentation/laudo_observacoes/laudo_observacoes_presenter.dart';

class LaudoObservacoesView extends StatefulWidget {
  final String _laudoType;
  final int _laudoId;

  LaudoObservacoesView(this._laudoType, this._laudoId);

  @override
  _LaudoObservacoesViewState createState() => _LaudoObservacoesViewState();
}

class _LaudoObservacoesViewState extends State<LaudoObservacoesView> implements LaudoObservacoesViewContract {
  LaudoObservacoesPresenterContract _presenter;

  @override
  void initState() {
    _presenter = LaudoObservacoesPresenter(this, this.widget._laudoType, this.widget._laudoId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          GlobalizationStrings.of(context).value("laudo_observacoes_appbar_title"),
        ),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: ListviewHeader(
              showHeader: true,
              globalizationKey: "laudo_observacoes_description",
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(5),
              width: double.infinity,
              height: double.infinity,
              child: TextField(
                controller: _presenter.controller.noteTextController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            width: double.infinity,
            height: 80,
            child: RaisedButton(
              color: AppColors.primary,
              textColor: Colors.white,
              onPressed: () async {
                await _presenter.saveNotes();
                Navigator.of(context).pop();
              },
              child: Center(
                child: Text("OK"),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  notifyDataChanged() {
    // TODO: implement notifyDataChanged
    return null;
  }
}
