import 'dart:io';

import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/views/operations/read_meter/bloc/read_meter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class FlagCustomerView extends StatefulWidget {
  const FlagCustomerView({super.key});

  @override
  State<FlagCustomerView> createState() => _FlagCustomerViewState();
}

class _FlagCustomerViewState extends State<FlagCustomerView> {
  late final TextEditingController _commentTextController;
  File? _image;

  Future getImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (image == null) {
        return;
      }

      final imageTemporary = File(image.path);

      setState(() {
        _image = imageTemporary;
      });
    } on PlatformException catch (e) {
      await showErrorDialog(context, 'Failed to pick image: $e');
    }
  }

  @override
  void initState() {
    _commentTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadMeterBloc, ReadMeterState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Flag Customer'),
            leading: BackButton(
              onPressed: () {
                context
                    .read<ReadMeterBloc>()
                    .add(const ReadMeterEventClickedBackToFirstPage());
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                _image != null
                    ? Image.file(
                        _image!,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        "assets/images/camera.png",
                        height: 250,
                        width: 250,
                      ),
                CustomButton(
                  title: 'Take Picture',
                  icon: Icons.camera,
                  onClick: () async {
                    await getImage();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  minLines: 3,
                  maxLines: 3,
                  controller: _commentTextController,
                  decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.0))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_image == null) {
                      await showErrorDialog(
                          context, 'No image to upload! Take Pic');
                    } else {
                      context.read<ReadMeterBloc>().add(
                          ReadMeterEventSubmitFlagReport(
                              comment: _commentTextController.text,
                              image: _image!));
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
