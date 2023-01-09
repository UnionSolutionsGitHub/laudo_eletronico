import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:laudo_eletronico/bloc/additional_photos/additional_photos_bloc.dart';
import 'package:laudo_eletronico/bloc/summary/summary_bloc.dart';
import 'package:laudo_eletronico/common/widgets/summary_card.dart';
import 'package:laudo_eletronico/infrastructure/resources/file_manager.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/model/summary_item.dart';
import 'package:laudo_eletronico/presentation/laudo_concluido/laudo_concluido_view.dart';
import 'package:laudo_eletronico/view/additional_photos/additional_photos_view.dart';
import 'package:laudo_eletronico/view/item_execution/item_execution_view.dart';

class SummaryView extends StatefulWidget {
  final SummaryBloc bloc;

  SummaryView({@required this.bloc}) : assert(bloc != null);

  @override
  _SummaryViewState createState() => _SummaryViewState();
}

class _SummaryViewState extends State<SummaryView>
    with SingleTickerProviderStateMixin {
  final scrollController = ScrollController();
  AnimationController controller;
  Animation<Offset> offset;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 2.0))
        .animate(controller);
  }

  _setupScrollBehavior() {
    scrollController.addListener(
      () => widget.bloc.onScroll(scrollController.position),
    );
  }

  @override
  Widget build(BuildContext context) {
    _setupScrollBehavior();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          GlobalizationStrings.of(context).value("laudo_fotos_appbar_title"),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToAdditionalPhotosView(context),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildGridView(),
        ],
      ),
      floatingActionButton: StreamBuilder<bool>(
          stream: widget.bloc.isSendButtonVisible,
          builder: (context, snapshot) {
            final visible = snapshot.data ?? false;

            visible ? controller.reverse() : controller.forward();

            return SlideTransition(
              position: offset,
              child: FloatingActionButton.extended(
                icon: Icon(Icons.cloud_upload),
                label: Text(
                  GlobalizationStrings.of(context).value("end_laudo"),
                ),
                clipBehavior: Clip.none,
                onPressed: () => _sendData(context),
              ),
            );
          }),
    );
  }

  Widget _buildGridView() {
    return Expanded(
      child: StreamBuilder<List<SummaryItem>>(
        stream: widget.bloc.items,
        builder: (context, snapshot) {
          final items = snapshot.data;

          if (items == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final screenwidth = MediaQuery.of(context).size.width;
          widget.bloc.onWidthDefined(screenwidth);

          return GridView.count(
            crossAxisCount: widget.bloc.cardsPerRow,
            childAspectRatio: widget.bloc.cardAspectRatio,
            controller: scrollController,
            children: List.generate(
              items.length,
              (index) {
                return Padding(
                  padding: EdgeInsets.all(widget.bloc.cardSpacing),
                  child: _buildItemCard(context, items[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, SummaryItem item) {
    return SummaryCard(
      item: item,
      width: widget.bloc.cardWidth,
      height: widget.bloc.cardHeight,
      photoPath: widget.bloc.photoPathFor(item),
      description: item.itemConfigurations[0].descption,
      onTap: () => widget.bloc.onItemClicked(item).then(
            (newBloc) async {
              //Wait for any changes made on laudo, inside ItemExecutionView
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      ItemExecutionView(newBloc, false),
                ),
              );
              //Rebuild the SummaryItems list with these changes
              widget.bloc.onDataChanged();
            },
          ),
    );
  }

  _navigateToAdditionalPhotosView(BuildContext context) async {
    final fileManager = await FileManager.instance;
    final additionalPhotosView = AdditionalPhotosView(
      bloc: AdditionalPhotosBloc(
        laudo: widget.bloc.laudo,
        fileManager: fileManager,
      ),
    );
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => additionalPhotosView));
  }

  _sendData(BuildContext context) {
    if (widget.bloc.isReadyToSendLaudo) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LaudoConcluidoView(widget.bloc.laudo)));
    } else {
      _showErrorDialog(context);
    }
  }

  _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(
              GlobalizationStrings.of(context).value("alert_title_warning"),
            ),
            content: Text(
              GlobalizationStrings.of(context)
                  .value("laudo_checklist_alert_cant_go_next_step"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  GlobalizationStrings.of(context).value("alert_button_ok"),
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
    );
  }
}
