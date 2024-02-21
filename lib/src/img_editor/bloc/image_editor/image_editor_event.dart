import 'package:document_reader/src/img_editor/image_editor.dart';
import 'package:flutter/foundation.dart';

abstract class ImageEditorEvent {}

class SetPdfNameEvent extends ImageEditorEvent {
  final String name;

  SetPdfNameEvent({required this.name});
}

class SetCurrentIndexEvent extends ImageEditorEvent {
  final int index;

  SetCurrentIndexEvent({required this.index});
}

class SaveImageEvent extends ImageEditorEvent {
  final List<Uint8List> imageList;

  SaveImageEvent({required this.imageList});
}

class ConvertPathToIIntListEvent extends ImageEditorEvent {
  final String path;

  ConvertPathToIIntListEvent({required this.path});
}

class FilterApplyEvent extends ImageEditorEvent {
  final String path;

  FilterApplyEvent({required this.path});
}

class ImageStatusEvent extends ImageEditorEvent {
  final ImageStatus imageType;

  ImageStatusEvent({required this.imageType});
}

class RemoveAtIndexEvent extends ImageEditorEvent {
  final int index;

  RemoveAtIndexEvent({required this.index});
}

class FilterEvent extends ImageEditorEvent {
  final Uint8List imagePath;

  FilterEvent({required this.imagePath});
}

class SetFilterOptions extends ImageEditorEvent {
  final int index;

  SetFilterOptions({required this.index});
}
