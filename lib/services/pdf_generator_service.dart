import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/content_repository.dart';

class PdfGeneratorService {
  /// Generate customizable Speed Math Cheat-Sheet dynamically
  static Future<Uint8List> generateCustomCheatSheet({
    bool includeTables = true,
    int maxTable = 20,
    int tableMultipliers = 10,
    bool includeSquares = true,
    int maxSquare = 50,
    bool includeCubes = true,
    int maxCube = 30,
    bool includeFractions = true,
    bool includeTriples = true,
    bool includeVedicTricks = true,
    String sheetTitle = 'SPEED MATH FORMULA CHEAT-SHEET',
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // Title Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        sheetTitle,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'SSC | Banking | Railways | CAT | State Exams | Math Speed Practice',
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.amber100,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'OFFLINE DESK CHEAT-SHEET',
                      style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.amber900),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Section: Multiplication Tables
            if (includeTables) ...[
              pw.Row(
                children: [
                  pw.Text(
                    '1. Multiplication Tables (1 to $maxTable | Multipliers up to x$tableMultipliers)',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              _buildTablesGrid(maxTable: maxTable, multipliers: tableMultipliers),
              pw.SizedBox(height: 12),
            ],

            // Section: Squares
            if (includeSquares) ...[
              pw.Text(
                '${includeTables ? "2" : "1"}. Squares (1 to $maxSquare)',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
              ),
              pw.SizedBox(height: 4),
              _buildSquaresGrid(maxSquare: maxSquare),
              pw.SizedBox(height: 12),
            ],

            // Section: Cubes
            if (includeCubes) ...[
              pw.Text(
                '${(includeTables ? 1 : 0) + (includeSquares ? 1 : 0) + 1}. Cubes (1 to $maxCube)',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
              ),
              pw.SizedBox(height: 4),
              _buildCubesGrid(maxCube: maxCube),
              pw.SizedBox(height: 12),
            ],

            // Section: Fractions
            if (includeFractions) ...[
              pw.Text(
                '${(includeTables ? 1 : 0) + (includeSquares ? 1 : 0) + (includeCubes ? 1 : 0) + 1}. Fraction to Percentage & Decimal Equivalents',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
              ),
              pw.SizedBox(height: 4),
              _buildFractionsTable(),
              pw.SizedBox(height: 12),
            ],

            // Section: Pythagorean Triples
            if (includeTriples) ...[
              pw.Text(
                '${(includeTables ? 1 : 0) + (includeSquares ? 1 : 0) + (includeCubes ? 1 : 0) + (includeFractions ? 1 : 0) + 1}. Pythagorean Triples (Right-Angle Triangles)',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
              ),
              pw.SizedBox(height: 4),
              _buildTriplesList(),
              pw.SizedBox(height: 12),
            ],

            // Section: Vedic Math Shortcuts
            if (includeVedicTricks) ...[
              pw.Text(
                '${(includeTables ? 1 : 0) + (includeSquares ? 1 : 0) + (includeCubes ? 1 : 0) + (includeFractions ? 1 : 0) + (includeTriples ? 1 : 0) + 1}. Vedic Speed Math Calculation Rules',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
              ),
              pw.SizedBox(height: 4),
              _buildVedicTricksList(),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Preset: Master Speed Math Sheet (All-In-One)
  static Future<Uint8List> generateMasterCheatSheet() {
    return generateCustomCheatSheet(
      includeTables: true,
      maxTable: 20,
      tableMultipliers: 10,
      includeSquares: true,
      maxSquare: 50,
      includeCubes: true,
      maxCube: 30,
      includeFractions: true,
      includeTriples: true,
      includeVedicTricks: true,
      sheetTitle: 'MASTER SPEED MATH ALL-IN-ONE CHEAT-SHEET',
    );
  }

  /// Preset: Multiplication Tables Poster (1 to 20 or 1 to 30)
  static Future<Uint8List> generateTablesPoster({int maxTable = 20, int multipliers = 10}) {
    return generateCustomCheatSheet(
      includeTables: true,
      maxTable: maxTable,
      tableMultipliers: multipliers,
      includeSquares: false,
      includeCubes: false,
      includeFractions: false,
      includeTriples: false,
      includeVedicTricks: false,
      sheetTitle: 'MULTIPLICATION TABLES WALL POSTER (1 to $maxTable)',
    );
  }

  /// Preset: Powers & Roots Master Chart
  static Future<Uint8List> generatePowersChart({int maxSquare = 50, int maxCube = 30}) {
    return generateCustomCheatSheet(
      includeTables: false,
      includeSquares: true,
      maxSquare: maxSquare,
      includeCubes: true,
      maxCube: maxCube,
      includeFractions: false,
      includeTriples: false,
      includeVedicTricks: true,
      sheetTitle: 'SQUARES (1-$maxSquare) & CUBES (1-$maxCube) MASTER CHART',
    );
  }

  /// Preset: Fractions & Pythagorean Triples
  static Future<Uint8List> generateFractionsTriplesChart() {
    return generateCustomCheatSheet(
      includeTables: false,
      includeSquares: false,
      includeCubes: false,
      includeFractions: true,
      includeTriples: true,
      includeVedicTricks: false,
      sheetTitle: 'PERCENTAGE FRACTIONS & PYTHAGOREAN TRIPLES CHART',
    );
  }

  /// Helper to safely print or export cheat sheet
  static Future<void> printOrExportCheatSheet({BuildContext? context}) async {
    try {
      final bytes = await generateMasterCheatSheet();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Speed_Math_Formula_CheatSheet.pdf',
      );
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Print service error: $e. Using Direct Download/Share instead.',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
      try {
        final bytes = await generateMasterCheatSheet();
        await Printing.sharePdf(bytes: bytes, filename: 'Speed_Math_Formula_CheatSheet.pdf');
      } catch (_) {}
    }
  }

  /// Direct Download / Save to device
  static Future<bool> downloadOrSavePdf(Uint8List bytes, {String filename = 'Speed_Math_Formula_CheatSheet.pdf'}) async {
    try {
      return await Printing.sharePdf(bytes: bytes, filename: filename);
    } catch (_) {
      return false;
    }
  }

  // --- Sub-widgets for PDF Generation ---

  static pw.Widget _buildTablesGrid({required int maxTable, required int multipliers}) {
    // 4 tables per row in compact box layout
    List<pw.Widget> tableCards = [];
    for (int t = 1; t <= maxTable; t++) {
      tableCards.add(
        pw.Container(
          width: 125,
          margin: const pw.EdgeInsets.all(2.5),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
          ),
          child: pw.Column(
            children: [
              pw.Container(
                width: double.infinity,
                color: PdfColors.indigo800,
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Center(
                  child: pw.Text(
                    'Table of $t',
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ),
              ...List.generate(multipliers, (m) {
                int mult = m + 1;
                return pw.Container(
                  color: (mult % 2 == 0) ? PdfColors.grey100 : PdfColors.white,
                  padding: const pw.EdgeInsets.symmetric(vertical: 1.2, horizontal: 4),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('$t × $mult', style: const pw.TextStyle(fontSize: 7)),
                      pw.Text('${t * mult}', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }

    return pw.Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tableCards,
    );
  }

  static pw.Widget _buildSquaresGrid({int maxSquare = 50}) {
    List<pw.TableRow> rows = [];
    for (int i = 1; i <= maxSquare; i += 5) {
      rows.add(
        pw.TableRow(
          children: List.generate(5, (col) {
            int n = i + col;
            if (n > maxSquare) return pw.Container();
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              color: (n % 2 == 0) ? PdfColors.grey100 : PdfColors.white,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('$n²', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${n * n}', style: pw.TextStyle(fontSize: 8, color: PdfColors.blue900)),
                ],
              ),
            );
          }),
        ),
      );
    }
    return pw.Table(border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5), children: rows);
  }

  static pw.Widget _buildCubesGrid({int maxCube = 30}) {
    List<pw.TableRow> rows = [];
    for (int i = 1; i <= maxCube; i += 5) {
      rows.add(
        pw.TableRow(
          children: List.generate(5, (col) {
            int n = i + col;
            if (n > maxCube) return pw.Container();
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              color: (n % 2 == 0) ? PdfColors.grey100 : PdfColors.white,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('$n³', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${n * n * n}', style: pw.TextStyle(fontSize: 8, color: PdfColors.purple900)),
                ],
              ),
            );
          }),
        ),
      );
    }
    return pw.Table(border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5), children: rows);
  }

  static pw.Widget _buildFractionsTable() {
    final allFractions = ContentRepository.fractionData;
    List<pw.TableRow> rows = [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.indigo800),
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Fraction', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Percentage', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Decimal', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
        ],
      )
    ];

    for (int i = 0; i < allFractions.length; i++) {
      var f = allFractions[i];
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: i % 2 == 0 ? PdfColors.grey100 : PdfColors.white),
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(f['fraction'] ?? '', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(f['percent'] ?? '', style: pw.TextStyle(fontSize: 7.5, color: PdfColors.green900))),
            pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(f['decimal'] ?? '', style: pw.TextStyle(fontSize: 7.5, color: PdfColors.blue900))),
          ],
        ),
      );
    }
    return pw.Table(border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5), children: rows);
  }

  static pw.Widget _buildTriplesList() {
    List<String> list = ContentRepository.pythagoreanTriples.map((t) => '(${t[0]}, ${t[1]}, ${t[2]})').toList();
    return pw.Wrap(
      spacing: 6,
      runSpacing: 4,
      children: list.map((item) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
        ),
        child: pw.Text(item, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
      )).toList(),
    );
  }

  static pw.Widget _buildVedicTricksList() {
    final tricks = [
      {'title': '1. Ending in 5 Squaring', 'rule': '(A5)² = [A × (A + 1)] | 25', 'eg': '65² = (6×7)|25 = 4225'},
      {'title': '2. Multiply by 11', 'rule': 'Add adjacent digits: ab × 11 = a | (a+b) | b', 'eg': '43 × 11 = 4|7|3 = 473'},
      {'title': '3. Base 100 Multiplication', 'rule': '(100+a)(100+b) = (100+a+b) | (a×b)', 'eg': '104 × 107 = 111 | 28 = 11128'},
      {'title': '4. Multiply by 5 Shortcut', 'rule': 'N × 5 = (N / 2) × 10', 'eg': '84 × 5 = 42 × 10 = 420'},
      {'title': '5. Multiply by 25 Shortcut', 'rule': 'N × 25 = (N / 4) × 100', 'eg': '48 × 25 = 12 × 100 = 1200'},
      {'title': '6. Criss-Cross 2D × 2D', 'rule': '(ab) × (cd) = ac | (ad + bc) | bd', 'eg': '23 × 14 = 2|11|12 = 322'},
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: tricks.map((item) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 3),
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: pw.BoxDecoration(
            color: PdfColors.amber50,
            border: pw.Border.all(color: PdfColors.amber200, width: 0.5),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(item['title']!, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.amber900)),
              pw.Text(item['rule']!, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey900)),
              pw.Text(item['eg']!, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
