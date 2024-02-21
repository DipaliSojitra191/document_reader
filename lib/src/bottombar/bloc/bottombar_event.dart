abstract class BottomBarEvent {}

class GetPageIndexEvent extends BottomBarEvent {
  final int? index;

  GetPageIndexEvent({this.index});
}
