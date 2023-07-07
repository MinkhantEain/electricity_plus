import 'package:flutter/foundation.dart';

typedef ClosePasswordEnquiry = bool Function();

@immutable
class PasswordEnquiryController {
  final ClosePasswordEnquiry close;

  const PasswordEnquiryController({
    required this.close,
  });
}
