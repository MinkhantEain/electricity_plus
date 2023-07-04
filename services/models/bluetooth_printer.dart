import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';

class BluetoothPrinter {
  int? id;
  String? deviceName;
  String? address;
  String? vendorId;
  String? productId;

  PrinterType typePrinter;
  bool? state;

  BluetoothPrinter(
      {this.deviceName,
      this.address,
      this.state,
      this.vendorId,
      this.productId,
      this.typePrinter = PrinterType.bluetooth,});
}
