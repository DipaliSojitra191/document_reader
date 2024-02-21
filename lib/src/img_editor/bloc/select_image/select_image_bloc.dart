import 'package:document_reader/src/img_editor/bloc/select_image/select_image_event.dart';
import 'package:document_reader/src/img_editor/bloc/select_image/select_image_state.dart';
import 'package:document_reader/src/img_editor/select_img.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/logs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectImageBloc extends Bloc<SelectImageEvent, SelectImageState> {
  SelectImageBloc() : super(SelectImageInitial()) {
    on<FetchAssetsEvent>(_fetchAssets);
    on<AddAssetsEvent>(_addAssets);
  }

  _fetchAssets(FetchAssetsEvent event, Emitter<SelectImageState> emit) async {
    emit(FetchAssetsLoadingState());
    List<SelectImageModel> assets = [];

    try {
      await storagePermission();
      await PhotoManager.requestPermissionExtend();
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(type: RequestType.image);

      int count = await PhotoManager.getAssetCount(type: RequestType.image);
      for (var album in albums) {
        if (album.isAll) {
          List<AssetEntity> images = await album.getAssetListRange(start: 0, end: count);
          for (var element in images) {
            element.originFile.then((value) async {
              final path = value?.path.toLowerCase() ?? "";
              if (path.endsWith(".jpg") || path.endsWith(".png") || path.endsWith(".jpeg") || path.endsWith(".heic") || path.endsWith(".webp")) {
                assets.add(SelectImageModel(path: value?.path ?? "", count: -1));
              }
            });
          }
        }
      }
    } catch (e) {
      logs(message: "Fetch assets E:-----> $e");
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    emit(FetchAssetsState(assets: assets));
  }

  _addAssets(AddAssetsEvent event, Emitter<SelectImageState> emit) {
    List<String> selectedAssets = event.selectedAssets;

    final int ind = selectedAssets.indexWhere((element) => element == event.path);

    if (ind > -1) {
      selectedAssets.removeAt(ind);
    } else {
      selectedAssets.add(event.path);
    }

    emit(AddAssetsState(selectedAssets: selectedAssets));
  }
}
