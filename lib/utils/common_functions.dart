import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:document_reader/main.dart';
import 'package:document_reader/shared_Preference/preferences_helper.dart';
import 'package:document_reader/src/file/model/files_data_model.dart';
import 'package:document_reader/utils/AppImages.dart';
import 'package:document_reader/utils/AppStrings.dart';
import 'package:document_reader/utils/custom_data/custom_bottomsheet.dart';
import 'package:document_reader/utils/custom_snackbar.dart';
import 'package:document_reader/utils/logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

/// Permission
Future<bool> storagePermission({required BuildContext context}) async {
  try {
    String permiMessage = AppLocalizations.of(context)?.permissionRequired ?? "";
    if (Platform.isIOS) {
      await Permission.storage.request();
      return (await Permission.storage.status) == PermissionStatus.granted;
    } else {
      await Permission.mediaLibrary.request();
      await Permission.manageExternalStorage.request();
      bool s1 = await Permission.mediaLibrary.status == PermissionStatus.granted;
      bool s = await Permission.manageExternalStorage.status == PermissionStatus.granted;

      if (s1 == false || s == false) {
        if (context.mounted) {
          showSnackBar(message: permiMessage, context: context);
        }
      }

      return s1 == true && s == true;
    }
  } catch (e) {
    logs(message: "Error $e");
    return false;
  }
}

/// File format converter
Future<String> uIntListToPath({required Uint8List imageBytes}) async {
  final Directory tempDir = await getTemporaryDirectory();

  final String tempFileName = '${DateTime.now().toLocal().microsecondsSinceEpoch}.png';

  final File tempFile = File('${tempDir.path}/$tempFileName');
  await tempFile.writeAsBytes(imageBytes);
  return tempFile.path;
}

Future<Uint8List> pathToUIntList({required String path}) async {
  List<int> bytes = await File(path).readAsBytes();
  return Uint8List.fromList(bytes);
}

/// Get language code from name
Locale getLocaleFromName({required String languageName}) {
  switch (languageName) {
    case StringUtils.english:
      return const Locale("en", 'US');
    case StringUtils.arabic:
      return const Locale('ar', 'AR');
    case StringUtils.bulgarian:
      return const Locale('bg', 'BG');
    case StringUtils.czech:
      return const Locale("cs", 'CZ');
    case StringUtils.polish:
      return const Locale("pl", 'PL');
    case StringUtils.french:
      return const Locale("fr", 'CR');
    default:
      return const Locale("en", 'US');
  }
}

class GetTypeNameTitle {
  final String image;
  final String title;
  final String fileType;

  GetTypeNameTitle({required this.image, required this.title, required this.fileType});
}

GetTypeNameTitle getTypeAndTitle({required BuildContext context, required int index}) {
  String image = IconStrings.all;
  String fileType = AppLocalizations.of(context)?.allFiles ?? '';
  String title = "all";

  switch (index) {
    case 0:
      image = IconStrings.all;
      title = AppLocalizations.of(context)?.allFiles ?? '';
      fileType = 'all';
      break;
    case 1:
      image = IconStrings.pdf;
      title = AppLocalizations.of(context)?.pdfFiles ?? '';
      fileType = 'pdf';
      break;
    case 2:
      image = IconStrings.word;
      title = AppLocalizations.of(context)?.wordFiles ?? '';
      fileType = 'word';
      break;
    case 3:
      image = IconStrings.ppt;
      title = AppLocalizations.of(context)?.pptFiles ?? '';
      fileType = 'ppt';
      break;
    case 4:
      image = IconStrings.excel;
      title = AppLocalizations.of(context)?.excelFiles ?? '';
      fileType = 'excel';
      break;
    case 5:
      image = IconStrings.text;
      title = AppLocalizations.of(context)?.txtFiles ?? '';
      fileType = 'text';
      break;
    case 6:
      image = IconStrings.image;
      title = AppLocalizations.of(context)?.imageFiles ?? '';
      fileType = 'image';
      break;
    case 7:
      image = IconStrings.directories;
      title = AppLocalizations.of(context)?.directories ?? '';
      fileType = 'Directories';
      break;
    default:
      logs(message: 'Invalid arguments.');
  }
  return GetTypeNameTitle(image: image, title: title, fileType: fileType);
}

String getImageFromExt(String ext, {bool? isFolder}) {
  String name = "mcs";

  if (isFolder == true) {
    name = "directories";
  } else if (ext.toLowerCase() == "pdf") {
    name = "pdf";
  } else if (ext.toLowerCase() == "doc" || ext.toLowerCase() == "docx") {
    name = "word";
  } else if (ext.toLowerCase() == "ppt" || ext.toLowerCase() == "pptx") {
    name = "ppt";
  } else if (ext.toLowerCase() == "xlsx" || ext.toLowerCase() == "xls") {
    name = "excel";
  } else if (ext.toLowerCase() == "txt") {
    name = "text";
  } else if (ext.toLowerCase() == "png" || ext.toLowerCase() == "jpg" || ext.toLowerCase() == "jpeg") {
    name = "image";
  } else if (ext.toLowerCase() == "png" || ext.toLowerCase() == "jpg" || ext.toLowerCase() == "jpeg") {
    name = "image";
  }
  return "${IconStrings.imgPath}/outline_$name.png";
}

