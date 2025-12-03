import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../models/seed_inventory_model.dart';

/// Report Service - Export data as PDF or Excel
class ReportService {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: 'ج.م ', decimalDigits: 2);

  // ========== SEED INVENTORY REPORTS ==========

  /// Export seed inventory as PDF
  Future<File> exportSeedInventoryPdf({
    required List<SeedInventory> seeds,
    required String farmName,
    String? notes,
  }) async {
    final pdf = pw.Document();
    
    // Load Arabic font if available (fallback to default)
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    // Add cover page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green700,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'SEED INVENTORY REPORT',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 24,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'تقرير مخزون البذور',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 18,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              
              // Farm info
              _buildInfoRow('Farm / المزرعة:', farmName, font, fontBold),
              _buildInfoRow('Date / التاريخ:', _dateTimeFormat.format(DateTime.now()), font, fontBold),
              _buildInfoRow('Total Items / إجمالي الأصناف:', seeds.length.toString(), font, fontBold),
              _buildInfoRow(
                'Total Value / القيمة الإجمالية:',
                _currencyFormat.format(seeds.fold(0.0, (sum, s) => sum + s.totalValue)),
                font,
                fontBold,
              ),
              
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              // Summary statistics
              pw.Text(
                'Summary / الملخص',
                style: pw.TextStyle(font: fontBold, fontSize: 16),
              ),
              pw.SizedBox(height: 10),
              
              _buildStatRow('Available / متاح', seeds.where((s) => s.status == SeedStatus.available).length, PdfColors.green, font),
              _buildStatRow('Low Stock / مخزون منخفض', seeds.where((s) => s.status == SeedStatus.lowStock).length, PdfColors.orange, font),
              _buildStatRow('Expired / منتهي الصلاحية', seeds.where((s) => s.isExpired).length, PdfColors.red, font),
              _buildStatRow('Expiring Soon / ينتهي قريباً', seeds.where((s) => s.isExpiringSoon).length, PdfColors.amber, font),
              
              if (notes != null && notes.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text('Notes / ملاحظات:', style: pw.TextStyle(font: fontBold)),
                pw.SizedBox(height: 5),
                pw.Text(notes, style: pw.TextStyle(font: font)),
              ],
            ],
          );
        },
      ),
    );

    // Add inventory table pages
    final itemsPerPage = 15;
    for (var i = 0; i < seeds.length; i += itemsPerPage) {
      final pageSeeds = seeds.skip(i).take(itemsPerPage).toList();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Seed Inventory Details',
                      style: pw.TextStyle(font: fontBold, fontSize: 16),
                    ),
                    pw.Text(
                      'Page ${(i ~/ itemsPerPage) + 1}',
                      style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                
                // Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1.5),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(1),
                    4: const pw.FlexColumnWidth(1.2),
                    5: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.green100),
                      children: [
                        _buildTableHeader('Name', font),
                        _buildTableHeader('Variety', font),
                        _buildTableHeader('Qty', font),
                        _buildTableHeader('Unit', font),
                        _buildTableHeader('Value', font),
                        _buildTableHeader('Status', font),
                      ],
                    ),
                    // Data rows
                    ...pageSeeds.map((seed) => pw.TableRow(
                      children: [
                        _buildTableCell(seed.name, font),
                        _buildTableCell(seed.variety, font),
                        _buildTableCell(seed.quantity.toStringAsFixed(1), font),
                        _buildTableCell(seed.unit, font),
                        _buildTableCell(_currencyFormat.format(seed.totalValue), font),
                        _buildStatusCell(seed, font),
                      ],
                    )),
                  ],
                ),
                
                pw.Spacer(),
                pw.Divider(),
                pw.Text(
                  'Generated by O\'TFha Agricultural Platform - ${_dateFormat.format(DateTime.now())}',
                  style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey),
                ),
              ],
            );
          },
        ),
      );
    }

    // Save PDF
    final output = await getTemporaryDirectory();
    final fileName = 'seed_inventory_${_dateFormat.format(DateTime.now())}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  /// Export seed inventory as Excel
  Future<File> exportSeedInventoryExcel({
    required List<SeedInventory> seeds,
    required String farmName,
  }) async {
    final excel = Excel.createExcel();
    
    // Remove default sheet
    excel.delete('Sheet1');
    
    // Create Inventory sheet
    final inventorySheet = excel['Seed Inventory'];
    
    // Add header
    final headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.green,
      fontColorHex: ExcelColor.white,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );
    
    final headers = [
      'Name',
      'Arabic Name',
      'Variety',
      'Category',
      'Quantity',
      'Unit',
      'Price/Unit',
      'Total Value',
      'Purchase Date',
      'Expiry Date',
      'Supplier',
      'Storage',
      'Status',
    ];
    
    for (var i = 0; i < headers.length; i++) {
      final cell = inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }
    
    // Add data rows
    for (var i = 0; i < seeds.length; i++) {
      final seed = seeds[i];
      final row = i + 1;
      
      inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(seed.name);
      inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(seed.nameArabic);
      inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(seed.variety);
      inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(seed.category);
      inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = DoubleCellValue(seed.quantity);
      inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = TextCellValue(seed.unit);
      inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value = DoubleCellValue(seed.pricePerUnit);
      inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value = DoubleCellValue(seed.totalValue);
      inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value = TextCellValue(_dateFormat.format(seed.purchaseDate));
      inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row)).value = TextCellValue(seed.expiryDate != null ? _dateFormat.format(seed.expiryDate!) : 'N/A');
      inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row)).value = TextCellValue(seed.supplier ?? '');
      inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: row)).value = TextCellValue(seed.storageLocation ?? '');
      inventorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: row)).value = TextCellValue(seed.status.name);
    }
    
    // Create Summary sheet
    final summarySheet = excel['Summary'];
    
    summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Farm Name');
    summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue(farmName);
    
    summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value = TextCellValue('Report Date');
    summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value = TextCellValue(_dateTimeFormat.format(DateTime.now()));
    
    summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value = TextCellValue('Total Items');
    summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value = IntCellValue(seeds.length);
    
    summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).value = TextCellValue('Total Value');
    summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3)).value = DoubleCellValue(seeds.fold(0.0, (sum, s) => sum + s.totalValue));
    
    summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5)).value = TextCellValue('By Category');
    var categoryRow = 6;
    final categories = <String, int>{};
    for (var seed in seeds) {
      categories[seed.category] = (categories[seed.category] ?? 0) + 1;
    }
    for (var entry in categories.entries) {
      summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: categoryRow)).value = TextCellValue(entry.key);
      summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: categoryRow)).value = IntCellValue(entry.value);
      categoryRow++;
    }

    // Save Excel file
    final output = await getTemporaryDirectory();
    final fileName = 'seed_inventory_${_dateFormat.format(DateTime.now())}.xlsx';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(excel.encode()!);
    
    return file;
  }

  // ========== EXPENSE REPORTS ==========

  /// Export expenses as PDF
  Future<File> exportExpensesPdf({
    required List<ExpenseData> expenses,
    required String farmName,
    required double totalIncome,
    required double totalExpenses,
    required String period,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'FINANCIAL REPORT',
                      style: pw.TextStyle(font: fontBold, fontSize: 24, color: PdfColors.white),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'التقرير المالي',
                      style: pw.TextStyle(font: font, fontSize: 18, color: PdfColors.white),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              
              // Info
              _buildInfoRow('Farm / المزرعة:', farmName, font, fontBold),
              _buildInfoRow('Period / الفترة:', period, font, fontBold),
              _buildInfoRow('Date / التاريخ:', _dateTimeFormat.format(DateTime.now()), font, fontBold),
              
              pw.SizedBox(height: 30),
              
              // Financial Summary
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildFinancialCard('Total Income\nإجمالي الدخل', totalIncome, PdfColors.green, font, fontBold),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: _buildFinancialCard('Total Expenses\nإجمالي المصروفات', totalExpenses, PdfColors.red, font, fontBold),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: _buildFinancialCard('Net Profit\nصافي الربح', totalIncome - totalExpenses, 
                      totalIncome - totalExpenses >= 0 ? PdfColors.green : PdfColors.red, font, fontBold),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              // Expense Categories
              pw.Text('Expense Breakdown / تفاصيل المصروفات', style: pw.TextStyle(font: fontBold, fontSize: 16)),
              pw.SizedBox(height: 15),
              
              ...expenses.map((e) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(e.category, style: pw.TextStyle(font: font)),
                    pw.Text(_currencyFormat.format(e.amount), style: pw.TextStyle(font: fontBold)),
                  ],
                ),
              )),
              
              pw.Spacer(),
              pw.Divider(),
              pw.Text(
                'Generated by O\'TFha Agricultural Platform',
                style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final fileName = 'financial_report_${_dateFormat.format(DateTime.now())}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  // ========== UTILITY METHODS ==========

  /// Share a file
  Future<void> shareFile(File file, {String? subject}) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject ?? 'O\'TFha Report',
    );
  }

  /// Open a file
  Future<void> openFile(File file) async {
    await OpenFilex.open(file.path);
  }

  // ========== PRIVATE HELPER METHODS ==========

  pw.Widget _buildInfoRow(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(font: fontBold, fontSize: 12)),
          pw.SizedBox(width: 10),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 12)),
        ],
      ),
    );
  }

  pw.Widget _buildStatRow(String label, int count, PdfColor color, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Container(
            width: 12,
            height: 12,
            decoration: pw.BoxDecoration(
              color: color,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Text(label, style: pw.TextStyle(font: font)),
          pw.Spacer(),
          pw.Text(count.toString(), style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeader(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 10, fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 9)),
    );
  }

  pw.Widget _buildStatusCell(SeedInventory seed, pw.Font font) {
    PdfColor color;
    String status;
    
    if (seed.isExpired) {
      color = PdfColors.red;
      status = 'Expired';
    } else if (seed.isExpiringSoon) {
      color = PdfColors.amber;
      status = 'Expiring';
    } else if (seed.isLowStock) {
      color = PdfColors.orange;
      status = 'Low';
    } else {
      color = PdfColors.green;
      status = 'OK';
    }
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: pw.BoxDecoration(
          color: color.shade(0.8),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          status,
          style: pw.TextStyle(font: font, fontSize: 8, color: color),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  pw.Widget _buildFinancialCard(String title, double amount, PdfColor color, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: color.shade(0.9),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: color),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(font: font, fontSize: 10), textAlign: pw.TextAlign.center),
          pw.SizedBox(height: 8),
          pw.Text(
            _currencyFormat.format(amount),
            style: pw.TextStyle(font: fontBold, fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }
}

/// Expense data model for reports
class ExpenseData {
  final String category;
  final double amount;
  final String? icon;

  ExpenseData({
    required this.category,
    required this.amount,
    this.icon,
  });
}

