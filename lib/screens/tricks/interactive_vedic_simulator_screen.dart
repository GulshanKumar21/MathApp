import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bouncing_card.dart';
import '../practice/practice_quiz_screen.dart';
import '../../models/math_models.dart';
import '../../data/vedic_tricks_repository.dart';

enum VedicTrickType {
  base100Below,
  base100Above,
  endsInFive,
  sameTensUnitsSum10,
  multiplyBy11,
  multiplyBy99,
  numbersIn50s,
  crissCross,
}

/// Interactive Vedic Math Simulator that dynamically computes and visualizes
/// mental math shortcuts with illuminated mathematical breakdowns and live testing.
class InteractiveVedicSimulatorScreen extends StatefulWidget {
  final VedicTrickType initialTrick;

  const InteractiveVedicSimulatorScreen({
    super.key,
    this.initialTrick = VedicTrickType.base100Below,
  });

  @override
  State<InteractiveVedicSimulatorScreen> createState() => _InteractiveVedicSimulatorScreenState();
}

class _InteractiveVedicSimulatorScreenState extends State<InteractiveVedicSimulatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VedicTrickType _selectedTrick;

  // Controllers for custom input
  final TextEditingController _num1Ctrl = TextEditingController(text: '96');
  final TextEditingController _num2Ctrl = TextEditingController(text: '97');

  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedTrick = widget.initialTrick;
    _setPresetForTrick(_selectedTrick);
  }

  void _setPresetForTrick(VedicTrickType trick) {
    switch (trick) {
      case VedicTrickType.base100Below:
        _num1Ctrl.text = '96';
        _num2Ctrl.text = '97';
        break;
      case VedicTrickType.base100Above:
        _num1Ctrl.text = '104';
        _num2Ctrl.text = '107';
        break;
      case VedicTrickType.endsInFive:
        _num1Ctrl.text = '65';
        _num2Ctrl.text = '65';
        break;
      case VedicTrickType.sameTensUnitsSum10:
        _num1Ctrl.text = '74';
        _num2Ctrl.text = '76';
        break;
      case VedicTrickType.multiplyBy11:
        _num1Ctrl.text = '53';
        _num2Ctrl.text = '11';
        break;
      case VedicTrickType.multiplyBy99:
        _num1Ctrl.text = '64';
        _num2Ctrl.text = '99';
        break;
      case VedicTrickType.numbersIn50s:
        _num1Ctrl.text = '54';
        _num2Ctrl.text = '54';
        break;
      case VedicTrickType.crissCross:
        _num1Ctrl.text = '23';
        _num2Ctrl.text = '14';
        break;
    }
  }

  void _randomizeCurrentTrick() {
    switch (_selectedTrick) {
      case VedicTrickType.base100Below:
        int a = 91 + _rnd.nextInt(8);
        int b = 91 + _rnd.nextInt(8);
        _num1Ctrl.text = '$a';
        _num2Ctrl.text = '$b';
        break;
      case VedicTrickType.base100Above:
        int a = 101 + _rnd.nextInt(8);
        int b = 101 + _rnd.nextInt(8);
        _num1Ctrl.text = '$a';
        _num2Ctrl.text = '$b';
        break;
      case VedicTrickType.endsInFive:
        int tens = 1 + _rnd.nextInt(9);
        _num1Ctrl.text = '${tens * 10 + 5}';
        _num2Ctrl.text = '${tens * 10 + 5}';
        break;
      case VedicTrickType.sameTensUnitsSum10:
        int t = 1 + _rnd.nextInt(9);
        int u1 = 1 + _rnd.nextInt(8);
        int u2 = 10 - u1;
        _num1Ctrl.text = '${t * 10 + u1}';
        _num2Ctrl.text = '${t * 10 + u2}';
        break;
      case VedicTrickType.multiplyBy11:
        int a = 12 + _rnd.nextInt(85);
        _num1Ctrl.text = '$a';
        _num2Ctrl.text = '11';
        break;
      case VedicTrickType.multiplyBy99:
        int a = 12 + _rnd.nextInt(85);
        _num1Ctrl.text = '$a';
        _num2Ctrl.text = '99';
        break;
      case VedicTrickType.numbersIn50s:
        int u = 1 + _rnd.nextInt(8);
        _num1Ctrl.text = '${50 + u}';
        _num2Ctrl.text = '${50 + u}';
        break;
      case VedicTrickType.crissCross:
        int a = 12 + _rnd.nextInt(40);
        int b = 12 + _rnd.nextInt(40);
        _num1Ctrl.text = '$a';
        _num2Ctrl.text = '$b';
        break;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _num1Ctrl.dispose();
    _num2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7.5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vedic Math Speed Lab',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.5, color: Colors.white),
                ),
                Text(
                  'Fast Mental Shortcuts & Simulator',
                  style: TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.bolt_rounded, size: 18), text: 'Interactive Lab'),
            Tab(icon: Icon(Icons.auto_awesome_rounded, size: 18), text: 'All 10 Speed Tricks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSimulatorTab(),
          _buildAllTricksLibraryTab(),
        ],
      ),
    );
  }

  // --- TAB 1: INTERACTIVE LAB & SIMULATOR ---
  Widget _buildSimulatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '1. Shortcut Chunein (Select Shortcut):',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  '⚡ 2-SECOND RECALL',
                  style: TextStyle(color: AppTheme.gold, fontSize: 9.5, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal Selector Carousel
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _trickTypePill(VedicTrickType.base100Below, 'Base 100 Below', '96 × 97', Icons.trending_down_rounded),
                _trickTypePill(VedicTrickType.base100Above, 'Base 100 Above', '104 × 107', Icons.trending_up_rounded),
                _trickTypePill(VedicTrickType.endsInFive, 'Squaring (ends in 5)', '65²', Icons.star_rounded),
                _trickTypePill(VedicTrickType.sameTensUnitsSum10, 'Tens Same, Units Sum 10', '74 × 76', Icons.auto_awesome_rounded),
                _trickTypePill(VedicTrickType.multiplyBy11, 'Multiply by 11', '53 × 11', Icons.flash_on_rounded),
                _trickTypePill(VedicTrickType.multiplyBy99, 'Multiply by 99', '64 × 99', Icons.filter_9_plus_rounded),
                _trickTypePill(VedicTrickType.numbersIn50s, 'Squares in 50s', '54²', Icons.crop_square_rounded),
                _trickTypePill(VedicTrickType.crissCross, '2-Digit Criss-Cross', '23 × 14', Icons.shuffle_rounded),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Number Input Box with Quick Randomize
          _buildInteractiveInputBox(),
          const SizedBox(height: 18),

          // Step-by-Step Illuminated Breakdown
          _buildVisualStepBreakdown(),
          const SizedBox(height: 22),

          // Rapid Quiz CTA on this trick
          _buildPracticeCtaButton(),
        ],
      ),
    );
  }

  Widget _trickTypePill(VedicTrickType type, String title, String example, IconData icon) {
    final bool isSelected = _selectedTrick == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: BouncingCard(
        onTap: () {
          setState(() {
            _selectedTrick = type;
            _setPresetForTrick(type);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  )
                : null,
            color: isSelected ? null : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white.withValues(alpha: 0.45) : AppTheme.surfaceLight,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppTheme.accent),
              const SizedBox(width: 7),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                  Text(
                    example,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.gold : Colors.white38,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveInputBox() {
    final bool isSquareMode = _selectedTrick == VedicTrickType.endsInFive || _selectedTrick == VedicTrickType.numbersIn50s;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '2. Apna Number Daal Kar Dekhein:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: _randomizeCurrentTrick,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.casino_rounded, color: AppTheme.accent, size: 14),
                      SizedBox(width: 5),
                      Text(
                        'Random 🎲',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Inputs with Dedicated Non-Overlapping Labels
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // First Number Field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSquareMode ? 'Number to Square' : 'First Number (A)',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white60),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.bgDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        controller: _num1Ctrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.white24),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Operator Symbol
              Padding(
                padding: const EdgeInsets.only(top: 18, left: 10, right: 10),
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    isSquareMode ? '²' : '×',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.gold),
                  ),
                ),
              ),

              // Second Number Field (if not squaring)
              if (!isSquareMode)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Second Number (B)',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white60),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.bgDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: TextField(
                          controller: _num2Ctrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.white24),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Icon(Icons.bolt_rounded, size: 14, color: AppTheme.gold),
              SizedBox(width: 4),
              Text(
                'Instant Presets (1-Tap Test):',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _getPresetsForTrick(_selectedTrick).map((preset) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () {
                      _num1Ctrl.text = preset['a']!;
                      if (preset['b'] != null) {
                        _num2Ctrl.text = preset['b']!;
                      }
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.bgDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        preset['label']!,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualStepBreakdown() {
    int? a = int.tryParse(_num1Ctrl.text.trim());
    int? b = int.tryParse(_num2Ctrl.text.trim());

    a ??= 96;
    b ??= 97;

    switch (_selectedTrick) {
      case VedicTrickType.base100Below:
        return _buildBase100BelowBreakdown(a, b);
      case VedicTrickType.base100Above:
        return _buildBase100AboveBreakdown(a, b);
      case VedicTrickType.endsInFive:
        return _buildEndsInFiveBreakdown(a);
      case VedicTrickType.sameTensUnitsSum10:
        return _buildSameTensUnitsSum10Breakdown(a, b);
      case VedicTrickType.multiplyBy11:
        return _buildMultiplyBy11Breakdown(a);
      case VedicTrickType.multiplyBy99:
        return _buildMultiplyBy99Breakdown(a);
      case VedicTrickType.numbersIn50s:
        return _buildNumbersIn50sBreakdown(a);
      case VedicTrickType.crissCross:
        return _buildCrissCrossBreakdown(a, b);
    }
  }

  Widget _buildBase100BelowBreakdown(int a, int b) {
    int devA = 100 - a;
    int devB = 100 - b;
    int leftPart = a - devB;
    int rightPart = devA * devB;
    String rightPartStr = rightPart.abs() < 10 ? '0$rightPart' : '$rightPart';
    int finalAns = a * b;

    return _breakdownContainer(
      title: '100 se Chhote Numbers ka Fast Multiply',
      methodName: 'Trick: 100 se kami dekho aur cross-minus karo',
      equation: '$a × $b = $finalAns',
      steps: [
        _stepData('1', 'Dono 100 se kitne kam hain dekho:', [
          '• $a ➔ 100 se $devA kam hai (-$devA)',
          '• $b ➔ 100 se $devB kam hai (-$devB)',
        ]),
        _stepData('2', 'Cross-minus karo (Pehla hissa):', [
          '• $a me se dusre ki kami ($devB) ghatao: $a - $devB = $leftPart',
          '• (Ya $b - $devA = $leftPart — dono se same aayega!)',
        ]),
        _stepData('3', 'Dono kami ko aapas me multiply karo (Aakhiri 2 digits):', [
          '• $devA × $devB = $rightPartStr',
        ]),
      ],
      resultLeft: '$leftPart',
      resultRight: rightPartStr,
      finalResult: '$finalAns',
    );
  }

  Widget _buildBase100AboveBreakdown(int a, int b) {
    int devA = a - 100;
    int devB = b - 100;
    int leftPart = a + devB;
    int rightPart = devA * devB;
    String rightPartStr = rightPart < 10 ? '0$rightPart' : '$rightPart';
    int finalAns = a * b;

    return _breakdownContainer(
      title: '100 se Bade Numbers ka Fast Multiply',
      methodName: 'Trick: 100 se kitna zyada hai dekho aur cross-add karo',
      equation: '$a × $b = $finalAns',
      steps: [
        _stepData('1', 'Dono 100 se kitne zyada hain dekho:', [
          '• $a ➔ 100 se $devA zyada hai (+$devA)',
          '• $b ➔ 100 se $devB zyada hai (+$devB)',
        ]),
        _stepData('2', 'Cross-add karo (Pehla hissa):', [
          '• $a me dusre ka extra ($devB) jodo: $a + $devB = $leftPart',
          '• (Ya $b + $devA = $leftPart — dono se same aayega!)',
        ]),
        _stepData('3', 'Extra numbers ko multiply karo (Aakhiri 2 digits):', [
          '• $devA × $devB = $rightPartStr',
        ]),
      ],
      resultLeft: '$leftPart',
      resultRight: rightPartStr,
      finalResult: '$finalAns',
    );
  }

  Widget _buildEndsInFiveBreakdown(int a) {
    final bool endsIn5 = a % 10 == 5;
    final int baseNum = endsIn5 ? a : ((a ~/ 10) * 10 + 5);
    int tens = baseNum ~/ 10;
    int leftPart = tens * (tens + 1);
    int finalAns = baseNum * baseNum;

    return _breakdownContainer(
      title: 'Aakhiri me 5 wale numbers ka Square',
      methodName: 'Trick: Pehla number × Agla number | Aakhiri me 25',
      equation: endsIn5 ? '$a² = $finalAns' : '$baseNum² = $finalAns',
      steps: [
        if (!endsIn5)
          _stepData('!', '⚠️ Dhyaan Dein: $a ke aakhiri me 5 nahi hai', [
            'Yeh shortcut sirf 5 par khatam hone wale numbers (jaise 15, 25, 35, 65, 85...) ke liye hai.',
            'Isliye hum $tens se shuru hone wale ${baseNum}² ka step-by-step method dikha rahe hain:',
          ]),
        _stepData('1', 'Pehle digit ko uske agle number se multiply karo:', [
          '• Pehla digit = $tens',
          '• $tens ko uske agle number (${tens + 1}) se guna: $tens × ${tens + 1} = $leftPart',
        ]),
        _stepData('2', 'Aakhiri me hamesha 25 chipka do:', [
          '• 5² = 25 (Hamesha last me 25 hi aayega)',
        ]),
      ],
      resultLeft: '$leftPart',
      resultRight: '25',
      finalResult: '$finalAns',
    );
  }

  Widget _buildSameTensUnitsSum10Breakdown(int a, int b) {
    int tA = a ~/ 10;
    int uA = a % 10;
    int uB = b % 10;
    int leftPart = tA * (tA + 1);
    int rightPart = uA * uB;
    String rightPartStr = rightPart < 10 ? '0$rightPart' : '$rightPart';
    int finalAns = a * b;

    return _breakdownContainer(
      title: 'Pehla Digit Same & Last Digits ka Jod = 10',
      methodName: 'Trick: Pehla digit × Agla number | Last digits ka multiply',
      equation: '$a × $b = $finalAns',
      steps: [
        _stepData('1', 'Pehle same digit ko uske agle number se multiply karo:', [
          '• Pehla digit = $tA',
          '• $tA × ($tA + 1) = $tA × ${tA + 1} = $leftPart',
        ]),
        _stepData('2', 'Aakhiri dono digits ko aapas me multiply karo:', [
          '• Aakhiri digits: $uA aur $uB (Jod: $uA + $uB = 10)',
          '• $uA × $uB = $rightPartStr (Hamesha 2 digits)',
        ]),
      ],
      resultLeft: '$leftPart',
      resultRight: rightPartStr,
      finalResult: '$finalAns',
    );
  }

  Widget _buildMultiplyBy11Breakdown(int a) {
    int hundreds = a ~/ 100;
    int tens = (a ~/ 10) % 10;
    int ones = a % 10;
    int finalAns = a * 11;

    return _breakdownContainer(
      title: 'Kisi bhi Number ko 11 se Fast Multiply',
      methodName: 'Trick: Kinare ke digits likho aur beech me unhe jodo',
      equation: '$a × 11 = $finalAns',
      steps: [
        _stepData('1', 'Kinare ke digits ko aage aur peeche likho:', [
          '• Shuru me: ${a < 100 ? tens : hundreds}',
          '• Aakhiri me: $ones',
        ]),
        _stepData('2', 'Beech me padosi digits ko jodo:', [
          if (a < 100) ...[
            '• Beech ka number = $tens + $ones = ${tens + ones}',
            if (tens + ones >= 10) '• (10 ya zyada aane par 1 aage carry jud jayega)',
          ] else ...[
            '• Padosi jodi: ($tens + $ones) aur ($hundreds + $tens)',
          ],
        ]),
      ],
      resultLeft: '${finalAns ~/ 10}',
      resultRight: '${finalAns % 10}',
      finalResult: '$finalAns',
    );
  }

  Widget _buildMultiplyBy99Breakdown(int a) {
    int leftPart = a - 1;
    int rightPart = 100 - a;
    String rightPartStr = rightPart < 10 ? '0$rightPart' : '$rightPart';
    int finalAns = a * 99;

    return _breakdownContainer(
      title: 'Kisi 2-Digit Number ko 99 se Multiply karna',
      methodName: 'Trick: 1 minus karo | 100 me se bacha hua hissa likho',
      equation: '$a × 99 = $finalAns',
      steps: [
        _stepData('1', 'Number me se 1 ghatao (Pehla hissa):', [
          '• $a - 1 = $leftPart',
        ]),
        _stepData('2', '100 me se us number ko minus karo (Aakhiri hissa):', [
          '• 100 - $a = $rightPartStr',
        ]),
      ],
      resultLeft: '$leftPart',
      resultRight: rightPartStr,
      finalResult: '$finalAns',
    );
  }

  Widget _buildNumbersIn50sBreakdown(int a) {
    int u = a % 10;
    int leftPart = 25 + u;
    int rightPart = u * u;
    String rightPartStr = rightPart < 10 ? '0$rightPart' : '$rightPart';
    int finalAns = a * a;

    return _breakdownContainer(
      title: '51 se 59 tak ke Numbers ka Fast Square',
      methodName: 'Trick: 25 + Aakhiri digit | Aakhiri digit ka square',
      equation: '$a² = $finalAns',
      steps: [
        _stepData('1', '25 me aakhiri digit jodo (Pehla hissa):', [
          '• Aakhiri digit = $u',
          '• 25 + $u = $leftPart',
        ]),
        _stepData('2', 'Aakhiri digit ka square karo (Aakhiri 2 digits):', [
          '• $u² = $rightPartStr (Hamesha 2 digits me)',
        ]),
      ],
      resultLeft: '$leftPart',
      resultRight: rightPartStr,
      finalResult: '$finalAns',
    );
  }

  Widget _buildCrissCrossBreakdown(int a, int b) {
    int a1 = a ~/ 10;
    int a2 = a % 10;
    int b1 = b ~/ 10;
    int b2 = b % 10;
    int step1 = a2 * b2;
    int step2 = (a1 * b2) + (a2 * b1);
    int step3 = a1 * b1;
    int finalAns = a * b;

    return _breakdownContainer(
      title: 'Universal 2-Digit Multiply (Criss-Cross)',
      methodName: 'Trick: Sidha guna ➔ Cross guna karke jod ➔ Sidha guna',
      equation: '$a × $b = $finalAns',
      steps: [
        _stepData('1', 'Right side ke digits ka sidha multiply karo:', [
          '• $a2 × $b2 = $step1 (Likhna hai ${step1 % 10}, Carry = ${step1 ~/ 10})',
        ]),
        _stepData('2', 'Cross-multiply karke aapas me jodo:', [
          '• ($a1 × $b2) + ($a2 × $b1) = ${a1 * b2} + ${a2 * b1} = $step2',
          if (step1 ~/ 10 > 0) '• Carry (${step1 ~/ 10}) jodne par = ${step2 + (step1 ~/ 10)}',
        ]),
        _stepData('3', 'Left side ke digits ka sidha multiply + Carry:', [
          '• $a1 × $b1 = $step3 (Bachi hui carry jodo)',
        ]),
      ],
      resultLeft: '${finalAns ~/ 100}',
      resultRight: '${finalAns % 100}',
      finalResult: '$finalAns',
    );
  }

  // --- REUSABLE ILLUMINATED CONTAINER (ZERO OVERLAPPING GUARANTEED) ---
  Widget _breakdownContainer({
    required String title,
    required String methodName,
    required String equation,
    required List<Map<String, dynamic>> steps,
    required String resultLeft,
    required String resultRight,
    required String finalResult,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.4), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Category Tag & Target Equation Badge (Dedicated separated row - NO OVERLAP)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 12, color: AppTheme.gold),
                    SizedBox(width: 3),
                    Text(
                      'SPEED SHORTCUT',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.gold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  equation,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Title and English Method Rule
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '💡 $methodName',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF93C5FD),
            ),
          ),
          const SizedBox(height: 16),

          // Steps List
          ...steps.map((st) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _stepRow(st['num'] as String, st['title'] as String, st['lines'] as List<String>),
          )),
          const SizedBox(height: 4),

          // Final Answer Highlight Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white12,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppTheme.gold, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚡ INSTANT ANSWER (Seedha Jawab)',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF6EE7B7),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$resultLeft | $resultRight = $finalResult',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _stepData(String num, String title, List<String> lines) {
    return {
      'num': num,
      'title': title,
      'lines': lines,
    };
  }

  Widget _stepRow(String num, String title, List<String> lines) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(num, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 3),
              ...lines.map(
                (l) => Text(
                  l,
                  style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1), height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _startPracticeQuizForTrick(VedicTrickType trick) {
    final questions = _generateQuestionsForTrick(trick);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: 'vedic_${trick.name}',
            title: '${_getTrickTitle(trick)} Speed Sprint',
            subtitle: 'Test 2-Second Shortcut Mastery',
            type: TopicType.hardMultiplier,
            iconName: 'psychology_rounded',
          ),
          customQuestions: questions,
          isTimed: true,
          questionCount: questions.length,
        ),
      ),
    );
  }

  String _getTrickTitle(VedicTrickType trick) {
    switch (trick) {
      case VedicTrickType.base100Below:
        return 'Base 100 Below';
      case VedicTrickType.base100Above:
        return 'Base 100 Above';
      case VedicTrickType.endsInFive:
        return 'Squares Ending in 5';
      case VedicTrickType.sameTensUnitsSum10:
        return 'Same Tens & Units Sum 10';
      case VedicTrickType.multiplyBy11:
        return 'Multiply by 11';
      case VedicTrickType.multiplyBy99:
        return 'Multiply by 99';
      case VedicTrickType.numbersIn50s:
        return 'Squares in 50s';
      case VedicTrickType.crissCross:
        return '2-Digit Criss-Cross';
    }
  }

  List<Map<String, String>> _getPresetsForTrick(VedicTrickType trick) {
    switch (trick) {
      case VedicTrickType.base100Below:
        return [
          {'label': '96 × 97', 'a': '96', 'b': '97'},
          {'label': '98 × 94', 'a': '98', 'b': '94'},
          {'label': '92 × 99', 'a': '92', 'b': '99'},
          {'label': '89 × 98', 'a': '89', 'b': '98'},
          {'label': '95 × 95', 'a': '95', 'b': '95'},
        ];
      case VedicTrickType.base100Above:
        return [
          {'label': '104 × 107', 'a': '104', 'b': '107'},
          {'label': '103 × 108', 'a': '103', 'b': '108'},
          {'label': '105 × 109', 'a': '105', 'b': '109'},
          {'label': '112 × 104', 'a': '112', 'b': '104'},
          {'label': '106 × 106', 'a': '106', 'b': '106'},
        ];
      case VedicTrickType.endsInFive:
        return [
          {'label': '25²', 'a': '25', 'b': '25'},
          {'label': '35²', 'a': '35', 'b': '35'},
          {'label': '65²', 'a': '65', 'b': '65'},
          {'label': '85²', 'a': '85', 'b': '85'},
          {'label': '95²', 'a': '95', 'b': '95'},
          {'label': '115²', 'a': '115', 'b': '115'},
        ];
      case VedicTrickType.sameTensUnitsSum10:
        return [
          {'label': '74 × 76', 'a': '74', 'b': '76'},
          {'label': '83 × 87', 'a': '83', 'b': '87'},
          {'label': '42 × 48', 'a': '42', 'b': '48'},
          {'label': '61 × 69', 'a': '61', 'b': '69'},
          {'label': '95 × 95', 'a': '95', 'b': '95'},
        ];
      case VedicTrickType.multiplyBy11:
        return [
          {'label': '53 × 11', 'a': '53', 'b': '11'},
          {'label': '78 × 11', 'a': '78', 'b': '11'},
          {'label': '94 × 11', 'a': '94', 'b': '11'},
          {'label': '124 × 11', 'a': '124', 'b': '11'},
          {'label': '345 × 11', 'a': '345', 'b': '11'},
        ];
      case VedicTrickType.multiplyBy99:
        return [
          {'label': '64 × 99', 'a': '64', 'b': '99'},
          {'label': '83 × 99', 'a': '83', 'b': '99'},
          {'label': '47 × 99', 'a': '47', 'b': '99'},
          {'label': '92 × 99', 'a': '92', 'b': '99'},
          {'label': '28 × 99', 'a': '28', 'b': '99'},
        ];
      case VedicTrickType.numbersIn50s:
        return [
          {'label': '51²', 'a': '51', 'b': '51'},
          {'label': '54²', 'a': '54', 'b': '54'},
          {'label': '56²', 'a': '56', 'b': '56'},
          {'label': '58²', 'a': '58', 'b': '58'},
          {'label': '59²', 'a': '59', 'b': '59'},
        ];
      case VedicTrickType.crissCross:
        return [
          {'label': '23 × 14', 'a': '23', 'b': '14'},
          {'label': '31 × 24', 'a': '31', 'b': '24'},
          {'label': '42 × 33', 'a': '42', 'b': '33'},
          {'label': '52 × 26', 'a': '52', 'b': '26'},
          {'label': '64 × 32', 'a': '64', 'b': '32'},
        ];
    }
  }

  VedicTrickType? _mapVedicTrickToType(int index) {
    switch (index) {
      case 0:
        return VedicTrickType.endsInFive;
      case 1:
        return VedicTrickType.sameTensUnitsSum10;
      case 2:
        return VedicTrickType.multiplyBy11;
      case 3:
        return VedicTrickType.base100Below;
      case 4:
        return VedicTrickType.base100Above;
      case 5:
        return VedicTrickType.multiplyBy99;
      case 6:
        return VedicTrickType.numbersIn50s;
      case 7:
        return VedicTrickType.crissCross;
      default:
        return null;
    }
  }

  Widget _buildPracticeCtaButton() {
    return BouncingCard(
      onTap: () => _startPracticeQuizForTrick(_selectedTrick),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt_rounded, color: AppTheme.gold, size: 20),
            SizedBox(width: 8),
            Text(
              '⚡ Test This Shortcut in 60s Drill (10 Questions)',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  List<QuestionModel> _generateQuestionsForTrick(VedicTrickType trick) {
    List<QuestionModel> list = [];
    for (int i = 0; i < 10; i++) {
      int a = 0;
      int b = 0;
      int ans = 0;
      String prompt = '';
      String explanation = '';

      switch (trick) {
        case VedicTrickType.endsInFive:
          int tens = _rnd.nextInt(9) + 1; // 1 to 9
          a = tens * 10 + 5;
          ans = a * a;
          prompt = '$a² = ?';
          explanation = 'Shortcut: $tens × ${tens + 1} = ${tens * (tens + 1)} | 25 = $ans';
          break;
        case VedicTrickType.sameTensUnitsSum10:
          int t = _rnd.nextInt(9) + 1;
          int u1 = _rnd.nextInt(8) + 1;
          int u2 = 10 - u1;
          a = t * 10 + u1;
          b = t * 10 + u2;
          ans = a * b;
          prompt = '$a × $b = ?';
          explanation = 'Shortcut: $t × ${t + 1} = ${t * (t + 1)} | $u1 × $u2 = ${u1 * u2} ➔ $ans';
          break;
        case VedicTrickType.multiplyBy11:
          a = _rnd.nextInt(80) + 12;
          ans = a * 11;
          prompt = '$a × 11 = ?';
          explanation = 'Shortcut: Add neighboring digits ➔ $ans';
          break;
        case VedicTrickType.multiplyBy99:
          a = _rnd.nextInt(89) + 11;
          ans = a * 99;
          prompt = '$a × 99 = ?';
          explanation = 'Shortcut: (${a - 1}) | (${100 - a}) = $ans';
          break;
        case VedicTrickType.numbersIn50s:
          int u = _rnd.nextInt(9) + 1;
          a = 50 + u;
          ans = a * a;
          prompt = '$a² = ?';
          explanation = 'Shortcut: (25 + $u = ${25 + u}) | ($u² = ${u * u}) ➔ $ans';
          break;
        case VedicTrickType.base100Below:
          a = 91 + _rnd.nextInt(8);
          b = 91 + _rnd.nextInt(8);
          ans = a * b;
          prompt = '$a × $b = ?';
          explanation = 'Base 100: ($a - ${100 - b}) | (${100 - a} × ${100 - b}) = $ans';
          break;
        case VedicTrickType.base100Above:
          a = 101 + _rnd.nextInt(8);
          b = 101 + _rnd.nextInt(8);
          ans = a * b;
          prompt = '$a × $b = ?';
          explanation = 'Base 100: ($a + ${b - 100}) | (${a - 100} × ${b - 100}) = $ans';
          break;
        case VedicTrickType.crissCross:
          a = 12 + _rnd.nextInt(35);
          b = 12 + _rnd.nextInt(35);
          ans = a * b;
          prompt = '$a × $b = ?';
          explanation = 'Criss-Cross: Vertical multiply ends, cross-multiply middle ➔ $ans';
          break;
      }

      Set<int> optionsSet = {ans};
      final int unit = (ans % 10).abs();
      int step = 1;
      while (optionsSet.length < 4) {
        int plus = ans + (10 * step);
        if (plus > 0 && plus % 10 == unit) optionsSet.add(plus);
        if (optionsSet.length < 4) {
          int minus = ans - (10 * step);
          if (minus > 0 && minus % 10 == unit) optionsSet.add(minus);
        }
        step++;
      }
      List<int> sortedOptions = optionsSet.take(4).toList()..shuffle();

      list.add(
        QuestionModel(
          id: 'vedic_${trick.name}_$i',
          prompt: prompt,
          options: sortedOptions.map((e) => '$e').toList(),
          correctAnswer: '$ans',
          explanation: explanation,
          topicId: 'vedic_${trick.name}',
        ),
      );
    }
    return list;
  }

  // --- TAB 2: ALL 10 SPEED TRICKS LIBRARY ---
  Widget _buildAllTricksLibraryTab() {
    const tricks = VedicTricksRepository.tricks;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
      itemCount: tricks.length,
      itemBuilder: (context, index) {
        final t = tricks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category & Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      t.category.toUpperCase(),
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppTheme.primaryLight),
                    ),
                  ),
                  const Icon(Icons.bolt_rounded, color: AppTheme.gold, size: 20),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                t.title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 3),
              Text(
                '💡 Method: ${t.sutraName}',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF93C5FD)),
              ),
              const SizedBox(height: 10),

              // Rule Explanation Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  t.rule,
                  style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                ),
              ),
              const SizedBox(height: 10),

              // Example Breakdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B4B).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
                ),
                child: Text(
                  t.example,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Exam Tip
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.gold, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      t.examTip,
                      style: const TextStyle(fontSize: 11, color: Colors.white60, height: 1.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 12),

              // Action Buttons: Open in Simulator + Start Quiz
              Builder(
                builder: (context) {
                  final mappedTrick = _mapVedicTrickToType(index);
                  return Row(
                    children: [
                      if (mappedTrick != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: AppTheme.primaryLight.withValues(alpha: 0.6)),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.psychology_rounded, size: 16, color: AppTheme.accent),
                            label: const Text(
                              'Simulate 🧪',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedTrick = mappedTrick;
                                _setPresetForTrick(mappedTrick);
                              });
                              _tabController.animateTo(0);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryLight,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.bolt_rounded, size: 16, color: AppTheme.gold),
                            label: const Text(
                              'Test Drill ⚡',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                            onPressed: () => _startPracticeQuizForTrick(mappedTrick),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.menu_book_rounded, size: 16, color: AppTheme.gold),
                            label: const Text(
                              'Master Concept',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('📖 ${t.title}: Master this formula for instant speed recall!'),
                                  backgroundColor: const Color(0xFF1E1B4B),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