/// File operation
Future<void> shareFile({required List<String> path}) async {
  List<XFile> filePath = [];
  for (var element in path) {
    filePath.add(XFile(element));
  }

  try {
    final result = await Share.shareXFiles(filePath);
    if (result.status == ShareResultStatus.success) {
      logs(message: 'Thank you for sharing the files!');
    }
  } catch (e) {
    logs(message: "$e", name: 'Delete');
  }
}

Future<Map> renameFile({required String oldFilePath, required String newFileName, required BuildContext context}) async {
  File oldFile = File(oldFilePath);

  try {
    if (oldFile.existsSync()) {
      String ext = oldFile.path.split(".").last;
      String directory = oldFile.parent.path;
      String newFilePath = '$directory/$newFileName.$ext';

      oldFile.renameSync(newFilePath);
      showSnackBar(message: "File rename successfully", context: context);
      return {"old": oldFilePath, "new": newFilePath};
    } else {
      logs(message: "File not found");
      return {"old": oldFilePath, "new": ''};
    }
  } catch (e) {
    logs(message: "Catch file rename:-> $e");
    return {"old": oldFilePath, "new": ''};
  }
}

Future<bool> deleteFile(String path) async {
  File oldFile = File(path);

  if (oldFile.existsSync()) {
    try {
      oldFile.deleteSync();
      return true;
    } catch (e) {
      logs(message: "Catch delete file:-> $e");
      return false;
    }
  } else {
    return false;
  }
}

Future openFileOnTap({required FilesDataModel data, required BuildContext context}) async {
  try {
    final result = await OpenFile.open(data.path.path);
    logs(message: "File open.. ${result.message}");

    if (result.type.name == "done") {
      PrefsRepo().setRecentJson(data: data);
    } else {
      if (context.mounted) {
        fileNotSupportBottomSheet(context: context);
      }
    }
  } catch (e) {
    if (context.mounted) {
      fileNotSupportBottomSheet(context: context);
    }
  }
}

Future addToBookmark({
  required FilesDataModel data,
  required bool bookmark,
}) async {
  final PrefsRepo prefsRepo = PrefsRepo();
  List<FilesDataModel> bookmarkData = await prefsRepo.getBookmarkJson();
  List<FilesDataModel> recentData = await prefsRepo.getRecentJson();

  for (int i = 0; i < recentData.length; i++) {
    if (recentData[i].path.path == data.path.path) {
      recentData[i].bookmark = bookmark;
      prefsRepo.updateRecentJson(
        path: data.path.path,
        bookmarkValue: bookmark,
      );
    }
  }

  if (bookmarkData.isEmpty) {
    prefsRepo.setBookmarkJson(data: data);
  } else {
    if (bookmark == true) {
      prefsRepo.setBookmarkJson(data: data);
    } else {
      for (int i = 0; i < bookmarkData.length; i++) {
        if (bookmarkData[i].path.path == data.path.path) {
          prefsRepo.deleteBookmarkJson(path: data.path.path);
        }
      }
    }
  }
}

/// internet connectivity
bool dialogOpen = false;
final Connectivity connectivity = Connectivity();
Future<bool> checkInternetConnection({required BuildContext context}) async {
  try {
    ConnectivityResult result = await connectivity.checkConnectivity();

    connectivitySubscription = connectivity.onConnectivityChanged.listen((ConnectivityResult status) {
      result = status;
    });

    if (result == ConnectivityResult.none) {
      if (dialogOpen == true) {
        if (context.mounted) {
          internetDialog(
            context: context,
            okTap: () {
              dialogOpen = false;
            },
          );
          dialogOpen = true;
        }
      }
    } else {
      if (dialogOpen == true) {
        if (context.mounted) {
          Navigator.pop(context);
          dialogOpen = false;
        }
      }
    }
    ConnectivityResult result1 = await connectivity.checkConnectivity();

    return result1 != ConnectivityResult.none;
  } on PlatformException catch (e) {
    logs(message: '$e', name: 'Error');
    return false;
  }
}

void internetDialog({required VoidCallback okTap, required BuildContext context}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      print("internet dialog open");
      return AlertDialog(
        title: Text(AppLocalizations.of(context)?.noConnectionError ?? ""),
        content: Text(AppLocalizations.of(context)?.checkInternetConnectivity ?? ""),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context)!.ok),
            onPressed: () {
              okTap();
              SystemNavigator.pop();
            },
          ),
        ],
      );
    },
  ).then((value) => print("internet dialog closed....."));
}
