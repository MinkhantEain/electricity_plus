import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:electricity_plus/services/models/bluetooth_printer.dart';
import 'package:electricity_plus/utilities/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/esc_pos_utils_platform.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:image/image.dart' as img;
import 'package:screenshot/screenshot.dart';

class PrinterSelectView extends StatefulWidget {
  const PrinterSelectView({super.key});

  @override
  State<PrinterSelectView> createState() => _PrinterSelectViewState();
}

class _PrinterSelectViewState extends State<PrinterSelectView> {
  final ScreenshotController screenshotController = ScreenshotController();
  // Printer Type [bluetooth, usb, network]
  var _isConnected = false;
  var printerManager = PrinterManager.instance;
  var devices = <BluetoothPrinter>[];
  StreamSubscription<PrinterDevice>? _subscription;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;

  BTStatus _currentStatus = BTStatus.none;
  // _currentUsbStatus is only supports on Android
  // ignore: unused_field
  List<int>? pendingTask;
  String _port = '9100';
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  BluetoothPrinter? selectedPrinter;

  @override
  void initState() {
    super.initState();
    _portController.text = _port;
    _scan();

    // subscription to listen change status of bluetooth connection
    _subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      log(' ----------------- status bt $status ------------------ ');
      _currentStatus = status;
      if (status == BTStatus.connected) {
        setState(() {
          _isConnected = true;
        });
      }
      if (status == BTStatus.none) {
        setState(() {
          _isConnected = false;
        });
      }
      if (status == BTStatus.connected && pendingTask != null) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          });
        } else if (Platform.isIOS) {
          PrinterManager.instance
              .send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscriptionBtStatus?.cancel();
    _portController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  // method to scan devices according PrinterType
  void _scan() {
    devices.clear();
    _subscription =
        printerManager.discovery(type: PrinterType.bluetooth).listen((device) {
      devices.add(BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: PrinterType.bluetooth,
      ));
      setState(() {});
    });
  }

  void selectDevice(BluetoothPrinter device) async {
    if (selectedPrinter != null) {
      if ((device.address != selectedPrinter!.address) ||
          (device.typePrinter == PrinterType.usb &&
              selectedPrinter!.vendorId != device.vendorId)) {
        await PrinterManager.instance
            .disconnect(type: selectedPrinter!.typePrinter);
      }
    }

    selectedPrinter = device;
    setState(() {});
  }

  Future printReceiveTest() async {
    List<int> bytes = [];

    // Xprinter XP-N160I
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    // default profile
    // final profile = await CapabilityProfile.load();

    // PaperSize.mm80 or PaperSize.mm58
    final generator = Generator(PaperSize.mm58, profile);
    await screenshotController
        .captureFromWidget(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: const Text(
              "This isမြန်မာစကားwidget",
              style: TextStyle(color: Colors.black),
            )),
        Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: const Text(
              "This isမြန်မာစကားwidget",
              style: TextStyle(color: Colors.black),
            )),
        Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: const Text(
              "This isမြန်မာစကားwidget",
              style: TextStyle(color: Colors.black),
            )),
      ],
    ))
        .then((capturedImage) async {
      final decodedImage = img.decodeImage(capturedImage)!;
      // Create a black bottom layer
      // Resize the image to a 130x? thumbnail (maintaining the aspect ratio).
      img.Image thumbnail = img.copyResize(
        decodedImage,
        width: 350,
      );
      // creates a copy of the original image with set dimensions
      // img.Image originalImg = img.copyResize(decodedImage, width: 380, height: 130);
      // fills the original image with a white background
      img.fill(decodedImage, color: img.ColorRgb8(255, 255, 255));

      //insert the image inside the frame and center it
      drawImage(decodedImage, thumbnail);

      // convert image to grayscale
      var grayscaleImage = img.grayscale(decodedImage);

      // bytes += generator.feed(1);
      // bytes += generator.imageRaster(img.decodeImage(imageBytes)!, align: PosAlign.center);
      bytes += generator.imageRaster(grayscaleImage, align: PosAlign.center);
    });
    _printEscPos(bytes, generator);
  }

  /// print ticket
  void _printEscPos(List<int> bytes, Generator generator) async {
    if (selectedPrinter == null) return;
    var bluetoothPrinter = selectedPrinter!;

    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.bluetooth:
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: BluetoothPrinterInput(
                name: bluetoothPrinter.deviceName,
                address: bluetoothPrinter.address!));
        pendingTask = null;
        if (Platform.isAndroid) pendingTask = bytes;
        break;
      default:
    }
    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth &&
        Platform.isAndroid) {
      if (_currentStatus == BTStatus.connected) {
        printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
        pendingTask = null;
      }
    }
  }

  // conectar dispositivo
  _connectDevice() async {
    _isConnected = false;
    if (selectedPrinter == null) return;
    switch (selectedPrinter!.typePrinter) {
      case PrinterType.bluetooth:
        log('name: ${selectedPrinter!.deviceName}, address: ${selectedPrinter!.address!}');
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: BluetoothPrinterInput(
                name: selectedPrinter!.deviceName,
                address: selectedPrinter!.address!));
        break;
      default:
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Pos Plugin Platform example app'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Container(
          height: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedPrinter == null || _isConnected
                              ? null
                              : () {
                                  _connectDevice();
                                },
                          child: const Text("Connect",
                              textAlign: TextAlign.center),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedPrinter == null || !_isConnected
                              ? null
                              : () {
                                  if (selectedPrinter != null) {
                                    printerManager.disconnect(
                                        type: selectedPrinter!.typePrinter);
                                  }
                                  setState(() {
                                    _isConnected = false;
                                  });
                                },
                          child: const Text("Disconnect",
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                    children: devices
                        .map(
                          (device) => ListTile(
                            title: Text('${device.deviceName}'),
                            subtitle: Platform.isAndroid == true
                                ? Visibility(
                                    visible: !Platform.isWindows,
                                    child: Text("${device.address}"))
                                : null,
                            onTap: () {
                              // do something
                              selectDevice(device);
                            },
                            leading: selectedPrinter != null &&
                                    ((device.typePrinter == PrinterType.usb &&
                                                Platform.isWindows
                                            ? device.deviceName ==
                                                selectedPrinter!.deviceName
                                            : device.vendorId != null &&
                                                selectedPrinter!.vendorId ==
                                                    device.vendorId) ||
                                        (device.address != null &&
                                            selectedPrinter!.address ==
                                                device.address))
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : null,
                            trailing: OutlinedButton(
                              onPressed: selectedPrinter == null ||
                                      device.deviceName !=
                                          selectedPrinter?.deviceName
                                  ? null
                                  : () async {
                                      printReceiveTest();
                                    },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 20),
                                child: Text("Print test ticket",
                                    textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                        )
                        .toList()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
