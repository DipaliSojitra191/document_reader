abstract class SelectImageEvent {}

class FetchAssetsEvent extends SelectImageEvent {
  final context;

  FetchAssetsEvent({required this.context});
}

class AddAssetsEvent extends SelectImageEvent {
  List<String> selectedAssets = [];
  final String path;

  AddAssetsEvent({
    required this.path,
    required this.selectedAssets,
  });
}
