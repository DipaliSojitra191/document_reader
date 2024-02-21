import 'package:document_reader/main.dart';
import 'package:flutter/material.dart';

final BuildContext currentContext = navigatorKey.currentState!.context;

Future<void> navigatorPush(navigate) async {
  await Navigator.push(
    currentContext,
    MaterialPageRoute(builder: (context) => navigate),
  );
}

navigateBack({BuildContext? argsContext, var result}) {
  Navigator.of(argsContext ?? currentContext).pop(result);
}

removeRoute(navigate) {
  Navigator.of(currentContext).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => navigate),
    (route) => false,
  );
}
