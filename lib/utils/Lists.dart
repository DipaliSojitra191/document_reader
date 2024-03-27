// ignore_for_file: file_names

import 'package:document_reader/src/language/model/setting_model.dart';
import 'package:document_reader/utils/AppStrings.dart';

// List<String> list1 = [
//   AppLocalizations.of(currentContext)!.name,
//   AppLocalizations.of(currentContext)!.date,
//   AppLocalizations.of(currentContext)!.file_size,
// ];
// List<String> list2 = [
//   AppLocalizations.of(currentContext)!.ascending,
//   AppLocalizations.of(currentContext)!.descending,
// ];

List<LanguageModel> languageList = [
  LanguageModel(title: StringUtils.english, img: 'english_us'),
  LanguageModel(title: StringUtils.arabic, img: 'arabic'),
  LanguageModel(title: StringUtils.bulgarian, img: 'bulgarian'),
  LanguageModel(title: StringUtils.czech, img: "czech"),
  LanguageModel(title: StringUtils.polish, img: 'polish'),
  LanguageModel(title: StringUtils.french, img: "french"),
];
