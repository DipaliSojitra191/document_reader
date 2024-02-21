import 'package:document_reader/src/file/model/files_data_model.dart';

abstract class AllFileState {}

class AllFileInitial extends AllFileState {}

class GetFileState extends AllFileState {
  final List<FilesDataModel> allFiles;
  final bool? selected;

  GetFileState({required this.allFiles, this.selected});
}

class CheckStoragePermissionStatus extends AllFileState {
  final bool isGranted;

  CheckStoragePermissionStatus({required this.isGranted});
}

class FilterState extends AllFileState {
  final List<FilesDataModel> allFiles;
  final bool? selected;

  FilterState({required this.allFiles, this.selected});
}

class GetDirState extends AllFileState {
  final List<FilesDataModel> allFiles;
  final bool? selected;
  final bool? isDocument;

  GetDirState({required this.allFiles, this.selected, this.isDocument});
}

class GetFileLoadingState extends AllFileState {}

class FileSelectState extends AllFileState {
  final bool selected;
  final bool isBookmark;
  final int index;

  FileSelectState({
    required this.selected,
    required this.isBookmark,
    required this.index,
  });
}

class DirSelectedState extends AllFileState {
  final int index;

  DirSelectedState({required this.index});
}

class SearchListState extends AllFileState {
  final List<FilesDataModel> searchList;
  final bool isDocument;

  SearchListState({required this.searchList, required this.isDocument});
}

class SearchOnTapState extends AllFileState {
  final bool search;

  SearchOnTapState({required this.search});
}

class SelectedBackTapState extends AllFileState {
  final bool selected;

  SelectedBackTapState({required this.selected});
}
