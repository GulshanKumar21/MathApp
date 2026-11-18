import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/english_models.dart';
import '../../services/english_tts_service.dart';
import 'english_quiz_screen.dart';

class EnglishLearnConceptScreen extends StatelessWidget {
  final EnglishTopicModule module;

  const EnglishLearnConceptScreen({
    super.key,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          module.title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Pronounce Title',
            icon: const Icon(Icons.volume_up_rounded, color: AppTheme.cyan),
            onPressed: () {
              HapticFeedback.lightImpact();
              EnglishTtsService().speakWord(module.title);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Topic Hero Banner
                    _buildHeroBanner(context),
                    const SizedBox(height: 18),

                    // 2. Word Vault Details if this is an English Word Topic
                    if (module.wordTopic != null) ...[
                      _buildWordTopicDetails(context, module.wordTopic!),
                      const SizedBox(height: 18),
                    ],

                    // 3. Rules & Concepts Section Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: module.color.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.psychology_rounded, color: module.color, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Key Concepts & Exam Rules (${module.rules.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 4. Detailed Concept & Rule Cards
                    ...module.rules.asMap().entries.map((entry) {
                      final int idx = entry.key;
                      final EnglishRuleItem rule = entry.value;
                      return _buildRuleCard(idx + 1, rule);
                    }),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Practice Button (Parity with Math's Learn Screen!)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(
                  top: BorderSide(color: Color(0xFF1E293B), width: 1.2),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: module.questions.isEmpty
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EnglishQuizScreen(
                                title: module.title,
                                subtitle: '${module.questions.length} Topic Practice Questions',
                                questions: module.questions,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: module.color,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 22, color: Colors.black),
                  label: Text(
                    module.questions.isNotEmpty
                        ? 'START PRACTICE QUIZ (${module.questions.length} MCQs)'
                        : 'NO PRACTICE QUESTIONS YET',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            module.color.withValues(alpha: 0.22),
            const Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: module.color.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: module.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: module.color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  module.category.toUpperCase(),
                  style: TextStyle(
                    color: module.color,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  module.examTag,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            module.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            module.subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(int num, EnglishRuleItem rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rule Title with Number Tag
          Text(
            rule.ruleTitle,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: module.color,
            ),
          ),
          const SizedBox(height: 8),

          // Rule Explanation
          Text(
            rule.explanation,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.45,
            ),
          ),

          // Examples Box
          if (rule.examples.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRACTICE EXAMPLES:',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...rule.examples.map(
                    (ex) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        ex,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: ex.startsWith('✅')
                              ? const Color(0xFF34D399)
                              : ex.startsWith('❌')
                                  ? const Color(0xFFF87171)
                                  : Colors.white70,
                          fontWeight: ex.startsWith('✅') || ex.startsWith('❌')
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Tip Callout Box
          if (rule.tip != null && rule.tip!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Exam Tip: ${rule.tip}',
                      style: const TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWordTopicDetails(BuildContext context, EnglishWordTopic wt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Root Word Card
        if (wt.rootWord.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.surfaceLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.psychology_rounded, color: AppTheme.gold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Root Word & Etymology',
                        style: TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        wt.rootWord,
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Synonyms
        _buildWordChipGroup(
          title: 'High-Frequency Synonyms (${wt.synonyms.length})',
          color: const Color(0xFF10B981),
          words: wt.synonyms,
        ),
        const SizedBox(height: 12),

        // Antonyms
        _buildWordChipGroup(
          title: 'High-Frequency Antonyms (${wt.antonyms.length})',
          color: const Color(0xFFEF4444),
          words: wt.antonyms,
        ),
      ],
    );
  }

  Widget _buildWordChipGroup({
    required String title,
    required Color color,
    required List<String> words,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: words.map((w) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  w,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
