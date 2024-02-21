part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class GetRecent extends HomeState {
  final List<FilesDataModel> recentList;
  final List<FilesDataModel> bookmarkList;

  GetRecent({
    required this.recentList,
    required this.bookmarkList,
  });
}

class RecentTabState extends HomeState {
  final int index;

  RecentTabState({required this.index});
}

class RecentBookmarkSelectedState extends HomeState {
  final bool selected;
  final bool isBookmark;
  final int index;

  RecentBookmarkSelectedState({
    required this.selected,
    required this.isBookmark,
    required this.index,
  });
}

class ShowBottomMenuState extends HomeState {
  final bool selected;

  ShowBottomMenuState({required this.selected});
}
