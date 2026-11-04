import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../services/pdf_generator_service.dart';
import '../../theme/app_theme.dart';

class PdfSheetHubScreen extends StatefulWidget {
  const PdfSheetHubScreen({super.key});

  @override
  State<PdfSheetHubScreen> createState() => _PdfSheetHubScreenState();
}

class _PdfSheetHubScreenState extends State<PdfSheetHubScreen> {
  // Custom Sheet Builder state
  bool _customIncludeTables = true;
  int _customMaxTable = 20;
  final int _customTableMultipliers = 10;

  bool _customIncludeSquares = true;
  int _customMaxSquare = 50;

  bool _customIncludeCubes = true;
  int _customMaxCube = 30;

  bool _customIncludeFractions = true;
  bool _customIncludeTriples = true;
  bool _customIncludeVedic = true;

  void _openPdfViewer({
    required String title,
    required Future<Uint8List> Function() documentBuilder,
    required String filename,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfSheetViewerScreen(
          title: title,
          documentBuilder: documentBuilder,
          filename: filename,
        ),
      ),
    );
  }

  void _generateCustomSheet() {
    _openPdfViewer(
      title: 'Custom Math Cheat-Sheet',
      filename: 'Custom_Math_CheatSheet.pdf',
      documentBuilder: () => PdfGeneratorService.generateCustomCheatSheet(
        includeTables: _customIncludeTables,
        maxTable: _customMaxTable,
        tableMultipliers: _customTableMultipliers,
        includeSquares: _customIncludeSquares,
        maxSquare: _customMaxSquare,
        includeCubes: _customIncludeCubes,
        maxCube: _customMaxCube,
        includeFractions: _customIncludeFractions,
        includeTriples: _customIncludeTriples,
        includeVedicTricks: _customIncludeVedic,
        sheetTitle: 'CUSTOM SPEED MATH FORMULA SHEET',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Formula Sheets & Cheat-Notes'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Hero Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4338CA).withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.amberAccent, size: 30),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Printable Speed Math Sheets',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Direct Download, Save to Phone & Print high-resolution A4 sheets for your study desk.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Section Header: Ready Presets
            const Text(
              '🌟 Popular Ready-to-Print Cheat-Sheets',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Preset 1: Master All-In-One Cheat-Sheet
            _buildPresetCard(
              title: 'Master All-in-One Cheat-Sheet',
              subtitle: 'Tables 1–20 • Squares 1–50 • Cubes 1–30 • Fractions & Triples • Vedic Tricks',
              badge: 'RECOMMENDED',
              badgeColor: Colors.amber,
              icon: Icons.auto_awesome_rounded,
              gradient: const [Color(0xFF0F172A), Color(0xFF1E293B)],
              accentColor: Colors.amberAccent,
              onTap: () => _openPdfViewer(
                title: 'Master All-in-One Cheat-Sheet',
                filename: 'Master_Speed_Math_CheatSheet.pdf',
                documentBuilder: () => PdfGeneratorService.generateMasterCheatSheet(),
              ),
            ),
            const SizedBox(height: 10),

            // Preset 2: Multiplication Tables Wall Poster
            _buildPresetCard(
              title: 'Multiplication Tables Wall Poster',
              subtitle: 'Clean 4-column compact layout for Tables 1 to 20 (or up to 30) with multipliers up to 10',
              badge: 'WALL POSTER',
              badgeColor: Colors.cyanAccent,
              icon: Icons.grid_view_rounded,
              gradient: const [Color(0xFF064E3B), Color(0xFF065F46)],
              accentColor: Colors.cyanAccent,
              onTap: () => _openPdfViewer(
                title: 'Multiplication Tables Poster (1–20)',
                filename: 'Multiplication_Tables_1_to_20_Poster.pdf',
                documentBuilder: () => PdfGeneratorService.generateTablesPoster(maxTable: 20, multipliers: 10),
              ),
            ),
            const SizedBox(height: 10),

            // Preset 3: Squares & Cubes Chart
            _buildPresetCard(
              title: 'Squares (1–50) & Cubes (1–30) Chart',
              subtitle: 'Quick memory recall for all powers, square roots & mental squaring patterns',
              badge: 'POWERS',
              badgeColor: Colors.purpleAccent,
              icon: Icons.offline_bolt_rounded,
              gradient: const [Color(0xFF581C87), Color(0xFF3B0764)],
              accentColor: Colors.purpleAccent,
              onTap: () => _openPdfViewer(
                title: 'Squares & Cubes Master Chart',
                filename: 'Squares_and_Cubes_CheatSheet.pdf',
                documentBuilder: () => PdfGeneratorService.generatePowersChart(maxSquare: 50, maxCube: 30),
              ),
            ),
            const SizedBox(height: 10),

            // Preset 4: Fractions & Pythagorean Triples
            _buildPresetCard(
              title: 'Fractions to % & Pythagorean Triples',
              subtitle: 'All 26 standard competitive fractions (1/2 to 1/25) & 21 right-angle triples',
              badge: 'ARITHMETIC & GEOMETRY',
              badgeColor: Colors.tealAccent,
              icon: Icons.percent_rounded,
              gradient: const [Color(0xFF134E4A), Color(0xFF042F2E)],
              accentColor: Colors.tealAccent,
              onTap: () => _openPdfViewer(
                title: 'Fractions & Triples Chart',
                filename: 'Fractions_and_Triples_CheatSheet.pdf',
                documentBuilder: () => PdfGeneratorService.generateFractionsTriplesChart(),
              ),
            ),
            const SizedBox(height: 24),

            // Section Header: Custom Sheet Builder
            const Text(
              '🎨 Custom Cheat-Sheet Builder',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select only what you want to revise and generate your own tailored PDF document.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),

            // Custom Builder Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: Column(
                children: [
                  // Tables Toggle & Options
                  _buildSwitchTile(
                    title: 'Multiplication Tables',
                    subtitle: 'Include multiplication tables grid',
                    value: _customIncludeTables,
                    onChanged: (val) => setState(() => _customIncludeTables = val),
                  ),
                  if (_customIncludeTables) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                      child: Row(
                        children: [
                          const Text('Table Range:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(width: 8),
                          _buildChoicePill('1–10', _customMaxTable == 10, () => setState(() => _customMaxTable = 10)),
                          const SizedBox(width: 6),
                          _buildChoicePill('1–20', _customMaxTable == 20, () => setState(() => _customMaxTable = 20)),
                          const SizedBox(width: 6),
                          _buildChoicePill('1–30', _customMaxTable == 30, () => setState(() => _customMaxTable = 30)),
                        ],
                      ),
                    ),
                    const Divider(color: AppTheme.surfaceLight, height: 1),
                  ],

                  // Squares Toggle & Options
                  _buildSwitchTile(
                    title: 'Squares',
                    subtitle: 'Include powers of 2 (1² to n²)',
                    value: _customIncludeSquares,
                    onChanged: (val) => setState(() => _customIncludeSquares = val),
                  ),
                  if (_customIncludeSquares) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                      child: Row(
                        children: [
                          const Text('Max Square:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(width: 8),
                          _buildChoicePill('1–30', _customMaxSquare == 30, () => setState(() => _customMaxSquare = 30)),
                          const SizedBox(width: 6),
                          _buildChoicePill('1–50', _customMaxSquare == 50, () => setState(() => _customMaxSquare = 50)),
                          const SizedBox(width: 6),
                          _buildChoicePill('1–100', _customMaxSquare == 100, () => setState(() => _customMaxSquare = 100)),
                        ],
                      ),
                    ),
                    const Divider(color: AppTheme.surfaceLight, height: 1),
                  ],

                  // Cubes Toggle & Options
                  _buildSwitchTile(
                    title: 'Cubes',
                    subtitle: 'Include powers of 3 (1³ to n³)',
                    value: _customIncludeCubes,
                    onChanged: (val) => setState(() => _customIncludeCubes = val),
                  ),
                  if (_customIncludeCubes) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                      child: Row(
                        children: [
                          const Text('Max Cube:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(width: 8),
                          _buildChoicePill('1–20', _customMaxCube == 20, () => setState(() => _customMaxCube = 20)),
                          const SizedBox(width: 6),
                          _buildChoicePill('1–30', _customMaxCube == 30, () => setState(() => _customMaxCube = 30)),
                        ],
                      ),
                    ),
                    const Divider(color: AppTheme.surfaceLight, height: 1),
                  ],

                  // Fractions Toggle
                  _buildSwitchTile(
                    title: 'Fraction to % Conversions',
                    subtitle: 'Include all 26 competitive exam fraction equivalents',
                    value: _customIncludeFractions,
                    onChanged: (val) => setState(() => _customIncludeFractions = val),
                  ),
                  const Divider(color: AppTheme.surfaceLight, height: 1),

                  // Triples Toggle
                  _buildSwitchTile(
                    title: 'Pythagorean Triples',
                    subtitle: 'Include standard right-angle triangle triples',
                    value: _customIncludeTriples,
                    onChanged: (val) => setState(() => _customIncludeTriples = val),
                  ),
                  const Divider(color: AppTheme.surfaceLight, height: 1),

                  // Vedic Tricks Toggle
                  _buildSwitchTile(
                    title: 'Vedic Math Speed Shortcuts',
                    subtitle: 'Include 6 core mental multiplication formulas',
                    value: _customIncludeVedic,
                    onChanged: (val) => setState(() => _customIncludeVedic = val),
                  ),
                  const SizedBox(height: 16),

                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: const Text(
                        'Generate & Preview Custom PDF Sheet',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onPressed: _generateCustomSheet,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetCard({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required List<Color> gradient,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 0.5),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(color: badgeColor, fontSize: 8.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      value: value,
      activeThumbColor: AppTheme.accent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      onChanged: onChanged,
    );
  }

  Widget _buildChoicePill(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Interactive Full-Screen PDF Viewer with Download, Save & Print actions
class PdfSheetViewerScreen extends StatefulWidget {
  final String title;
  final Future<Uint8List> Function() documentBuilder;
  final String filename;

  const PdfSheetViewerScreen({
    super.key,
    required this.title,
    required this.documentBuilder,
    required this.filename,
  });

  @override
  State<PdfSheetViewerScreen> createState() => _PdfSheetViewerScreenState();
}

class _PdfSheetViewerScreenState extends State<PdfSheetViewerScreen> {
  Uint8List? _cachedBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocumentBytes();
  }

  Future<void> _loadDocumentBytes() async {
    try {
      final bytes = await widget.documentBuilder();
      if (mounted) {
        setState(() {
          _cachedBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _downloadOrSave() async {
    if (_cachedBytes == null) return;
    try {
      final success = await PdfGeneratorService.downloadOrSavePdf(_cachedBytes!, filename: widget.filename);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '✅ Select "Save to Device / Downloads" or share with any app!' : 'PDF export dialog opened.'),
            backgroundColor: AppTheme.accent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    if (_cachedBytes == null) return;
    try {
      await Printing.sharePdf(bytes: _cachedBytes!, filename: widget.filename);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _printPdf() async {
    if (_cachedBytes == null) return;
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => _cachedBytes!,
        name: widget.filename,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Printer error: $e. Use "Download PDF" to save directly.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        actions: [
          // Explicit Download / Save Button
          IconButton(
            tooltip: 'Download & Save to Device',
            icon: const Icon(Icons.download_rounded, color: Colors.greenAccent),
            onPressed: _downloadOrSave,
          ),
          // Share Button
          IconButton(
            tooltip: 'Share PDF',
            icon: const Icon(Icons.share_rounded, color: Colors.cyanAccent),
            onPressed: _sharePdf,
          ),
          // Print Button
          IconButton(
            tooltip: 'Print Sheet',
            icon: const Icon(Icons.print_rounded, color: Colors.amberAccent),
            onPressed: _printPdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.accent),
                  SizedBox(height: 14),
                  Text('Generating high-resolution printable PDF...', style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          : Column(
              children: [
                // Quick Action Bar on top of preview
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppTheme.surfaceLight,
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 16),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'A4 Print-Ready Document',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.greenAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: _downloadOrSave,
                      ),
                    ],
                  ),
                ),
                // Live Interactive PDF Preview
                Expanded(
                  child: PdfPreview(
                    build: (format) async => _cachedBytes!,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    allowPrinting: true,
                    allowSharing: true,
                    pdfFileName: widget.filename,
                    loadingWidget: const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                    onError: (context, error) => Center(
                      child: Text('Preview error: $error', style: const TextStyle(color: AppTheme.error)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
