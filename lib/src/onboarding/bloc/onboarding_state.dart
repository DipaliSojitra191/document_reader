abstract class OnboardingState1 {}

class OnboardingInitial extends OnboardingState1 {}

class GetOnboardingIndexState extends OnboardingState1 {
  final int? pageIndex;

  GetOnboardingIndexState({this.pageIndex});
}
