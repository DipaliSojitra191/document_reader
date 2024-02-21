abstract class BottomBarState {}

class BottomBarInitial extends BottomBarState {}

class GetPageIndexState extends BottomBarState {
  final int? index;

  GetPageIndexState({this.index});
}
