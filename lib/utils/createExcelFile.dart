// ignore_for_file: file_names

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CreateExcel {
  static Future<void> createExcel(List<dynamic> data) async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // Create Excel workbook and sheet
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];
    // Add headers to the sheet
    sheet.appendRow([
      const TextCellValue("Name"),
      const TextCellValue("Email ID"),
      const TextCellValue("Registration No.")
    ]);
    // Add rows for each item in the data list
    for (var item in data) {
      sheet.appendRow([
        TextCellValue(item["name"]),
        TextCellValue(item["email"]),
        TextCellValue(item["regNo"])
      ]);
    }
    // Get the downloads directory and save the file
    Directory? appDownloadsDirectory = await getDownloadsDirectory();
    String appDownloadsPath = appDownloadsDirectory!.path;
    String filePath = '$appDownloadsPath/Attendance - $currentDate.xlsx';
    List<int> excelBytes = excel.encode()!;
    File(filePath).writeAsBytesSync(excelBytes);
    await Share.shareXFiles([XFile(filePath)],
        text: 'Excel file', subject: 'Excel file');
  }
}
