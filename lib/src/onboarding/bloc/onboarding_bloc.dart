import 'package:document_reader/src/onboarding/bloc/onboarding_event.dart';
import 'package:document_reader/src/onboarding/bloc/onboarding_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState1> {
  OnboardingBloc() : super(OnboardingInitial()) {
    on<GetOnboardingIndexEvent>((event, emit) {
      emit(GetOnboardingIndexState(pageIndex: event.pageIndex ?? 0));
    });
  }
}
