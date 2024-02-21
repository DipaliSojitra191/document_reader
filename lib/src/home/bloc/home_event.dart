part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class GetRecentData extends HomeEvent {
  final List<FilesDataModel> allFiles;

  GetRecentData({required this.allFiles});
}

class RecentTabEvent extends HomeEvent {
  final int index;

  RecentTabEvent({required this.index});
}

class RecentBookmarkSelectedEvent extends HomeEvent {
  final bool selected;
  final bool isBookmark;
  final int index;

  RecentBookmarkSelectedEvent({
    required this.selected,
    required this.isBookmark,
    required this.index,
  });
}

class ShowBottomMenuEvent extends HomeEvent {
  final bool selected;

  ShowBottomMenuEvent({required this.selected});
}
