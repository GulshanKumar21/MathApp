import 'package:flutter/material.dart';
import '../models/math_models.dart';
import '../screens/practice/recall_solve_screen.dart';
import '../screens/practice/practice_quiz_screen.dart';
import '../theme/app_theme.dart';
import 'bouncing_card.dart';

/// 1-Hour Recall Alert Multi-Question Deck
/// Displays ALL pending mistake questions in an interactive swipeable deck
/// with individual "Solve" buttons and a "Drill All" action to clear all mistakes
class SwiggyFloatingActionPill extends StatelessWidget {
  final List<MistakeModel> mistakes;
  final StudyPlanModel? activePlan;
  final bool isPlanDue;

  const SwiggyFloatingActionPill({
    super.key,
    required this.mistakes,
    this.activePlan,
    this.isPlanDue = false,
  });

  @override
  Widget build(BuildContext context) {
    if (mistakes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE11D48).withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Status Badge, Pending Count & Optional "Drill All"
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
                ),
                child: const Icon(Icons.alarm_on_rounded, color: Color(0xFFF87171), size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1-HR RECALL ALERT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFCA5A5),
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      '${mistakes.length} ${mistakes.length == 1 ? 'Question' : 'Questions'} Pending Recall',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (mistakes.length > 1) ...[
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 14, color: AppTheme.gold),
                  label: Text(
                    'Drill All (${mistakes.length})',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                  onPressed: () => _startDrillAll(context),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Body: Single Card or Multi-Card Swipeable Carousel
          if (mistakes.length == 1)
            _buildSingleMistakeCard(context, mistakes.first)
          else
            _buildMultiMistakesCarousel(context),
        ],
      ),
    );
  }

  // Single Question Layout
  Widget _buildSingleMistakeCard(BuildContext context, MistakeModel m) {
    final cleanPrompt = m.prompt.replaceAll(' = ?', '').replaceAll('?', '').trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13090C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        m.topicId.toUpperCase(),
                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFFFCA5A5)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Your previous: "${m.userAnswer}" ❌',
                        style: const TextStyle(fontSize: 10, color: Color(0xFFF87171), fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'What is $cleanPrompt?',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          BouncingCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecallSolveScreen(formula: m.prompt, mistake: m),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Solve',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFDC2626)),
                  ),
                  SizedBox(width: 3),
                  Icon(Icons.arrow_forward_rounded, color: Color(0xFFDC2626), size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Multi-Question Swipeable Deck Layout (Shows ALL Wrong Questions)
  Widget _buildMultiMistakesCarousel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 98,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: mistakes.length,
            separatorBuilder: (_, index) => const SizedBox(width: 10),
            itemBuilder: (context, idx) {
              final m = mistakes[idx];
              final cleanPrompt = m.prompt.replaceAll(' = ?', '').replaceAll('?', '').trim();

              return Container(
                width: 230,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF141928),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFF43F5E).withValues(alpha: 0.25),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Tag: Question # & Topic
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${idx + 1} ${m.topicId.toUpperCase()}',
                            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFFFCA5A5)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Missed: "${m.userAnswer}" ❌',
                            style: const TextStyle(fontSize: 9, color: Color(0xFFF87171), fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Problem Formula & Solve Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$cleanPrompt = ?',
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecallSolveScreen(formula: m.prompt, mistake: m),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Solve',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFFDC2626)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.swipe_rounded, size: 12, color: Colors.white38),
            const SizedBox(width: 4),
            Text(
              'Swipe to view all ${mistakes.length} mistakes',
              style: const TextStyle(fontSize: 9.5, color: Colors.white38, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  void _startDrillAll(BuildContext context) {
    if (mistakes.isEmpty) return;

    List<QuestionModel> revQuestions = mistakes.map((m) {
      int? ansInt = int.tryParse(m.correctAnswer);
      Set<String> opts = {m.correctAnswer};
      if (ansInt != null) {
        if (ansInt.abs() < 10) {
          final pool = [1, -1, 2, -2, 3, -3, 4, -4, 5, -5]..shuffle();
          for (int d in pool) {
            if (opts.length >= 4) break;
            int cand = ansInt + d;
            if (cand >= 0 && cand != ansInt) {
              opts.add('$cand');
            }
          }
          int step = 1;
          while (opts.length < 4) {
            if (ansInt + step >= 0) opts.add('${ansInt + step}');
            if (opts.length < 4 && ansInt - step >= 0) opts.add('${ansInt - step}');
            step++;
          }
        } else {
          int unit = (ansInt % 10).abs();
          int? userAnsInt = int.tryParse(m.userAnswer);
          if (userAnsInt != null && (userAnsInt % 10).abs() == unit && userAnsInt > 0) {
            opts.add(m.userAnswer);
          }
          int step = 1;
          while (opts.length < 4) {
            int plus = ansInt + (10 * step);
            if (plus > 0 && plus % 10 == unit) opts.add('$plus');
            if (opts.length < 4) {
              int minus = ansInt - (10 * step);
              if (minus > 0 && minus % 10 == unit) opts.add('$minus');
            }
            step++;
          }
        }
      } else {
        opts.addAll(['1/4', '1/8', '3/8']);
      }
      List<String> listOpts = opts.take(4).toList()..shuffle();

      return QuestionModel(
        id: m.id,
        topicId: m.topicId,
        prompt: m.prompt,
        correctAnswer: m.correctAnswer,
        options: listOpts,
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: 'recall_all',
            title: '1-Hour Recall Drill',
            subtitle: 'Re-solving all ${mistakes.length} past mistakes',
            type: TopicType.custom,
            iconName: 'alarm_on_rounded',
          ),
          customQuestions: revQuestions,
          isTimed: true,
          questionCount: revQuestions.length,
        ),
      ),
    );
  }
}
