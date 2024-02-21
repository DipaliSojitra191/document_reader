import 'package:document_reader/src/bottombar/bloc/bottombar_event.dart';
import 'package:document_reader/src/bottombar/bloc/bottombar_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomBarBloc extends Bloc<BottomBarEvent, BottomBarState> {
  BottomBarBloc() : super(BottomBarInitial()) {
    on<GetPageIndexEvent>((event, emit) {
      emit(GetPageIndexState(index: event.index));
    });
  }
}
