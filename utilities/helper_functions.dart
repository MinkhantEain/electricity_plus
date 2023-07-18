import 'dart:async';
import 'dart:typed_data';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/utilities/image_utils.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/esc_pos_utils_platform.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:image/image.dart' as img;

bool isNumeric(String? input) {
  if (input == null) {
    return false;
  } else {
    if (num.tryParse(input) == null) {
      return false;
    } else {
      return true;
    }
  }
}

String currentMonthYearDate() {
  return DateTime.now().toString().substring(0, 7);
}

///month date format of the previous year
String pastMonthYearDate() {
  return '${num.parse(DateTime.now().toString().substring(0, 4)) - 1}${DateTime.now().toString().substring(4, 7)}-01';
}

bool isWithinMonth(String date) {
  return DateTime.parse(date).isBefore(DateTime.now()) &&
      DateTime.parse(date).isAfter(
          DateTime.parse('${DateTime.now().toString().substring(0, 7)}-01'));
}

///return the previous month date of given date
///eg valid format 2023/05...
///if not valid date then return the date of the previous month date
String previousMonthYearDateNumericFormat({String? date}) {
  date ??= DateTime.now().toString();
  if (date.length < 7) {
    date = DateTime.now().toString();
  }
  num month = num.parse(date.substring(5, 7));
  num year = num.parse(date.substring(0, 4));
  if (month == 1) {
    month = 12;
    year -= 1;
  } else {
    month -= 1;
  }
  String result;
  if (month < 10) {
    result = '$year-0$month';
  } else {
    result = '$year-$month';
  }
  return result;
}

String paymentDueDate(String meterReadDate) {
  String result;
  result = '20/${dayMonthYearNumericFormat(meterReadDate).substring(3)}';

  return result;
}

// String billPaymentDueDate(String m)

///change from 2023/01/23 to Jan 2023
String monthYearWordFormat(String date) {
  final month = date.substring(5, 7);
  final year = date.substring(0, 4);
  Map<String, String> monthName = {
    '01': 'Jan',
    '02': 'Feb',
    '03': 'Mar',
    '04': 'Apr',
    '05': 'May',
    '06': 'Jun',
    '07': 'Jul',
    '08': 'Aug',
    '09': 'Sep',
    '10': 'Oct',
    '11': 'Nov',
    '12': 'Dec',
  };
  return '${monthName[month]} $year';
}

///If now is 2023/07/01, it will output 2023-01
///if now is 2023/06/01, it will output 2022-12
String halfYearAgo() {
  final currentMonth = DateTime.now().month;
  final resultantMonth = currentMonth - 6;
  final outPutYear = resultantMonth <= 0 ? DateTime.now().year - 1 : DateTime.now().year;
  final outPutMonth = resultantMonth <= 0 ? 12 - resultantMonth : resultantMonth;
  return '$outPutYear-$outPutMonth';
}

///change from 2023/05/11 to 11/05/2023
String dayMonthYearNumericFormat(String date) {
  String day;
  if (date.length > 9) {
    day = date.substring(8, 10);
  } else {
    day = date.substring(8);
  }
  final month = date.substring(5, 7);
  final year = date.substring(0, 4);
  return '$day/$month/$year';
}

bool isBookIdFormat(String input) {
  final inputCodeUnit = input.codeUnits;
  if (!intIsBetween(inputCodeUnit[0], 65, 90)) {
    return false;
  }
  if (input[2] != '/' && input[5] != '/') {
    return false;
  }
  input = input.substring(1).replaceAll(RegExp(r'/'), '');
  for (int code in input.codeUnits) {
    if (!intIsBetween(code, 48, 57)) {
      return false;
    }
  }
  return true;
}

String getTempBookId(String bookId) {
  List<int> codes = bookId.codeUnits.toList();
  codes.replaceRange(0,1,[codes[0] + 13]);
  
  return String.fromCharCodes(codes);
}

  String bookIdToDocId(String bookId) {
    return bookId.replaceAll(RegExp(r'/'), '-');
  }

  String docIdToBookId(String bookId) {
    return bookId.replaceAll(RegExp(r'-'), '/');
  }


bool intIsBetween(int input, int startInclusive, int endInclusive) {
  return input >= startInclusive && input <= endInclusive;
}

bool isIntInput(String input) {
  if (input.isEmpty) {
    return false;
  }
  final codes = input.codeUnits;
  for (int code in codes) {
    if (!intIsBetween(code, 48, 57)) {
      return false;
    }
  }
  return true;
}

