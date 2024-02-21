// ignore_for_file: depend_on_referenced_packages

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:document_reader/src/file/model/files_data_model.dart';
import 'package:document_reader/shared_Preference/preferences_helper.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<GetRecentData>((event, emit) async {
      emit(GetRecent(recentList: const [], bookmarkList: const []));

      List<FilesDataModel> recentList = [];
      List<FilesDataModel> bookmarkList = [];
      final PrefsRepo prefsRepo = PrefsRepo();

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
          recentList: tempRecentList,
          bookmarkList: tempBookmarkList,
        ),
      );
    });

    on<RecentTabEvent>((event, Emitter<HomeState> emit) {
      emit(RecentTabState(index: event.index));
    });
    on<RecentBookmarkSelectedEvent>((event, Emitter<HomeState> emit) {
      emit(
        RecentBookmarkSelectedState(
          index: event.index,
          isBookmark: event.isBookmark,
          selected: event.selected,
        ),
      );
    });

    on<ShowBottomMenuEvent>((event, Emitter<HomeState> emit) {
      emit(ShowBottomMenuState(selected: event.selected));
    });
  }
}
