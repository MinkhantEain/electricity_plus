
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/others/filestorage.dart';
import 'package:excel/excel.dart';
import 'dart:developer' as dev show log;

void inputData(Sheet excelSheet, CellStyle style, int colIndex, int rowIndex,
    dynamic value) {
  var cell = excelSheet.cell(
    CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex),
  );
  cell.cellStyle = style;
  cell.value = value;
}

void mergeFormat(Sheet excelSheet, int rowIndex) {
  excelSheet.merge(CellIndex.indexByString('B${rowIndex + 1}'),
      CellIndex.indexByString('C${rowIndex + 1}'));
  excelSheet.merge(CellIndex.indexByString('E${rowIndex + 1}'),
      CellIndex.indexByString('G${rowIndex + 1}'));
  excelSheet.merge(CellIndex.indexByString('I${rowIndex + 1}'),
      CellIndex.indexByString('K${rowIndex + 1}'));
  excelSheet.merge(CellIndex.indexByString('I${rowIndex + 1}'),
      CellIndex.indexByString('K${rowIndex + 1}'));
}

void inputCustomerData(CloudCustomer customer, CloudCustomerHistory history,
    Sheet excelSheet, int rowIndex) {
  final style = CellStyle(
    fontSize: 8,
    fontFamily: 'Pyidaungsu',
    textWrapping: TextWrapping.WrapText,
    verticalAlign: VerticalAlign.Top,
    horizontalAlign: HorizontalAlign.Center,
  );
  List<int> dataColumnIndex = [
    3,
    4,
    7,
    8,
    11,
    12,
    13,
    14,
    16, //
    17, //
    18, //
    19, //
    20,
    21, //
  ];
  List<dynamic> customerDataValue = [
    customer.meterId,
    customer.name,
    customer.bookId,
    customer.address,
    history.previousUnit,
    history.newUnit,
    history.meterMultiplier,
    customer.adder,
    history.getUnitUsed(),
    history.roadLightPrice,
    history.serviceChargeAtm,
    history.getHorsePowerCost(),
    history.getCost(),
    history.cost
  ];
  inputData(excelSheet, style, 1, rowIndex, rowIndex - 7);
  for (int i = 0; i < dataColumnIndex.length; i++) {
    inputData(
        excelSheet, style, dataColumnIndex[i], rowIndex, customerDataValue[i]);
  }
  mergeFormat(excelSheet, rowIndex);
  dev.log('added');
}

void addTotal(List<num> totalData, int rowIndex, Sheet excelSheet) {
  final style = CellStyle(
    fontSize: 8,
    fontFamily: 'Pyidaungsu',
    textWrapping: TextWrapping.WrapText,
    verticalAlign: VerticalAlign.Top,
    horizontalAlign: HorizontalAlign.Center,
  );
  List<int> indexCol = [
    16,
    17,
    18,
    19,
    21,
  ];

  for (int i = 0; i < indexCol.length; ++i) {
    inputData(excelSheet, style, indexCol[i], rowIndex, totalData[i]);
  }
  mergeFormat(excelSheet, rowIndex);
}

Future<void> inputAllCustomerData(
    FirebaseCloudStorage provider, Sheet excelSheet, String townName) async {
  num totalUnitUsed = 0;
  num totalRoadPrice = 0;
  num totalServiceCharge = 0;
  num totalHorsePowerCost = 0;
  num totalCost = 0;
  int rowIndex = 8;
  final customers = await provider.allCustomer();
  dev.log(customers.toString());
  for (var customer in customers) {
    CloudCustomerHistory history =
        await provider.getCustomerHistory(customer: customer);
    totalUnitUsed += (history.newUnit - history.previousUnit) * history.meterMultiplier;
    totalRoadPrice += history.roadLightPrice;
    totalServiceCharge += history.serviceChargeAtm;
    totalHorsePowerCost +=
        (history.horsePowerPerUnitCostAtm * history.horsePowerUnits);
    totalCost += history.cost;
    inputCustomerData(customer, history, excelSheet, rowIndex);
    //increment rowIndex
    rowIndex++;
  }
  final totalData = [
    totalUnitUsed,
    totalRoadPrice,
    totalServiceCharge,
    totalHorsePowerCost,
    totalCost,
  ];
  addTotal(totalData, rowIndex, excelSheet);
}

