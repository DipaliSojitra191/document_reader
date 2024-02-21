import 'package:document_reader/src/recognizer/bloc/display_text_event.dart';
import 'package:document_reader/src/recognizer/bloc/display_text_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DisplayTextBloc extends Bloc<DisplayTextEvent, DisplayTextState> {
  DisplayTextBloc() : super(DisplayTextInitial()) {
    on<DisplayTextEdit>(setDisplayEditText);
  }

  setDisplayEditText(DisplayTextEdit event, Emitter<DisplayTextState> emit) {
    emit(DisplayTextEditState(isEdit: event.isEdit));
  }
}