Future printBillReceipt(Uint8List capturedImage, PrinterManager printerManager,
    CloudCustomer customer, CloudCustomerHistory history) async {
  List<int> bytes = [];
  final profile = await CapabilityProfile.load(name: 'XP-N160I');
  final generator = Generator(PaperSize.mm58, profile);
  final decodedImage = img.decodeImage(capturedImage)!;
  // Create a black bottom layer
  // Resize the image to a 130x? thumbnail (maintaining the aspect ratio).
  // img.Image thumbnail = img.copyResize(decodedImage, width: 380, height: 1800);
  img.Image thumbnail = img.copyResize(decodedImage, width: 400);
  // creates a copy of the original image with set dimensions
  //width 380 is max for 58 mm
  // img.Image originalImg = img.copyResize(
  //   decodedImage,
  //   width: 380,
  //   height: 1820,
  // );
  img.Image originalImg = img.copyResize(
    decodedImage,
    width: 400,
  );
  // img.Image originalImg = img.copyResize(decodedImage, width: 380, height: 130);
  // fills the original image with a white background
  img.fill(originalImg, color: img.ColorRgb8(255, 255, 255));
  //insert the image inside the frame and center it
  // drawImage(originalImg, thumbnail, dstX: padding.toInt());
  drawImage(originalImg, thumbnail);

  // convert image to grayscale
  var grayscaleImage = img.grayscale(originalImg);

  // bytes += generator.feed(1);
  // bytes += generator.imageRaster(img.decodeImage(imageBytes)!, align: PosAlign.center);
  bytes += generator.imageRaster(grayscaleImage, align: PosAlign.left);
  // bytes += generator.imageRaster(grayscaleImage, align: PosAlign.center);
  bytes += generator.qrcode('${customer.documentId}/${history.documentId}');
  printerManager.send(type: PrinterType.bluetooth, bytes: bytes);
}

Future printBillReceipt80mm(Uint8List capturedImage, PrinterManager printerManager,
    CloudCustomer customer, CloudCustomerHistory history) async {
  List<int> bytes = [];
  final profile = await CapabilityProfile.load(name: 'XP-N160I');
  final generator = Generator(PaperSize.mm80, profile);
  final decodedImage = img.decodeImage(capturedImage)!;
  // Create a black bottom layer
  // Resize the image to a 130x? thumbnail (maintaining the aspect ratio).
  // img.Image thumbnail = img.copyResize(decodedImage, width: 380, height: 1800);
  img.Image thumbnail = img.copyResize(decodedImage, width: 400);
  // creates a copy of the original image with set dimensions
  //width 380 is max for 58 mm
  // img.Image originalImg = img.copyResize(
  //   decodedImage,
  //   width: 380,
  //   height: 1820,
  // );
  img.Image originalImg = img.copyResize(
    decodedImage,
    width: 400,
  );
  // img.Image originalImg = img.copyResize(decodedImage, width: 380, height: 130);
  // fills the original image with a white background
  img.fill(originalImg, color: img.ColorRgb8(255, 255, 255));
  //insert the image inside the frame and center it
  // drawImage(originalImg, thumbnail, dstX: padding.toInt());
  drawImage(originalImg, thumbnail);

  // convert image to grayscale
  var grayscaleImage = img.grayscale(originalImg);

  // bytes += generator.feed(1);
  // bytes += generator.imageRaster(img.decodeImage(imageBytes)!, align: PosAlign.center);
  bytes += generator.imageRaster(grayscaleImage, align: PosAlign.left);
  // bytes += generator.imageRaster(grayscaleImage, align: PosAlign.center);
  bytes += generator.qrcode('${customer.documentId}/${history.documentId}');
  printerManager.send(type: PrinterType.bluetooth, bytes: bytes);
}

Future printReceipt(
    Uint8List capturedImage, PrinterManager printerManager) async {
  List<int> bytes = [];
  final profile = await CapabilityProfile.load(name: 'XP-N160I');
  final generator = Generator(PaperSize.mm58, profile);
  final decodedImage = img.decodeImage(capturedImage)!;
  // Create a black bottom layer
  // Resize the image to a 130x? thumbnail (maintaining the aspect ratio).
  // img.Image thumbnail = img.copyResize(decodedImage, width: 380, height: 380);
  img.Image thumbnail = img.copyResize(decodedImage, width: 400);
  // creates a copy of the original image with set dimensions
  //width 380 is max for 58 mm
  // img.Image originalImg = img.copyResize(
  //   decodedImage,
  //   width: 380,
  //   height: 380,
  // );
  img.Image originalImg = img.copyResize(
    decodedImage,
    width: 400
  );
  // img.Image originalImg = img.copyResize(decodedImage, width: 380, height: 130);
  // fills the original image with a white background
  img.fill(originalImg, color: img.ColorRgb8(255, 255, 255));

  //insert the image inside the frame and center it
  // drawImage(originalImg, thumbnail, dstX: padding.toInt());
  drawImage(originalImg, thumbnail);

  // convert image to grayscale
  var grayscaleImage = img.grayscale(originalImg);

  // bytes += generator.feed(1);
  // bytes += generator.imageRaster(img.decodeImage(imageBytes)!, align: PosAlign.center);
  bytes += generator.imageRaster(grayscaleImage, align: PosAlign.left);
  // bytes += generator.imageRaster(grayscaleImage, align: PosAlign.center);
  printerManager.send(type: PrinterType.bluetooth, bytes: bytes);
}
