import 'package:flutter/foundation.dart';

typedef CloseGenericEnquiry = bool Function();

@immutable
class GenericOverlayEnquiryController {
  final CloseGenericEnquiry close;

  const GenericOverlayEnquiryController({
    required this.close,
  });
}
