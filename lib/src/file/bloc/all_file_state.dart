import 'package:document_reader/src/file/model/files_data_model.dart';

abstract class AllFileBlocState {}

class AllFileInitial extends AllFileBlocState {}

class GetFileState extends AllFileBlocState {
  final List<FilesDataModel> allFiles;
  final bool? selected;

  GetFileState({required this.allFiles, this.selected});
}

class CheckStoragePermissionStatus extends AllFileBlocState {
  final bool isGranted;

  CheckStoragePermissionStatus({required this.isGranted});
}

class FilterState extends AllFileBlocState {
  final List<FilesDataModel> allFiles;
  final bool? selected;

  FilterState({required this.allFiles, this.selected});
}

class GetDirState extends AllFileBlocState {
  final List<FilesDataModel> allFiles;
  final bool? selected;
  final bool? isDocument;

  GetDirState({required this.allFiles, this.selected, this.isDocument});
}

class GetFileLoadingState extends AllFileBlocState {}

class FileSelectState extends AllFileBlocState {
  final bool selected;
  final bool isBookmark;
  final int index;

  FileSelectState({
    required this.selected,
    required this.isBookmark,
    required this.index,
  });
}

class DirSelectedState extends AllFileBlocState {
  final int index;

  DirSelectedState({required this.index});
}

class SearchListState extends AllFileBlocState {
  final List<FilesDataModel> searchList;
  final bool isDocument;

  SearchListState({required this.searchList, required this.isDocument});
}

class SearchOnTapState extends AllFileBlocState {
  final bool search;

  SearchOnTapState({required this.search});
}

class SelectedBackTapState extends AllFileBlocState {
  final bool selected;

  SelectedBackTapState({required this.selected});
}
