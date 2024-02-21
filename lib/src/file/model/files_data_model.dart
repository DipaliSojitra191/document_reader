import 'dart:io';

class FilesDataModel {
  File path;

  String name;
  String size;
  String date;
  bool selected;
  bool? isFolder;
  bool bookmark;

  String count;

  FilesDataModel({
    required this.path,
    this.isFolder,
    required this.name,
    required this.count,
    required this.size,
    required this.date,
    required this.selected,
    required this.bookmark,
  });
  Map<String, dynamic> toJson() {
    return {
      'path': (path.path),
      'name': name,
      'count': count,
      'size': size,
      'date': date,
      'selected': selected,
      'bookmark': bookmark,
      'isFolder': isFolder ?? false,
    };
  }

  factory FilesDataModel.fromJson(Map<String, dynamic> json) {
    return FilesDataModel(
      path: File(json['path']),
      count: json['count'] ?? "0",
      isFolder: json['isFolder'] ?? false,
      name: json['name'],
      size: json['size'],
      date: json['date'],
      selected: json['selected'],
      bookmark: json['bookmark'],
    );
  }
}
