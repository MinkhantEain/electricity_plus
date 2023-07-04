import 'package:flutter/foundation.dart' show immutable;

typedef ColseLoadingScreen = bool Function();

typedef UpdateLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final ColseLoadingScreen close;
  final UpdateLoadingScreen update;

  const LoadingScreenController({
    required this.close,
    required this.update,
  });
}
