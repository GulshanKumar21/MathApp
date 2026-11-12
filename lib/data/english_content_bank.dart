import 'blackbook_vocabulary_bank.dart';
import '../models/english_models.dart';

class EnglishContentBank {

  // =========================================================================
  // PREPVANTA VOCABULARY DICTIONARY ENGINE GETTERS
  // =========================================================================
  static List<BlackbookOwsItem> get blackbookOws => BlackbookVocabularyBank.topOws;
  static List<BlackbookIdiomItem> get blackbookIdioms => BlackbookVocabularyBank.topIdioms;
  static List<BlackbookSynAntItem> get blackbookSynAnt => BlackbookVocabularyBank.topSynAnt;
  static List<BlackbookHomonymPair> get blackbookHomonyms => BlackbookVocabularyBank.topHomonyms;
  static List<BlackbookSpellingItem> get blackbookSpellings => BlackbookVocabularyBank.topSpellings;
  static List<BlackbookRootWordItem> get blackbookRoots => BlackbookVocabularyBank.rootWords;
  static List<EnglishExerciseQuestion> get blackbookPractice => BlackbookVocabularyBank.blackbookPracticeQuestions;

  // =========================================================================
  // 1. 100 REAL EXAM FIXED PREPOSITIONS (Q151 to Q250) WITH VERIFIED SOLUTIONS
  // =========================================================================
  static final List<FixedPrepositionQuestion> fixedPrepositions = [
    const FixedPrepositionQuestion(
      number: 151,
      sentence: 'She has great affection ________ me.',
      options: ['for', 'in', 'with', 'to'],
      correctIndex: 0,
      rule: 'Fixed Preposition: "Affection" takes "for" (affection for someone). But note: "Affectionate" takes "to".',
    ),
    const FixedPrepositionQuestion(
      number: 152,
      sentence: 'Kanak is endowed ________ many great qualities.',
      options: ['in', 'with', 'of', 'by'],
      correctIndex: 1,
      rule: 'Fixed Preposition: "Endowed" always takes "with" (endowed with = naturally gifted with).',
    ),
    const FixedPrepositionQuestion(
      number: 153,
      sentence: 'Our country is committed ________ a policy of peaceful co-existence.',
      options: ['with', 'for', 'to', 'by'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Committed" takes "to" + noun / V1+ing (committed to a cause / doing something).',
    ),
    const FixedPrepositionQuestion(
      number: 154,
      sentence: 'He stumbled at the stone and fell ________ a ditch.',
      options: ['on', 'into', 'in', 'within'],
      correctIndex: 1,
      rule: 'Preposition of Motion: Movement from outside to inside takes "into" (fell into a ditch / river).',
    ),
    const FixedPrepositionQuestion(
      number: 155,
      sentence: 'The storehouse was infested ________ rats.',
      options: ['by', 'of', 'with', 'in'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Infested" always takes "with" (overrun in large numbers by pests).',
    ),
    const FixedPrepositionQuestion(
      number: 156,
      sentence: 'You must adapt yourself ________ your new surroundings.',
      options: ['towards', 'in', 'with', 'to'],
      correctIndex: 3,
      rule: 'Fixed Preposition: "Adapt to" = adjust or calibrate to new circumstances.',
    ),
    const FixedPrepositionQuestion(
      number: 157,
      sentence: 'We should abide ________ the rules of the institution.',
      options: ['with', 'to', 'on', 'by'],
      correctIndex: 3,
      rule: 'Fixed Preposition: "Abide by" = to follow or accept a rule, decision, or agreement.',
    ),
    const FixedPrepositionQuestion(
      number: 158,
      sentence: 'He has resigned himself ________ fate.',
      options: ['in', 'into', 'for', 'to'],
      correctIndex: 3,
      rule: 'Fixed Preposition: "Resign oneself to" = to accept an unpleasant situation that cannot be changed.',
    ),
    const FixedPrepositionQuestion(
      number: 159,
      sentence: 'We should always stick to our decisions otherwise people will mock ________ us.',
      options: ['over', 'at', 'on', 'upon'],
      correctIndex: 1,
      rule: 'Fixed Preposition: "Mock at" / "Laugh at" / "Sneer at" / "Jeer at" take "at".',
    ),
    const FixedPrepositionQuestion(
      number: 160,
      sentence: 'I shall take revenge ________ you.',
      options: ['at', 'on', 'with', 'from'],
      correctIndex: 1,
      rule: 'Fixed Preposition: "Revenge on someone" (e.g. avenge a wrong on someone, take revenge on a rival).',
    ),
    const FixedPrepositionQuestion(
      number: 161,
      sentence: 'I cannot deprive him ________ his rights.',
      options: ['of', 'off', 'with', 'from'],
      correctIndex: 0,
      rule: 'Fixed Preposition: "Deprive of" = to take something away from someone (deprive sb of sth).',
    ),
    const FixedPrepositionQuestion(
      number: 162,
      sentence: 'She was compensated ________ the loss of her belongings.',
      options: ['over', 'for', 'against', 'at'],
      correctIndex: 1,
      rule: 'Fixed Preposition: "Compensated for" = reimbursed for a loss or damage.',
    ),
    const FixedPrepositionQuestion(
      number: 163,
      sentence: 'Sometimes it is difficult to deal ________ a problem child.',
      options: ['with', 'in', 'at', 'out'],
      correctIndex: 0,
      rule: 'Fixed Preposition: "Deal with a person/issue" (manage), whereas "Deal in a commodity" (trade).',
    ),
    const FixedPrepositionQuestion(
      number: 164,
      sentence: 'Ajeet was annoyed ________ his wife.',
      options: ['upon', 'on', 'with', 'at'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Annoyed with a person", but "Annoyed at/about something / someone\'s behavior".',
    ),
    const FixedPrepositionQuestion(
      number: 165,
      sentence: 'Do not quarrel ________ your neighbours.',
      options: ['from', 'by', 'with', 'against'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Quarrel with someone over/about a matter".',
    ),
    const FixedPrepositionQuestion(
      number: 166,
      sentence: 'The people, who depend ________ others, can never prosper in life.',
      options: ['on', 'over', 'at', 'upon'],
      correctIndex: 0,
      rule: 'Fixed Preposition: "Depend on" / "Rely on" / "Count on" / "Bank on".',
    ),
    const FixedPrepositionQuestion(
      number: 167,
      sentence: 'Your statement is replete ________ contradictions.',
      options: ['by', 'of', 'in', 'with'],
      correctIndex: 3,
      rule: 'Fixed Preposition: "Replete with" = filled or well-supplied with something.',
    ),
    const FixedPrepositionQuestion(
      number: 168,
      sentence: 'She smiled ________ my words.',
      options: ['at', 'upon', 'on', 'over'],
      correctIndex: 0,
      rule: 'Fixed Preposition: "Smile at" / "Laugh at". (Note: Fate smiled on him = favoured him).',
    ),
    const FixedPrepositionQuestion(
      number: 169,
      sentence: 'The president will be provided ________ all the facilities he is entitled to.',
      options: ['of', 'to', 'by', 'with'],
      correctIndex: 3,
      rule: 'Fixed Preposition: "Provide someone with something" (or provide something for/to someone).',
    ),
    const FixedPrepositionQuestion(
      number: 170,
      sentence: 'It is difficult for me to part ________ my belongings.',
      options: ['from', 'of', 'with', 'off'],
      correctIndex: 2,
      rule: 'Rule: "Part with sth" (separate from a thing/possession); "Part from sb" (separate from a person).',
    ),
    const FixedPrepositionQuestion(
      number: 171,
      sentence: 'He was charged ________ murder and brought to trial.',
      options: ['by', 'for', 'of', 'with'],
      correctIndex: 3,
      rule: 'Rule: "Charged with a crime" (accused officially), but "Accused of a crime".',
    ),
    const FixedPrepositionQuestion(
      number: 172,
      sentence: 'Everything hinges ________ what happens next.',
      options: ['of', 'with', 'in', 'on'],
      correctIndex: 3,
      rule: 'Fixed Preposition: "Hinge on/upon" = depends entirely on.',
    ),
    const FixedPrepositionQuestion(
      number: 173,
      sentence: 'Corruption is a standing hindrance ________ the nation\'s development.',
      options: ['of', 'over', 'to', 'upon'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Hindrance to" / "Obstacle to" / "Barrier to".',
    ),
    const FixedPrepositionQuestion(
      number: 174,
      sentence: 'The farmers suffered because the monsoon did not arrive ________ time.',
      options: ['at', 'by', 'on', 'after'],
      correctIndex: 2,
      rule: 'Rule: "On time" = punctual/scheduled time; "In time" = with sufficient time to spare.',
    ),
    const FixedPrepositionQuestion(
      number: 175,
      sentence: 'The garbage has been disposed ________.',
      options: ['off', 'of', 'with', 'out'],
      correctIndex: 1,
      rule: 'Fixed Preposition: "Dispose of" (single \'f\', not double \'f\') = to discard or get rid of.',
    ),
    const FixedPrepositionQuestion(
      number: 176,
      sentence: 'You are trying to drag me ________ a controversy.',
      options: ['in', 'into', 'from', 'for'],
      correctIndex: 1,
      rule: 'Preposition of Motion: "Drag someone into an argument / controversy".',
    ),
    const FixedPrepositionQuestion(
      number: 177,
      sentence: 'I complimented him ________ his brilliant success in the examination.',
      options: ['over', 'for', 'to', 'on'],
      correctIndex: 3,
      rule: 'Fixed Preposition: "Compliment on" / "Congratulate on" (congratulate/compliment sb on sth).',
    ),
    const FixedPrepositionQuestion(
      number: 178,
      sentence: 'He was heartbroken ________ Mary\'s indifference to him.',
      options: ['at', 'on', 'to', 'for'],
      correctIndex: 0,
      rule: 'Fixed Preposition: "Heartbroken at someone\'s behavior or news".',
    ),
    const FixedPrepositionQuestion(
      number: 179,
      sentence: 'Translate this passage from English ________ Telugu.',
      options: ['in', 'into', 'to', 'upto'],
      correctIndex: 1,
      rule: 'Rule of Change: "Translate from X into Y" (transition of state/form uses into).',
    ),
    const FixedPrepositionQuestion(
      number: 180,
      sentence: 'This accommodation is not adequate ________ the needs of our family.',
      options: ['upto', 'on', 'to', 'for'],
      correctIndex: 3,
      rule: 'Fixed Preposition: "Adequate for" (meeting a requirement/need).',
    ),
    const FixedPrepositionQuestion(
      number: 181,
      sentence: 'I challenged him ________ a game of chess.',
      options: ['for', 'to', 'against', 'on'],
      correctIndex: 1,
      rule: 'Fixed Preposition: "Challenge someone to a contest/duel/game".',
    ),
    const FixedPrepositionQuestion(
      number: 182,
      sentence: 'I saw my friend leaning ________ a lamp-post with a cigarette between his lips.',
      options: ['over', 'upon', 'against', 'on'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Lean against" = resting against a vertical surface for support.',
    ),
    const FixedPrepositionQuestion(
      number: 183,
      sentence: 'He is in the habit of finding fault ________ other\'s works.',
      options: ['in', 'with', 'of', 'for'],
      correctIndex: 1,
      rule: 'Idiomatic Preposition: "Find fault with" = to criticize or point out flaws in something/someone.',
    ),
    const FixedPrepositionQuestion(
      number: 184,
      sentence: 'The college term will end ________ a month.',
      options: ['in', 'with', 'from', 'about'],
      correctIndex: 0,
      rule: 'Time Preposition: "In a month" = at the end of a month.',
    ),
    const FixedPrepositionQuestion(
      number: 185,
      sentence: 'They wanted advice ________ how they could procure funds for their new business.',
      options: ['about', 'to', 'for', 'on'],
      correctIndex: 3,
      rule: 'Fixed Preposition: "Advice on" a subject/matter (or advice about). "Advice on" is preferred in exam English.',
    ),
    const FixedPrepositionQuestion(
      number: 186,
      sentence: 'There is already opposition ________ the government\'s industrial policy.',
      options: ['for', 'from', 'to', 'towards'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Opposition to" (opposed to something).',
    ),
    const FixedPrepositionQuestion(
      number: 187,
      sentence: 'In an election, those in power should feel obliged to compete ________ their opponents on equal terms.',
      options: ['with', 'towards', 'against', 'on'],
      correctIndex: 0,
      rule: 'Fixed Preposition: "Compete with someone for a prize".',
    ),
    const FixedPrepositionQuestion(
      number: 188,
      sentence: 'The work on this project has been seriously set ________.',
      options: ['on', 'off', 'of', 'about'],
      correctIndex: 1,
      rule: 'Phrasal Verb: "Set back" (delayed/hindered) or "Set off" (started/triggered).',
    ),
    const FixedPrepositionQuestion(
      number: 189,
      sentence: 'This house is too expensive to keep ________.',
      options: ['off', 'up', 'to', 'at'],
      correctIndex: 1,
      rule: 'Phrasal Verb: "Keep up" = maintain in good condition / sustain.',
    ),
    const FixedPrepositionQuestion(
      number: 190,
      sentence: 'Gandhiji was dearer ________ all.',
      options: ['from', 'for', 'since', 'to'],
      correctIndex: 3,
      rule: 'Fixed Preposition: "Dear to someone" (precious or cherished by someone).',
    ),
    const FixedPrepositionQuestion(
      number: 191,
      sentence: 'A girl with blue eyes has just gone ________ the door.',
      options: ['off', 'in', 'besides', 'through'],
      correctIndex: 3,
      rule: 'Preposition of Passage: Passing across a doorway/threshold uses "through the door".',
    ),
    const FixedPrepositionQuestion(
      number: 192,
      sentence: 'His genius borders ________ lunacy.',
      options: ['to', 'upto', 'on', 'about'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Border on / upon" = to come very close to an extreme quality.',
    ),
    const FixedPrepositionQuestion(
      number: 193,
      sentence: 'Ravi is married ________ a cousin of mine.',
      options: ['with', 'to', 'off', 'alongwith'],
      correctIndex: 1,
      rule: 'Rule: In passive voice, "Married to" (NOT married with). e.g., "He is married to Sita."',
    ),
    const FixedPrepositionQuestion(
      number: 194,
      sentence: 'When I parted ________ my mother, there were tears in my eyes.',
      options: ['from', 'with', 'off', 'of'],
      correctIndex: 0,
      rule: 'Rule: "Part from a person", but "Part with a possession/thing".',
    ),
    const FixedPrepositionQuestion(
      number: 195,
      sentence: 'Conversation was carried on ________ whispers.',
      options: ['with', 'by', 'away', 'in'],
      correctIndex: 3,
      rule: 'Manner Preposition: "In whispers" / "in a low voice" / "in silence".',
    ),
    const FixedPrepositionQuestion(
      number: 196,
      sentence: 'He gave an order ________ a cup of coffee.',
      options: ['of', 'for', 'about', 'on'],
      correctIndex: 1,
      rule: 'Noun Rule: As a noun, "Order for something". (As a verb, no preposition: "He ordered a cup of coffee").',
    ),
    const FixedPrepositionQuestion(
      number: 197,
      sentence: 'My mother is afflicted ________ pain in the joints.',
      options: ['with', 'at', 'of', 'for'],
      correctIndex: 0,
      rule: 'Fixed Preposition: "Afflicted with a disease/pain" (suffering from).',
    ),
    const FixedPrepositionQuestion(
      number: 198,
      sentence: 'With your help, I could tide ________ my difficulties.',
      options: ['away', 'off', 'against', 'over'],
      correctIndex: 3,
      rule: 'Phrasal Verb: "Tide over" = to help or support someone through a difficult period.',
    ),
    const FixedPrepositionQuestion(
      number: 199,
      sentence: 'The minister will be requested to give ________ the prizes to the winners.',
      options: ['away', 'in', 'off', 'no preposition'],
      correctIndex: 0,
      rule: 'Phrasal Verb: "Give away" = distribute prizes/gifts. "Give in" = surrender.',
    ),
    const FixedPrepositionQuestion(
      number: 200,
      sentence: 'She said that she was feeling sick ________ heart.',
      options: ['of', 'in', 'at', 'to'],
      correctIndex: 2,
      rule: 'Idiomatic Phrase: "Sick at heart" = deeply grieved or discouraged.',
    ),

    // Questions 201 to 250
    const FixedPrepositionQuestion(
      number: 201,
      sentence: 'Those who count ________ other\'s help generally lose the game.',
      options: ['about', 'above', 'around', 'on'],
      correctIndex: 3,
      rule: 'Fixed Preposition: "Count on someone" = rely on someone\'s assistance.',
    ),
    const FixedPrepositionQuestion(
      number: 202,
      sentence: 'The lion sprang ________ the cow.',
      options: ['upon', 'on', 'over', 'off'],
      correctIndex: 0,
      rule: 'Preposition of Attack/Motion: "Spring upon" / "Pounce upon" denotes sudden aggressive leap onto a prey.',
    ),
    const FixedPrepositionQuestion(
      number: 203,
      sentence: 'Nepal lies ________ India and China.',
      options: ['among', 'beyond', 'between', 'below'],
      correctIndex: 2,
      rule: 'Rule: "Between" is used for two distinct entities (India and China). "Among" is used for three or more.',
    ),
    const FixedPrepositionQuestion(
      number: 204,
      sentence: 'I shall stand by you ________ thick and thin.',
      options: ['in', 'into', 'about', 'through'],
      correctIndex: 3,
      rule: 'Idiom: "Through thick and thin" = under all circumstances, no matter how difficult.',
    ),
    const FixedPrepositionQuestion(
      number: 205,
      sentence: 'Mohini resembles ________ her mother.',
      options: ['with', 'after', 'to', 'no preposition'],
      correctIndex: 3,
      rule: 'Transitive Verb Rule: "Resemble" is a transitive verb that takes NO preposition (Mohini resembles her mother).',
    ),
    const FixedPrepositionQuestion(
      number: 206,
      sentence: 'The minister has promised to look ________ the matter.',
      options: ['at', 'into', 'for', 'about'],
      correctIndex: 1,
      rule: 'Phrasal Verb: "Look into" = investigate thoroughly.',
    ),
    const FixedPrepositionQuestion(
      number: 207,
      sentence: 'Employees who have twenty-five years service become entitled ________ a pension.',
      options: ['of', 'on', 'to', 'towards'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Entitled to something" = having a rightful claim to receive something.',
    ),
    const FixedPrepositionQuestion(
      number: 208,
      sentence: 'Poor old Mr. Singh, he has suffered ________ rheumatism for twenty years.',
      options: ['with', 'of', 'from', 'no preposition'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Suffer from an illness/ailment".',
    ),
    const FixedPrepositionQuestion(
      number: 209,
      sentence: 'The frustrated lover jumped ________ the river.',
      options: ['in', 'within', 'at', 'into'],
      correctIndex: 3,
      rule: 'Preposition of Motion: Dynamic movement entering a fluid/body of water requires "into".',
    ),
    const FixedPrepositionQuestion(
      number: 210,
      sentence: 'You are advised to learn this lesson word ________ word.',
      options: ['for', 'by', 'to', 'in'],
      correctIndex: 0,
      rule: 'Idiomatic Precision: The correct English idiom is "Word for word" (verbatim), NOT "word by word".',
    ),
    const FixedPrepositionQuestion(
      number: 211,
      sentence: 'Nearly sixty years have gone by ________ Gandhiji passed away.',
      options: ['till', 'until', 'off', 'since'],
      correctIndex: 3,
      rule: 'Conjunction of Time: Present Perfect + "since" + Simple Past ("have gone by since Gandhiji passed away").',
    ),
    const FixedPrepositionQuestion(
      number: 212,
      sentence: 'Let us discuss ________ The Female Education in India.',
      options: ['on', 'about', 'of', 'no preposition'],
      correctIndex: 3,
      rule: 'Transitive Verb: "Discuss", "Describe", "Explain" take direct objects with NO preposition (discuss sth, not discuss about sth).',
    ),
    const FixedPrepositionQuestion(
      number: 213,
      sentence: 'I can write a book ________ grammar.',
      options: ['on', 'of', 'about', 'in'],
      correctIndex: 0,
      rule: 'Subject Preposition: A treatise or formal book is written "on a subject" (a book on grammar / physics).',
    ),
    const FixedPrepositionQuestion(
      number: 214,
      sentence: 'Each boy and each girl was presented ________ sweets.',
      options: ['away', 'with', 'to', 'no preposition'],
      correctIndex: 1,
      rule: 'Fixed Preposition: "Present someone with something".',
    ),
    const FixedPrepositionQuestion(
      number: 215,
      sentence: 'There are certain rare qualities which raise a man ________ the common breed of men.',
      options: ['over', 'on', 'above', 'upon'],
      correctIndex: 2,
      rule: 'Preposition of Degree/Status: "Raise above" indicates superiority in moral stature or character.',
    ),
    const FixedPrepositionQuestion(
      number: 216,
      sentence: 'The amazing thing about Gandhiji was that he adhered ________ his ideals and to his conception of truth.',
      options: ['on', 'against', 'for', 'to'],
      correctIndex: 3,
      rule: 'Fixed Preposition: "Adhere to" = to stick firmly to principles, beliefs, or guidelines.',
    ),
    const FixedPrepositionQuestion(
      number: 217,
      sentence: 'Tagore was awarded the Nobel Prize ________ literature.',
      options: ['into', 'of', 'for', 'about'],
      correctIndex: 2,
      rule: 'Purpose Preposition: Awards are presented "for" achievements in a field (Nobel Prize for Literature).',
    ),
    const FixedPrepositionQuestion(
      number: 218,
      sentence: 'A house-owner can throw you ________ the street any moment.',
      options: ['onto', 'on', 'to', 'towards'],
      correctIndex: 1,
      rule: 'Idiomatic Usage: "Throw on the street" / "out on the street" (into destitution).',
    ),
    const FixedPrepositionQuestion(
      number: 219,
      sentence: 'A miser cannot part ________ his gold.',
      options: ['from', 'to', 'of', 'with'],
      correctIndex: 3,
      rule: 'Gold is an inanimate thing, so "part with his gold". (Part with things; part from people).',
    ),
    const FixedPrepositionQuestion(
      number: 220,
      sentence: 'An educated man should know what is first rate in those activities which spring ________ the creative faculties.',
      options: ['from', 'out of', 'to', 'on'],
      correctIndex: 0,
      rule: 'Origin Preposition: "Spring from" = originate or emanate from.',
    ),
    const FixedPrepositionQuestion(
      number: 221,
      sentence: 'An epidemic of influenza broke out last winter, and did not die ________ for many months.',
      options: ['of', 'down', 'out', 'no preposition'],
      correctIndex: 1,
      rule: 'Phrasal Verb: "Die down" = subside or decrease in intensity.',
    ),
    const FixedPrepositionQuestion(
      number: 222,
      sentence: 'Cigarette smoking is injurious ________ health.',
      options: ['to', 'for', 'on', 'at'],
      correctIndex: 0,
      rule: 'Fixed Preposition: "Injurious to" / "Detrimental to" / "Harmful to". (NOT for health).',
    ),
    const FixedPrepositionQuestion(
      number: 223,
      sentence: 'Five hundred rupees was allotted for the purchase of books ________ physics.',
      options: ['of', 'about', 'in', 'on'],
      correctIndex: 3,
      rule: 'Subject Preposition: Academic books are written or purchased "on a subject" (books on physics).',
    ),
    const FixedPrepositionQuestion(
      number: 224,
      sentence: 'Does the old lady object ________ my smoking cigarettes?',
      options: ['on', 'of', 'to', 'for'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Object to" + V1+ing (object to doing something).',
    ),
    const FixedPrepositionQuestion(
      number: 225,
      sentence: 'I went on holiday ________ a friend.',
      options: ['by', 'with', 'for', 'no preposition'],
      correctIndex: 1,
      rule: 'Companionship: "With a friend".',
    ),
    const FixedPrepositionQuestion(
      number: 226,
      sentence: 'Mohan may be slow ________ his work.',
      options: ['at', 'for', 'about', 'to'],
      correctIndex: 0,
      rule: 'Skill/Speed: "Slow at an activity/work", "Good at math", "Quick at calculations".',
    ),
    const FixedPrepositionQuestion(
      number: 227,
      sentence: 'Socrates was the greatest of ancient Greek philosophers and was a seeker ________ truth.',
      options: ['of', 'after', 'for', 'on'],
      correctIndex: 1,
      rule: 'Classical Phrase: "Seeker after truth" (pursuing enlightenment or truth).',
    ),
    const FixedPrepositionQuestion(
      number: 228,
      sentence: 'The world is disgusted ________ frequent display of violent behavior.',
      options: ['of', 'from', 'in', 'with'],
      correctIndex: 3,
      rule: 'Fixed Preposition: "Disgusted with someone / something".',
    ),
    const FixedPrepositionQuestion(
      number: 229,
      sentence: 'I would willingly part ________ my goat.',
      options: ['from', 'with', 'of', 'no preposition'],
      correctIndex: 1,
      rule: 'Separation Rule: A goat is treated as property/chattel, hence "part with".',
    ),
    const FixedPrepositionQuestion(
      number: 230,
      sentence: 'The young boy was enchanted ________ the beauty of the girl.',
      options: ['at', 'by', 'with', 'in'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Enchanted with" / "enchanted by" (captivated by charm).',
    ),
    const FixedPrepositionQuestion(
      number: 231,
      sentence: 'Be content ________ what you have.',
      options: ['by', 'with', 'of', 'in'],
      correctIndex: 1,
      rule: 'Fixed Preposition: "Content with" = satisfied with what one possesses.',
    ),
    const FixedPrepositionQuestion(
      number: 232,
      sentence: 'Sindhu was greatly amused ________ the performance of the dancing goats.',
      options: ['from', 'on', 'at', 'in'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Amused at / by" a show, joke, or spectacle.',
    ),
    const FixedPrepositionQuestion(
      number: 233,
      sentence: 'Sudha got divorce ________ her husband.',
      options: ['from', 'of', 'to', 'at'],
      correctIndex: 0,
      rule: 'Separation: "Divorce from someone". (Note: as a verb, "She divorced him" takes no preposition).',
    ),
    const FixedPrepositionQuestion(
      number: 234,
      sentence: 'When this young person called ________ me, she was all dressed up.',
      options: ['at', 'off', 'on', 'up'],
      correctIndex: 2,
      rule: 'Phrasal Verb: "Call on a person" = visit a person; "Call at a place" = visit a place.',
    ),
    const FixedPrepositionQuestion(
      number: 235,
      sentence: 'It has been hardly ten years ________ the reform was introduced.',
      options: ['on', 'over', 'since', 'no preposition'],
      correctIndex: 2,
      rule: 'Time Clause: "It has been [period] since [event happened in past]".',
    ),
    const FixedPrepositionQuestion(
      number: 236,
      sentence: 'We searched ________ happiness in vain.',
      options: ['into', 'in', 'for', 'after'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Search for something" = look to find something.',
    ),
    const FixedPrepositionQuestion(
      number: 237,
      sentence: 'He emphasized ________ his point.',
      options: ['on', 'at', 'over', 'no preposition'],
      correctIndex: 3,
      rule: 'Transitive Verb Rule: "Emphasize", "Stress" take NO preposition (emphasize his point, NOT emphasize on his point).',
    ),
    const FixedPrepositionQuestion(
      number: 238,
      sentence: 'We entered ________ the class room.',
      options: ['into', 'in', 'for', 'no preposition'],
      correctIndex: 3,
      rule: 'Physical Movement Rule: "Enter a room/building" takes NO preposition. ("Enter into" is only used for an agreement/contract).',
    ),
    const FixedPrepositionQuestion(
      number: 239,
      sentence: 'The Hindustan Times aspires to have a million readers ________ the next year.',
      options: ['by', 'to', 'until', 'through'],
      correctIndex: 0,
      rule: 'Deadline/Future Limit: "By the next year" = not later than that time.',
    ),
    const FixedPrepositionQuestion(
      number: 240,
      sentence: 'As I approached ________ him, he turned and walked away.',
      options: ['to', 'beside', 'by', 'no preposition'],
      correctIndex: 3,
      rule: 'Transitive Verb: "Approach someone" takes NO preposition (approach him, NOT approach to him).',
    ),
    const FixedPrepositionQuestion(
      number: 241,
      sentence: '________ uranium, we can use another metal thorium to produce nuclear power.',
      options: ['besides', 'beside', 'against', 'of'],
      correctIndex: 0,
      rule: 'Rule: "Besides" = in addition to. ("Beside" = by the side of).',
    ),
    const FixedPrepositionQuestion(
      number: 242,
      sentence: 'The prisoner was bound ________ a chain.',
      options: ['with', 'by', 'from', 'on'],
      correctIndex: 0,
      rule: 'Instrument Preposition: Fastened using an instrument/tool takes "with" (bound with a chain / cord).',
    ),
    const FixedPrepositionQuestion(
      number: 243,
      sentence: 'He was honorably acquitted ________ the charge.',
      options: ['from', 'of', 'off', 'for'],
      correctIndex: 1,
      rule: 'Fixed Preposition: "Acquitted of" = declared not guilty of a crime.',
    ),
    const FixedPrepositionQuestion(
      number: 244,
      sentence: 'Monkeys live ________ trees.',
      options: ['on', 'upon', 'into', 'in'],
      correctIndex: 3,
      rule: 'Natural Habitat: Birds and monkeys live "in trees" (within the branches and foliage), not "on trees".',
    ),
    const FixedPrepositionQuestion(
      number: 245,
      sentence: 'The train is running ________ time.',
      options: ['on', 'in', 'at', 'to'],
      correctIndex: 0,
      rule: 'Schedule: "Running on time" = operating strictly according to timetable.',
    ),
    const FixedPrepositionQuestion(
      number: 246,
      sentence: 'Students should be ordered to write only ________ ink.',
      options: ['with', 'of', 'from', 'in'],
      correctIndex: 3,
      rule: 'Medium Rule: "Write in ink / in pencil" (medium). But "Write with a pen / with a pencil" (instrument).',
    ),
    const FixedPrepositionQuestion(
      number: 247,
      sentence: 'He abandoned his comrade ________ the wolves.',
      options: ['to', 'with', 'for', 'towards'],
      correctIndex: 0,
      rule: 'Idiomatic Phrase: "Abandon / throw someone to the wolves".',
    ),
    const FixedPrepositionQuestion(
      number: 248,
      sentence: 'The godown is infested ________ rats.',
      options: ['of', 'about', 'with', 'in'],
      correctIndex: 2,
      rule: 'Fixed Preposition: "Infested with" pests or vermin.',
    ),
    const FixedPrepositionQuestion(
      number: 249,
      sentence: 'Bangs alternated ________ crashes.',
      options: ['in', 'with', 'from', 'no preposition'],
      correctIndex: 1,
      rule: 'Fixed Preposition: "Alternate with" = occur successively with another phenomenon.',
    ),
    const FixedPrepositionQuestion(
      number: 250,
      sentence: 'The writer accuses the national government ________ resorting to violence.',
      options: ['of', 'for', 'with', 'on'],
      correctIndex: 0,
      rule: 'Fixed Preposition: "Accuse someone of a crime / action".',
    ),
  ];

  // =========================================================================
  // 2. THEMATIC IDIOMS & PHRASES CLUSTERS (24 LIFE & EXAM DOMAINS)
  // =========================================================================

  // =========================================================================
  // 2. THEMATIC IDIOMS & PHRASES (CATEGORIZED AS IN COMPETITIVE EXAMS)
  // =========================================================================
  static final List<IdiomThematicGroup> thematicIdioms = [
    const IdiomThematicGroup(
      theme: 'Carefulness',
      category: 'Focus & Alertness',
      idioms: [
        IdiomItem(
          idiom: 'Argus-eyed',
          meaning: 'Extremely vigilant, observant, and watchful.',
          example: 'The customs officer was Argus-eyed at the border checkpoint.',
        ),
        IdiomItem(
          idiom: 'On the ball',
          meaning: 'Competent, quick to understand, and alert to new developments.',
          example: 'She is really on the ball and caught the accounting error immediately.',
        ),
        IdiomItem(
          idiom: 'All ears / Lend an ear',
          meaning: 'Listening with eager, undivided attention.',
          example: 'Tell me your strategy, I am all ears.',
        ),
        IdiomItem(
          idiom: 'Walk on eggshells',
          meaning: 'Be extremely cautious about one\'s words and actions to avoid offending someone.',
          example: 'Everyone walks on eggshells around the temperamental boss.',
        ),
        IdiomItem(
          idiom: 'Keep a weather eye on',
          meaning: 'To watch someone or something very carefully for any signs of trouble.',
          example: 'Keep a weather eye on the market indicators today.',
        ),
      ],
    ),
    const IdiomThematicGroup(
      theme: 'Carelessness',
      category: 'Rash & Reckless',
      idioms: [
        IdiomItem(
          idiom: 'Fast and loose',
          meaning: 'To behave in an irresponsible, deceitful, or careless manner.',
          example: 'He played fast and loose with the company funds.',
        ),
        IdiomItem(
          idiom: 'Hand over head',
          meaning: 'Rashly and without consideration; careless.',
          example: 'He made the stock purchase hand over head and lost his savings.',
        ),
        IdiomItem(
          idiom: 'Like a bull in a china shop',
          meaning: 'Enthusiastic and energetic, but extremely clumsy, careless, and destructive.',
          example: 'He entered the diplomatic meeting like a bull in a china shop.',
        ),
        IdiomItem(
          idiom: 'Asleep at the switch',
          meaning: 'Failing to attend to one\'s duty; careless at work.',
          example: 'The security guard was asleep at the switch during the robbery.',
        ),
      ],
    ),
    const IdiomThematicGroup(
      theme: 'Shortage & Dearth',
      category: 'Scarcity & Penury',
      idioms: [
        IdiomItem(
          idiom: 'A drop in the ocean',
          meaning: 'A tiny, insignificant amount compared to what is needed.',
          example: 'Ten thousand rupees is a drop in the ocean for this massive project.',
        ),
        IdiomItem(
          idiom: 'Barmecide feast',
          meaning: 'An illusion of plenty; an invitation that promises much but yields nothing.',
          example: 'Their election promises turned out to be a Barmecide feast.',
        ),
        IdiomItem(
          idiom: 'Lean times',
          meaning: 'A period of financial hardship, scarcity, and limited resources.',
          example: 'Startups often survive lean times before reaching profitability.',
        ),
        IdiomItem(
          idiom: 'Chicken feed',
          meaning: 'A ridiculously small, inadequate amount of money.',
          example: 'He refused to work overtime for chicken feed.',
        ),
        IdiomItem(
          idiom: 'Hard up',
          meaning: 'Short of money; poor or destitute.',
          example: 'Students are often hard up before their monthly scholarship arrives.',
        ),
      ],
    ),
    const IdiomThematicGroup(
      theme: 'Plentiful & Prosperity',
      category: 'Abundance & Wealth',
      idioms: [
        IdiomItem(
          idiom: 'Dime a dozen',
          meaning: 'Extremely common and available in vast quantities, therefore of little value.',
          example: 'Smartphone apps like that are a dime a dozen nowadays.',
        ),
        IdiomItem(
          idiom: 'Packed like sardines',
          meaning: 'Crowded extremely closely together in a confined space.',
          example: 'Passengers in the Mumbai local train were packed like sardines.',
        ),
        IdiomItem(
          idiom: 'Born with a silver spoon',
          meaning: 'Born into a very wealthy, affluent, and privileged family.',
          example: 'He never worried about finances as he was born with a silver spoon.',
        ),
        IdiomItem(
          idiom: 'Bring sand to the beach',
          meaning: 'To supply or bring something that is already superabundant.',
          example: 'Selling tea in Darjeeling is like bringing sand to the beach.',
        ),
        IdiomItem(
          idiom: 'Thick on the ground',
          meaning: 'Present in very large numbers or quantities.',
          example: 'Coaching centers are thick on the ground in Mukherjee Nagar.',
        ),
        IdiomItem(
          idiom: 'High on the hog',
          meaning: 'Living in luxurious, lavish, and expensive comfort.',
          example: 'After the startup buyout, the founders lived high on the hog.',
        ),
      ],
    ),
    const IdiomThematicGroup(
      theme: 'Adroit & Expertise',
      category: 'Skill & Mastery',
      idioms: [
        IdiomItem(
          idiom: 'Worth one\'s salt',
          meaning: 'Competent, deserving of respect, and efficient at one\'s job.',
          example: 'Any teacher worth their salt would clarify doubts patiently.',
        ),
        IdiomItem(
          idiom: 'Sharp as a needle',
          meaning: 'Extremely quick-witted, intelligent, and perceptive.',
          example: 'The young lawyer was as sharp as a needle during cross-examination.',
        ),
        IdiomItem(
          idiom: 'Sharp cookie',
          meaning: 'A clever, astute person who cannot easily be deceived.',
          example: 'She is a sharp cookie and negotiated the best contract.',
        ),
        IdiomItem(
          idiom: 'Dab hand',
          meaning: 'An expert who is exceptionally skilled at a particular manual task.',
          example: 'My grandfather is a dab hand at carpentry.',
        ),
        IdiomItem(
          idiom: 'Know the ropes',
          meaning: 'To understand the detailed procedures and mechanics of a job.',
          example: 'Give the new recruit a week to learn the ropes.',
        ),
      ],
    ),
    const IdiomThematicGroup(
      theme: 'Beginners & Novice',
      category: 'Inexperience',
      idioms: [
        IdiomItem(
          idiom: 'Babe in the woods',
          meaning: 'An innocent, naive, and inexperienced person in a complex situation.',
          example: 'Without a mentor in Delhi, the newcomer was a babe in the woods.',
        ),
        IdiomItem(
          idiom: 'Greenhorn',
          meaning: 'A novice or newcomer who lacks experience and wisdom.',
          example: 'The experienced mechanics playfully teased the greenhorn.',
        ),
        IdiomItem(
          idiom: 'Wet behind the ears',
          meaning: 'Immature, inexperienced, and naive.',
          example: 'He thought he could crack UPSC in a month; he is still wet behind the ears.',
        ),
      ],
    ),
    const IdiomThematicGroup(
      theme: 'Anger & Annoyance',
      category: 'Negative Emotions',
      idioms: [
        IdiomItem(
          idiom: 'Fly off the handle',
          meaning: 'To lose one\'s temper suddenly and violently without warning.',
          example: 'He flew off the handle when he saw his car scratched.',
        ),
        IdiomItem(
          idiom: 'Blow your top',
          meaning: 'To explode in furious rage.',
          example: 'The manager blew his top when the report was submitted late.',
        ),
        IdiomItem(
          idiom: 'Make someone\'s blood boil',
          meaning: 'To cause extreme indignation and fury in someone.',
          example: 'Corruption and paper leaks make every honest aspirant\'s blood boil.',
        ),
        IdiomItem(
          idiom: 'Get someone\'s goat',
          meaning: 'To deliberately irritate or annoy someone.',
          example: 'His sarcastic remarks really got her goat.',
        ),
      ],
    ),
    const IdiomThematicGroup(
      theme: 'Pacify & Calm',
      category: 'Positive Emotions',
      idioms: [
        IdiomItem(
          idiom: 'Pour oil on troubled waters',
          meaning: 'To try to settle a dispute or calm down agitated feelings.',
          example: 'The senior diplomat tried to pour oil on troubled waters during the heated summit.',
        ),
        IdiomItem(
          idiom: 'Pull yourself together',
          meaning: 'To recover control of one\'s emotions and regain composure.',
          example: 'Stop crying, pull yourself together, and face the exam bravely.',
        ),
        IdiomItem(
          idiom: 'Smooth ruffled feathers',
          meaning: 'To soothe feelings after an argument or misunderstanding.',
          example: 'An apology was needed to smooth ruffled feathers after the debate.',
        ),
        IdiomItem(
          idiom: 'Hold one\'s nerve',
          meaning: 'To remain calm and courageous in a tense, dangerous situation.',
          example: 'The bowler held his nerve and defended 4 runs in the final over.',
        ),
      ],
    ),
    const IdiomThematicGroup(
      theme: 'Fear & Courage',
      category: 'Mindset & Bravery',
      idioms: [
        IdiomItem(
          idiom: 'Cold feet',
          meaning: 'Loss of nerve, courage, or confidence before an important event.',
          example: 'He developed cold feet right before walking onto the interview stage.',
        ),
        IdiomItem(
          idiom: 'Heart of a lion',
          meaning: 'Extraordinary bravery, courage, and valor.',
          example: 'The soldier fought with the heart of a lion against the intruders.',
        ),
        IdiomItem(
          idiom: 'Nerves of steel',
          meaning: 'Immense courage and calm under extreme pressure.',
          example: 'Bomb disposal squads need nerves of steel.',
        ),
        IdiomItem(
          idiom: 'Butterflies in stomach',
          meaning: 'A fluttery, nervous feeling of anxiety before performing.',
          example: 'Every topper admits having butterflies in the stomach before Tier 1.',
        ),
      ],
    ),
    const IdiomThematicGroup(
      theme: 'Happiness & Sadness',
      category: 'General Emotions',
      idioms: [
        IdiomItem(
          idiom: 'On cloud nine',
          meaning: 'In a state of blissful, ecstatic happiness.',
          example: 'She was on cloud nine when she saw her AIR 1 on the merit list.',
        ),
        IdiomItem(
          idiom: 'Down in the dumps',
          meaning: 'Feeling unhappy, depressed, and dejected.',
          example: 'He has been down in the dumps ever since he missed the cutoff by 1 mark.',
        ),
        IdiomItem(
          idiom: 'Over the moon',
          meaning: 'Extremely pleased and delighted.',
          example: 'The parents were over the moon at their son\'s selection.',
        ),
        IdiomItem(
          idiom: 'Face like a wet weekend',
          meaning: 'Looking miserable, gloomy, and sad.',
          example: 'Why do you have a face like a wet weekend on a festive day?',
        ),
      ],
    ),
  ];

  // =========================================================================
  // 3. 18 TOPIC-WISE VOCABULARY UNITS (ORGANIZED EXACTLY AS IN EXAM BOOK)
  // =========================================================================
  static List<EnglishWordTopic> get topics => vocabularyTopics;
  static final List<EnglishWordTopic> vocabularyTopics = [
    // 1. SLIPSHOD (adjective)
    EnglishWordTopic(
      id: 1,
      word: 'SLIPSHOD',
      partOfSpeech: 'adjective',
      rootWord: 'Slip + shod (wearing loose shoes; hence slovenly and careless)',
      synonyms: [
        'Reckless', 'Unwary', 'Careless', 'Heedless', 'Neglectful', 'Negligent',
        'Rash', 'Remiss', 'Lax', 'Unmindful', 'Foolhardy', 'Impetuous', 'Hasty',
        'Impulsive', 'Derelict', 'Shoddy', 'Sloppy', 'Slack'
      ],
      antonyms: [
        'Wary', 'Careful', 'Meticulous', 'Vigilant', 'Considerate', 'Thoughtful',
        'Attentive', 'Punctilious', 'Chary', 'Discreet', 'Circumspect', 'Cautious',
        'Heedful', 'Observant', 'Scrupulous', 'Solicitous', 'Prudent'
      ],
      idioms: {
        'Carefulness': ['Argus-eyed: Vigilant', 'On the ball', 'All ears', 'Walk on eggshells', 'Keep a weather eye on'],
        'Carelessness': ['Fast and loose', 'Hand over head: Rash, careless', 'Like a bull in a china shop: Enthusiastic but careless'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '1_1',
          questionText: 'Select the SYNONYM of Circumspect:',
          options: ['Heedful', 'Relaxed', 'Joyful', 'Clean'],
          correctIndex: 0,
          explanation: 'Circumspect means wary, heedful, and cautious of all circumstances before acting.',
        ),
        const EnglishExerciseQuestion(
          id: '1_2',
          questionText: 'Select the ANTONYM of Meticulous:',
          options: ['Careful', 'Sloppy', 'Heedful', 'Polite'],
          correctIndex: 1,
          explanation: 'Meticulous means showing great attention to detail; its opposite is Sloppy / Slipshod.',
        ),
        const EnglishExerciseQuestion(
          id: '1_3',
          questionText: 'Select the ANTONYM of Negligent:',
          options: ['Chary', 'Calm', 'Composed', 'Careless'],
          correctIndex: 0,
          explanation: 'Chary means cautiously or suspiciously reluctant, watchful; antonym to careless/negligent.',
        ),
        const EnglishExerciseQuestion(
          id: '1_4',
          questionText: 'Select the ANTONYM of Rash:',
          options: ['Immature', 'Audacious', 'Considerate', 'Bold'],
          correctIndex: 2,
          explanation: 'Rash means acting without thinking; its antonym is Considerate or Thoughtful.',
        ),
        const EnglishExerciseQuestion(
          id: '1_5',
          questionText: 'Select the SYNONYM of Reckless:',
          options: ['Rational', 'Veritable', 'Rash', 'Queer'],
          correctIndex: 2,
          explanation: 'Reckless means heedless of danger; exactly synonymous with Rash.',
        ),
        const EnglishExerciseQuestion(
          id: '1_6',
          questionText: 'Select the SYNONYM of Alert:',
          options: ['Daring', 'Cautious', 'Heedless', 'Brash'],
          correctIndex: 1,
          explanation: 'Alert means watchful and aware of surroundings; synonym is Cautious.',
        ),
        const EnglishExerciseQuestion(
          id: '1_7',
          questionText: 'Select the ANTONYM of Vigilant:',
          options: ['Cautious', 'Amicable', 'Foolhardy', 'Wary'],
          correctIndex: 2,
          explanation: 'Vigilant means watchful; opposite is Foolhardy (recklessly bold and incautious).',
        ),
        const EnglishExerciseQuestion(
          id: '1_8',
          questionText: 'Select the ANTONYM of Impetuous:',
          options: ['Dense', 'Arguable', 'Tangible', 'Sensible'],
          correctIndex: 3,
          explanation: 'Impetuous means acting quickly without thought; opposite is Sensible.',
        ),
        const EnglishExerciseQuestion(
          id: '1_9',
          questionText: 'Select the ANTONYM of Solicitous:',
          options: ['Worried', 'Heedless', 'Knowledgeable', 'Interesting'],
          correctIndex: 1,
          explanation: 'Solicitous means showing care or concern; opposite is Heedless / Careless.',
        ),
        const EnglishExerciseQuestion(
          id: '1_10',
          questionText: 'Select the SYNONYM of Discreet:',
          options: ['Heedless', 'Harmless', 'Tactful', 'Careful'],
          correctIndex: 3,
          explanation: 'Discreet means careful and circumspect in speech or actions.',
        ),
      ],
    ),

    // 2. ABSTRUSE (adjective)
    EnglishWordTopic(
      id: 2,
      word: 'ABSTRUSE',
      partOfSpeech: 'adjective',
      rootWord: 'Latin "abstrudere" (to push away, conceal) -> hidden away from understanding',
      synonyms: [
        'Unclear', 'Incomprehensible', 'Unintelligible', 'Vague', 'Esoteric',
        'Recondite', 'Nebulous', 'Implicit', 'Obscure', 'Equivocal',
        'Inarticulate', 'Arcane', 'Ambiguous', 'Cryptic', 'Dubious'
      ],
      antonyms: [
        'Comprehensible', 'Intelligible', 'Pellucid', 'Lucid', 'Explicit',
        'Distinct', 'Eloquent', 'Expressive', 'Coherent', 'Transparent',
        'Perspicuous', 'Definite', 'Clear', 'Evident', 'Obvious', 'Apparent'
      ],
      idioms: {
        'Unclear': ['Clear as mud: Impossible to understand', 'Greek to me: Meaningless or unintelligible', 'Double Dutch'],
        'Clear': ['Plain as the nose on your face: Obvious', 'See through: Lucid and transparent'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '2_1',
          questionText: 'Select the ANTONYM of Equivocal:',
          options: ['Ambiguous', 'Definite', 'Insecure', 'Secure'],
          correctIndex: 1,
          explanation: 'Equivocal means open to more than one interpretation (vague); opposite is Definite.',
        ),
        const EnglishExerciseQuestion(
          id: '2_2',
          questionText: 'Select the SYNONYM of Dubious:',
          options: ['Indecisive', 'Ambiguous', 'Definitive', 'Improbable'],
          correctIndex: 1,
          explanation: 'Dubious means hesitating or causing doubt; ambiguous in certainty.',
        ),
        const EnglishExerciseQuestion(
          id: '2_3',
          questionText: 'Select the ANTONYM of Lucid:',
          options: ['Ambiguous', 'Orderly', 'Intelligible', 'Transparent'],
          correctIndex: 0,
          explanation: 'Lucid means expressed clearly; opposite is Ambiguous.',
        ),
        const EnglishExerciseQuestion(
          id: '2_4',
          questionText: 'Select the SYNONYM of Elucidate:',
          options: ['Exhaust', 'Examine', 'Oracular', 'Explicate'],
          correctIndex: 3,
          explanation: 'Elucidate means make something clear; explain or explicate.',
        ),
        const EnglishExerciseQuestion(
          id: '2_5',
          questionText: 'Select the SYNONYM of Limpid:',
          options: ['Subtle', 'Blunt', 'Lucid', 'Obscure'],
          correctIndex: 2,
          explanation: 'Limpid means completely clear and transparent; synonymous with Lucid.',
        ),
      ],
    ),

    // 3. EXIGUOUS (adjective)
    EnglishWordTopic(
      id: 3,
      word: 'EXIGUOUS',
      partOfSpeech: 'adjective',
      rootWord: 'Latin "exiguus" (scanty, small, strictly weighed)',
      synonyms: [
        'Scanty', 'Sparse', 'Meager', 'Inadequate', 'Paltry', 'Skimpy',
        'Deficit', 'Deficiency', 'Shortage', 'Scarcity', 'Dearth', 'Paucity',
        'Lack', 'Want', 'Famine', 'Drought', 'Insufficiency', 'Mite', 'Tad'
      ],
      antonyms: [
        'Ample', 'Abundant', 'Surplus', 'Sufficient', 'Copious', 'Profuse',
        'Plentiful', 'Superfluous', 'Redundant', 'Exuberant', 'Bountiful',
        'Inundated', 'Awash', 'Excess', 'Glut', 'Surfeit', 'Plethora', 'Teeming'
      ],
      idioms: {
        'Scarcity': ['A drop in the ocean', 'Lean times', 'Chicken feed', 'Hard up', 'Hand to mouth'],
        'Plentiful': ['Dime a dozen', 'Packed like sardines', 'Born with a silver spoon', 'Thick on the ground'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '3_1',
          questionText: 'Select the ANTONYM of Paucity:',
          options: ['Dearth', 'Scarcity', 'Surplus', 'Meager'],
          correctIndex: 2,
          explanation: 'Paucity means the presence of something in only small quantities (scarcity); opposite is Surplus.',
        ),
        const EnglishExerciseQuestion(
          id: '3_2',
          questionText: 'Select the SYNONYM of Copious:',
          options: ['Sparse', 'Plentiful', 'Meager', 'Skimpy'],
          correctIndex: 1,
          explanation: 'Copious means abundant in supply or quantity; synonym is Plentiful.',
        ),
        const EnglishExerciseQuestion(
          id: '3_3',
          questionText: 'Select the ANTONYM of Dearth:',
          options: ['Shortage', 'Abundance', 'Lack', 'Deficiency'],
          correctIndex: 1,
          explanation: 'Dearth means a scarcity or lack of something; opposite is Abundance.',
        ),
        const EnglishExerciseQuestion(
          id: '3_4',
          questionText: 'Select the SYNONYM of Plethora:',
          options: ['Excess', 'Scarcity', 'Paucity', 'Want'],
          correctIndex: 0,
          explanation: 'Plethora means a large or excessive amount; synonym is Excess.',
        ),
        const EnglishExerciseQuestion(
          id: '3_5',
          questionText: 'Select the SYNONYM of Ample:',
          options: ['Entertain', 'Sample', 'Sufficient', 'Temple'],
          correctIndex: 2,
          explanation: 'Ample means enough or more than enough; plentiful or sufficient.',
        ),
      ],
    ),

    // 4. NOVICE (noun)
    EnglishWordTopic(
      id: 4,
      word: 'NOVICE',
      partOfSpeech: 'noun',
      rootWord: 'Latin "novus" (new) -> a newcomer, beginner',
      synonyms: [
        'Beginner', 'Learner', 'Neophyte', 'Tyro', 'Tenderfoot', 'Fledgling',
        'Newbie', 'Greenhorn', 'Apprentice', 'Probationer', 'Amateur',
        'Inexpert', 'Dilettante', 'Ingenuous', 'Gullible', 'Innocent', 'Credulous'
      ],
      antonyms: [
        'Adroit', 'Dexterous', 'Expert', 'Skilled', 'Deft', 'Proficient',
        'Nimble', 'Acrobatic', 'Agile', 'Savvy', 'Veteran', 'Connoisseur',
        'Gourmet', 'Epicure', 'Virtuoso', 'Doyen', 'Maestro'
      ],
      idioms: {
        'Beginner': ['Babe in the woods', 'Wet behind the ears', 'Greenhorn'],
        'Expert': ['Worth one\'s salt', 'Sharp as a needle', 'Dab hand', 'Know the ropes'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '4_1',
          questionText: 'Select the SYNONYM of Tyro:',
          options: ['Expert', 'Novice', 'Veteran', 'Maestro'],
          correctIndex: 1,
          explanation: 'Tyro means a beginner or novice.',
        ),
        const EnglishExerciseQuestion(
          id: '4_2',
          questionText: 'Select the ANTONYM of Adroit:',
          options: ['Skilled', 'Deft', 'Clumsy', 'Agile'],
          correctIndex: 2,
          explanation: 'Adroit means clever or skillful; its opposite is Clumsy / Inexpert.',
        ),
        const EnglishExerciseQuestion(
          id: '4_3',
          questionText: 'Select the SYNONYM of Neophyte:',
          options: ['Connoisseur', 'Virtuoso', 'Beginner', 'Veteran'],
          correctIndex: 2,
          explanation: 'Neophyte means a person who is new to a subject, skill, or belief; Beginner.',
        ),
        const EnglishExerciseQuestion(
          id: '4_4',
          questionText: 'Select the ANTONYM of Amateur:',
          options: ['Novice', 'Apprentice', 'Professional', 'Learner'],
          correctIndex: 2,
          explanation: 'Amateur means engaging in a pursuit on an unpaid basis; opposite is Professional.',
        ),
        const EnglishExerciseQuestion(
          id: '4_5',
          questionText: 'Select the SYNONYM of Adroit:',
          options: ['Clumsy', 'Despotic', 'Skillful', 'Sane'],
          correctIndex: 2,
          explanation: 'Adroit means clever or skillful in using the hands or mind; Skillful.',
        ),
      ],
    ),

    // 5. APOGEE (noun)
    EnglishWordTopic(
      id: 5,
      word: 'APOGEE',
      partOfSpeech: 'noun',
      rootWord: 'Greek "apo" (away) + "ge" (earth) -> highest celestial point',
      synonyms: [
        'Pinnacle', 'Peak', 'Apex', 'Summit', 'Zenith', 'Climax',
        'Apotheosis', 'Acme', 'Culmination', 'Crest', 'Supreme', 'Paramount', 'Vertex'
      ],
      antonyms: [
        'Base', 'Bottom', 'Nadir', 'Abyss', 'Plinth', 'Foot', 'Bed', 'Depth', 'Floor', 'Low Point', 'Trough', 'Underbelly'
      ],
      idioms: {
        'Top': ['Top of the tree', 'Head and shoulders above', 'High watermark'],
        'Bottom': ['At rock bottom', 'In the gutter'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '5_1',
          questionText: 'Select the SYNONYM of Apex:',
          options: ['Core', 'Bottom', 'Corner', 'Pinnacle'],
          correctIndex: 3,
          explanation: 'Apex means the highest point or peak; synonymous with Pinnacle.',
        ),
        const EnglishExerciseQuestion(
          id: '5_2',
          questionText: 'Select the ANTONYM of Zenith:',
          options: ['Nadir', 'Summit', 'Acme', 'Pinnacle'],
          correctIndex: 0,
          explanation: 'Zenith means the highest point; opposite is Nadir (the lowest point).',
        ),
        const EnglishExerciseQuestion(
          id: '5_3',
          questionText: 'Select the SYNONYM of Acme:',
          options: ['Essence', 'Abyss', 'Apogee', 'Talent'],
          correctIndex: 2,
          explanation: 'Acme means the point at which something is at its best; synonymous with Apogee.',
        ),
        const EnglishExerciseQuestion(
          id: '5_4',
          questionText: 'Select the ANTONYM of Pinnacle:',
          options: ['Crest', 'Peak', 'Base', 'Summit'],
          correctIndex: 2,
          explanation: 'Pinnacle means the highest point; opposite is Base / Bottom.',
        ),
      ],
    ),

    // 6. AMELIORATE (verb)
    EnglishWordTopic(
      id: 6,
      word: 'AMELIORATE',
      partOfSpeech: 'verb',
      rootWord: 'Latin "melior" (better) -> to make better or improve',
      synonyms: [
        'Improve', 'Upgrade', 'Modify', 'Amend', 'Mend', 'Revamp',
        'Reform', 'Rectify', 'Overhaul', 'Better', 'Enhance', 'Boost', 'Refine', 'Alleviate', 'Mitigate'
      ],
      antonyms: [
        'Worsen', 'Deteriorate', 'Degrade', 'Aggravate', 'Injure', 'Harm',
        'Impair', 'Maim', 'Cripple', 'Exacerbate', 'Undermine'
      ],
      idioms: {
        'Improve': ['A shot in the arm', 'Step up a gear', 'Kick it up a notch', 'Turn over a new leaf'],
        'Worsen': ['Go to the dogs', 'Add insult to injury', 'Add fuel to the fire', 'Out of the frying pan into the fire'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '6_1',
          questionText: 'Select the SYNONYM of Amend:',
          options: ['Rectify', 'Hassle', 'Impair', 'Worsen'],
          correctIndex: 0,
          explanation: 'Amend means to make minor changes in order to make something fairer or more accurate; Rectify.',
        ),
        const EnglishExerciseQuestion(
          id: '6_2',
          questionText: 'Select the SYNONYM of Ameliorate:',
          options: ['Deteriorate', 'Improve', 'Weaken', 'Degrade'],
          correctIndex: 1,
          explanation: 'Ameliorate means to make something bad or unsatisfactory better; synonym is Improve.',
        ),
        const EnglishExerciseQuestion(
          id: '6_3',
          questionText: 'Select the ANTONYM of Exacerbate:',
          options: ['Aggravate', 'Worsen', 'Alleviate', 'Harm'],
          correctIndex: 2,
          explanation: 'Exacerbate means make a problem worse; opposite is Alleviate (make less severe / improve).',
        ),
        const EnglishExerciseQuestion(
          id: '6_4',
          questionText: 'Select the ANTONYM of Overhaul:',
          options: ['Mend', 'Worsen', 'Divide', 'Branch'],
          correctIndex: 1,
          explanation: 'Overhaul means to examine and repair thoroughly; opposite is Worsen.',
        ),
      ],
    ),

    // 7. CLANDESTINE (adjective)
    EnglishWordTopic(
      id: 7,
      word: 'CLANDESTINE',
      partOfSpeech: 'adjective',
      rootWord: 'Latin "clam" (secretly) -> kept secret or done secretly',
      synonyms: [
        'Secret', 'Hidden', 'Concealed', 'Stealthy', 'Surreptitious', 'Private',
        'Covert', 'Furtive', 'Veiled', 'Ulterior', 'Incognito', 'Devious'
      ],
      antonyms: [
        'Open', 'Clear', 'Forthright', 'Upright', 'Aboveboard', 'Candid',
        'Straightforward', 'Overt', 'Revealed', 'Unveiled', 'Exposed'
      ],
      idioms: {
        'Secret': ['Under the counter: Secret or illicit', 'Behind closed doors', 'Under the table: Secretly and illegally'],
        'Open': ['Above board: Honest and open', 'In broad daylight'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '7_1',
          questionText: 'Select the SYNONYM of Concealed:',
          options: ['Unveiled', 'Upright', 'Candid', 'Covert'],
          correctIndex: 3,
          explanation: 'Concealed means kept secret or hidden; synonym is Covert.',
        ),
        const EnglishExerciseQuestion(
          id: '7_2',
          questionText: 'Select the ANTONYM of Clandestine:',
          options: ['Surreptitious', 'Casual', 'Overt', 'Pristine'],
          correctIndex: 2,
          explanation: 'Clandestine means secret; its direct antonym is Overt (done openly).',
        ),
        const EnglishExerciseQuestion(
          id: '7_3',
          questionText: 'Select the SYNONYM of Aboveboard:',
          options: ['Uncomplaining', 'Candid', 'Sapient', 'Humble'],
          correctIndex: 1,
          explanation: 'Aboveboard means open, honest, and frank; synonym is Candid.',
        ),
        const EnglishExerciseQuestion(
          id: '7_4',
          questionText: 'Select the SYNONYM of Surreptitious:',
          options: ['Furtive', 'Apparent', 'Clear', 'Patent'],
          correctIndex: 0,
          explanation: 'Surreptitious means kept secret, especially because unauthorized; synonym is Furtive.',
        ),
      ],
    ),

    // 8. AUDACIOUS (adjective)
    EnglishWordTopic(
      id: 8,
      word: 'AUDACIOUS',
      partOfSpeech: 'adjective',
      rootWord: 'Latin "audax" (bold, daring)',
      synonyms: [
        'Fearless', 'Valiant', 'Brave', 'Gallant', 'Dauntless', 'Bold',
        'Brazen', 'Effrontery', 'Intrepid', 'Candid', 'Impudent', 'Daring',
        'Temerity', 'Heroic', 'Chivalric', 'Mettlesome', 'Gritty', 'Lionhearted'
      ],
      antonyms: [
        'Timid', 'Timorous', 'Pusillanimous', 'Diffident', 'Coward', 'Meek',
        'Fearful', 'Fretful', 'Dauntful', 'Bashful', 'Mousy', 'Craven',
        'Recreant', 'Skittish'
      ],
      idioms: {
        'Fear': ['Cold feet', 'Curl someone\'s hair', 'Butterflies in stomach', 'Heart in one\'s mouth', 'Lily-livered'],
        'Courage': ['Put on a brave face', 'To have guts', 'Hold one\'s ground', 'Nerves of steel', 'Heart of a lion'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '8_1',
          questionText: 'Select the ANTONYM of Valiant:',
          options: ['Barren', 'Cowardly', 'Gallant', 'Worthy'],
          correctIndex: 1,
          explanation: 'Valiant means brave and heroic; its opposite is Cowardly.',
        ),
        const EnglishExerciseQuestion(
          id: '8_2',
          questionText: 'Select the SYNONYM of Brave:',
          options: ['Cautious', 'Timid', 'Daring', 'Mild'],
          correctIndex: 2,
          explanation: 'Brave means showing courage; synonymous with Daring / Audacious.',
        ),
        const EnglishExerciseQuestion(
          id: '8_3',
          questionText: 'Select the ANTONYM of Timorous:',
          options: ['Brazen', 'Scared', 'Gutless', 'Reserved'],
          correctIndex: 0,
          explanation: 'Timorous means suffering from nervousness or fear; opposite is Brazen / Audacious.',
        ),
        const EnglishExerciseQuestion(
          id: '8_4',
          questionText: 'Select the SYNONYM of Intrepid:',
          options: ['Cowardly', 'Fearless', 'Shy', 'Hesitant'],
          correctIndex: 1,
          explanation: 'Intrepid means fearless and adventurous; synonymous with Fearless.',
        ),
      ],
    ),

    // 9. BLISS (noun)
    EnglishWordTopic(
      id: 9,
      word: 'BLISS',
      partOfSpeech: 'noun',
      rootWord: 'Old English "bliths" (gladness, gentle joy)',
      synonyms: [
        'Pleasure', 'Delight', 'Happiness', 'Gladness', 'Joy', 'Ecstasy',
        'Elation', 'Euphoria', 'Exhilaration', 'Rapture', 'Jubilation', 'Mirth',
        'Felicity', 'Glee', 'Jovial', 'Jocund', 'Cheerful', 'Merry', 'Buoyant'
      ],
      antonyms: [
        'Sorrow', 'Sadness', 'Mourning', 'Grief', 'Despair', 'Gloom',
        'Woe', 'Doleful', 'Dolorous', 'Melancholy', 'Depression', 'Dejection',
        'Desolation', 'Misery', 'Anguish', 'Affliction', 'Agony', 'Dismal', 'Morose'
      ],
      idioms: {
        'Happiness': ['On cloud nine', 'In seventh heaven', 'Walking on air', 'Over the moon', 'Happy as a clam'],
        'Sadness': ['Down in the dumps', 'Face like a wet weekend', 'Heart in one\'s boots', 'Cry one\'s eyes out'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '9_1',
          questionText: 'Select the ANTONYM of Felicity:',
          options: ['Delight', 'Happiness', 'Grief', 'Bliss'],
          correctIndex: 2,
          explanation: 'Felicity means intense happiness; opposite is Grief (deep sorrow).',
        ),
        const EnglishExerciseQuestion(
          id: '9_2',
          questionText: 'Select the ANTONYM of Glee:',
          options: ['Woe', 'Joy', 'Fun', 'Bliss'],
          correctIndex: 0,
          explanation: 'Glee means great delight; its direct opposite is Woe (great sorrow or distress).',
        ),
        const EnglishExerciseQuestion(
          id: '9_3',
          questionText: 'Select the SYNONYM of Mirth:',
          options: ['Scene', 'Delight', 'View', 'Joint'],
          correctIndex: 1,
          explanation: 'Mirth means amusement, especially as expressed in laughter; synonym is Delight.',
        ),
        const EnglishExerciseQuestion(
          id: '9_4',
          questionText: 'Select the SYNONYM of Ecstasy:',
          options: ['Mourning', 'Bliss', 'Fantasy', 'Appreciation'],
          correctIndex: 1,
          explanation: 'Ecstasy means an overwhelming feeling of great happiness; synonymous with Bliss.',
        ),
      ],
    ),

    // 10. ASSUAGE (verb)
    EnglishWordTopic(
      id: 10,
      word: 'ASSUAGE',
      partOfSpeech: 'verb',
      rootWord: 'Latin "ad" (to) + "suavis" (sweet) -> to sweeten, make less severe',
      synonyms: [
        'Ease', 'Gratify', 'Satisfy', 'Lull', 'Appease', 'Relieve',
        'Alleviate', 'Allay', 'Placate', 'Pacify', 'Tranquilise',
        'Conciliate', 'Mitigate', 'Palliate', 'Propitiate', 'Mollify',
        'Soothe', 'Calm Down', 'Please', 'Sedate'
      ],
      antonyms: [
        'Aggravate', 'Incense', 'Arouse', 'Stir', 'Incite', 'Instigate',
        'Enrage', 'Outrage', 'Infuriate', 'Foment', 'Ferment',
        'Exasperate', 'Umbrage', 'Exacerbate', 'Abet', 'Provoke',
        'Kindle', 'Inflame', 'Ignite', 'Goad', 'Embroil', 'Egg On'
      ],
      idioms: {
        'Anger': ['Up in arms', 'Blow your top', 'Bone to pick', 'Get someone\'s goat', 'Fly off the handle'],
        'Pacify': ['Smooth ruffled feathers', 'Pull yourself together', 'Hold one\'s nerve', 'Pour oil on troubled waters'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '10_1',
          questionText: 'Select the ANTONYM of Assuage:',
          options: ['Relieve', 'Decrease', 'Provoke', 'Soothe'],
          correctIndex: 2,
          explanation: 'Assuage means to soothe or alleviate; its opposite is Provoke / Aggravate.',
        ),
        const EnglishExerciseQuestion(
          id: '10_2',
          questionText: 'Select the SYNONYM of Lull:',
          options: ['Disturb', 'Aggravate', 'Nullify', 'Placate'],
          correctIndex: 3,
          explanation: 'Lull means to calm or soothe; synonymous with Placate.',
        ),
        const EnglishExerciseQuestion(
          id: '10_3',
          questionText: 'Select the SYNONYM of Appease:',
          options: ['Pacify', 'Irritate', 'Excite', 'Worsen'],
          correctIndex: 0,
          explanation: 'Appease means to pacify or placate someone by acceding to their demands.',
        ),
        const EnglishExerciseQuestion(
          id: '10_4',
          questionText: 'Select the ANTONYM of Mitigate:',
          options: ['Please', 'Appease', 'Exacerbate', 'Allay'],
          correctIndex: 2,
          explanation: 'Mitigate means make less severe; opposite is Exacerbate (make more severe).',
        ),
      ],
    ),

    // 11. TURMOIL (noun)
    EnglishWordTopic(
      id: 11,
      word: 'TURMOIL',
      partOfSpeech: 'noun',
      rootWord: 'Early 16th century: state of great disturbance, confusion, or uncertainty',
      synonyms: [
        'Commotion', 'Pandemonium', 'Chaos', 'Upheaval', 'Tumult', 'Ferment',
        'Ruckus', 'Agitation', 'Disorder', 'Clamour', 'Anarchy', 'Disturbance',
        'Bedlam', 'Frenzy', 'Havoc', 'Mayhem'
      ],
      antonyms: [
        'Peace', 'Calm', 'Tranquillity', 'Serenity', 'Order', 'Quietude',
        'Stillness', 'Harmony', 'Equanimity', 'Composure', 'Rest', 'Repose'
      ],
      idioms: {
        'Chaos': ['All hell broke loose', 'At sixes and sevens: In total confusion', 'Mad as a March hare'],
        'Calm': ['Calm before the storm', 'Cool as a cucumber'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '11_1',
          questionText: 'Select the SYNONYM of Pandemonium:',
          options: ['Order', 'Turmoil', 'Peace', 'Silence'],
          correctIndex: 1,
          explanation: 'Pandemonium means wild and noisy disorder or confusion; synonymous with Turmoil.',
        ),
        const EnglishExerciseQuestion(
          id: '11_2',
          questionText: 'Select the ANTONYM of Tumult:',
          options: ['Tranquillity', 'Chaos', 'Upheaval', 'Commotion'],
          correctIndex: 0,
          explanation: 'Tumult means loud confusion and noise; opposite is Tranquillity (calmness).',
        ),
        const EnglishExerciseQuestion(
          id: '11_3',
          questionText: 'Select the SYNONYM of Mayhem:',
          options: ['Harmony', 'Disorder', 'Balance', 'Control'],
          correctIndex: 1,
          explanation: 'Mayhem means violent or extreme disorder; synonymous with Disorder / Turmoil.',
        ),
        const EnglishExerciseQuestion(
          id: '11_4',
          questionText: 'Select the ANTONYM of Bedlam:',
          options: ['Ruckus', 'Uproar', 'Clamour', 'Serenity'],
          correctIndex: 3,
          explanation: 'Bedlam means a scene of uproar and confusion; opposite is Serenity.',
        ),
      ],
    ),

    // 12. PLAUDIT (noun)
    EnglishWordTopic(
      id: 12,
      word: 'PLAUDIT',
      partOfSpeech: 'noun',
      rootWord: 'Latin "plaudite" (applaud! - customary appeal for applause at end of Roman play)',
      synonyms: [
        'Acclaim', 'Applause', 'Eulogy', 'Accolade', 'Commendation', 'Praise',
        'Tribute', 'Paean', 'Encomium', 'Ovation', 'Compliment', 'Approval',
        'Laudation', 'Kudos', 'Cheers', 'Panegyric'
      ],
      antonyms: [
        'Condemnation', 'Criticism', 'Censorship', 'Disapproval', 'Reproach',
        'Denunciation', 'Blame', 'Stricture', 'Flak', 'Rebuke', 'Reproof', 'Castigation'
      ],
      idioms: {
        'Praise': ['Sing someone\'s praises', 'Give credit where credit is due', 'Pat on the back'],
        'Criticism': ['Take someone to task', 'Pull to pieces', 'Cast aspersions'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '12_1',
          questionText: 'Select the SYNONYM of Accolade:',
          options: ['Criticism', 'Plaudit', 'Blame', 'Rebuke'],
          correctIndex: 1,
          explanation: 'Accolade means an award or privilege granted as a special honor; synonymous with Plaudit / Praise.',
        ),
        const EnglishExerciseQuestion(
          id: '12_2',
          questionText: 'Select the ANTONYM of Encomium:',
          options: ['Denunciation', 'Eulogy', 'Tribute', 'Acclaim'],
          correctIndex: 0,
          explanation: 'Encomium means a speech or piece of writing that praises someone highly; opposite is Denunciation.',
        ),
        const EnglishExerciseQuestion(
          id: '12_3',
          questionText: 'Select the SYNONYM of Eulogy:',
          options: ['Panegyric', 'Slander', 'Defamation', 'Insult'],
          correctIndex: 0,
          explanation: 'Eulogy is a speech praising someone; synonymous with Panegyric.',
        ),
        const EnglishExerciseQuestion(
          id: '12_4',
          questionText: 'Select the ANTONYM of Plaudit:',
          options: ['Applause', 'Kudos', 'Stricture', 'Ovation'],
          correctIndex: 2,
          explanation: 'Plaudit means praise; opposite is Stricture (harsh criticism).',
        ),
      ],
    ),

    // 13. PERTINACIOUS (adjective)
    EnglishWordTopic(
      id: 13,
      word: 'PERTINACIOUS',
      partOfSpeech: 'adjective',
      rootWord: 'Latin "pertinax" (holding fast, stubborn) from per- (thoroughly) + tenax (tenacious)',
      synonyms: [
        'Obstinate', 'Tenacious', 'Stubborn', 'Inflexible', 'Dogged', 'Persistent',
        'Mulish', 'Pigheaded', 'Intractable', 'Willful', 'Unyielding', 'Resolute',
        'Steadfast', 'Adamant', 'Bullheaded', 'Obdurate'
      ],
      antonyms: [
        'Docile', 'Yielding', 'Flexible', 'Pliant', 'Compliant', 'Submissive',
        'Amenable', 'Tractable', 'Irresolute', 'Vacillating', 'Adaptable', 'Malleable'
      ],
      idioms: {
        'Stubborn': ['Stubborn as a mule', 'Dig one\'s heels in', 'Set in one\'s ways'],
        'Flexible': ['Go with the flow', 'Bend over backwards'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '13_1',
          questionText: 'Select the SYNONYM of Obstinate:',
          options: ['Pliant', 'Pertinacious', 'Docile', 'Submissive'],
          correctIndex: 1,
          explanation: 'Obstinate means stubbornly refusing to change opinion; synonymous with Pertinacious.',
        ),
        const EnglishExerciseQuestion(
          id: '13_2',
          questionText: 'Select the ANTONYM of Tenacious:',
          options: ['Stubborn', 'Dogged', 'Irresolute', 'Adamant'],
          correctIndex: 2,
          explanation: 'Tenacious means not readily giving up; opposite is Irresolute (hesitant, wavering).',
        ),
        const EnglishExerciseQuestion(
          id: '13_3',
          questionText: 'Select the SYNONYM of Obdurate:',
          options: ['Adamant', 'Yielding', 'Tractable', 'Flexible'],
          correctIndex: 0,
          explanation: 'Obdurate means stubbornly refusing to change one\'s opinion; synonymous with Adamant.',
        ),
        const EnglishExerciseQuestion(
          id: '13_4',
          questionText: 'Select the ANTONYM of Mulish:',
          options: ['Pigheaded', 'Compliant', 'Unyielding', 'Inflexible'],
          correctIndex: 1,
          explanation: 'Mulish means resembling or characteristic of a mule (stubborn); opposite is Compliant.',
        ),
      ],
    ),

    // 14. OUTLANDISH (adjective)
    EnglishWordTopic(
      id: 14,
      word: 'OUTLANDISH',
      partOfSpeech: 'adjective',
      rootWord: 'Old English "utlendisc" (foreign, from an outlying land)',
      synonyms: [
        'Bizarre', 'Peculiar', 'Eccentric', 'Quirky', 'Grotesque', 'Weird',
        'Freakish', 'Exotic', 'Odd', 'Uncanny', 'Fantastic', 'Baffling',
        'Abnormal', 'Singular', 'Curious', 'Unconventional'
      ],
      antonyms: [
        'Conventional', 'Normal', 'Ordinary', 'Commonplace', 'Typical', 'Standard',
        'Familiar', 'Regular', 'Customary', 'Usual', 'Everyday', 'Traditional'
      ],
      idioms: {
        'Strange': ['Odd fish: An eccentric person', 'Queer as a three-dollar bill', 'Off the wall'],
        'Normal': ['Run of the mill: Ordinary', 'Par for the course'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '14_1',
          questionText: 'Select the SYNONYM of Bizarre:',
          options: ['Ordinary', 'Outlandish', 'Customary', 'Typical'],
          correctIndex: 1,
          explanation: 'Bizarre means very strange or unusual; synonymous with Outlandish.',
        ),
        const EnglishExerciseQuestion(
          id: '14_2',
          questionText: 'Select the ANTONYM of Eccentric:',
          options: ['Quirky', 'Conventional', 'Weird', 'Peculiar'],
          correctIndex: 1,
          explanation: 'Eccentric means unconventional and slightly strange; opposite is Conventional.',
        ),
        const EnglishExerciseQuestion(
          id: '14_3',
          questionText: 'Select the SYNONYM of Grotesque:',
          options: ['Freakish', 'Familiar', 'Charming', 'Natural'],
          correctIndex: 0,
          explanation: 'Grotesque means comically or repulsively ugly or distorted; synonym is Freakish.',
        ),
        const EnglishExerciseQuestion(
          id: '14_4',
          questionText: 'Select the ANTONYM of Peculiar:',
          options: ['Uncanny', 'Commonplace', 'Odd', 'Curious'],
          correctIndex: 1,
          explanation: 'Peculiar means strange or particular; opposite is Commonplace.',
        ),
      ],
    ),

    // 15. AUGMENT (verb)
    EnglishWordTopic(
      id: 15,
      word: 'AUGMENT',
      partOfSpeech: 'verb',
      rootWord: 'Latin "augmentum" (an increase) from augere (to increase)',
      synonyms: [
        'Increase', 'Elevate', 'Magnify', 'Amplify', 'Enlarge', 'Boost',
        'Heighten', 'Intensify', 'Expand', 'Escalate', 'Multiply', 'Supplement',
        'Enhance', 'Aggrandize', 'Proliferate', 'Swell'
      ],
      antonyms: [
        'Decrease', 'Diminish', 'Curtail', 'Reduce', 'Abate', 'Lessen',
        'Contract', 'Deplete', 'Dwindle', 'Shrink', 'Truncate', 'Subside'
      ],
      idioms: {
        'Increase': ['Snowball effect', 'Gain ground', 'Go through the roof'],
        'Decrease': ['Peter out', 'Die down', 'Hit the skids'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '15_1',
          questionText: 'Select the SYNONYM of Augment:',
          options: ['Diminish', 'Curtail', 'Amplify', 'Shrink'],
          correctIndex: 2,
          explanation: 'Augment means to make something greater by adding to it; synonym is Amplify.',
        ),
        const EnglishExerciseQuestion(
          id: '15_2',
          questionText: 'Select the ANTONYM of Proliferate:',
          options: ['Dwindle', 'Multiply', 'Expand', 'Escalate'],
          correctIndex: 0,
          explanation: 'Proliferate means increase rapidly in number; opposite is Dwindle (gradually decrease).',
        ),
        const EnglishExerciseQuestion(
          id: '15_3',
          questionText: 'Select the SYNONYM of Aggrandize:',
          options: ['Lessen', 'Magnify', 'Curtail', 'Abate'],
          correctIndex: 1,
          explanation: 'Aggrandize means enhance power, wealth, or status; synonym is Magnify.',
        ),
        const EnglishExerciseQuestion(
          id: '15_4',
          questionText: 'Select the ANTONYM of Curtail:',
          options: ['Reduce', 'Shorten', 'Extend', 'Diminish'],
          correctIndex: 2,
          explanation: 'Curtail means reduce in extent or quantity; opposite is Extend / Augment.',
        ),
      ],
    ),

    // 16. ERUDITE (adjective)
    EnglishWordTopic(
      id: 16,
      word: 'ERUDITE',
      partOfSpeech: 'adjective',
      rootWord: 'Latin "erudire" (to educate, polish, polish out of the rough)',
      synonyms: [
        'Learned', 'Scholarly', 'Sagacious', 'Sage', 'Knowledgeable', 'Cultured',
        'Intellectual', 'Bookish', 'Wise', 'Well-read', 'Enlightened', 'Academic',
        'Pedantic', 'Discerning', 'Profound', 'Polymath'
      ],
      antonyms: [
        'Ignorant', 'Illiterate', 'Uneducated', 'Unscholarly', 'Unlettered', 'Lowbrow',
        'Foolish', 'Benighted', 'Naive', 'Unlearned', 'Philistine', 'Inexperienced'
      ],
      idioms: {
        'Wise': ['Wise as an owl', 'Old head on young shoulders'],
        'Ignorant': ['Know nothing: Ignorant', 'In the dark'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '16_1',
          questionText: 'Select the SYNONYM of Erudite:',
          options: ['Illiterate', 'Scholarly', 'Ignorant', 'Lowbrow'],
          correctIndex: 1,
          explanation: 'Erudite means having or showing great knowledge or learning; Scholarly.',
        ),
        const EnglishExerciseQuestion(
          id: '16_2',
          questionText: 'Select the ANTONYM of Sagacious:',
          options: ['Wise', 'Foolish', 'Sage', 'Insightful'],
          correctIndex: 1,
          explanation: 'Sagacious means having or showing keen mental discernment and good judgment; opposite is Foolish.',
        ),
        const EnglishExerciseQuestion(
          id: '16_3',
          questionText: 'Select the SYNONYM of Polymath:',
          options: ['Novice', 'Savant', 'Amateur', 'Tyrant'],
          correctIndex: 1,
          explanation: 'Polymath is a person of wide knowledge or learning; synonymous with Savant / Erudite.',
        ),
        const EnglishExerciseQuestion(
          id: '16_4',
          questionText: 'Select the ANTONYM of Enlightened:',
          options: ['Learned', 'Educated', 'Benighted', 'Cultured'],
          correctIndex: 2,
          explanation: 'Enlightened means having modern spiritual or intellectual understanding; opposite is Benighted.',
        ),
      ],
    ),

    // 17. BENEFICIAL (adjective)
    EnglishWordTopic(
      id: 17,
      word: 'BENEFICIAL',
      partOfSpeech: 'adjective',
      rootWord: 'Latin "beneficium" (kindness, favor) from bene (well) + facere (to do)',
      synonyms: [
        'Advantageous', 'Lucrative', 'Salubrious', 'Salutary', 'Favourable', 'Profitable',
        'Useful', 'Gainful', 'Helpful', 'Wholesome', 'Benign', 'Constructive',
        'Beneficent', 'Valuable', 'Fruitful', 'Propitious'
      ],
      antonyms: [
        'Detrimental', 'Harmful', 'Noxious', 'Pernicious', 'Inimical', 'Damaging',
        'Disadvantageous', 'Adverse', 'Destructive', 'Injurious', 'Deleterious', 'Toxic'
      ],
      idioms: {
        'Beneficial': ['In one\'s best interest', 'Pay dividends: Bring benefits', 'Bear fruit'],
        'Harmful': ['Bane of one\'s existence', 'Spanner in the works'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '17_1',
          questionText: 'Select the SYNONYM of Salubrious:',
          options: ['Harmful', 'Wholesome', 'Deleterious', 'Toxic'],
          correctIndex: 1,
          explanation: 'Salubrious means health-giving; healthy and wholesome.',
        ),
        const EnglishExerciseQuestion(
          id: '17_2',
          questionText: 'Select the ANTONYM of Beneficial:',
          options: ['Advantageous', 'Helpful', 'Detrimental', 'Favourable'],
          correctIndex: 2,
          explanation: 'Beneficial means favorable or advantageous; opposite is Detrimental (tending to cause harm).',
        ),
        const EnglishExerciseQuestion(
          id: '17_3',
          questionText: 'Select the SYNONYM of Pernicious:',
          options: ['Helpful', 'Destructive', 'Profitable', 'Benign'],
          correctIndex: 1,
          explanation: 'Pernicious means having a harmful effect, especially in a gradual way; Destructive.',
        ),
        const EnglishExerciseQuestion(
          id: '17_4',
          questionText: 'Select the ANTONYM of Deleterious:',
          options: ['Salutary', 'Noxious', 'Injurious', 'Inimical'],
          correctIndex: 0,
          explanation: 'Deleterious means causing harm or damage; opposite is Salutary (producing good effects).',
        ),
      ],
    ),

    // 18. OBSTREPEROUS (adjective)
    EnglishWordTopic(
      id: 18,
      word: 'OBSTREPEROUS',
      partOfSpeech: 'adjective',
      rootWord: 'Latin "obstrepere" from ob- (against) + strepere (to make a noise)',
      synonyms: [
        'Boisterous', 'Clamorous', 'Vociferous', 'Unruly', 'Rowdy', 'Tumultuous',
        'Defiant', 'Turbulent', 'Riotous', 'Loud', 'Belligerent', 'Rebellious',
        'Disorderly', 'Rambunctious', 'Wild', 'Disobedient'
      ],
      antonyms: [
        'Quiet', 'Disciplined', 'Docile', 'Peaceful', 'Well-behaved', 'Restrained',
        'Subdued', 'Obedient', 'Orderly', 'Placid', 'Mute', 'Calm'
      ],
      idioms: {
        'Noisy': ['Kick up a row', 'Raise the roof: Make noisy celebration', 'Make a racket'],
        'Quiet': ['Quiet as a mouse', 'Hold one\'s tongue'],
      },
      exercises: [
        const EnglishExerciseQuestion(
          id: '18_1',
          questionText: 'Select the SYNONYM of Obstreperous:',
          options: ['Docile', 'Unruly', 'Disciplined', 'Placid'],
          correctIndex: 1,
          explanation: 'Obstreperous means noisy and difficult to control; synonymous with Unruly.',
        ),
        const EnglishExerciseQuestion(
          id: '18_2',
          questionText: 'Select the ANTONYM of Boisterous:',
          options: ['Rowdy', 'Loud', 'Subdued', 'Clamorous'],
          correctIndex: 2,
          explanation: 'Boisterous means noisy, energetic, and cheerful; opposite is Subdued / Quiet.',
        ),
        const EnglishExerciseQuestion(
          id: '18_3',
          questionText: 'Select the SYNONYM of Vociferous:',
          options: ['Clamorous', 'Silent', 'Restrained', 'Gentle'],
          correctIndex: 0,
          explanation: 'Vociferous means expressing or characterized by vehement opinions loudly; Clamorous.',
        ),
        const EnglishExerciseQuestion(
          id: '18_4',
          questionText: 'Select the ANTONYM of Rambunctious:',
          options: ['Wild', 'Turbulent', 'Orderly', 'Unruly'],
          correctIndex: 2,
          explanation: 'Rambunctious means uncontrollably exuberant or boisterous; opposite is Orderly.',
        ),
      ],
    ),
  ];

  // =========================================================================
  // 4. ONE WORD SUBSTITUTION (OWS) - 35 REAL SSC EXAM QUESTIONS
  // =========================================================================
  static final List<EnglishExerciseQuestion> oneWordSubstitutionQuestions = [
    const EnglishExerciseQuestion(
      id: 'ows_1',
      questionText: 'A person who cannot make a mistake or is never wrong:',
      options: ['Infallible', 'Incorrigible', 'Impeccable', 'Ineffable'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Infallible = Incapable of making mistakes or being wrong. Incorrigible = Cannot be reformed. Impeccable = Flawless.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_2',
      questionText: 'One who loves books and collects them passionately:',
      options: ['Bibliophile', 'Philanthropist', 'Bibliographer', 'Polyglot'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Bibliophile (Biblio = Book + Phile = Love) = A lover or collector of books.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_3',
      questionText: 'A person who walks in sleep:',
      options: ['Somniloquist', 'Somnambulist', 'Soporific', 'Insomniac'],
      correctIndex: 1,
      type: 'ows',
      explanation: 'Somnambulist (Somnus = Sleep + Ambulare = Walk) = Sleepwalker. Somniloquist = One who talks in sleep.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_4',
      questionText: 'An extreme or irrational fear of confined or enclosed spaces:',
      options: ['Agoraphobia', 'Claustrophobia', 'Acrophobia', 'Hydrophobia'],
      correctIndex: 1,
      type: 'ows',
      explanation: 'Claustrophobia = Fear of confined places. Agoraphobia = Fear of open spaces. Acrophobia = Fear of heights.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_5',
      questionText: 'A system of government in which one person has absolute, unlimited power:',
      options: ['Oligarchy', 'Democracy', 'Autocracy', 'Aristocracy'],
      correctIndex: 2,
      type: 'ows',
      explanation: 'Autocracy (Auto = Self + Cratos = Power) = Government by one single ruler. Oligarchy = Government by a small group.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_6',
      questionText: 'One who looks at the dark or negative side of things:',
      options: ['Optimist', 'Pessimist', 'Pacifist', 'Fatalist'],
      correctIndex: 1,
      type: 'ows',
      explanation: 'Pessimist = One who expects the worst outcome. Optimist = One who looks at the bright side.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_7',
      questionText: 'A person who does not believe in the existence of God:',
      options: ['Atheist', 'Theist', 'Agnostic', 'Iconoclast'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Atheist = A person who disbelieves or lacks belief in God. Agnostic = One who believes nothing is known about God.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_8',
      questionText: 'The act of killing a king or queen:',
      options: ['Homicide', 'Patricide', 'Regicide', 'Fratricide'],
      correctIndex: 2,
      type: 'ows',
      explanation: 'Regicide (Rex = King + Cide = Kill) = Murder of a monarch. Patricide = Murder of father. Fratricide = Murder of brother.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_9',
      questionText: 'A person who knows and can speak many different languages:',
      options: ['Linguist', 'Polyglot', 'Bilingual', 'Orator'],
      correctIndex: 1,
      type: 'ows',
      explanation: 'Polyglot (Poly = Many + Glot = Tongue/Language) = One who speaks many languages.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_10',
      questionText: 'Occurring, awarded, or published after a person\'s death:',
      options: ['Posthumous', 'Post-mortem', 'Perpetual', 'Posterity'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Posthumous = Awarded or occurring after death (e.g. Posthumous Param Vir Chakra, posthumous novel).',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_11',
      questionText: 'A person who is indifferent to both pain and pleasure:',
      options: ['Stoic', 'Epicure', 'Ascetic', 'Cynic'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Stoic = A person who can endure pain or hardship without showing feelings or complaining.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_12',
      questionText: 'Lasting for a very short or transient time:',
      options: ['Eternal', 'Ephemeral', 'Perennial', 'Ceaseless'],
      correctIndex: 1,
      type: 'ows',
      explanation: 'Ephemeral = Fleeting, transitory, lasting for a brief time.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_13',
      questionText: 'Handwriting that is impossible or very difficult to read:',
      options: ['Eligible', 'Illegible', 'Inaudible', 'Illogical'],
      correctIndex: 1,
      type: 'ows',
      explanation: 'Illegible = Unreadable handwriting. Eligible = Qualified or entitled.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_14',
      questionText: 'One who eats human flesh:',
      options: ['Carnivore', 'Herbivore', 'Cannibal', 'Omnivore'],
      correctIndex: 2,
      type: 'ows',
      explanation: 'Cannibal = A person who eats the flesh of other human beings.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_15',
      questionText: 'A person who unselfishly cares for and helps others:',
      options: ['Altruist', 'Egoist', 'Misanthrope', 'Narcissist'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Altruist = A selfless person devoted to the welfare of others.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_16',
      questionText: 'A government administered by appointed civil officials:',
      options: ['Plutocracy', 'Bureaucracy', 'Aristocracy', 'Theocracy'],
      correctIndex: 1,
      type: 'ows',
      explanation: 'Bureaucracy = Government by civil servants / non-elected officials.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_17',
      questionText: 'One who collects, studies, or values postage stamps:',
      options: ['Numismatist', 'Philatelist', 'Cartographer', 'Anthropologist'],
      correctIndex: 1,
      type: 'ows',
      explanation: 'Philatelist = Stamp collector. Numismatist = Coin collector.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_18',
      questionText: 'Scientific study of the origin and history of words:',
      options: ['Etymology', 'Entomology', 'Epitaph', 'Epistemology'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Etymology = Study of word origins. Entomology = Study of insects.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_19',
      questionText: 'A universal remedy or solution for all diseases and difficulties:',
      options: ['Panacea', 'Placebo', 'Antibiotic', 'Elixir'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Panacea = A cure-all; remedy for all diseases or problems.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_20',
      questionText: 'A speech or presentation delivered without any prior preparation:',
      options: ['Extempore', 'Maiden speech', 'Eulogy', 'Soliloquy'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Extempore (or Impromptu) = Spoken or done without preparation.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_21',
      questionText: 'A place where bees are kept for honey production:',
      options: ['Aviary', 'Apiary', 'Aquarium', 'Sanctuary'],
      correctIndex: 1,
      type: 'ows',
      explanation: 'Apiary (Apis = Bee) = Bee yard. Aviary (Avis = Bird) = Enclosure for birds.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_22',
      questionText: 'Something that cannot be repaired, reformed, or cured:',
      options: ['Incorrigible', 'Incurable', 'Irrevocable', 'Infallible'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Incorrigible = Incapable of being reformed, corrected, or improved.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_23',
      questionText: 'Present everywhere at the same time:',
      options: ['Omnipresent', 'Omnipotent', 'Omniscient', 'Ubiquitous'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Omnipresent (or Ubiquitous) = Present in all places at once. Omnipotent = All-powerful. Omniscient = All-knowing.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_24',
      questionText: 'An expert judge in matters of art, taste, food, and wine:',
      options: ['Connoisseur', 'Amateur', 'Dilettante', 'Virtuoso'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Connoisseur = A critical judge of art or matters of taste.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_25',
      questionText: 'A person who hates or distrusts humankind:',
      options: ['Misanthrope', 'Misogynist', 'Misogamist', 'Cannibal'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Misanthrope (Misein = Hate + Anthropos = Man) = Hater of humankind. Misogynist = Hater of women.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_26',
      questionText: 'The practice of having more than one spouse at the same time:',
      options: ['Monogamy', 'Polygamy', 'Bigamy', 'Celibacy'],
      correctIndex: 1,
      type: 'ows',
      explanation: 'Polygamy = Marriage to multiple spouses. Bigamy = Marriage to two spouses illegally.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_27',
      questionText: 'A decision or verdict accepted by all members without dissent:',
      options: ['Unanimous', 'Equivocal', 'Ambiguous', 'Bilateral'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Unanimous = In complete agreement, shared by everyone.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_28',
      questionText: 'A person who has no money to pay off his debts:',
      options: ['Insolvent', 'Pauper', 'Miser', 'Spendthrift'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Insolvent (or Bankrupt) = Unable to pay debts owed.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_29',
      questionText: 'A remedy to counteract the dangerous effects of a poison:',
      options: ['Antidote', 'Antibiotic', 'Antiseptic', 'Antigen'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Antidote = Medicine taken to counteract a particular poison.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_30',
      questionText: 'A building where dead bodies are kept before cremation or burial:',
      options: ['Mortuary', 'Cemetery', 'Crematorium', 'Sanatorium'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Mortuary = A room or building where dead bodies are kept.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_31',
      questionText: 'One who pretends to possess skills or beliefs that one does not have:',
      options: ['Hypocrite', 'Fanatic', 'Chauvinist', 'Apostate'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Hypocrite (or Impostor) = A person claiming to have higher moral standards or knowledge than is the case.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_32',
      questionText: 'A government by wealthy and rich individuals:',
      options: ['Plutocracy', 'Aristocracy', 'Oligarchy', 'Democracy'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Plutocracy (Ploutos = Wealth + Cratos = Power) = Rule by the wealthy.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_33',
      questionText: 'The life history of a person written by that same person:',
      options: ['Autobiography', 'Biography', 'Memoir', 'Calligraphy'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Autobiography (Auto = Self + Bio = Life + Graph = Write) = Life story written by oneself.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_34',
      questionText: 'Fear of heights:',
      options: ['Acrophobia', 'Hydrophobia', 'Pyrophobia', 'Xenophobia'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Acrophobia (Akros = Summit/Peak) = Extreme fear of heights.',
    ),
    const EnglishExerciseQuestion(
      id: 'ows_35',
      questionText: 'One who easily believes everything told without critical thinking:',
      options: ['Credulous', 'Incredulous', 'Gullible', 'Plausible'],
      correctIndex: 0,
      type: 'ows',
      explanation: 'Credulous = Ready to believe things too easily; gullible and unsuspecting.',
    ),
  ];

  // =========================================================================
  // 5. IDIOMS & PHRASES - 30 REAL SSC EXAM QUESTIONS
  // =========================================================================
  static final List<EnglishExerciseQuestion> idiomQuestions = [
    const EnglishExerciseQuestion(
      id: 'idm_1',
      questionText: 'Select the meaning of the idiom: "To bite the bullet"',
      options: [
        'To accept a grim situation and face it with courage',
        'To eat unhealthy food rapidly',
        'To start an unnecessary fight',
        'To refuse to take medicine'
      ],
      correctIndex: 0,
      type: 'idiom',
      explanation: '"To bite the bullet" means to face a difficult or unpleasant situation with courage and determination.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_2',
      questionText: 'Select the meaning of the idiom: "Break the ice"',
      options: [
        'To shatter a frozen object',
        'To initiate conversation and relieve social tension',
        'To cause emotional distress to someone',
        'To solve a difficult mathematical puzzle'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Break the ice" means to make people feel more relaxed and comfortable, especially in a new social setting.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_3',
      questionText: 'Select the meaning of the idiom: "Burn the midnight oil"',
      options: [
        'To waste precious fuel',
        'To work or study late into the night',
        'To start a fire by negligence',
        'To suffer from chronic insomnia'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Burn the midnight oil" means to study or work very late into the night.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_4',
      questionText: 'Select the meaning of the idiom: "Apple of one\'s eye"',
      options: [
        'Someone who has sharp eyesight',
        'Someone cherished and loved above all others',
        'An apple harvested in autumn',
        'An envious person'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Apple of one\'s eye" denotes a person of whom one is extremely fond and proud.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_5',
      questionText: 'Select the meaning of the idiom: "Under the weather"',
      options: [
        'Experiencing seasonal rainfall',
        'Feeling unwell or slightly sick',
        'Traveling in turbulent weather',
        'Being trapped in a storm'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Under the weather" means slightly indisposed or feeling ill.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_6',
      questionText: 'Select the meaning of the idiom: "Spill the beans"',
      options: [
        'To drop groceries accidentally',
        'To reveal secret information prematurely',
        'To waste precious food items',
        'To plant crops in spring'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Spill the beans" means to disclose a secret or confidential fact, often unintentionally.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_7',
      questionText: 'Select the meaning of the idiom: "At one\'s wit\'s end"',
      options: [
        'At the peak of intellectual power',
        'Completely perplexed and not knowing what to do',
        'Very witty and humorous in conversation',
        'Arriving at the final destination'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"At one\'s wit\'s end" means overwhelmed by difficulty and completely at a loss for what to do.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_8',
      questionText: 'Select the meaning of the idiom: "Leave no stone unturned"',
      options: [
        'To complete a masonry job',
        'To try every possible course of action in order to achieve something',
        'To search for precious minerals',
        'To leave things in disarray'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Leave no stone unturned" means to do everything possible to find something or achieve a goal.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_9',
      questionText: 'Select the meaning of the idiom: "Once in a blue moon"',
      options: [
        'Happening on a full moon night',
        'Occurring very rarely',
        'Happening frequently and regularly',
        'Observing an astronomical wonder'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Once in a blue moon" describes an event that happens extremely infrequently.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_10',
      questionText: 'Select the meaning of the idiom: "Gift of the gab"',
      options: [
        'Receiving a surprise present',
        'Natural ability to speak fluently and persuasively',
        'Gossiping behind someone\'s back',
        'A sharp memory for names'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Gift of the gab" refers to eloquence and persuasive communication skills.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_11',
      questionText: 'Select the meaning of the idiom: "Face the music"',
      options: [
        'To attend an orchestra concert',
        'To confront the unpleasant consequences of one\'s actions',
        'To learn to play an instrument',
        'To praise someone publicly'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Face the music" means to accept criticism or punishment for what you have done.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_12',
      questionText: 'Select the meaning of the idiom: "A blessing in disguise"',
      options: [
        'A prayer offered in secret',
        'Something that seems bad at first, but turns out to have good results',
        'A fake holy person',
        'A pleasant dream'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"A blessing in disguise" is an apparent misfortune that eventually has unexpected beneficial results.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_13',
      questionText: 'Select the meaning of the idiom: "Beat about the bush"',
      options: [
        'To clear a forest pathway',
        'To discuss a matter without addressing the main point directly',
        'To physically attack an opponent',
        'To search for lost livestock'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Beat about the bush" means to speak evasively or ambiguously without coming to the core topic.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_14',
      questionText: 'Select the meaning of the idiom: "Wild goose chase"',
      options: [
        'A bird hunting expedition',
        'A foolish, fruitless, and hopeless search',
        'A fast athletic race',
        'A sudden military maneuver'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Wild goose chase" is a futile pursuit of something unattainable or nonexistent.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_15',
      questionText: 'Select the meaning of the idiom: "Cut corners"',
      options: [
        'To trim sharp edges with scissors',
        'To do something poorly or cheaply to save time or money',
        'To take a shortcut on a road',
        'To design geometric shapes'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Cut corners" means doing something perfunctorily or omitting necessary steps to save resources.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_16',
      questionText: 'Select the meaning of the idiom: "Cost an arm and a leg"',
      options: [
        'To suffer a battlefield injury',
        'To be extremely expensive',
        'To require a medical surgery',
        'To lose physical vitality'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Cost an arm and a leg" means exorbitant or excessively pricey.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_17',
      questionText: 'Select the meaning of the idiom: "Through thick and thin"',
      options: [
        'Navigating a dense jungle',
        'Through both prosperous and difficult times',
        'Gaining and losing weight',
        'Reading voluminous literature'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Through thick and thin" means supporting someone under all circumstances, whether good or bad.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_18',
      questionText: 'Select the meaning of the idiom: "Blow one\'s own trumpet"',
      options: [
        'To play musical instruments in a band',
        'To boastfully praise oneself and one\'s achievements',
        'To sound an alarm in danger',
        'To criticize others arrogantly'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Blow one\'s own trumpet" means to praise one\'s own abilities, success, or status.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_19',
      questionText: 'Select the meaning of the idiom: "A bolt from the blue"',
      options: [
        'A lightning strike from clear sky',
        'A sudden, unexpected, and shocking event',
        'A blue-colored electrical fastener',
        'A pleasant surprise'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"A bolt from the blue" describes an unexpected catastrophic or surprising event.',
    ),
    const EnglishExerciseQuestion(
      id: 'idm_20',
      questionText: 'Select the meaning of the idiom: "Dark horse"',
      options: [
        'A black stallion',
        'An unexpected winner who was previously little known',
        'A dishonest businessman',
        'A competitor who cheats'
      ],
      correctIndex: 1,
      type: 'idiom',
      explanation: '"Dark horse" is a candidate or competitor about whom little is known, but who unexpectedly triumphs.',
    ),
  ];

  // =========================================================================
  // 6. SPELLING CORRECTION (MISSPELT WORDS) - 25 REAL SSC EXAM QUESTIONS
  // =========================================================================
  static final List<EnglishExerciseQuestion> spellingQuestions = [
    const EnglishExerciseQuestion(
      id: 'spl_1',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Acommodation', 'Accomodation', 'Accommodation', 'Acomodation'],
      correctIndex: 2,
      type: 'spelling',
      explanation: 'Correct spelling is ACCOMMODATION (Double C, Double M).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_2',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Priviledge', 'Privilege', 'Privelege', 'Privilage'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is PRIVILEGE (No \'d\'; P-R-I-V-I-L-E-G-E).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_3',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Occurence', 'Ocurrence', 'Occurrence', 'Occurrance'],
      correctIndex: 2,
      type: 'spelling',
      explanation: 'Correct spelling is OCCURRENCE (Double C, Double R, ends in -ence).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_4',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Seperate', 'Separate', 'Seprate', 'Seperite'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is SEPARATE (Remember: there is "a rat" in separate: S-E-P-A-R-A-T-E).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_5',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Bureaucracy', 'Beurocracy', 'Burocracy', 'Bureaucrasy'],
      correctIndex: 0,
      type: 'spelling',
      explanation: 'Correct spelling is BUREAUCRACY (B-U-R-E-A-U-C-R-A-C-Y).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_6',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Harrassment', 'Harassment', 'Harresment', 'Harrasment'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is HARASSMENT (Single R, Double S: H-A-R-A-S-S-M-E-N-T).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_7',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Millenium', 'Millennium', 'Milennium', 'Milenium'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is MILLENNIUM (Double L, Double N: M-I-L-L-E-N-N-I-U-M).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_8',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Maintainance', 'Maintenance', 'Maintenence', 'Mentenance'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is MAINTENANCE (Root: maintain, but spelling shifts to M-A-I-N-T-E-N-A-N-C-E).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_9',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Embarassment', 'Embarrasment', 'Embarrassment', 'Embarasment'],
      correctIndex: 2,
      type: 'spelling',
      explanation: 'Correct spelling is EMBARRASSMENT (Double R, Double S: E-M-B-A-R-R-A-S-S-M-E-N-T).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_10',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Questionaire', 'Questionnaire', 'Questionair', 'Questionnair'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is QUESTIONNAIRE (Double N: Q-U-E-S-T-I-O-N-N-A-I-R-E).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_11',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Conscientous', 'Conscientious', 'Conscentous', 'Conscienous'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is CONSCIENTIOUS (C-O-N-S-C-I-E-N-T-I-O-U-S).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_12',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Perserverance', 'Perseverance', 'Perseverence', 'Perseverence'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is PERSEVERANCE (P-E-R-S-E-V-E-R-A-N-C-E).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_13',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Supercede', 'Supersede', 'Superceed', 'Supersead'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is SUPERSEDE (Ends in -sede, from Latin sedere: S-U-P-E-R-S-E-D-E).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_14',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Cemetary', 'Cemetery', 'Cemetry', 'Cematary'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is CEMETERY (All E\'s, no A: C-E-M-E-T-E-R-Y).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_15',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Hygene', 'Hygiene', 'Hygeine', 'Higene'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is HYGIENE (H-Y-G-I-E-N-E).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_16',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Liason', 'Liaison', 'Liasion', 'Liaizon'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is LIAISON (L-I-A-I-S-O-N).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_17',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Lieutnant', 'Lieutenant', 'Leftenant', 'Lietenant'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is LIEUTENANT (L-I-E-U-T-E-N-A-N-T).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_18',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Gaurantee', 'Guarantee', 'Garanty', 'Garentee'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is GUARANTEE (G-U-A-R-A-N-T-E-E).',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_19',
      questionText: 'Select the INCORRECTLY spelt word:',
      options: ['Noticeable', 'Manageable', 'Changeable', 'Gageable'],
      correctIndex: 3,
      type: 'spelling',
      explanation: 'Gageable is incorrectly spelt; the correct form is GAUGEABLE.',
    ),
    const EnglishExerciseQuestion(
      id: 'spl_20',
      questionText: 'Select the CORRECTLY spelt word:',
      options: ['Miscelaneous', 'Miscellaneous', 'Miscellanous', 'Miscelanious'],
      correctIndex: 1,
      type: 'spelling',
      explanation: 'Correct spelling is MISCELLANEOUS (M-I-S-C-E-L-L-A-N-E-O-U-S).',
    ),
  ];

  // =========================================================================
  // 7. SPOTTING ERRORS (CORE GRAMMAR RULES) - 30 REAL SSC EXAM QUESTIONS
  // =========================================================================
  static final List<EnglishExerciseQuestion> spottingErrorQuestions = [
    const EnglishExerciseQuestion(
      id: 'err_1',
      questionText: 'Identify the segment with grammatical error:\n\nNeither of the two candidates (A) / are eligible for (B) / the government scholarship. (C) / No error (D)',
      options: ['Neither of the two candidates (A)', 'are eligible for (B)', 'the government scholarship. (C)', 'No error (D)'],
      correctIndex: 1,
      type: 'error',
      explanation: 'Rule: "Neither of" + plural noun takes a SINGULAR verb. Replace "are eligible" with "is eligible".',
    ),
    const EnglishExerciseQuestion(
      id: 'err_2',
      questionText: 'Identify the segment with grammatical error:\n\nScarcely had the train arrived (A) / than the eager passengers (B) / rushed to the doors. (C) / No error (D)',
      options: ['Scarcely had the train arrived (A)', 'than the eager passengers (B)', 'rushed to the doors. (C)', 'No error (D)'],
      correctIndex: 1,
      type: 'error',
      explanation: 'Rule: Correlative conjunction "Scarcely / Hardly" is always paired with "WHEN", not "than". ("No sooner" is paired with "than").',
    ),
    const EnglishExerciseQuestion(
      id: 'err_3',
      questionText: 'Identify the segment with grammatical error:\n\nUnless you do not work hard, (A) / you cannot secure (B) / the top rank in the exam. (C) / No error (D)',
      options: ['Unless you do not work hard, (A)', 'you cannot secure (B)', 'the top rank in the exam. (C)', 'No error (D)'],
      correctIndex: 0,
      type: 'error',
      explanation: 'Rule: "Unless" is already inherently negative. Do not use "not" with it. Correct: "Unless you work hard...".',
    ),
    const EnglishExerciseQuestion(
      id: 'err_4',
      questionText: 'Identify the segment with grammatical error:\n\nIf he had informed me earlier, (A) / I would lend him (B) / the required money. (C) / No error (D)',
      options: ['If he had informed me earlier, (A)', 'I would lend him (B)', 'the required money. (C)', 'No error (D)'],
      correctIndex: 1,
      type: 'error',
      explanation: 'Rule: Third Conditional structure: If + Past Perfect (had + V3) -> main clause takes "would have + V3". Replace "would lend" with "would have lent".',
    ),
    const EnglishExerciseQuestion(
      id: 'err_5',
      questionText: 'Identify the segment with grammatical error:\n\nShe prefers drinking black tea (A) / than drinking cold milk (B) / in the morning. (C) / No error (D)',
      options: ['She prefers drinking black tea (A)', 'than drinking cold milk (B)', 'in the morning. (C)', 'No error (D)'],
      correctIndex: 1,
      type: 'error',
      explanation: 'Rule: "Prefer" and "Preferable" always take the preposition "TO", never "than". Replace "than" with "to".',
    ),
    const EnglishExerciseQuestion(
      id: 'err_6',
      questionText: 'Identify the segment with grammatical error:\n\nBetween you and I, (A) / he is completely unfit (B) / for this responsible post. (C) / No error (D)',
      options: ['Between you and I, (A)', 'he is completely unfit (B)', 'for this responsible post. (C)', 'No error (D)'],
      correctIndex: 0,
      type: 'error',
      explanation: 'Rule: Prepositions are followed by OBJECTIVE case pronouns. Replace "Between you and I" with "Between you and ME".',
    ),
    const EnglishExerciseQuestion(
      id: 'err_7',
      questionText: 'Identify the segment with grammatical error:\n\nOne must always do (A) / his duty sincerely (B) / toward one\'s country. (C) / No error (D)',
      options: ['One must always do (A)', 'his duty sincerely (B)', 'toward one\'s country. (C)', 'No error (D)'],
      correctIndex: 1,
      type: 'error',
      explanation: 'Rule: When the subject is the indefinite pronoun "One", the possessive must be "ONE\'S", not "his". Replace "his duty" with "one\'s duty".',
    ),
    const EnglishExerciseQuestion(
      id: 'err_8',
      questionText: 'Identify the segment with grammatical error:\n\nThe captain along with (A) / all the team members were (B) / given a grand reception. (C) / No error (D)',
      options: ['The captain along with (A)', 'all the team members were (B)', 'given a grand reception. (C)', 'No error (D)'],
      correctIndex: 1,
      type: 'error',
      explanation: 'Rule: When subjects are joined by "along with / as well as / together with / accompanied by", the verb agrees with the FIRST subject ("The captain" = singular). Replace "were" with "WAS".',
    ),
    const EnglishExerciseQuestion(
      id: 'err_9',
      questionText: 'Identify the segment with grammatical error:\n\nEach of the students (A) / have submitted their project (B) / before the deadline. (C) / No error (D)',
      options: ['Each of the students (A)', 'have submitted their project (B)', 'before the deadline. (C)', 'No error (D)'],
      correctIndex: 1,
      type: 'error',
      explanation: 'Rule: "Each of" takes a singular verb and singular possessive pronoun. Replace "have submitted their" with "HAS submitted HIS / HER project".',
    ),
    const EnglishExerciseQuestion(
      id: 'err_10',
      questionText: 'Identify the segment with grammatical error:\n\nAll the furnitures in the old palace (A) / were auctioned off (B) / at very high prices. (C) / No error (D)',
      options: ['All the furnitures in the old palace (A)', 'were auctioned off (B)', 'at very high prices. (C)', 'No error (D)'],
      correctIndex: 0,
      type: 'error',
      explanation: 'Rule: "Furniture" is an uncountable noun and does not have a plural form "furnitures". Use "All the furniture... was auctioned off".',
    ),
    const EnglishExerciseQuestion(
      id: 'err_11',
      questionText: 'Identify the segment with grammatical error:\n\nThe cattles are grazing peacefully (A) / in the green pastures (B) / outside the village. (C) / No error (D)',
      options: ['The cattles are grazing peacefully (A)', 'in the green pastures (B)', 'outside the village. (C)', 'No error (D)'],
      correctIndex: 0,
      type: 'error',
      explanation: 'Rule: "Cattle" is inherently plural and does not take an \'s\'. Say "The cattle are grazing".',
    ),
    const EnglishExerciseQuestion(
      id: 'err_12',
      questionText: 'Identify the segment with grammatical error:\n\nHe is senior than me (A) / in the department (B) / by almost five years. (C) / No error (D)',
      options: ['He is senior than me (A)', 'in the department (B)', 'by almost five years. (C)', 'No error (D)'],
      correctIndex: 0,
      type: 'error',
      explanation: 'Rule: Latin comparative adjectives ending in -ior (Senior, Junior, Superior, Inferior, Prior) take "TO", not "than". Replace "than" with "to".',
    ),
    const EnglishExerciseQuestion(
      id: 'err_13',
      questionText: 'Identify the segment with grammatical error:\n\nDespite of working hard day and night, (A) / she could not clear (B) / the final cutoff. (C) / No error (D)',
      options: ['Despite of working hard day and night, (A)', 'she could not clear (B)', 'the final cutoff. (C)', 'No error (D)'],
      correctIndex: 0,
      type: 'error',
      explanation: 'Rule: "Despite" never takes "of" (Despite = In spite of). Replace "Despite of" with "Despite" or "In spite of".',
    ),
    const EnglishExerciseQuestion(
      id: 'err_14',
      questionText: 'Identify the segment with grammatical error:\n\nI am looking forward (A) / to meet you in person (B) / at the upcoming seminar. (C) / No error (D)',
      options: ['I am looking forward (A)', 'to meet you in person (B)', 'at the upcoming seminar. (C)', 'No error (D)'],
      correctIndex: 1,
      type: 'error',
      explanation: 'Rule: Phrases like "looking forward to / with a view to / addicted to / used to" take a gerund (V1 + ing). Replace "to meet" with "to MEETING".',
    ),
    const EnglishExerciseQuestion(
      id: 'err_15',
      questionText: 'Identify the segment with grammatical error:\n\nNo sooner did the bell ring (A) / when the children (B) / ran out of the school. (C) / No error (D)',
      options: ['No sooner did the bell ring (A)', 'when the children (B)', 'ran out of the school. (C)', 'No error (D)'],
      correctIndex: 1,
      type: 'error',
      explanation: 'Rule: "No sooner" is always followed by "THAN", not "when". Replace "when" with "than".',
    ),
  ];

  // =========================================================================
  // 8. SENTENCE IMPROVEMENT & VOICE/NARRATION - 25 REAL SSC EXAM QUESTIONS
  // =========================================================================
  static final List<EnglishExerciseQuestion> sentenceImprovementQuestions = [
    const EnglishExerciseQuestion(
      id: 'imp_1',
      questionText: 'Select the best alternative for the bracketed part:\n\nHe (has been waiting) for the bus since two hours.',
      options: [
        'has been waiting for the bus for two hours',
        'is waiting for the bus since two hours',
        'had waited for the bus since two hours',
        'No Improvement'
      ],
      correctIndex: 0,
      type: 'improvement',
      explanation: 'Rule: Use "FOR" for a duration/period of time ("for two hours"), and "SINCE" for a specific point in time ("since 2 o\'clock").',
    ),
    const EnglishExerciseQuestion(
      id: 'imp_2',
      questionText: 'Select the best alternative for the bracketed part:\n\nThe manager called (out) the strike after meeting the union leaders.',
      options: ['called off', 'called up', 'called upon', 'No Improvement'],
      correctIndex: 0,
      type: 'improvement',
      explanation: '"Call off" = To cancel or terminate an event / strike. "Call up" = Summon / telephone.',
    ),
    const EnglishExerciseQuestion(
      id: 'imp_3',
      questionText: 'Select the best alternative for the bracketed part:\n\nShe was so tired that she (could not hardly) walk another step.',
      options: ['could hardly', 'could not', 'hardly could not', 'No Improvement'],
      correctIndex: 0,
      type: 'improvement',
      explanation: '"Hardly" is already negative. Using "not" with it creates an incorrect double negative. Correct: "could hardly".',
    ),
    const EnglishExerciseQuestion(
      id: 'imp_4',
      questionText: 'Select the best alternative for the bracketed part:\n\nThe train (left) before we reached the railway station.',
      options: ['had left', 'has left', 'was leaving', 'No Improvement'],
      correctIndex: 0,
      type: 'improvement',
      explanation: 'Rule: When two actions occurred in the past, the earlier completed action takes Past Perfect (had + V3): "The train had left before we reached".',
    ),
    const EnglishExerciseQuestion(
      id: 'imp_5',
      questionText: 'Select the correct PASSIVE VOICE:\n\n"The chef prepared a sumptuous meal for the royal guests."',
      options: [
        'A sumptuous meal was prepared by the chef for the royal guests.',
        'A sumptuous meal has been prepared by the chef for the royal guests.',
        'A sumptuous meal is prepared by the chef for the royal guests.',
        'A sumptuous meal had been prepared by the chef for the royal guests.'
      ],
      correctIndex: 0,
      type: 'voice',
      explanation: 'Simple Past (prepared) transforms to "was/were + prepared" in passive voice.',
    ),
    const EnglishExerciseQuestion(
      id: 'imp_6',
      questionText: 'Select the correct INDIRECT SPEECH (Narration):\n\nRahul said, "I am writing a letter to my brother."',
      options: [
        'Rahul said that he was writing a letter to his brother.',
        'Rahul said that I was writing a letter to my brother.',
        'Rahul said that he is writing a letter to his brother.',
        'Rahul told that he had written a letter to his brother.'
      ],
      correctIndex: 0,
      type: 'narration',
      explanation: 'Present Continuous (am writing) shifts to Past Continuous (was writing), and 1st person pronouns change according to the subject (I -> he, my -> his).',
    ),
    const EnglishExerciseQuestion(
      id: 'imp_7',
      questionText: 'Select the correct PASSIVE VOICE:\n\n"Who broke this priceless antique vase?"',
      options: [
        'By whom was this priceless antique vase broken?',
        'Who was this priceless antique vase broken by?',
        'By who has this priceless antique vase been broken?',
        'By whom this priceless antique vase was broken?'
      ],
      correctIndex: 0,
      type: 'voice',
      explanation: 'Interrogative "Who" transforms to "By whom + aux verb + subject + V3?". Correct: "By whom was this priceless antique vase broken?".',
    ),
    const EnglishExerciseQuestion(
      id: 'imp_8',
      questionText: 'Select the correct INDIRECT SPEECH (Narration):\n\nThe teacher said to the students, "The Sun rises in the East."',
      options: [
        'The teacher told the students that the Sun rises in the East.',
        'The teacher told the students that the Sun rose in the East.',
        'The teacher said the students that the Sun rises in the East.',
        'The teacher told to the students that the Sun had risen in the East.'
      ],
      correctIndex: 0,
      type: 'narration',
      explanation: 'Rule: Universal truths, scientific facts, and geographical truths DO NOT change their tense in indirect speech!',
    ),
    const EnglishExerciseQuestion(
      id: 'imp_9',
      questionText: 'Select the best alternative for the bracketed part:\n\nHe insisted (on to go) to the temple on foot.',
      options: ['on going', 'to go', 'for going', 'No Improvement'],
      correctIndex: 0,
      type: 'improvement',
      explanation: '"Insist" takes the preposition "ON" + gerund (V1 + ing). Correct: "insisted on going".',
    ),
    const EnglishExerciseQuestion(
      id: 'imp_10',
      questionText: 'Select the best alternative for the bracketed part:\n\nIf I (was) the Prime Minister, I would eradicate corruption.',
      options: ['were', 'am', 'had been', 'No Improvement'],
      correctIndex: 0,
      type: 'improvement',
      explanation: 'Rule: In imaginary, unreal, or subjunctive wishes/conditions, "WERE" is used for all persons and numbers (If I were you / If I were the Prime Minister).',
    ),
  ];

  // =========================================================================
  // MASTER ACCESSORS
  // =========================================================================
  static List<EnglishExerciseQuestion> get allOneWordSubstitution => oneWordSubstitutionQuestions;
  static List<EnglishExerciseQuestion> get allIdiomQuestions => idiomQuestions;
  static List<EnglishExerciseQuestion> get allSpellingQuestions => spellingQuestions;
  static List<EnglishExerciseQuestion> get allSpottingErrors => spottingErrorQuestions;
  static List<EnglishExerciseQuestion> get allSentenceImprovement => sentenceImprovementQuestions;

  static List<EnglishExerciseQuestion> get allGrammarQuestions => [
    ...spottingErrorQuestions,
    ...sentenceImprovementQuestions,
  ];

  static List<EnglishExerciseQuestion> get allVocabQuestions => [
    ...oneWordSubstitutionQuestions,
    ...idiomQuestions,
    ...spellingQuestions,
  ];

}
