import 'package:flutter/material.dart';
import 'package:laudo_eletronico/common/widgets/search_bar.dart';
import 'package:laudo_eletronico/common/widgets/selection_app_bar.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/main.dart';
import './vistorias_pendentes_contract.dart';
import './vistorias_pendentes_presenter.dart';
import './widgets/vistorias_pendentes_listagem_builder.dart';

class VistoriasPendentesView extends StatefulWidget {
  final Widget configMenu;

  VistoriasPendentesView({@required this.configMenu});

  @override
  _VistoriasPendentesViewState createState() => _VistoriasPendentesViewState();
}

class _VistoriasPendentesViewState extends State<VistoriasPendentesView>
    with RouteAware
    implements VistoriasPendentesViewContract {
  VistoriasPendentesPresenterContract _presenter;

  @override
  void initState() {
    _presenter = VistoriasPendentesPresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _presenter.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _presenter.reloadData();
  }

  @override
  Widget build(BuildContext context) {
    return _presenter.isInSelectionMode
        ? _buildSelectionBar(context)
        : _buildSearchBar(context);
  }

  Widget _buildSelectionBar(BuildContext context) {
    return Scaffold(
      appBar: SelectionAppBar(
        selectedItemsCount: _presenter.selectedCount,
        cancelSelection: _presenter.cancelSelection,
        deleteSelected: () => _showDeleteLaudosDialog(context),
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  _showDeleteLaudosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              GlobalizationStrings.of(context).value('alert_title_warning')),
          content: Text(
              GlobalizationStrings.of(context).value('confirm_laudo_deletion')),
          actions: <Widget>[
            FlatButton(
              child: Text(GlobalizationStrings.of(context)
                  .value('alert_button_negative')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text(GlobalizationStrings.of(context)
                  .value('alert_button_positive')),
              onPressed: () {
                _deleteLaudos();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _deleteLaudos() {
    _presenter.deleteSelected().then((success) {
      if (!success) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(GlobalizationStrings.of(context)
                  .value('alert_title_warning')),
              content: Text(GlobalizationStrings.of(context)
                  .value('error_deleting_laudos')),
            );
          },
        );
      }
    });
  }

  SearchBar _buildSearchBar(BuildContext context) {
    return SearchBar(
      title: GlobalizationStrings.of(context)
          .value("vistorias_pendentes_appbar_title"),
      extraActions: this.widget?.configMenu ?? Container(),
      queryController: _presenter.queryController,
      onQueryChanged: _presenter.onQueryChanged,
      child: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () async {
        Navigator.of(context).pushNamed(Routes.NOVA_VISTORIA);
      },
    );
  }

  Widget _buildBody() {
    return _presenter.isLoading
        ? Center(child: CircularProgressIndicator())
        : _presenter.isEmpty
            ? _buildEmptyView()
            : VistoriasPendentesListagemBuilder(_presenter);
  }

  Widget _buildEmptyView() {
    return Center(
      child: Text(
        GlobalizationStrings.of(context).value("no_pending_laudos_to_show"),
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  void notifyDataChanged() {
    this.setState(() {});
  }

  @override
  navigatorPush(MaterialPageRoute route) {
    Navigator.push(this.context, route);
  }

  @override
  showProgressIndeterminate() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            GlobalizationStrings.of(this.context)
                .value("vistorias_pendentes_indeterminate_alert_title"),
          ),
          content: Container(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  @override
  hideProgressIndeterminate() {
    Navigator.of(context).pop();
  }
}
