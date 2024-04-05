import 'dart:io';

import 'package:document_reader/src/file/model/files_data_model.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => TestState();
}

class TestState extends State<Test> {
  List<FilesDataModel> files = [];
  final List<FilesDataModel> tempList = [
    FilesDataModel(
      count: "1",
      size: "17 KB",
      path: File("https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"),
      selected: false,
      bookmark: true,
      isFolder: false,
      name: "dummy.pdf",
      date: DateTime.now().toString(),
    ),
    FilesDataModel(
      count: "1",
      size: "17 KB",
      path: File("https://clickdimensions.com/links/TestPDFfile.pdf"),
      selected: false,
      bookmark: true,
      isFolder: false,
      name: "TestPDFfile.pdf",
      date: DateTime.now().toString(),
    ),
    FilesDataModel(
      count: "1",
      size: "17 KB",
      path: File("https://picsum.photos/seed/500/100"),
      selected: false,
      bookmark: false,
      isFolder: false,
      name: "seed500.png",
      date: DateTime.now().toString(),
    ),
    FilesDataModel(
      count: "1",
      size: "17 KB",
      path: File("https://picsum.photos/seed/501/100"),
      selected: false,
      bookmark: false,
      isFolder: false,
      name: "seed501.png",
      date: DateTime.now().toString(),
    ),
  ];

  Future<void> getDataFromStorage() async {
    await Permission.photos.request();
    photosStatus = await Permission.photos.status;
    () {
      setState(() {});
    }();
  }

  PermissionStatus photosStatus = PermissionStatus.provisional;

  checkPermission() async {
    photosStatus = await Permission.photos.request();
    print("status: $photosStatus");
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkPermission();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.cyan),
      body: Center(child: Text(photosStatus.toString(), key: const Key('status'))),
    );
  }
}
