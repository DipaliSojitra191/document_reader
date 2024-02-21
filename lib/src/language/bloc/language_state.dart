abstract class LanguageState {}

class LanguageInitial extends LanguageState {}

class SetLanguageState extends LanguageState {
  final String language;

  SetLanguageState({required this.language});
}
