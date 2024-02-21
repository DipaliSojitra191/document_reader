abstract class LanguageEvent {}

class SetLanguageEvent extends LanguageEvent {
  final String ?title;

  SetLanguageEvent({this.title});
}
