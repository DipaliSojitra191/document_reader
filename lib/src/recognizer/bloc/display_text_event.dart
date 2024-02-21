abstract class DisplayTextEvent {}

class DisplayTextEdit extends DisplayTextEvent {
  final bool? isEdit;

  DisplayTextEdit({this.isEdit});
}
