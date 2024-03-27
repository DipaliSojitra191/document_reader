import 'dart:convert';
import 'dart:io';

import 'package:document_reader/src/file/model/files_data_model.dart';
import 'package:document_reader/utils/AppStrings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsRepo {
  static const language = "language";
  static const onboarding = 'onboarding';
  static const filter1 = 'filter1';
  static const filter2 = 'filter2';
  static const recent = 'recent';
  static const bookmark = 'bookmark';
  static const rate = 'rate';

  static SharedPreferences? _prefs;

  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void setString({required String key, String? value}) {
    if (_prefs != null) _prefs!.setString(key, value ?? "");
  }

  String getString({required String key}) {
    return _prefs == null ? "" : _prefs!.getString(key) ?? (key == language ? StringUtils.english : "");
  }

  void setBool({String? key, bool? value}) {
    if (_prefs != null) _prefs!.setBool(key ?? "", value ?? false);
  }

  bool getBool({String? key}) {
    return _prefs == null ? false : _prefs!.getBool(key ?? '') ?? false;
  }

  void setInt({String? key, int? value}) {
    if (_prefs != null) _prefs!.setInt(key ?? '', value ?? 0);
  }

  int getInt({required String key}) {
    return _prefs == null ? 0 : _prefs!.getInt(key) ?? 0;
  }

  ///

  Future<void> setRecentJson({
    required FilesDataModel data,
  }) async {
    List<FilesDataModel> recentList = await getRecentJson();

    for (int i = 0; i < recentList.length; i++) {
      if (recentList[i].path.path == data.path.path) {
        recentList.removeAt(i);
      }
    }

    recentList.add(
      FilesDataModel(
        count: data.count,
        path: data.path,
        name: data.name,
        size: data.size,
        date: data.date,
        selected: data.selected,
        bookmark: data.bookmark,
      ),
    );

    List<String> jsonStringList = recentList.map((result) => jsonEncode(result.toJson())).toList();

    await _prefs?.setStringList(recent, jsonStringList);
  }

  Future<void> updateRecentJson({
    required String path,
    required bool bookmarkValue,
  }) async {
    List<FilesDataModel> recentList = await getRecentJson();

    for (int i = 0; i < recentList.length; i++) {
      if (recentList[i].path.path == path) {
        recentList[i].bookmark = bookmarkValue;
      }
    }

    List<String> jsonStringList = recentList.map((result) => jsonEncode(result.toJson())).toList();

    await _prefs?.setStringList(recent, jsonStringList);
  }

  Future<void> updateRecentPathJson({
    required String path,
    required String newPath,
  }) async {
    List<FilesDataModel> recentList = await getRecentJson();

    for (int i = 0; i < recentList.length; i++) {
      if (recentList[i].path.path == path) {
        recentList[i].path = File(newPath);
        recentList[i].name = recentList[i].path.path.split('/').last;
      }
    }

    List<String> jsonStringList = recentList.map((result) => jsonEncode(result.toJson())).toList();

    await _prefs?.setStringList(recent, jsonStringList);
  }

  Future<void> deleteRecentJson({required String path}) async {
    List<FilesDataModel> recentList = await getRecentJson();

    for (int i = 0; i < recentList.length; i++) {
      if (recentList[i].path.path == path) {
        recentList.removeAt(i);
      }
    }

    List<String> jsonStringList = recentList.map((result) => jsonEncode(result.toJson())).toList();

    await _prefs?.setStringList(recent, jsonStringList);
  }

  Future<List<FilesDataModel>> getRecentJson() async {
    List<String>? jsonStringList = _prefs?.getStringList(recent);

    if (jsonStringList == null) {
      return [];
    }

    List<FilesDataModel> recentList = jsonStringList.map((jsonString) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return FilesDataModel.fromJson(jsonMap);
    }).toList();

    return recentList;
  }

  /// bookmark
  Future<void> setBookmarkJson({required FilesDataModel data}) async {
    List<FilesDataModel> bookmarkList = await getBookmarkJson();

    for (int i = 0; i < bookmarkList.length; i++) {
      if (bookmarkList[i].path.path == data.path.path) {
        bookmarkList.removeAt(i);
      }
    }

    bookmarkList.add(
      FilesDataModel(
        count: data.count,
        path: data.path,
        name: data.name,
        size: data.size,
        date: data.date,
        selected: data.selected,
        bookmark: data.bookmark,
      ),
    );

    List<String> jsonStringList = bookmarkList.map((result) {
      return jsonEncode(result.toJson());
    }).toList();
    await _prefs?.setStringList(bookmark, jsonStringList);
  }

  Future<void> updateBookmarkPathJson({
    required String path,
    required String newPath,
  }) async {
    List<FilesDataModel> bookmarkList = await getBookmarkJson();

    for (int i = 0; i < bookmarkList.length; i++) {
      if (bookmarkList[i].path.path == path) {
        bookmarkList[i].path = File(newPath);
        bookmarkList[i].name = bookmarkList[i].path.path.split('/').last;
      }
    }

    List<String> jsonStringList = bookmarkList.map((result) => jsonEncode(result.toJson())).toList();

    await _prefs?.setStringList(bookmark, jsonStringList);
  }

  Future<List<FilesDataModel>> getBookmarkJson() async {
    List<String>? jsonStringList = _prefs?.getStringList(bookmark);

    if (jsonStringList == null) {
      return [];
    }

    List<FilesDataModel> bookmarkList = jsonStringList.map((jsonString) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      return FilesDataModel.fromJson(jsonMap);
    }).toList();
    return bookmarkList;
  }

  Future deleteBookmarkJson({required String path}) async {
    List<FilesDataModel> bookmarkList = await getBookmarkJson();

    for (int i = 0; i < bookmarkList.length; i++) {
      if (bookmarkList[i].path.path == path) {
        bookmarkList.removeAt(i);
      }
    }

    List<String> jsonStringList = bookmarkList.map((result) {
      return jsonEncode(result.toJson());
    }).toList();
    await _prefs?.setStringList(bookmark, jsonStringList);
  }

  ///
  Future clearPreferenceData() async {
    _prefs?.clear();
  }
}
