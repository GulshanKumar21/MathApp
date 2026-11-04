import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/services/pdf_generator_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('PdfGeneratorService dynamically generates valid non-empty PDF sheets', () async {
    // 1. Master Cheat Sheet (All-In-One with Tables, Squares, Cubes, Fractions, Triples, Vedic Tricks)
    final masterBytes = await PdfGeneratorService.generateMasterCheatSheet();
    expect(masterBytes.isNotEmpty, isTrue);
    // PDF files always begin with '%PDF'
    final header = String.fromCharCodes(masterBytes.take(4));
    expect(header, equals('%PDF'));

    // 2. Multiplication Tables Poster (Tables 1 to 20 dynamically)
    final tablesBytes = await PdfGeneratorService.generateTablesPoster(maxTable: 20, multipliers: 10);
    expect(tablesBytes.isNotEmpty, isTrue);
    expect(String.fromCharCodes(tablesBytes.take(4)), equals('%PDF'));

    // 3. Powers & Roots Chart (Squares 1 to 50 & Cubes 1 to 30)
    final powersBytes = await PdfGeneratorService.generatePowersChart(maxSquare: 50, maxCube: 30);
    expect(powersBytes.isNotEmpty, isTrue);
    expect(String.fromCharCodes(powersBytes.take(4)), equals('%PDF'));

    // 4. Fractions & Pythagorean Triples Chart
    final fractionsBytes = await PdfGeneratorService.generateFractionsTriplesChart();
    expect(fractionsBytes.isNotEmpty, isTrue);
    expect(String.fromCharCodes(fractionsBytes.take(4)), equals('%PDF'));

    // 5. Dynamic Custom Cheat Sheet with selective toggles
    final customBytes = await PdfGeneratorService.generateCustomCheatSheet(
      includeTables: true,
      maxTable: 30,
      tableMultipliers: 12,
      includeSquares: true,
      maxSquare: 100,
      includeCubes: true,
      maxCube: 30,
      includeFractions: true,
      includeTriples: true,
      includeVedicTricks: true,
      sheetTitle: 'TEST DYNAMIC CHEAT SHEET',
    );
    expect(customBytes.isNotEmpty, isTrue);
    expect(String.fromCharCodes(customBytes.take(4)), equals('%PDF'));
  });
}
