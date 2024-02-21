abstract class OnboardingState {}

class OnboardingInitial extends OnboardingState {}

class GetOnboardingIndexState extends OnboardingState {
  final int? pageIndex;

  GetOnboardingIndexState({this.pageIndex});
}
