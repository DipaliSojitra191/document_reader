abstract class SelectImageEvent {}

class FetchAssetsEvent extends SelectImageEvent {}

class AddAssetsEvent extends SelectImageEvent {
  List<String> selectedAssets = [];
  final String path;

  AddAssetsEvent({
    required this.path,
    required this.selectedAssets,
  });
}
