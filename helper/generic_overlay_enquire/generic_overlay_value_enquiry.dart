import 'package:electricity_plus/helper/generic_overlay_enquire/generic_overlay_value_enquirer_controller.dart';
import 'package:flutter/material.dart';

class GenericOverlayEnquiry {
  GenericOverlayEnquiry._sharedInstance();
  static final GenericOverlayEnquiry _shared =
      GenericOverlayEnquiry._sharedInstance();
  factory GenericOverlayEnquiry() => _shared;

  GenericOverlayEnquiryController? controller;

  void show({
    required BuildContext context,
    required VoidCallback onTap,
    required bool condition,
    required Future<void>? dialog,
  }) {
    controller = showOverlay(
        context: context, onTap: onTap, condition: condition, dialog: dialog);
  }

  void hide() {
    controller?.close();
    controller = null;
  }

  GenericOverlayEnquiryController showOverlay({
    required BuildContext context,
    required VoidCallback onTap,
    required bool condition,
    required Future<void>? dialog,
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
                                if (condition) {
                                  hide();
                                  onTap();
                                } else {
                                  hide();
                                  // ignore: use_build_context_synchronously
                                  if (dialog != null) {
                                    await dialog;
                                  }

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

    return GenericOverlayEnquiryController(
      close: () {
        overlay.remove();
        return true;
      },
    );
  }
}
