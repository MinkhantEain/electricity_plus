import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer' as dev show log;
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:image/image.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:screenshot/screenshot.dart';

class PrinterSelectView extends StatefulWidget {
  const PrinterSelectView({super.key});

  @override
  State<PrinterSelectView> createState() => _PrinterSelectViewState();
}

class _PrinterSelectViewState extends State<PrinterSelectView> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  ScreenshotController screenshotController = ScreenshotController();

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'no device connected';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  Future<void> printReceipt() async {
    Map<String, dynamic> config = Map();
    List<LineText> list1 = [];
    ByteData data = await rootBundle.load("assets/images/electric.png");
    List<int> imageBytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    String base64Image = base64Encode(imageBytes);
    list1.add(LineText(
      type: LineText.TYPE_IMAGE,
      x: 10,
      y: 10,
      content: base64Image,
    ));
    await bluetoothPrint.printLabel(config, list1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Printer'),
        leading: BackButton(
          onPressed: () =>
              context.read<OperationBloc>().add(const OperationEventDefault()),
        ),
        actions: [
          StreamBuilder(
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  onPressed: () => bluetoothPrint.stopScan(),
                  icon: const Icon(Icons.stop),
                  iconSize: 30,
                );
              } else {
                return IconButton(
                  onPressed: () {
                    bluetoothPrint.startScan(
                        timeout: const Duration(seconds: 4));
                  },
                  icon: const Icon(Icons.refresh_sharp),
                  iconSize: 30,
                );
              }
            },
            initialData: false,
            stream: bluetoothPrint.isScanning,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            bluetoothPrint.startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Text(tips),
                  ),
                ],
              ),
              const Divider(),
              StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothPrint.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((d) => ListTile(
                            title: Text(d.name ?? ''),
                            subtitle: Text(d.address ?? ''),
                            onTap: () async {
                              setState(() {
                                _device = d;
                              });
                            },
                            trailing:
                                _device != null && _device!.address == d.address
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )
                                    : null,
                          ))
                      .toList(),
                ),
              ),
              const Divider(),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        OutlinedButton(
                          onPressed: _connected
                              ? null
                              : () async {
                                  if (_device != null &&
                                      _device!.address != null) {
                                    setState(() {
                                      tips = 'connecting...';
                                    });
                                    await bluetoothPrint.connect(_device!);
                                  } else {
                                    setState(() {
                                      tips = 'please select device';
                                    });
                                  }
                                },
                          child: const Text('connect'),
                        ),
                        const SizedBox(width: 10.0),
                        OutlinedButton(
                          onPressed: _connected
                              ? () async {
                                  setState(() {
                                    tips = 'disconnecting...';
                                  });
                                  await bluetoothPrint.disconnect();
                                }
                              : null,
                          child: const Text('disconnect'),
                        ),
                      ],
                    ),
                    const Divider(),
                    OutlinedButton(
                      onPressed: _connected
                          ? () async {
                              await printReceipt();
                            }
                          : null,
                      child: const Text('print receipt'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
