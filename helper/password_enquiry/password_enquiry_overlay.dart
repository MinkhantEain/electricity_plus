import 'package:electricity_plus/helper/password_enquiry/password_enquiry_controller.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/utilities/dialogs/password_enquiry_dialogs.dart';
import 'package:flutter/material.dart';

class PasswordEnquiry {
  PasswordEnquiry._sharedInstance();
  static final PasswordEnquiry _shared = PasswordEnquiry._sharedInstance();
  factory PasswordEnquiry() => _shared;

  PasswordEnquiryController? controller;

  void show({
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    controller = showOverlay(context: context, onTap: onTap);
  }

  void hide() {
    controller?.close();
    controller = null;
  }

  PasswordEnquiryController showOverlay({
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    // ignore: no_leading_underscores_for_local_identifiers
    final _password = TextEditingController();

    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      TextField(
                        decoration: const InputDecoration(hintText: 'Password'),
                        controller: _password,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                hide();
                              },
                              child: const Text('Close')),
                          ElevatedButton(
                              onPressed: () async {
                                final serverToken =
                                    await FirebaseCloudStorage().getServerToken;
                                if (serverToken == _password.text.trim()) {
                                  hide();
                                  onTap();
                                } else {
                                  hide();
                                  // ignore: use_build_context_synchronously
                                  await showWrongPasswordErrrDialog(context);
                                  _password.clear();
                                }
                              },
                              child: const Text('Enter')),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    state.insert(overlay);

    return PasswordEnquiryController(
      close: () {
        overlay.remove();
        return true;
      },
    );
  }
}
