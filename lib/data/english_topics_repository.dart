import 'package:flutter/material.dart';
import '../models/english_models.dart';
import 'english_content_bank.dart';
import '../services/vocab_dictionary_service.dart';

class EnglishTopicsRepository {
  static List<EnglishTopicModule>? _cachedModules;

  /// Returns all topic modules organized cleanly into categories
  static List<EnglishTopicModule> getModules() {
    if (_cachedModules != null && _cachedModules!.isNotEmpty) {
      return _cachedModules!;
    }

    final List<EnglishTopicModule> modules = [];
    final dict = VocabDictionaryService();

    // ─────────────────────────────────────────────────────────────────────────
    // 1. GRAMMAR: SPOTTING ERRORS ARENA
    // ─────────────────────────────────────────────────────────────────────────
    final spottingQs = EnglishContentBank.allSpottingErrors;
    modules.add(
      EnglishTopicModule(
        id: 'spotting_errors',
        title: 'Spotting Errors Arena',
        subtitle: 'Subject-Verb Agreement, Conditionals, Modifiers & Tenses',
        category: 'Grammar',
        icon: Icons.gavel_rounded,
        color: const Color(0xFF6366F1), // Indigo
        examTag: 'SSC CGL / CHSL • ${spottingQs.length} MCQs',
        rules: const [
          EnglishRuleItem(
            ruleTitle: 'Rule 1: Subject-Verb Agreement Connectors',
            explanation:
                'When two subjects are connected by "as well as", "along with", "together with", "with", "in addition to", the verb agrees with the FIRST subject.\n\nWhen connected by "neither... nor", "either... or", "not only... but also", the verb agrees with the NEAREST subject.',
            examples: [
              '❌ The captain, along with his sailors, were drowned.',
              '✅ The captain, along with his sailors, was drowned. (Captain is singular)',
              '❌ Neither the teacher nor the students was present.',
              '✅ Neither the teacher nor the students were present. (Students is plural & nearest)',
            ],
            tip: 'Always identify the primary subject before looking at commas or parenthetical phrases.',
          ),
          EnglishRuleItem(
            ruleTitle: 'Rule 2: The Three Conditional Sentence Formulas',
            explanation:
                '1. Zero/First: If + Simple Present -> will / shall + V1\n2. Second: If + Simple Past (were / V2) -> would / could + V1\n3. Third: If + Past Perfect (had + V3) -> would have + V3',
            examples: [
              '❌ If he will come here, I will help him.',
              '✅ If he comes here, I will help him. (Never use "will" in "if" clause)',
              '❌ If you had informed me, I would come earlier.',
              '✅ If you had informed me, I would have come earlier. (had + V3 -> would have + V3)',
            ],
            tip: 'If clause never takes "would" or "will". Always inspect the auxiliary verb in the main clause.',
          ),
          EnglishRuleItem(
            ruleTitle: 'Rule 3: Pronouns & Indefinite Antecedents',
            explanation:
                'Words like "Each", "Every", "Everyone", "Neither", "Either" take a singular pronoun (his/her) and singular verb.\nWhen "One" is used as subject, its possessive form must be "one\'s" (not his).',
            examples: [
              '❌ One must keep his promise.',
              '✅ One must keep one\'s promise.',
              '❌ Each of the boys completed their homework.',
              '✅ Each of the boys completed his homework.',
            ],
            tip: 'The polite pronoun sequence for normal sentences is 2nd -> 3rd -> 1st person (You, he and I).',
          ),
          EnglishRuleItem(
            ruleTitle: 'Rule 4: Adverb Inversion & Correlative Conjunctions',
            explanation:
                'When a sentence begins with a negative adverb (Hardly, Scarcely, Barely, No sooner, Seldom), the auxiliary verb comes BEFORE the subject (Inversion).\n\n• Hardly / Scarcely is always paired with "when".\n• No sooner is always paired with "than".',
            examples: [
              '❌ Hardly had I stepped out than it started to rain.',
              '✅ Hardly had I stepped out when it started to rain.',
              '❌ No sooner he entered the hall, the bell rang.',
              '✅ No sooner did he enter the hall than the bell rang.',
            ],
            tip: 'Check: 1) Inversion structure, 2) Matching correlative word (when vs than).',
          ),
        ],
        questions: spottingQs,
      ),
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 2. GRAMMAR: SENTENCE IMPROVEMENT & VOICE / NARRATION
    // ─────────────────────────────────────────────────────────────────────────
    final improvementQs = EnglishContentBank.allSentenceImprovement;
    modules.add(
      EnglishTopicModule(
        id: 'sentence_improvement',
        title: 'Sentence Improvement & Transformation',
        subtitle: 'Phrasal Verbs, Redundancy, Voice & Narration Rules',
        category: 'Grammar',
        icon: Icons.auto_fix_high_rounded,
        color: const Color(0xFF8B5CF6), // Violet
        examTag: 'SSC CGL / CHSL • ${improvementQs.length} MCQs',
        rules: const [
          EnglishRuleItem(
            ruleTitle: 'Rule 1: Eliminate Redundant & Superfluous Words',
            explanation:
                'SSC frequently tests redundant combinations where two words express the same meaning.',
            examples: [
              '❌ Return back / Revert back -> ✅ Return / Revert',
              '❌ Repeat again -> ✅ Repeat',
              '❌ Cousin brother / sister -> ✅ Cousin',
              '❌ Supposing if -> ✅ Supposing OR If',
              '❌ Kindly request -> ✅ Request',
            ],
            tip: 'If a word already has "re-" (meaning back/again), never add "again" or "back".',
          ),
          EnglishRuleItem(
            ruleTitle: 'Rule 2: Gerunds after Prepositional "TO"',
            explanation:
                'Usually "to" is followed by V1 (infinitive). However, when "to" is part of a fixed phrase, it is followed by a Gerund (V1 + ing):\n• Look forward to, Accustomed to, With a view to, In addition to, Devoted to, Prone to, Object to.',
            examples: [
              '❌ I am looking forward to meet you.',
              '✅ I am looking forward to meeting you.',
              '❌ He went there with a view to purchase a car.',
              '✅ He went there with a view to purchasing a car.',
            ],
            tip: 'Ask: Can you replace the verb with a noun? "Look forward to [vacation]". If yes, use V-ing!',
          ),
          EnglishRuleItem(
            ruleTitle: 'Rule 3: Active & Passive Voice Transformation',
            explanation:
                'The tense does NOT change in Voice; only the structure changes:\n• Present Continuous: is/am/are + being + V3\n• Perfect: has/have/had + been + V3\n• Modals: modal + be + V3\n• Imperative: Let + object + be + V3',
            examples: [
              'Active: She is preparing the report. -> Passive: The report is being prepared by her.',
              'Active: Shut the window. -> Passive: Let the window be shut.',
            ],
            tip: 'Never change the tense in Voice (e.g. Present stays Present).',
          ),
          EnglishRuleItem(
            ruleTitle: 'Rule 4: Direct to Indirect Speech (Narration)',
            explanation:
                'When reporting verb is in Past (said/told), tense shifts backward:\n• Simple Present -> Simple Past\n• Simple Past -> Past Perfect\n• Present Perfect -> Past Perfect\n• Tomorrow -> The next day / The following day\n• Universal truths do NOT change tense!',
            examples: [
              'Direct: He said, "I visited Agra yesterday." -> Indirect: He said that he had visited Agra the previous day.',
              'Direct: Teacher said, "The earth revolves around the sun." -> Indirect: Teacher said that the earth revolves around the sun. (Universal Truth)',
            ],
            tip: 'Always check if the sentence expresses a universal truth or habitual action.',
          ),
        ],
        questions: improvementQs,
      ),
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 3. FIXED PREPOSITIONS (100 ESSENTIAL PAIRS)
    // ─────────────────────────────────────────────────────────────────────────
    final rawPreps = EnglishContentBank.fixedPrepositions;
    final List<EnglishExerciseQuestion> prepQs = rawPreps.map((p) {
      return EnglishExerciseQuestion(
        id: 'prep_${p.number}',
        questionText: 'Fill in the blank with the correct fixed preposition:\n\n${p.sentence}',
        options: p.options,
        correctIndex: p.correctIndex,
        type: 'preposition',
        explanation: p.rule.isNotEmpty
            ? p.rule
            : 'The verb/adjective here takes "${p.options[p.correctIndex]}" as its fixed preposition.',
      );
    }).toList();

    modules.add(
      EnglishTopicModule(
        id: 'fixed_prepositions',
        title: 'Fixed Prepositions Mastery',
        subtitle: '100 High-Yield Exam Prepositions with Rules & Hindi Notes',
        category: 'Fixed Prepositions',
        icon: Icons.rule_folder_rounded,
        color: const Color(0xFFF59E0B), // Amber
        examTag: '100 MCQs • Complete SSC & Banking Bank',
        rules: const [
          EnglishRuleItem(
            ruleTitle: 'Group 1: Preposition "TO" (Preference & Comparison)',
            explanation:
                'Words ending in "-ior" take "to" (never "than"). Also used for habit, attachment and consequence:\n• Senior to, Junior to, Superior to, Inferior to, Prior to, Preferable to.\n• Accustomed to, Addicted to, Yield to, Subject to, Conducive to, Detrimental to.',
            examples: [
              '❌ Milk is preferable than tea.',
              '✅ Milk is preferable to tea.',
              '❌ He is senior than me in college.',
              '✅ He is senior to me in college.',
            ],
            tip: 'Never use "more" or "than" with comparative adjectives ending in "-ior".',
          ),
          EnglishRuleItem(
            ruleTitle: 'Group 2: Preposition "FROM" (Separation & Prevention)',
            explanation:
                'Verbs indicating refraining, preventing, stopping, or distinguishing take "from":\n• Abstain from (bad habits), Refrain from (actions), Prohibit from, Prevent from, Protect from, Differ from.',
            examples: [
              '❌ We must abstain of alcohol.',
              '✅ We must abstain from alcohol.',
              '❌ The police prevented him to enter the building.',
              '✅ The police prevented him from entering the building.',
            ],
            tip: 'Remember: Abstain / Refrain is always followed by "from + V-ing".',
          ),
          EnglishRuleItem(
            ruleTitle: 'Group 3: Preposition "OF" (Causes, Deprivation & Guilt)',
            explanation:
                '• Accused of, Guilty of, Convicted of (crime/fault)\n• Devoid of, Deprived of, Short of (lacking)\n• Aware of, Conscious of, Ignorant of (knowledge)\n• Die OF a disease (malaria, cancer) vs Die FROM a cause (overwork, thirst, wound).',
            examples: [
              '❌ The patient died from cholera.',
              '✅ The patient died of cholera. (Disease takes "of")',
              '❌ He is accused for theft.',
              '✅ He is accused of theft.',
            ],
            tip: 'Die + OF = Disease; Die + FROM = Hunger, thirst, poison, overeating.',
          ),
          EnglishRuleItem(
            ruleTitle: 'Group 4: Verbs Taking NO Preposition (The Exam Traps!)',
            explanation:
                'The following transitive verbs take a DIRECT object without any preposition:\n• Enter (a place), Discuss (a topic), Describe, Order, Attack, Resemble, Marry, Reach, Tell, Sign.',
            examples: [
              '❌ He entered into the classroom.',
              '✅ He entered the classroom. (Note: "enter into an agreement" is an idiom and takes into)',
              '❌ We will discuss about the problem.',
              '✅ We will discuss the problem.',
              '❌ She ordered for two cups of tea.',
              '✅ She ordered two cups of tea.',
            ],
            tip: 'Never write "discuss about" or "order for food" in exams!',
          ),
        ],
        questions: prepQs,
      ),
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 4. ONE WORD SUBSTITUTION (OWS)
    // ─────────────────────────────────────────────────────────────────────────
    final owsQs = EnglishContentBank.allOneWordSubstitution;
    modules.add(
      EnglishTopicModule(
        id: 'one_word_substitution',
        title: 'One Word Substitution (OWS)',
        subtitle: 'Repeated SSC Words, High-Yield Etymology & Hindi Meanings',
        category: 'Vocabulary',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF10B981), // Emerald
        examTag: 'SSC CGL / CHSL • ${owsQs.length} MCQs',
        rules: const [
          EnglishRuleItem(
            ruleTitle: 'Root Family 1: -CIDE (Act of Killing)',
            explanation:
                '• Homicide = Killing of a human being (नरहत्या)\n• Patricide = Killing of one\'s father (पितृहत्या)\n• Matricide = Killing of one\'s mother (मातृहत्या)\n• Fratricide = Killing of one\'s brother (भ्रातृघात)\n• Regicide = Killing of a king (राजहत्या)\n• Uxoricide = Killing of one\'s wife (पत्नीहत्या)\n• Sororicide = Killing of one\'s sister',
            examples: [
              'Patricide: P for Papa / Father',
              'Matricide: M for Mother',
              'Regicide: R for Royal / King',
            ],
            tip: 'Break the word into Root + Suffix: Patri (father) + cide (kill).',
          ),
          EnglishRuleItem(
            ruleTitle: 'Root Family 2: -CRACY & -ARCHY (Forms of Government)',
            explanation:
                '• Autocracy = Rule by a single person with absolute power\n• Plutocracy = Government by the wealthy class (धनिक तंत्र)\n• Oligarchy = Government by a small group of powerful people\n• Gerontocracy = Government by elderly people\n• Theocracy = Government by religious leaders / divine guidance\n• Anarchy = Absence of government or law (अराजकता)',
            examples: [
              'Pluto was the god of wealth -> Plutocracy = wealthy rule.',
              'Theo relates to religion/god -> Theocracy.',
            ],
            tip: 'Focus on the prefix: Auto (self/single), Pluto (wealth), Theo (God/religion).',
          ),
          EnglishRuleItem(
            ruleTitle: 'Root Family 3: Phobia (Fear) & Phile (Love)',
            explanation:
                '• Claustrophobia = Fear of closed or confined spaces\n• Acrophobia = Fear of heights\n• Agoraphobia = Fear of open or crowded spaces\n• Bibliophile = A lover/collector of books\n• Philanthropist = One who loves and helps humanity\n• Altruist = One who selflessly cares for the welfare of others',
            examples: [
              'Acro relates to summit/heights (Acrobat) -> Acrophobia.',
              'Biblio relates to books (Bible, Bibliography) -> Bibliophile.',
            ],
            tip: 'Phobia = Irration fear; Phile = Deep affection/love.',
          ),
        ],
        questions: owsQs,
      ),
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 5. IDIOMS & PHRASES ARENA
    // ─────────────────────────────────────────────────────────────────────────
    final sscIdiomQuestions = dict.getQuestionsForTopic('ssc_idioms');
    final seenIdioms = <String>{};
    final List<EnglishExerciseQuestion> idiomQs = [];
    for (final q in [...EnglishContentBank.allIdiomQuestions, ...sscIdiomQuestions]) {
      if (seenIdioms.add(q.questionText.trim().toLowerCase())) {
        idiomQs.add(q);
      }
    }
    modules.add(
      EnglishTopicModule(
        id: 'idioms_phrases',
        title: 'Idioms & Phrases Mastery',
        subtitle: 'Thematic Idioms: Animal, Color, Body & Weather with Context',
        category: 'Idioms',
        icon: Icons.lightbulb_rounded,
        color: const Color(0xFFFB923C), // Orange
        examTag: 'SSC CGL / CHSL • ${idiomQs.length} MCQs',
        rules: const [
          EnglishRuleItem(
            ruleTitle: 'Theme 1: Body Part Idioms',
            explanation:
                '• All ears = Listening very attentively and eagerly\n• Cold feet = Feeling sudden nervous hesitation or fear before an action\n• Bite the bullet = Face a difficult or painful situation with courage\n• Turn a blind eye = Pretend not to notice an infraction\n• Cost an arm and a leg = Extremely expensive',
            examples: [
              'Context: Before stepping on stage, the actor developed cold feet.',
              'Context: Knowing surgery was essential, he bit the bullet and scheduled it.',
            ],
            tip: 'Body part idioms relate physical sensations to emotional responses.',
          ),
          EnglishRuleItem(
            ruleTitle: 'Theme 2: Color Idioms',
            explanation:
                '• Out of the blue = Completely unexpected, without warning\n• Red tape = Excessive official formalities and bureaucracy\n• Once in a blue moon = Extremely rare event\n• Black sheep = An odd or disreputable member of a family\n• Green-eyed monster = Jealousy and envy',
            examples: [
              'Context: The promotion offer came out of the blue.',
              'Context: Starting the business took months due to government red tape.',
            ],
            tip: 'Colors carry universal symbolism: Red = bureaucracy/danger, Blue = rarity/surprise.',
          ),
          EnglishRuleItem(
            ruleTitle: 'Theme 3: Animal Idioms',
            explanation:
                '• White elephant = A possession that is useless and very costly to maintain\n• Dark horse = A competitor who unexpectedly wins or succeeds\n• Bull in a china shop = A person who is extremely careless or tactless\n• Cat\'s paw = A person used as a tool by another to do unpleasant work\n• Lion\'s share = The largest portion of something',
            examples: [
              'Context: The giant stadium became a white elephant for the small town.',
              'Context: The youngest participant was the dark horse of the tournament.',
            ],
            tip: 'Visualize the animal\'s character to easily remember the meaning.',
          ),
        ],
        questions: idiomQs,
      ),
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 6. SYNONYMS & ANTONYMS ARENA
    // ─────────────────────────────────────────────────────────────────────────
    final synQs = dict.getQuestionsForTopic('synonyms');
    final antQs = dict.getQuestionsForTopic('antonyms');
    final combinedSynAnt = [...synQs, ...antQs];

    modules.add(
      EnglishTopicModule(
        id: 'synonyms_antonyms',
        title: 'Synonyms & Antonyms Arena',
        subtitle: 'Root Decomposition, Tone-Elimination & High-Yield Vocab',
        category: 'Vocabulary',
        icon: Icons.swap_horiz_rounded,
        color: const Color(0xFF06B6D4), // Cyan
        examTag: 'SSC & Banking • ${combinedSynAnt.length} MCQs',
        rules: const [
          EnglishRuleItem(
            ruleTitle: 'Strategy 1: The Positive vs Negative Tone Filter',
            explanation:
                'When you do not know the exact definition of a word, determine its emotional tone (Positive, Negative, or Neutral) from its prefix:\n• Bene-, Eu-, Ambi-, Pro- are usually POSITIVE.\n• Mal-, Dys-, Mis-, In-, Dis-, Non- are usually NEGATIVE.\n\nIf the question asks for a SYNONYM of a negative word, eliminate all positive choices immediately!',
            examples: [
              'Malicious (Mal- = bad) -> tone is negative. Eliminate "kind", "helpful".',
              'Euphoric (Eu- = good) -> tone is highly positive. Eliminate "depressed", "gloomy".',
            ],
            tip: 'Tone elimination cuts down options from 4 to 2 in seconds!',
          ),
          EnglishRuleItem(
            ruleTitle: 'Strategy 2: Secondary Meanings of Words',
            explanation:
                'Competitive exams rarely test the primary meaning. They test secondary meanings:\n• Sanction = To approve / authorize OR an economic penalty.\n• Compromise = Settle dispute OR expose to danger / weaken.\n• Cleave = Split apart OR stick firmly to.\n• Flag = Droop / become weak with exhaustion.',
            examples: [
              'Context: His energy began to flag after the 10-mile run. (Flag = weaken)',
              'Context: Security of the system was compromised. (Compromised = weakened)',
            ],
            tip: 'Read the context carefully to see which meaning fits the register.',
          ),
        ],
        questions: combinedSynAnt,
      ),
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 7. SPELLING TRAPS MASTERY
    // ─────────────────────────────────────────────────────────────────────────
    final spellQs = EnglishContentBank.allSpellingQuestions;
    modules.add(
      EnglishTopicModule(
        id: 'spelling_traps',
        title: 'Spelling Traps Mastery',
        subtitle: 'Double Consonants, Silent Letters & SSC Top 25 Misspelt Words',
        category: 'Vocabulary',
        icon: Icons.spellcheck_rounded,
        color: const Color(0xFFEC4899), // Pink
        examTag: 'SSC CGL / CHSL • ${spellQs.length} MCQs',
        rules: const [
          EnglishRuleItem(
            ruleTitle: 'Rule 1: The Famous "I before E except after C"',
            explanation:
                'Use "ie" for the /ee/ sound: Believe, Achieve, Relieve, Thief, Chief.\nExcept after "c", where you use "ei": Receive, Deceive, Perceive, Ceiling, Receipt.\n\nExceptions to memorize: Seize, Weird, Foreign, Height, Leisure.',
            examples: [
              '✅ Re-c-ei-ve (after c)',
              '✅ B-el-ie-ve (not after c)',
              '⚠️ Weird, Seize are exceptions!',
            ],
            tip: 'Rhyme: "I before E, except after C, or when sounded as A, as in neighbor and weigh."',
          ),
          EnglishRuleItem(
            ruleTitle: 'Rule 2: SSC Top 10 Most Repeated Spelling Traps',
            explanation:
                '1. Accommodate (2 C\'s, 2 M\'s)\n2. Millennium (2 L\'s, 2 N\'s)\n3. Embarrass (2 R\'s, 2 S\'s)\n4. Questionnaire (2 N\'s)\n5. Occurrence (2 C\'s, 2 R\'s)\n6. Privilege (NO letter D!)\n7. Gauge (G-A-U-G-E, not guage)\n8. Supersede (ends in -SEDE, not -cede)\n9. Bureaucracy (B-U-R-E-A-U-C-R-A-C-Y)\n10. Conscientious (C-O-N-S-C-I-E-N-T-I-O-U-S)',
            examples: [
              '❌ Accomodate -> ✅ Accommodate',
              '❌ Millenium -> ✅ Millennium',
              '❌ Embarass -> ✅ Embarrass',
              '❌ Priviledge -> ✅ Privilege',
            ],
            tip: 'Write the word by hand once — muscle memory catches spelling traps faster than eyesight.',
          ),
        ],
        questions: spellQs,
      ),
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 8. HOMONYMS & CONFUSING WORDS
    // ─────────────────────────────────────────────────────────────────────────
    final homonymQs = dict.getQuestionsForTopic('homonyms');
    if (homonymQs.isNotEmpty) {
      modules.add(
        EnglishTopicModule(
          id: 'homonyms',
          title: 'Homonyms & Confusing Pairs',
          subtitle: 'Look-Alike & Sound-Alike Words with Subtle Distinct Meanings',
          category: 'Vocabulary',
          icon: Icons.compare_arrows_rounded,
          color: const Color(0xFF14B8A6), // Teal
          examTag: 'SSC & Banking • ${homonymQs.length} MCQs',
          rules: const [
            EnglishRuleItem(
              ruleTitle: 'Top Confusing Pairs Examined by SSC',
              explanation:
                '• Affect (verb = to influence) vs Effect (noun = result / impact)\n• Compliment (praise) vs Complement (completes or matches well)\n• Principle (moral rule / truth) vs Principal (head of school / main sum)\n• Stationary (not moving) vs Stationery (writing materials / paper)\n• Discreet (careful / private) vs Discrete (separate / distinct)\n• Eminent (famous / prominent) vs Imminent (about to happen soon)',
              examples: [
                'Context: Smoking will affect your lungs. The effect was immediate.',
                'Context: Red wine complements the steak nicely. He paid her a lovely compliment.',
                'Context: The principal of the college is a man of high principles.',
              ],
              tip: 'Station-ER-y with "er" is for pap-ER and lett-ER!',
            ),
          ],
          questions: homonymQs,
        ),
      );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 9. THE 18 CORE WORD VAULT TOPICS (Individual In-Depth Vocabulary Units)
    // ─────────────────────────────────────────────────────────────────────────
    for (final wt in EnglishContentBank.vocabularyTopics) {
      modules.add(
        EnglishTopicModule(
          id: 'vault_${wt.id}',
          title: 'Word Vault #${wt.id}: ${wt.word}',
          subtitle: '${wt.partOfSpeech.toUpperCase()} • ${wt.synonyms.take(4).join(", ")}...',
          category: 'Word Vaults',
          icon: Icons.diamond_rounded,
          color: const Color(0xFF38BDF8), // Light Blue
          examTag: 'Deep Study • ${wt.exercises.length} MCQs',
          rules: [
            EnglishRuleItem(
              ruleTitle: 'Headword: ${wt.word} (${wt.partOfSpeech})',
              explanation:
                  'Etymology & Root: ${wt.rootWord.isNotEmpty ? wt.rootWord : "High-frequency root word"}\n\nHigh-Frequency Synonyms:\n${wt.synonyms.join(" • ")}\n\nHigh-Frequency Antonyms:\n${wt.antonyms.join(" • ")}',
              examples: wt.idioms.entries
                  .map((e) => '${e.key}: ${e.value.join(", ")}')
                  .toList(),
              tip: 'Use flashcard repetition to cement both synonyms and antonyms.',
            ),
          ],
          questions: wt.exercises,
          wordTopic: wt,
        ),
      );
    }

    _cachedModules = modules;
    return modules;
  }

  /// Returns modules filtered by category: 'All', 'Grammar', 'Vocabulary', 'Fixed Prepositions', 'Idioms', 'Word Vaults'
  static List<EnglishTopicModule> getModulesByCategory(String category) {
    final all = getModules();
    if (category == 'All') return all;
    return all.where((m) => m.category == category).toList();
  }
}
