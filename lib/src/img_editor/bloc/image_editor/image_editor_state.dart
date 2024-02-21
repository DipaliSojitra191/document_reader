// ignore_for_file: depend_on_referenced_packages

import 'package:document_reader/src/img_editor/image_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

abstract class ImageEditorState {}

class ImageEditorInitial extends ImageEditorState {}

class SetPdfNameState extends ImageEditorState {
  final String name;

  SetPdfNameState({required this.name});
}

class SetCurrentIndexState extends ImageEditorState {
  final int index;

  SetCurrentIndexState({required this.index});
}

class SaveImageLoadingState extends ImageEditorState {}

class SaveImageState extends ImageEditorState {
  final bool status;

  SaveImageState({required this.status});
}

class ConvertPathToIIntListState extends ImageEditorState {
  final Uint8List path;

  ConvertPathToIIntListState({required this.path});
}

class FilterApplyState extends ImageEditorState {
  final Uint8List path;

  FilterApplyState({required this.path});
}

class ImageStatusState extends ImageEditorState {
  final ImageStatus imageType;

  ImageStatusState({required this.imageType});
}

class RemoveAtIndexState extends ImageEditorState {
  final int index;

  RemoveAtIndexState({required this.index});
}

class FilterState extends ImageEditorState {
  final ImageStatus imageStatus;
  final String fileName;
  final img.Image? imageFile;

  FilterState({
    required this.fileName,
    required this.imageFile,
    required this.imageStatus,
  });
}

class SetFilterOptionsState extends ImageEditorState {
  final int index;

  SetFilterOptionsState({required this.index});
}
