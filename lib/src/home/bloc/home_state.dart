part of 'home_bloc.dart';

@immutable
abstract class HomeBlocState {}

class HomeInitial extends HomeBlocState {}

class GetRecent extends HomeBlocState {
  final List<FilesDataModel> recentList;
  final List<FilesDataModel> bookmarkList;

  GetRecent({
    required this.recentList,
    required this.bookmarkList,
  });
}

class RecentTabState extends HomeBlocState {
  final int index;

  RecentTabState({required this.index});
}

class RecentBookmarkSelectedState extends HomeBlocState {
  final bool selected;
  final bool isBookmark;
  final int index;

  RecentBookmarkSelectedState({
    required this.selected,
    required this.isBookmark,
    required this.index,
  });
}

class ShowBottomMenuState extends HomeBlocState {
  final bool selected;

  ShowBottomMenuState({required this.selected});
}
