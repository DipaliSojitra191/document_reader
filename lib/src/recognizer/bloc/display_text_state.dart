abstract class DisplayTextState {}

class DisplayTextInitial extends DisplayTextState {}

class DisplayTextEditState extends DisplayTextState {
  final bool? isEdit;

  DisplayTextEditState({this.isEdit});
}
