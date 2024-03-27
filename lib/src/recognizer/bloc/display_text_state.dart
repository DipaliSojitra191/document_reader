abstract class DisplayTextBlocState {}

class DisplayTextInitial extends DisplayTextBlocState {}

class DisplayTextEditState extends DisplayTextBlocState {
  final bool? isEdit;

  DisplayTextEditState({this.isEdit});
}
