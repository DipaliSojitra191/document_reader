// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:document_reader/shared_Preference/preferences_helper.dart';
import 'package:document_reader/src/file/bloc/all_file_event.dart';
import 'package:document_reader/src/file/bloc/all_file_state.dart';
import 'package:document_reader/src/file/model/files_data_model.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/custom_data/custom_dialog.dart';
import 'package:document_reader/utils/logs.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AllFileBloc extends Bloc<AllFileEvent, AllFileBlocState> {
  AllFileBloc() : super(AllFileInitial()) {
    on<GetFileEvent>(getFileEvent);
    on<GetDirEvent>(getDirEvent);
    on<FilterEvent>(filterEvent);
    on<FileSelectEvent>(fileSelectEvent);
    on<FileSelectedUnSelectedEvent>(fileSelectedUnSelectedEvent);
    on<SearchOnTapEvent>((event, emit) {
      emit(SearchOnTapState(search: event.search));
    });
    on<SelectedBackTapEvent>((event, emit) {
      emit(SelectedBackTapState(selected: event.selected));
    });

    on<DirSelectedEvent>((event, emit) {
      emit(DirSelectedState(index: event.index));
    });

    on<SearchListEvent>((event, emit) {
      List<FilesDataModel> results = event.allFiles
          .where(
            (item) => item.name.toLowerCase().contains(event.searchText.toString().toLowerCase()),
          )
          .toList();

      emit(
        SearchListState(searchList: results, isDocument: event.isDocument),
      );
    });
  }

  String directory = "";
  List<FilesDataModel> allFiles = [];

  fileSelectedUnSelectedEvent(FileSelectedUnSelectedEvent event, Emitter<AllFileBlocState> emit) {
    if (event.selected == false) {
      for (var element in event.allFiles) {
        element.selected = false;
      }
    }
    emit(GetFileState(allFiles: event.allFiles, selected: event.selected));
  }

  fileSelectEvent(FileSelectEvent event, Emitter<AllFileBlocState> emit) {
    emit(
      FileSelectState(
        isBookmark: event.isBookmark,
        selected: event.selected,
        index: event.index,
      ),
    );
  }

  bool hasPermission = false;

  getFileEvent(GetFileEvent event, Emitter<AllFileBlocState> emit) async {
    // List<FilesDataModel> allFiles = [
    //   FilesDataModel(
    //     count: "1",
    //     size: "17 KB",
    //     path: File("1"),
    //     selected: false,
    //     bookmark: false,
    //     isFolder: false,
    //     name: "entity ${Random().nextInt(100)}.pdf",
    //     date: DateTime.now().toString(),
    //   ),
    //   FilesDataModel(
    //     count: "2",
    //     size: "15 KB",
    //     path: File("2"),
    //     selected: false,
    //     bookmark: false,
    //     isFolder: false,
    //     name: "entity ${Random().nextInt(100)}.doc",
    //     date: DateTime.now().toString(),
    //   ),
    //   FilesDataModel(
    //     count: "3",
    //     size: "13 KB",
    //     path: File("3"),
    //     selected: false,
    //     bookmark: false,
    //     isFolder: false,
    //     name: "entity ${Random().nextInt(100)}.ppt",
    //     date: DateTime.now().toString(),
    //   ),
    //   FilesDataModel(
    //     count: "4",
    //     size: "11 KB",
    //     path: File("4"),
    //     selected: false,
    //     bookmark: false,
    //     isFolder: false,
    //     name: "entity ${Random().nextInt(100)}.txt",
    //     date: DateTime.now().toString(),
    //   ),
    //   FilesDataModel(
    //     count: "5",
    //     size: "15 KB",
    //     path: File("5"),
    //     selected: false,
    //     bookmark: false,
    //     isFolder: false,
    //     name: "entity ${Random().nextInt(100)}.ppt",
    //     date: DateTime.now().toString(),
    //   ),
    //   FilesDataModel(
    //     count: "6",
    //     size: "20 KB",
    //     path: File("6"),
    //     selected: false,
    //     bookmark: false,
    //     isFolder: false,
    //     name: "entity ${Random().nextInt(100)}.xls",
    //     date: DateTime.now().toString(),
    //   ),
    // ];
    //
    // emit(GetFileState(allFiles: allFiles));

    allFiles = [];
    bool s1 = await Permission.mediaLibrary.status == PermissionStatus.granted;
    bool s = await Permission.manageExternalStorage.status == PermissionStatus.granted;

    hasPermission = s1 == true && s == true;
    if (!hasPermission) {
      if (Platform.isAndroid) {
        logs(message: "show permission dialog");
        await permissionDialog(
          internetContext: event.context,
          allow: () async {
            hasPermission = await storagePermission(context: event.context);
            if (hasPermission) {
              navigateBack(context: event.context);
              CheckStoragePermissionStatus(isGranted: true);
            } else {
              CheckStoragePermissionStatus(isGranted: false);
              return;
            }
          },
        );
      }
    }

    emit(GetFileLoadingState());
    List ext = [];

    switch (event.fileType.toLowerCase()) {
      case "all":
        ext = [".pdf", ".doc", ".docx", ".ppt", ".pptx", ".xls", ".xlsx", ".txt", ".png", ".jpg", ".jpeg"];
        break;
      case "pdf":
        ext = [".pdf"];
        break;
      case "word":
        ext = [".doc", ".docx"];
        break;
      case "ppt":
        ext = [".ppt", ".pptx"];
        break;
      case "excel":
        ext = ['.xls', '.xlsx'];
        break;
      case "text":
        ext = ['.txt'];
        break;
      case "image":
        ext = ['.png', '.jpg', '.jpeg'];
        break;
      case "directories":
        ext = ['dir'];
        break;
      default:
        ext = [""];
    }

    if (Platform.isIOS) {
      logs(message: "IF part");
      await Permission.storage.request();

      emit(GetFileState(allFiles: allFiles));
    } else {
      if (ext[0] == "dir") {
        try {
          Directory dir = Directory('/storage/emulated/0');
          directory = dir.path;

          List<FileSystemEntity> dirEntity = await dir.list().toList();

          for (var entity1 in dirEntity) {
            String path = entity1.path;
            FileSystemEntity entity = File(path);
            if (entity.statSync().type == FileSystemEntityType.file) {
              await addFile(entity1: File(entity1.path));
            } else if (entity.statSync().type == FileSystemEntityType.directory) {
              await addFile(entity1: File(entity1.path), isFolder: true);
            } else {}
          }
        } catch (e) {
          logs(message: "DIRectories not found", name: 'directory');
        }
      } else if (ext != [""]) {
        try {
          Directory dir = Directory('/storage/emulated/0/');
          directory = dir.path;
          List<FileSystemEntity> dirEntity = await dir.list().toList();
          for (var element in ext) {
            for (var entity1 in dirEntity) {
              if (entity1.path.toLowerCase().endsWith(element)) {
                await addFile(entity1: File(entity1.path));
              }
            }
          }
        } catch (e) {
          debugPrint("E:--> $e");
          logs(message: "DIR not found", name: 'directory');
        }

        ///
        try {
          Directory dirDocument = Directory('/storage/emulated/0/documents/');
          directory = dirDocument.path;

          List<FileSystemEntity> entities = await dirDocument.list().toList();
          for (var element in ext) {
            for (var entity in entities) {
              if (entity.path.toLowerCase().endsWith(element)) {
                await addFile(entity1: File(entity.path));
              }
            }
          }
        } catch (e) {
          debugPrint("E:--> $e");
          logs(message: "Document not found", name: 'directory');
        }

        ///
        try {
          Directory download = Directory('/storage/emulated/0/download/');
          directory = download.path;
          List<FileSystemEntity> downloadEntities = await download.list().toList();
          for (var element in ext) {
            for (var downloadEntity in downloadEntities) {
              if (downloadEntity.path.toLowerCase().endsWith(element)) {
                await addFile(entity1: File(downloadEntity.path));
              }
            }
          }
        } catch (e) {
          debugPrint("E:--> $e");
          logs(message: "Download not found", name: 'directory');
        }
      }
      await Future.delayed(const Duration(milliseconds: 500));
      allFiles = await filterData(PrefsRepo().getInt(key: PrefsRepo.filter1), PrefsRepo().getInt(key: PrefsRepo.filter2));

      emit(GetFileState(allFiles: allFiles));
    }
  }

  getDirEvent(GetDirEvent event, Emitter<AllFileBlocState> emit) async {
    try {
      allFiles = [];
      emit(GetFileLoadingState());

      Directory dir = Directory(event.dir);
      directory = dir.path;

      List<FileSystemEntity> dirEntity = await dir.list().toList();
      for (var entity1 in dirEntity) {
        String path = entity1.path;
        FileSystemEntity entity = File(path);
        if (entity.statSync().type == FileSystemEntityType.file) {
          await addFile(entity1: File(entity1.path));
        } else if (entity.statSync().type == FileSystemEntityType.directory) {
          await addFile(entity1: File(entity1.path), isFolder: true);
        } else {}
      }
      emit(GetDirState(allFiles: allFiles));
    } catch (e) {
      emit(GetDirState(allFiles: const []));
    }
  }

  filterEvent(FilterEvent event, Emitter<AllFileBlocState> emit) async {
    allFiles = await filterData(event.selected1, event.selected2);
    emit(FilterState(allFiles: allFiles));
  }

  Future<List<FilesDataModel>> filterData(int select1, int select2) async {
    int selected1 = select1;
    int selected2 = select2;

    if (selected2 == 0) {
      if (selected1 == 0) {
        allFiles.sort((a, b) => a.name.compareTo(b.name));
      } else if (selected1 == 1) {
        allFiles.sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
      } else if (selected1 == 2) {
        allFiles.sort((a, b) => a.size.compareTo(b.size));
      }
    } else if (selected2 == 1) {
      if (selected1 == 0) {
        allFiles.sort((a, b) => b.name.compareTo(a.name));
      } else if (selected1 == 1) {
        allFiles.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
      } else if (selected1 == 2) {
        allFiles.sort((a, b) => b.size.compareTo(a.size));
      }
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return allFiles;
  }

  Future<void> addFile({required File entity1, bool? isFolder}) async {
    File file = File(entity1.path);
    isFolder = isFolder ?? false;
    String size = "";

    if (isFolder) {
      try {
        Directory dirDocument = Directory(entity1.path);
        List<FileSystemEntity> entities = await dirDocument.list().toList();
        size = "${entities.length} files";
      } catch (e) {
        size = "0 files";
      }
    } else {
      if (file.existsSync()) {
        int fileSizeInBytes = file.lengthSync();
        double fileSizeInKB = fileSizeInBytes / 1024;
        double fileSizeInMB = fileSizeInKB / 1024;

        if (fileSizeInMB > 1) {
          size = '${fileSizeInMB.toStringAsFixed(2)} KB';
        } else {
          size = '${fileSizeInKB.toStringAsFixed(2)} KB';
        }
      }
    }

    final List<FilesDataModel> data = await PrefsRepo().getBookmarkJson();

    bool match = false;
    for (var element in data) {
      if (element.path.path == entity1.path) {
        match = true;
        break;
      }
    }

    try {
      allFiles.add(
        FilesDataModel(
          count: size,
          size: size,
          path: entity1,
          selected: false,
          bookmark: match,
          isFolder: isFolder,
          name: entity1.path.split("/").last.toString(),
          date: isFolder ? "" : File(entity1.path).lastModifiedSync().toString(),
        ),
      );
    } catch (e) {
      logs(message: "Add File Error:-----> $e");
    }
  }
}
