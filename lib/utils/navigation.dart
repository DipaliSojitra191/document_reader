import 'package:flutter/material.dart';

Future<void> navigatorPush({required BuildContext context, required StatefulWidget navigate}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => navigate),
  );
}

navigateBack({required BuildContext context}) {
  Navigator.of(context).pop();
}

removeRoute({required StatefulWidget navigate, required BuildContext context}) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => navigate),
    (route) => false,
  );
}
