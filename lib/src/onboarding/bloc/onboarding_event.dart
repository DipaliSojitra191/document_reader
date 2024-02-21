abstract class OnboardingEvent {}

class GetOnboardingIndexEvent extends OnboardingEvent {
  final int? pageIndex;

  GetOnboardingIndexEvent({this.pageIndex});
}
