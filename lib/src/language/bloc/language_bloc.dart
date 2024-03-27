import 'package:document_reader/main.dart';
import 'package:document_reader/shared_Preference/preferences_helper.dart';
import 'package:document_reader/src/language/bloc/language_event.dart';
import 'package:document_reader/src/language/bloc/language_state.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageBlocState> {
  LanguageBloc() : super(LanguageInitial()) {
    on<SetLanguageEvent>((event, emit) {
      String language = event.title ?? "";

      if (language == "") {
        language = PrefsRepo().getString(key: PrefsRepo.language);
      }

      PrefsRepo().setString(key: PrefsRepo.language, value: language);

      languageStream.add(getLocaleFromName(languageName: language));
      emit(SetLanguageState(language: language));
    });
  }
}
