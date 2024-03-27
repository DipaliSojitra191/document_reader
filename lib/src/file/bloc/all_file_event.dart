import 'package:document_reader/src/file/model/files_data_model.dart';
import 'package:flutter/cupertino.dart';

abstract class AllFileEvent {}

class GetFileEvent extends AllFileEvent {
  final BuildContext context;
  final String fileType;
  final int selected1;
  final int selected2;

  GetFileEvent({
    required this.context,
    required this.fileType,
    required this.selected1,
    required this.selected2,
  });
}

class FilterEvent extends AllFileEvent {
  final int selected1;
  final int selected2;

  FilterEvent({
    required this.selected1,
    required this.selected2,
  });
}

class GetDirEvent extends AllFileEvent {
  final String dir;

  GetDirEvent({required this.dir});
}

class FileSelectedUnSelectedEvent extends AllFileEvent {
  final List<FilesDataModel> allFiles;
  final bool selected;

  FileSelectedUnSelectedEvent({required this.allFiles, required this.selected});
}

class FileSelectEvent extends AllFileEvent {
  final int index;
  final bool selected;
  final bool isBookmark;

  FileSelectEvent({
    required this.selected,
    required this.isBookmark,
    required this.index,
  });
}

class FileDeleteEvent extends AllFileEvent {
  final int index;

  FileDeleteEvent({required this.index});
}

class DirSelectedEvent extends AllFileEvent {
  final int index;

  DirSelectedEvent({required this.index});
}

class SearchListEvent extends AllFileEvent {
  final List<FilesDataModel> allFiles;
  final String searchText;
  final bool isDocument;

  SearchListEvent({
    required this.allFiles,
    required this.isDocument,
    required this.searchText,
  });
}

class SearchOnTapEvent extends AllFileEvent {
  final bool search;

  SearchOnTapEvent({required this.search});
}

class SelectedBackTapEvent extends AllFileEvent {
  final bool selected;

  SelectedBackTapEvent({required this.selected});
}
