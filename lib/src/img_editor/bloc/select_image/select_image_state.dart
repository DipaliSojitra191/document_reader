import 'package:document_reader/src/img_editor/select_img.dart';

abstract class SelectImageState {}

class SelectImageInitial extends SelectImageState {}

class FetchAssetsLoadingState extends SelectImageState {}

class FetchAssetsState extends SelectImageState {
  final List<SelectImageModel>? assets;

  FetchAssetsState({this.assets});
}

class AddAssetsState extends SelectImageState {
  final List<String> selectedAssets;

  AddAssetsState({required this.selectedAssets});
}
