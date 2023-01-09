import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laudo_eletronico/bloc/additional_photos/add_description_bloc.dart';
import 'package:laudo_eletronico/bloc/additional_photos/additional_photos_bloc.dart';
import 'package:laudo_eletronico/bloc/photo_viwer/photo_viwer_bloc.dart';
import 'package:laudo_eletronico/common/widgets/album_card.dart';
import 'package:laudo_eletronico/common/widgets/listview_header.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/model/additional_photo.dart';
import 'package:laudo_eletronico/view/additional_photos/add_description_view.dart';
import 'package:laudo_eletronico/view/photo_viewer/photo_viewer_view.dart';

class AdditionalPhotosView extends StatelessWidget {
  final AdditionalPhotosBloc bloc;

  AdditionalPhotosView({@required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            GlobalizationStrings.of(context)
                .value("foto_adcional_appbar_title"),
          ),
        ),
        body: Column(
          children: <Widget>[
            _buildHeader(context),
            _buildGridView(),
          ],
        ));
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: ListviewHeader(
        showHeader: true,
        globalizationKey: "foto_adicional_header_title",
      ),
    );
  }

  Widget _buildGridView() {
    return Expanded(
      child: StreamBuilder<List<AdditionalPhoto>>(
        stream: bloc.additionalPhotos,
        builder: (context, snapshot) {
          final additionalPhotos = snapshot.data;
          if (additionalPhotos == null) return Container();

          final screenwidth = MediaQuery.of(context).size.width;
          bloc.onWidthDefined(screenwidth);

          return GridView.count(
            crossAxisCount: bloc.cardsPerRow,
            childAspectRatio: bloc.cardAspectRatio,
            children: List.generate(
              additionalPhotos.length + 1,
              (index) {
                return Padding(
                  padding: EdgeInsets.all(bloc.cardSpacing),
                  child: index == additionalPhotos.length
                      ? _buildAddNewPhotoCard(context)
                      : _buildCardWithPhoto(context, index),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddNewPhotoCard(BuildContext context) {
    return AlbumCard(
      width: bloc.cardWidth,
      height: bloc.cardHeight,
      onTap: () => _navigateToAddDescriptionView(context, ImageSource.camera),
      onCornerButtonPressed: () =>
          _navigateToAddDescriptionView(context, ImageSource.gallery),
      text: GlobalizationStrings.of(context).value("add_photo"),
    );
  }

  Widget _buildCardWithPhoto(BuildContext context, int index) {
    return AlbumCard(
      width: bloc.cardWidth,
      height: bloc.cardHeight,
      text: bloc.descriptionFor(index),
      onTap: () => _navigateToPhotoViewer(context, index),
      child: Image.file(
        bloc.thumbnailFor(index),
        fit: BoxFit.fill,
      ),
    );
  }

  void _navigateToPhotoViewer(BuildContext context, int index) {
    final photoViewer = PhotoViewerView(
      PhotoViwerBloc(
        fileDescription: bloc.descriptionFor(index),
        filePath: bloc.photoFor(index).path,
        onDeleted: bloc.onPhotoDeleted,
      ),
    );
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => photoViewer));
  }

  void _navigateToAddDescriptionView(BuildContext context, ImageSource source) {
    final addDescriptionView = AddDescriptionView(
      bloc: AddDescriptionBloc(bloc.takeNewAdditionalPhoto, source: source),
    );
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => addDescriptionView));
  }
}
