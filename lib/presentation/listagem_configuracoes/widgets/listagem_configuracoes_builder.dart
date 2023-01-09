import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../listagem_configuracoes_contract.dart';
import 'package:laudo_eletronico/common/widgets/listview_header.dart';

class ListagemConfiguracoesBuilder extends StatelessWidget {
  final ListagemConfiguracoesPresenterContract presenter;

  ListagemConfiguracoesBuilder(this.presenter);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => Column(
            children: <Widget>[
              ListviewHeader(
                showHeader: index == 0,
                globalizationKey: "listagem_cliente_list_header",
              ),
              Material(
                color: Colors.white,
                child: ListTile(
                  onTap: () {
                    this.presenter.onSelectedItemListener(index);
                  },
                  leading: Icon(MdiIcons.fileDocumentBoxMultipleOutline),
                  title: RichText(
                    text: TextSpan(
                      text: this.presenter.configurations[index].client.name.substring(
                          0, this.presenter.queryController.text.length),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: this.presenter.configurations[index].client.name.substring(
                              this.presenter.queryController.text.length),
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Text(this.presenter.configurations[index].name),
                ),
              ),
              Divider(
                color: Colors.grey,
                height: 2.0,
              ),
            ],
          ),
      itemCount: this.presenter.configurations.length,
    );
  }
}
