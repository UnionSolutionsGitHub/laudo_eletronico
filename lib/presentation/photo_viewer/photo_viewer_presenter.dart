import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laudo_eletronico/common/compress_imagem.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/additional_photo_dao.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';
import 'package:laudo_eletronico/model/additional_photo.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/presentation/photo_viewer/photo_viewer_contract.dart';
import 'package:laudo_eletronico/presentation/photo_viewer/photo_viewer_controller.dart';
import 'package:path_provider/path_provider.dart';

class PhotoViewerPresenter implements PhotoViewerPresenterContract {
	final PhotoViewerViewContract _view;
	PhotoViewerController _controller;
	final SingleTickerProviderStateMixin _vsync;
	final Laudo _laudo;
	AdditionalPhoto photo;
	Directory _applicationDirectory;
	int zoon = 0;

	PhotoViewerPresenter(this._view, this._vsync, this._laudo, {this.photo}) {
		getApplicationDocumentsDirectory().then((directory) => _applicationDirectory = directory);
		_controller = PhotoViewerController();
		_controller.tabController =
			TabController(vsync: _vsync, length: this.photosLength + 50);
		_init();
	}

	_init() async {
		if (this.photo != null) {
			final index = this.photos.indexOf(this.photo);
			_controller.tabController.animateTo(index + 1);
		}
	}

	@override
	PhotoViewerController get controller => _controller;

	@override
	int get photosLength => (_laudo?.additionalPhotos?.length ?? 0) + 1;

	@override
	List<AdditionalPhoto> get photos => _laudo.additionalPhotos.reversed.toList();

	@override
	onBtnTakePictureClickListener() async {
		try {
			final path = "${_applicationDirectory.path}/${DateTime.now().toIso8601String()}";
			final filePath = "$path.png";
			final thumbnailPath = "${path}_thumbnail.png";

			await _controller.cameraController.takePicture(filePath);

			await _saveImage(filePath, thumbnailPath);
			final additionalPhotoDao = AdditionalPhotoDAO();

			AdditionalPhoto additionalPhoto = AdditionalPhoto(
				path: filePath,
				description: _controller.txfdPhotoDescriptionController.text,
				laudo: _laudo,
			);

			UnionSolutionsService()
				.uploadImage(filePath)
				.then((url) {
				additionalPhoto.url = url;
				additionalPhotoDao.update(additionalPhoto);
			});

			additionalPhoto.id = await additionalPhotoDao.insert(additionalPhoto);

			_laudo.additionalPhotos.add(additionalPhoto);
			_controller.txfdPhotoDescriptionController.text = "";
			_view.notifyDataChanged();
			_controller.tabController.animateTo(1);
		} catch (e) {
			print(e.message);
		}
	}

	@override
	addFromGallery() async {
		await _controller?.cameraController?.dispose();

		final image =  await ImagePicker.pickImage(source: ImageSource.gallery);

		if(image?.path == null) {
			return;
		}

		final path = "${_applicationDirectory.path}/${DateTime.now().toIso8601String()}";
		final filePath = "$path.png";
		final thumbnailPath = "${path}_thumbnail.png";

		File(filePath).writeAsBytesSync(image.readAsBytesSync());

		await _saveImage(filePath, thumbnailPath);

		final additionalPhotoDao = AdditionalPhotoDAO();

		AdditionalPhoto additionalPhoto = AdditionalPhoto(
			path: filePath,
			description: _controller.txfdPhotoDescriptionController.text,
			laudo: _laudo,
		);

		UnionSolutionsService()
			.uploadImage(filePath)
			.then((url) {
			additionalPhoto.url = url;
			additionalPhotoDao.update(additionalPhoto);
		});

		additionalPhoto.id = await additionalPhotoDao.insert(additionalPhoto);

		_laudo.additionalPhotos.add(additionalPhoto);
		_controller.txfdPhotoDescriptionController.text = "";
		_view.notifyDataChanged();
		_controller.tabController.animateTo(1);
	}

	@override
	onBttnGoCameraClickListener() {
		_controller.tabController.animateTo(0);
		_view.notifyDataChanged();
	}

	@override
	delete(AdditionalPhoto photo) {
		final additionalPhotoDao = AdditionalPhotoDAO();

		additionalPhotoDao.delete({
			additionalPhotoDao.columnId: photo.id,
		});
		_laudo.additionalPhotos.remove(photo);
		_view.notifyDataChanged();
		_controller.tabController.animateTo(0);
	}

	Future _saveImage(String filePath, String thumbnailPath) async {
		final photoProperties = await FlutterNativeImage.getImageProperties(filePath);
		final photowidth = photoProperties.width > photoProperties.height ? 1024 : 720;
		final image = await CompressImage.compress(filePath, width: photowidth);

		File(filePath).writeAsBytesSync(image.readAsBytesSync());

		final thumbnail = await CompressImage.compress(filePath);
		File(thumbnailPath).writeAsBytesSync(thumbnail.readAsBytesSync());

		return filePath;
	}


}