Future<void> createExcelSheet(String townName) async {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel['sheet1'];
  final secondRowStyle = CellStyle(
    bold: true,
    rotation: 0,
    italic: false,
    underline: Underline.None,
    fontSize: 12,
    fontFamily: 'Pyidaungsu',
    textWrapping: TextWrapping.WrapText,
    verticalAlign: VerticalAlign.Bottom,
    horizontalAlign: HorizontalAlign.Left,
    fontColorHex: 'FF000000',
    backgroundColorHex: 'none',
    leftBorder: Border(borderStyle: null, borderColorHex: null),
    rightBorder: Border(borderStyle: null, borderColorHex: null),
    topBorder: Border(borderStyle: null, borderColorHex: null),
    bottomBorder: Border(borderStyle: null, borderColorHex: null),
    diagonalBorder: Border(borderStyle: null, borderColorHex: null),
    diagonalBorderUp: false,
    diagonalBorderDown: false,
  );
  var secondRowcell = sheetObject.cell(
    CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 1),
  );
  secondRowcell.value = 'Meter Units Report For ${monthYear()} ( $townName )';
  secondRowcell.cellStyle = secondRowStyle;
  sheetObject.merge(
      CellIndex.indexByString('J2'), CellIndex.indexByString('O3'));

  final thirdRowStyle = CellStyle(
    bold: false,
    rotation: 0,
    italic: false,
    underline: Underline.None,
    fontSize: 9,
    fontFamily: 'Pyidaungsu',
    textWrapping: TextWrapping.WrapText,
    verticalAlign: VerticalAlign.Bottom,
    horizontalAlign: HorizontalAlign.Left,
    fontColorHex: 'FF000000',
    backgroundColorHex: 'none',
    leftBorder: Border(borderStyle: null, borderColorHex: null),
    rightBorder: Border(borderStyle: null, borderColorHex: null),
    topBorder: Border(borderStyle: null, borderColorHex: null),
    bottomBorder: Border(borderStyle: null, borderColorHex: null),
    diagonalBorder: Border(borderStyle: null, borderColorHex: null),
    diagonalBorderUp: false,
    diagonalBorderDown: false,
  );

  var thirdRowCell = sheetObject.cell(
    CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2),
  );
  thirdRowCell.value = 'All Ledger';
  thirdRowCell.cellStyle = thirdRowStyle;
  sheetObject.merge(
      CellIndex.indexByString('C3'), CellIndex.indexByString('E4'));

  var informationRowStyle = CellStyle(
    bold: false,
    rotation: 0,
    italic: false,
    underline: Underline.None,
    fontSize: 8,
    fontFamily: 'Pyidaungsu',
    textWrapping: TextWrapping.WrapText,
    verticalAlign: VerticalAlign.Top,
    horizontalAlign: HorizontalAlign.Center,
    fontColorHex: 'FF000000',
    backgroundColorHex: 'none',
    leftBorder: Border(borderStyle: null, borderColorHex: null),
    rightBorder: Border(borderStyle: null, borderColorHex: null),
    topBorder: Border(borderStyle: null, borderColorHex: null),
    bottomBorder: Border(borderStyle: null, borderColorHex: null),
    diagonalBorder: Border(borderStyle: null, borderColorHex: null),
    diagonalBorderUp: false,
    diagonalBorderDown: false,
  );

  var infoCell0 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 1,
      rowIndex: 7,
    ),
  );
  infoCell0.value = 'No.1';
  infoCell0.cellStyle = informationRowStyle;

  var infoCell22 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 3,
      rowIndex: 7,
    ),
  );
  infoCell22.value = 'မီတာနံပါတ်';
  infoCell22.cellStyle = informationRowStyle;

  var infoCell1 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 4,
      rowIndex: 7,
    ),
  );
  infoCell1.value = 'အမည်';
  infoCell1.cellStyle = informationRowStyle;

  var infoCell2 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: 7,
    ),
  );
  infoCell2.value = 'စာရင်းအမှတ်';
  infoCell2.cellStyle = informationRowStyle;

  var infoCell3 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 8,
      rowIndex: 7,
    ),
  );
  infoCell3.value = 'လိပ်စာ';
  infoCell3.cellStyle = informationRowStyle;

  var infoCell4 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 11,
      rowIndex: 7,
    ),
  );
  infoCell4.value = 'Old Unit';
  infoCell4.cellStyle = informationRowStyle;

  var infoCell5 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 12,
      rowIndex: 7,
    ),
  );
  infoCell5.value = 'New Unit';
  infoCell5.cellStyle = informationRowStyle;

  var infoCell6 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 13,
      rowIndex: 7,
    ),
  );
  infoCell6.value = 'မြှောက်ကိန်း';
  infoCell6.cellStyle = informationRowStyle;

  var infoCell7 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 14,
      rowIndex: 7,
    ),
  );
  infoCell7.value = 'ပေါင်းရန်';
  infoCell7.cellStyle = informationRowStyle;

  var infoCell8 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 16,
      rowIndex: 7,
    ),
  );
  infoCell8.value = 'Unit Used';
  infoCell8.cellStyle = informationRowStyle;

  var infoCell9 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 17,
      rowIndex: 7,
    ),
  );
  infoCell9.value = 'လမ်းမီးခ';
  infoCell9.cellStyle = informationRowStyle;

  var infoCell10 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 18,
      rowIndex: 7,
    ),
  );
  infoCell10.value = '၀န်ဆောင်ခ';
  infoCell10.cellStyle = informationRowStyle;

  var infoCell11 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 19,
      rowIndex: 7,
    ),
  );
  infoCell11.value = 'မြင်းကောင်ရေခ';
  infoCell11.cellStyle = informationRowStyle;

  var infoCell12 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 20,
      rowIndex: 7,
    ),
  );
  infoCell12.value = 'Cost';
  infoCell12.cellStyle = informationRowStyle;

  var infoCell13 = sheetObject.cell(
    CellIndex.indexByColumnRow(
      columnIndex: 21,
      rowIndex: 7,
    ),
  );
  infoCell13.value = 'Total Cost';
  infoCell13.cellStyle = informationRowStyle;
  sheetObject.setColWidth(0, 0);
  sheetObject.setColWidth(1, 1);
  sheetObject.setColWidth(2, 3);
  sheetObject.setColWidth(3, 13);
  //E-g
  sheetObject.setColWidth(4, 10);
  sheetObject.setColWidth(5, 0);
  sheetObject.setColWidth(6, 2);
  //H
  sheetObject.setColWidth(7, 9);
  //IJK
  sheetObject.setColWidth(8, 5);
  sheetObject.setColWidth(9, 10);
  sheetObject.setColWidth(10, 10);

  sheetObject.setColWidth(11, 6);
  sheetObject.setColWidth(12, 6);

  sheetObject.setColWidth(13, 6);
  sheetObject.setColWidth(14, 7);

  sheetObject.setColWidth(15, 0);

  sheetObject.setColWidth(16, 8);
  sheetObject.setColWidth(17, 7);
  sheetObject.setColWidth(18, 8);
  sheetObject.setColWidth(19, 11);
  sheetObject.setColWidth(20, 8);
  sheetObject.setColWidth(21, 11);

  sheetObject.merge(
      CellIndex.indexByString('B8'), CellIndex.indexByString('C8'));
  sheetObject.merge(
      CellIndex.indexByString('E8'), CellIndex.indexByString('G8'));
  sheetObject.merge(
      CellIndex.indexByString('I8'), CellIndex.indexByString('K8'));
  sheetObject.merge(
      CellIndex.indexByString('I8'), CellIndex.indexByString('K8'));

  await inputAllCustomerData(FirebaseCloudStorage(), sheetObject, townName);

  var outputBytes = excel.save()!;
  FileStorage.save(outputBytes, monthYear());
  // final File toCloud = File('${dir.path}/${monthYear()}.xlsx')
  //   ..createSync(recursive: true)
  //   ..writeAsBytesSync(outputBytes);

  // FirebaseStorage.instance.ref().child('excel').putFile(toCloud);
}

String monthYear() {
  Map<String, String> intToMonth = {
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
  var result = DateTime.now().toString().substring(0, 7);
  return "${intToMonth[result.substring(5, 7)]} ${result.substring(0, 4)}";
}
