// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:document_reader/shared_Preference/preferences_helper.dart';
import 'package:document_reader/src/file/model/files_data_model.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeBlocState> {
  HomeBloc() : super(HomeInitial()) {
    on<GetRecentData>((event, emit) async {
      emit(GetRecent(recentList: const [], bookmarkList: const []));

      List<FilesDataModel> recentList = [];
      List<FilesDataModel> bookmarkList = [];
      final PrefsRepo prefsRepo = PrefsRepo();

      FilesDataModel data = FilesDataModel(
        path: File("https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"),
        name: "recent name.png",
        count: "10",
        size: "20",
        date: DateTime.now().toString(),
        selected: false,
        bookmark: false,
      );
      FilesDataModel data1 = FilesDataModel(
        path: File("https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"),
        name: "bookmark name.png",
        count: "10",
        size: "20",
        date: DateTime.now().toString(),
        selected: false,
        bookmark: true,
      );

      // prefsRepo.setRecentJson(data: data);
      // prefsRepo.setBookmarkJson(data: data1);

      List<FilesDataModel> tempRecentList = await prefsRepo.getRecentJson();
      List<FilesDataModel> tempBookmarkList = await prefsRepo.getBookmarkJson();

      if (tempBookmarkList.isNotEmpty || tempRecentList.isNotEmpty) {
        for (var element in tempRecentList) {
          for (var ele in event.allFiles) {
            if (ele.path.path == element.path.path) {
              recentList.add(ele);
            }
          }
        }

        for (var element in tempBookmarkList) {
          for (var ele in event.allFiles) {
            if (ele.path.path == element.path.path) {
              bookmarkList.add(ele);
              break;
            }
          }
        }
      }

      emit(
        GetRecent(
          recentList: [data],
          bookmarkList: [data1],
        ),
      );
    });

    on<RecentTabEvent>((RecentTabEvent event, Emitter<HomeBlocState> emit) {
      emit(RecentTabState(index: event.index));
    });

    on<RecentBookmarkSelectedEvent>((RecentBookmarkSelectedEvent event, Emitter<HomeBlocState> emit) {
      emit(
        RecentBookmarkSelectedState(
          index: event.index,
          isBookmark: event.isBookmark,
          selected: event.selected,
        ),
      );
    });

    on<ShowBottomMenuEvent>((ShowBottomMenuEvent event, Emitter<HomeBlocState> emit) {
      emit(ShowBottomMenuState(selected: event.selected));
    });
  }
}
