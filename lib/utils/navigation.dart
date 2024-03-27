import 'package:flutter/material.dart';

// final BuildContext currentContext = navigatorKey.currentState!.context;

Future<void> navigatorPush({required BuildContext context, required StatefulWidget navigate}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => navigate),
  );
}

navigateBack({required BuildContext context, var result}) {
  Navigator.of(context).pop(result);
}

removeRoute(navigate, {required BuildContext context}) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => navigate),
    (route) => false,
  );
}
