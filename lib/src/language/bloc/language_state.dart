abstract class LanguageBlocState {}

class LanguageInitial extends LanguageBlocState {}

class SetLanguageState extends LanguageBlocState {
  final String language;

  SetLanguageState({required this.language});
}
