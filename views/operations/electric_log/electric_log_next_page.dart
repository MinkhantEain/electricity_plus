import 'dart:io';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/views/operations/electric_log/bloc/electric_log_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev show log;

import 'package:image_picker/image_picker.dart';

class ELectricLogNextPageView extends StatefulWidget {
  const ELectricLogNextPageView({super.key});

  @override
  State<ELectricLogNextPageView> createState() =>
      _ELectricLogNextPageViewState();
}

class _ELectricLogNextPageViewState extends State<ELectricLogNextPageView> {
  late final TextEditingController _commentTextController;
  bool isChecked = false;
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
    return BlocBuilder<ElectricLogBloc, ElectricLogState>(
      builder: (context, state) {
        dev.log(state.toString());
        if (state is ELectricLogFormNextPage) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Image, Comment and Flag"),
              leading: BackButton(
                onPressed: () {
                  context
                      .read<ElectricLogBloc>()
                      .add(const ElectricLogClickedBackOnNextPage());
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
                          borderSide:
                              BorderSide(color: Colors.green, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0))),
                  ),
                  Row(
                    children: [
                      const Text("Flag:"),
                      Checkbox(
                        value: isChecked,
                        activeColor: Colors.black,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                      )
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_image == null) {
                        await showErrorDialog(
                            context, 'No image to upload! Take Pic');
                      } else {
                        context
                            .read<ElectricLogBloc>()
                            .add(ElectricLogSubmission(
                              comment: _commentTextController.text,
                              image: _image!,
                              customer: state.customer,
                              flag: isChecked,
                              newReading: state.newReading,
                            ));
                      }
                    },
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
