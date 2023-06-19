import 'dart:io';

import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev show log;

import 'package:image_picker/image_picker.dart';

class ImageCommentFlagView extends StatefulWidget {
  const ImageCommentFlagView({super.key});

  @override
  State<ImageCommentFlagView> createState() => _ImageCommentFlagViewState();
}

class _ImageCommentFlagViewState extends State<ImageCommentFlagView> {
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
    return BlocBuilder<OperationBloc, OperationState>(
      builder: (context, state) {
        state as OperationStateImageCommentFlag;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Image, Comment and Flag"),
            leading: BackButton(
              onPressed: () {
                context.read<OperationBloc>().add(
                      OperationEventCreateNewElectricLog(
                        customer: state.customer,
                        newReading: '',
                      ),
                    );
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
                Row(
                  children: [
                    const Text("Flag:"),
                    Checkbox(
                      value: isChecked,
                      activeColor: Colors.black,
                      onChanged: (value) {
                        dev.log(value.toString());
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
                          .read<OperationBloc>()
                          .add(OperationEventLogSubmission(
                            comment: _commentTextController.text,
                            image: _image!,
                            customer: state.customer,
                            flag: isChecked,
                            newReading: state.newReading,
                          ));
                    }

                    //send image to cloud storage
                    //update customer flag field and last unit
                    //update new history url and comment
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
