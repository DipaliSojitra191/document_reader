import 'dart:developer';

logs({String? name, required String message}) {
  log(name: (name ?? 'log').toUpperCase(), message);
}
