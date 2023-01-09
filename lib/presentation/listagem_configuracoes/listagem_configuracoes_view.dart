import 'package:flutter/material.dart';
import 'package:laudo_eletronico/common/widgets/configuration_menu_button.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/presentation/vistorias_pendentes/vistorias_pendentes_view.dart';

import './listagem_configuracoes_contract.dart';
import './listagem_configuracoes_presenter.dart';
import './widgets/listagem_configuracoes_builder.dart';

import 'package:laudo_eletronico/common/widgets/search_bar.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';

class ListagemConfiguracoesView extends StatefulWidget {
  final Laudo _laudo;

  ListagemConfiguracoesView(this._laudo);

  @override
  _ListagemConfiguracoesViewState createState() =>
      _ListagemConfiguracoesViewState();
}

class _ListagemConfiguracoesViewState extends State<ListagemConfiguracoesView>
    implements ListagemConfiguracoesViewContract {
  ListagemConfiguracoesPresenterContract _presenter;

  @override
  void initState() {
    _presenter = ListagemConfiguracoesPresenter(
      this,
      this.widget._laudo,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      title: GlobalizationStrings.of(context)
          .value("listagem_cliente_appbar_title"),
      queryController: _presenter.queryController,
      onQueryChanged: _presenter.onQueryChanged,
      onQuerySubmitted: (s) {},
      child: _presenter.isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListagemConfiguracoesBuilder(_presenter),
    );
  }

  @override
  void notifyDataChanged() {
    this.setState(() {});
  }

  @override
  navigatorPush(MaterialPageRoute route, bool newflow) {
    if (newflow) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => VistoriasPendentesView(
                configMenu: ConfigurationMenuButton(),
              ),
        ),
        (Route<dynamic> route) => false,
      );
    }

    Navigator.push(this.context, route);
  }
}
