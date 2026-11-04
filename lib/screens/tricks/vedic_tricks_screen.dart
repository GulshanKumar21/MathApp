import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../data/vedic_tricks_repository.dart';

import 'interactive_vedic_simulator_screen.dart';

class VedicTricksScreen extends StatelessWidget {
  const VedicTricksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tricks = VedicTricksRepository.tricks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vedic Math & Speed Tricks'),
        actions: [
          IconButton(
            tooltip: 'Interactive Simulator',
            icon: const Icon(Icons.psychology_rounded, color: AppTheme.accent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InteractiveVedicSimulatorScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tricks.length,
        itemBuilder: (context, index) {
          final t = tricks[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.category.toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
                      ),
                    ),
                    Text(
                      t.sutraName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.gold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  t.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  t.rule,
                  style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.surfaceLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRACTICAL EXAMPLE:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accent),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.example,
                        style: const TextStyle(fontSize: 14, fontFamily: 'monospace', color: Colors.white),
                      ),
                    ],
                  ),
                ),
                if (t.examTip.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.tips_and_updates_rounded, color: AppTheme.gold, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          t.examTip,
                          style: const TextStyle(fontSize: 12, color: Colors.white60, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  t.explanation,
                  style: const TextStyle(fontSize: 12, color: Colors.white38),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms, delay: (index * 60).ms).slideY(begin: 0.1);
        },
      ),
    );
  }
}
