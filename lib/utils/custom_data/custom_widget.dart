import 'dart:developer';

import 'package:document_reader/src/file/model/files_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// common widget
Widget menus({
  required BuildContext context,
  required VoidCallback onTap,
  required String name,
  required String image,
  required FilesDataModel allFiles,
}) {
  return Column(
    key: Key('widget-$name'),
    children: [
      InkWell(
        key: Key('onTap-$name'),
        onTap: () {
          print('onTap-$name');
          log("object:-----> $name");
          onTap();
        },
        // onTap: onTap,
        child: Image.asset(image, scale: 4.w),
      ),
      SizedBox(height: 5.h),
      Text(
        key: Key('text-$name'),
        name,
        style: Theme.of(context).textTheme.displaySmall,
      ),
    ],
  );
}
