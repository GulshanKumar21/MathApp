import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagramStepInfo {
  final String title;
  final String descriptionHindi;
  final String descriptionEnglish;
  final String examTip;

  const DiagramStepInfo({
    required this.title,
    required this.descriptionHindi,
    required this.descriptionEnglish,
    required this.examTip,
  });

  static List<DiagramStepInfo> getStepsForDiagram(String diagramType) {
    switch (diagramType) {
      case 'lines_intercept_theorem':
        return const [
          DiagramStepInfo(
            title: 'Construct 3 Parallel Lines (L₁ ∥ L₂ ∥ L₃)',
            descriptionHindi: 'Sabse pehle 3 parallel lines AD, BE aur CF horizontal orientation me banate hain jinke beech me parallel arrows lage hain.',
            descriptionEnglish: 'First, construct three parallel lines AD, BE, and CF marked with parallel direction arrows.',
            examTip: 'Parallel lines remain strictly equidistant and never meet (L₁ ∥ L₂ ∥ L₃).',
          ),
          DiagramStepInfo(
            title: 'Draw First Transversal Line S',
            descriptionHindi: 'Ab pehli transversal line S khinchte hain jo teeno parallel lines ko points A, B aur C par cut karti hai.',
            descriptionEnglish: 'Draw the first transversal line S intersecting the parallel lines at points A, B, and C.',
            examTip: 'A transversal line cuts proportional segments across parallel lines.',
          ),
          DiagramStepInfo(
            title: 'Draw Second Transversal Line T',
            descriptionHindi: 'Ab dusri transversal line T khinchte hain jo teeno lines ko points D, E aur F par cut karti hai.',
            descriptionEnglish: 'Draw the second transversal line T intersecting at points D, E, and F.',
            examTip: 'Transversals may have different angles, but segment ratios cut are always identical!',
          ),
          DiagramStepInfo(
            title: 'Mark Intercept Ratio (m : n)',
            descriptionHindi: 'Thales Intercept Theorem: AB aur BC ka ratio hamesha DE aur EF ke ratio ke barabar hota hai: AB/BC = DE/EF = m/n.',
            descriptionEnglish: 'Intercept Theorem: AB/BC = DE/EF = m/n. Segment proportions are strictly equal on both transversals.',
            examTip: 'If AB:BC = 2:3, then DE:EF = 2:3! [Direct SSC & Railway Exam Rule]',
          ),
          DiagramStepInfo(
            title: 'Apply Trapezium Internal Divider Formula',
            descriptionHindi: 'Trapezium ABCD me internal parallel divider BE = (a·n + b·m)/(m + n) hota hai, jahan a = top base aur b = bottom base.',
            descriptionEnglish: 'Trapezium parallel divider: BE = (a·n + b·m)/(m + n). If midpoints: EF = (a + b)/2.',
            examTip: 'Midpoint of legs: EF = (Top + Bottom) / 2 [SSC CHSL Tier-II 2024 Direct PYQ]',
          ),
        ];
      case 'lines_arrow_rule':
        return const [
          DiagramStepInfo(
            title: 'Draw Parallel Lines AB and CD',
            descriptionHindi: 'Pehle do horizontal parallel lines AB (top) aur CD (bottom) draw karte hain.',
            descriptionEnglish: 'First, draw two parallel lines AB (top) and CD (bottom).',
            examTip: 'Line AB aur CD ek dusre ke bilkul parallel hain (AB ∥ CD).',
          ),
          DiagramStepInfo(
            title: 'Connect Rays BO & DO at Vertex O (Arrow Shape)',
            descriptionHindi: 'Point B aur D se do rays nikal kar point O par milti hain, jisse Arrow (teer) ka shape banta hai.',
            descriptionEnglish: 'Draw rays BO and DO meeting at vertex O to form the classic Arrowhead shape.',
            examTip: 'Arrowhead vertex O parallel lines ke andar right side me banta hai.',
          ),
          DiagramStepInfo(
            title: 'Draw Auxiliary Parallel Line Through Vertex O',
            descriptionHindi: 'Isko prove karne ke liye vertex O se guzarne wali ek dotted line draw karte hain jo AB aur CD ke parallel hai.',
            descriptionEnglish: 'Draw an auxiliary dashed line passing through vertex O parallel to AB and CD.',
            examTip: 'This auxiliary line divides the reflex angle into two co-interior angle pairs.',
          ),
          DiagramStepInfo(
            title: 'Observe Two Co-Interior Pairs (180° + 180°)',
            descriptionHindi: 'Top pair ka sum 180° hota hai aur bottom pair ka sum bhi 180° hota hai (180° + 180° = 360°).',
            descriptionEnglish: 'Top co-interior pair sums to 180°, and bottom pair sums to 180° (Total = 360°).',
            examTip: 'Interior angles on the same side of parallel lines are supplementary (180°).',
          ),
          DiagramStepInfo(
            title: 'Arrowhead Rule: α + β + γ = 360°',
            descriptionHindi: 'Arrow Rule: Angle α (∠ABO) + Angle β (∠CDO) + Reflex Angle γ (∠BOD) = 360°!',
            descriptionEnglish: 'Arrow Rule: ∠ABO + ∠CDO + ∠BOD = 360° (α + β + γ = 360°).',
            examTip: 'Extending BO and DO gives vertically opposite angle equal to γ! [SSC MTS 2025]',
          ),
        ];
      case 'lines_zigzag_rule':
        return const [
          DiagramStepInfo(
            title: 'Draw Boundary Parallel Lines AB and CD',
            descriptionHindi: 'Pehle top line AB aur bottom line CD parallel lines draw karte hain.',
            descriptionEnglish: 'Draw boundary parallel lines AB and CD.',
            examTip: 'All zig-zag bends lie strictly between these two boundary parallel lines.',
          ),
          DiagramStepInfo(
            title: 'Draw Multi-Bend Zig-Zag Path',
            descriptionHindi: 'Line AB se shuru karke P, Q, R points par mudte hue line CD tak zig-zag path draw karte hain.',
            descriptionEnglish: 'Draw the multi-bend zig-zag path connecting from AB through P, Q, R to CD.',
            examTip: 'Har mod (vertex) par ek angle banta hai jo ya toh left khulta hai ya right.',
          ),
          DiagramStepInfo(
            title: 'Highlight Left-Opening Angles (LHS ←)',
            descriptionHindi: 'Left side khulne wale angles (m, n) ko identify karke glowing Emerald Green color se mark karte hain.',
            descriptionEnglish: 'Identify angles opening to the left (←) and mark them in glowing Emerald Green (m, n).',
            examTip: 'Their vertices are on the right and their openings face toward the left.',
          ),
          DiagramStepInfo(
            title: 'Highlight Right-Opening Angles (RHS →)',
            descriptionHindi: 'Right side khulne wale angles (α, β, γ) ko Coral Red color se mark karte hain.',
            descriptionEnglish: 'Identify angles opening to the right (→) and mark them in Coral Red (α, β, γ).',
            examTip: 'The sum of right-facing angles equals the sum of left-facing angles.',
          ),
          DiagramStepInfo(
            title: 'Zig-Zag Balance: LHS Angles = RHS Angles',
            descriptionHindi: 'Zig-Zag Rule: Left-opening angles ka total = Right-opening angles ka total (m + n = α + β + γ)!',
            descriptionEnglish: 'Zig-Zag Rule: Sum of all LHS Angles = Sum of all RHS Angles (α + β + γ = m + n).',
            examTip: 'Single-bend rule: Angle at bend = sum of angles at parallel lines! [RRB NTPC 2025]',
          ),
        ];
      case 'lines_transversal_angles':
      case 'parallel_lines':
        return const [
          DiagramStepInfo(
            title: 'Draw Parallel Lines l and m',
            descriptionHindi: 'Pehle do parallel lines l aur m horizontal direction me draw karte hain.',
            descriptionEnglish: 'Draw two parallel lines l and m with direction arrows.',
            examTip: 'Lines l and m are strictly parallel to each other (l ∥ m).',
          ),
          DiagramStepInfo(
            title: 'Draw Transversal Line t',
            descriptionHindi: 'Ek straight transversal line t draw karte hain jo line l ko E par aur line m ko F par cut karti hai.',
            descriptionEnglish: 'Draw transversal line t intersecting line l at E and line m at F.',
            examTip: 'A total of 8 angles are created across intersections E and F.',
          ),
          DiagramStepInfo(
            title: 'Number All 8 Angles (1 to 8)',
            descriptionHindi: 'Top intersection par 1, 2, 3, 4 aur bottom par 5, 6, 7, 8 mark karte hain. Acute angles Green me aur Obtuse Orange me.',
            descriptionEnglish: 'Number angles 1-4 at E and 5-8 at F. Color-code acute (Green) and obtuse (Amber).',
            examTip: 'Every intersection has only 2 angle measures: acute and obtuse (Acute + Obtuse = 180°)!',
          ),
          DiagramStepInfo(
            title: 'Corresponding (F-shape) & Alternate (Z-shape) Angles',
            descriptionHindi: 'Corresponding angles barabar hote hain (∠1 = ∠5). Alternate Interior angles barabar hote hain (∠3 = ∠5).',
            descriptionEnglish: 'Corresponding: ∠1 = ∠5. Alternate interior (Z-shape): ∠3 = ∠5.',
            examTip: 'Co-interior angles (same side) always sum to 180° (∠4 + ∠5 = 180°).',
          ),
          DiagramStepInfo(
            title: 'Co-Interior Angle Bisectors Meet at 90°',
            descriptionHindi: 'Co-interior angles ∠4 aur ∠5 ke bisectors draw karte hain jo point G par milkar 90° ka right angle banate hain!',
            descriptionEnglish: 'Bisectors of co-interior angles meet at point G at exactly 90° (∠EGF = 90°).',
            examTip: 'Exam Direct Rule: Bisectors of interior angles on same side always meet at 90°! [RRB NTPC 2025]',
          ),
        ];
      case 'tri_formation_condition':
        return const [
          DiagramStepInfo(
            title: 'Draw Base Segment BC of Length a',
            descriptionHindi: 'Sabse pehle triangle ka base BC (side a) horizontal line ke roop me draw karte hain.',
            descriptionEnglish: 'Construct the base line segment BC of length a.',
            examTip: 'Each side must be strictly less than half the perimeter: side < P/2.',
          ),
          DiagramStepInfo(
            title: 'Draw Arc of Radius b from Vertex C',
            descriptionHindi: 'Vertex C ko centre maan kar compass se radius b ki ek circular arc draw karte hain.',
            descriptionEnglish: 'From vertex C, draw an arc of radius b.',
            examTip: 'Side b aur side c ka sum base a se bada hona zaroori hai (b + c > a).',
          ),
          DiagramStepInfo(
            title: 'Draw Arc of Radius c from Vertex B (Vertex A)',
            descriptionHindi: 'Vertex B se radius c ka arc draw karte hain jo pehle arc ko point A par cut karta hai. Points ko mila kar ΔABC complete karein.',
            descriptionEnglish: 'From vertex B, draw an arc of radius c intersecting at vertex A. Connect AB and AC.',
            examTip: 'Agar do choti sides ka sum teesri side se chota ho toh arcs kabhi nahi milte, triangle nahi ban sakta!',
          ),
          DiagramStepInfo(
            title: 'Verify Triangle Inequality: |b − c| < a < b + c',
            descriptionHindi: 'Teeno sides ka check: do sides ka sum hamesha teesri se bada aur difference chota hota hai.',
            descriptionEnglish: 'Triangle Inequality: The length of any side lies strictly between difference and sum of other two.',
            examTip: 'Quick Exam Rule: Check if (Sum of two shorter sides) > longest side [SSC CGL 2023].',
          ),
          DiagramStepInfo(
            title: 'Apply Integer Triangles Count Formula',
            descriptionHindi: 'Given perimeter P ke integer triangles ki sankhya: Agar P odd hai toh Round(P²/48), agar even hai toh Round((P+3)²/48).',
            descriptionEnglish: 'Count integer triangles: For odd perimeter P: Round(P²/48); for even: Round((P+3)²/48).',
            examTip: 'Direct SSC CGL Formula: Perimeter 13 par exactly 5 integer triangles bante hain!',
          ),
        ];
      case 'tri_type_identification':
        return const [
          DiagramStepInfo(
            title: 'Draw Base a and Adjacent Leg b',
            descriptionHindi: 'Sabse pehle base a aur adjacent leg b draw karte hain.',
            descriptionEnglish: 'Draw base a and adjacent leg b.',
            examTip: 'Always isolate the longest side c and compute its square c².',
          ),
          DiagramStepInfo(
            title: 'Right Triangle Benchmark (c² = a² + b²)',
            descriptionHindi: 'Pythagoras rule benchmark: jab angle 90° hota hai tab hypotenuse c² = a² + b² hota hai.',
            descriptionEnglish: 'Right triangle benchmark: When angle is 90°, c² = a² + b² (Pythagorean theorem).',
            examTip: 'Pythagorean triplets: 3-4-5, 5-12-13, 8-15-17, 7-24-25, 9-40-41.',
          ),
          DiagramStepInfo(
            title: 'Acute Triangle Condition (c² < a² + b²)',
            descriptionHindi: 'Jab vertex angle 90° se chota hota hai, hypotenuse shrink ho jata hai: c² < a² + b² (Green arc).',
            descriptionEnglish: 'Acute triangle: The largest angle is < 90°, so c² < a² + b².',
            examTip: 'If all three angles are < 90°, the triangle is acute (c² < a² + b²) [SSC CGL Tier 2].',
          ),
          DiagramStepInfo(
            title: 'Obtuse Triangle Condition (c² > a² + b²)',
            descriptionHindi: 'Jab vertex angle 90° se bada hota hai, hypotenuse expand ho jata hai: c² > a² + b² (Red arc).',
            descriptionEnglish: 'Obtuse triangle: The largest angle is > 90°, so c² > a² + b².',
            examTip: 'Ratio 4:6:8 me 8² = 64 > 4² + 6² = 52 ➔ Obtuse-angled triangle [SSC CGL 2022].',
          ),
          DiagramStepInfo(
            title: 'Master Side Classification Rule',
            descriptionHindi: 'Master Rule: Largest² < Sum² ➔ Acute; Largest² = Sum² ➔ Right; Largest² > Sum² ➔ Obtuse!',
            descriptionEnglish: 'Classification Rule: c² < a² + b² (Acute), c² = a² + b² (Right), c² > a² + b² (Obtuse).',
            examTip: 'In exams, compare the square of the longest side with the sum of squares of the other two!',
          ),
        ];
      case 'tri_similarity':
        return const [
          DiagramStepInfo(
            title: 'Draw Reference Triangle ΔABC',
            descriptionHindi: 'Pehle base triangle ΔABC draw karte hain jisme angles A, B, C aur sides a, b, c mark hain.',
            descriptionEnglish: 'Construct reference triangle ΔABC with vertices and angles.',
            examTip: 'Similar triangles have identical shape and angles, but can differ in size.',
          ),
          DiagramStepInfo(
            title: 'Draw Scaled Triangle ΔDEF (Factor k)',
            descriptionHindi: 'Ab scale factor k se proportioned dusra triangle ΔDEF draw karte hain.',
            descriptionEnglish: 'Draw scaled triangle ΔDEF enlarged or reduced by factor k.',
            examTip: 'ΔABC ∼ ΔDEF means corresponding vertices A↔D, B↔E, C↔F align.',
          ),
          DiagramStepInfo(
            title: 'Match Corresponding Angles',
            descriptionHindi: 'Corresponding angles barabar hote hain: ∠A = ∠D, ∠B = ∠E, ∠C = ∠F (Color matching arcs).',
            descriptionEnglish: 'Corresponding angles are equal: ∠A = ∠D, ∠B = ∠E, ∠C = ∠F.',
            examTip: 'AAA criterion gives similarity, but does not guarantee congruency!',
          ),
          DiagramStepInfo(
            title: 'Mark Linear Measures Ratio k',
            descriptionHindi: 'Saari linear lengths same ratio k me hoti hain: AB/DE = BC/EF = AC/DF = Perimeters = Altitudes = Inradius = Circumradius.',
            descriptionEnglish: 'All corresponding linear measures share ratio k: Sides, perimeters, heights, medians, inradii.',
            examTip: 'Perimeter ratio = Side ratio (RS/24 = 26/39 = 2/3 ➔ RS = 16) [SSC CGL 2024].',
          ),
          DiagramStepInfo(
            title: 'Area Ratio Rule: Area₁ / Area₂ = k²',
            descriptionHindi: 'Similar triangles ka area ratio side ratio ke square ke barabar hota hai: Area(ABC) / Area(DEF) = (Side₁ / Side₂)²',
            descriptionEnglish: 'Area ratio equals the square of linear ratio: Area(ABC) / Area(DEF) = k².',
            examTip: 'Side ratio 9:1 ➔ Area ratio = 9²:1² = 81:1 [RRB NTPC CBT-I 2025].',
          ),
        ];
      case 'tri_congruency':
        return const [
          DiagramStepInfo(
            title: 'Draw Reference Triangle ΔABC',
            descriptionHindi: 'Base triangle ΔABC draw karte hain jiske teeno vertices mark hain.',
            descriptionEnglish: 'Construct the initial triangle ΔABC.',
            examTip: 'Similar triangles have identical shape and equal angles, but can differ in size.',
          ),
          DiagramStepInfo(
            title: 'Draw Congruent Triangle ΔDEF',
            descriptionHindi: 'ΔABC ke barabar dimension ka dusra triangle ΔDEF draw karte hain.',
            descriptionEnglish: 'Draw second identical triangle ΔDEF.',
            examTip: 'Congruent triangles coincide completely in shape and size (ΔABC ≅ ΔDEF).',
          ),
          DiagramStepInfo(
            title: 'Highlight Side Equality Marks (SSS)',
            descriptionHindi: 'Equal sides par matching tick marks lagate hain: AB = DE (single tick), BC = EF (double tick), AC = DF (triple tick).',
            descriptionEnglish: 'Apply matching tick marks for equal sides: AB = DE, BC = EF, AC = DF.',
            examTip: 'SSS Criterion: Triangles are congruent when all three corresponding sides are equal.',
          ),
          DiagramStepInfo(
            title: 'Congruence Criteria (SAS, ASA, AAS, RHS)',
            descriptionHindi: 'Matching criteria: SAS (do sides + beech ka angle), ASA, AAS aur RHS (Right angle + Hypotenuse + Leg).',
            descriptionEnglish: 'Verify criteria: SAS (included angle), ASA, AAS, and RHS (90° + hypotenuse + leg).',
            examTip: 'AAA aur SSA congruency criteria NAHI hote [SSC Selection Post 2024].',
          ),
          DiagramStepInfo(
            title: 'CPCT: Corresponding Parts of Congruent Triangles',
            descriptionHindi: 'Jab triangles congruent prove ho jayein toh CPCT se baaki saare corresponding sides aur angles barabar ho jate hain!',
            descriptionEnglish: 'By CPCT (Corresponding Parts of Congruent Triangles), all remaining matching elements are equal.',
            examTip: 'Right angle + Hypotenuse + one leg = RHS Congruency [SSC CGL 2025].',
          ),
        ];
      case 'tri_sine_rule':
        return const [
          DiagramStepInfo(
            title: 'Draw Circumcircle of Radius R',
            descriptionHindi: 'Centre O aur radius R ke saath circumscribed circle draw karte hain.',
            descriptionEnglish: 'Construct the circumscribed circle with centre O and radius R.',
            examTip: 'The circumcircle passes through all three vertices of the triangle.',
          ),
          DiagramStepInfo(
            title: 'Inscribe Triangle ΔABC',
            descriptionHindi: 'Circle ki boundary par teeno vertices A, B, C lekar triangle ABC draw karte hain.',
            descriptionEnglish: 'Inscribe triangle ABC with all three vertices on the circumference.',
            examTip: 'Side a is opposite to ∠A, side b opposite to ∠B, and side c opposite to ∠C.',
          ),
          DiagramStepInfo(
            title: 'Construct Circumdiameter 2R',
            descriptionHindi: 'Vertex B se centre O se guzarne wala diameter segment draw karte hain (length = 2R).',
            descriptionEnglish: 'Draw diameter segment of length 2R passing through centre O.',
            examTip: 'The diameter splits the circle into two semicircles with 90° right angles.',
          ),
          DiagramStepInfo(
            title: 'Verify Sine Ratio Proportions: a / sin A',
            descriptionHindi: 'Right triangle geometry se sin A = a / 2R nikalta hai, jisse a / sin A = 2R banta hai.',
            descriptionEnglish: 'From subtended arc: sin A = a / 2R ➔ a / sin A = 2R.',
            examTip: 'Sides are directly proportional to the sines of opposite angles: a:b:c = sin A : sin B : sin C.',
          ),
          DiagramStepInfo(
            title: 'Apply Master Sine Rule Formula',
            descriptionHindi: 'Master Sine Rule: a / sin A = b / sin B = c / sin C = 2R! Triangle Area Δ = abc / (4R).',
            descriptionEnglish: 'Master Sine Rule: a/sin A = b/sin B = c/sin C = 2R. Area = abc/(4R).',
            examTip: 'Opposite 120° side a = 2R · sin 120° = 2R · (√3/2) = R√3 [SSC CGL 2025]!',
          ),
        ];
      case 'tri_cosine_rule':
        return const [
          DiagramStepInfo(
            title: 'Draw Base Triangle ΔABC',
            descriptionHindi: 'Sides a, b, c ke saath general triangle ABC draw karte hain.',
            descriptionEnglish: 'Construct general triangle ABC with side lengths a, b, and c.',
            examTip: 'The Cosine Rule generalizes the Pythagorean theorem to any arbitrary triangle.',
          ),
          DiagramStepInfo(
            title: 'Draw Altitude AD ⊥ BC from Vertex A',
            descriptionHindi: 'Vertex A se base BC par perpendicular altitude h khinchte hain (D par 90° angle).',
            descriptionEnglish: 'Drop perpendicular altitude AD of height h onto base BC.',
            examTip: 'This altitude splits the triangle into two right-angled triangles ΔABD and ΔACD.',
          ),
          DiagramStepInfo(
            title: 'Mark Base Segments: c·cos B and a − c·cos B',
            descriptionHindi: 'Trigonometry se segment BD = c·cos B aur segment DC = a − c·cos B mark karte hain.',
            descriptionEnglish: 'Mark projections: BD = c·cos B and DC = a − c·cos B.',
            examTip: 'In right triangle ΔABD: cos B = BD / c ➔ BD = c·cos B.',
          ),
          DiagramStepInfo(
            title: 'Apply Pythagorean Theorem in Right Triangle ACD',
            descriptionHindi: 'ΔACD me: b² = h² + (a − c·cos B)². Value substitute karne par b² = c² + a² − 2ac·cos B banta hai.',
            descriptionEnglish: 'In ΔACD: b² = h² + (a − c·cos B)². Expanding gives b² = a² + c² − 2ac cos B.',
            examTip: 'When angle is 90°, cos 90° = 0, reducing the Cosine Rule to Pythagoras theorem.',
          ),
          DiagramStepInfo(
            title: 'Apply Master Cosine Rule Formula',
            descriptionHindi: 'cos A = (b² + c² − a²) / 2bc | cos B = (a² + c² − b²) / 2ac | cos C = (a² + b² − c²) / 2ab.',
            descriptionEnglish: 'Master Cosine Rule: cos A = (b² + c² − a²) / (2bc).',
            examTip: 'If cos B = -1/2, then angle B = 120° [SSC CHSL 2021]!',
          ),
        ];
      case 'tri_angle_bisector_results':
        return const [
          DiagramStepInfo(
            title: 'Draw Base Triangle ΔABC',
            descriptionHindi: 'Triangle ABC draw karte hain aur base side BC ko D tak aage badhate hain.',
            descriptionEnglish: 'Construct triangle ABC and produce base side BC to point D.',
            examTip: 'Cosine rule generalizes the Pythagorean theorem to any arbitrary triangle.',
          ),
          DiagramStepInfo(
            title: 'Draw Interior Bisector of ∠B & Exterior of ∠C',
            descriptionHindi: 'Angle B ka internal bisector aur exterior angle ∠ACD ka bisector draw karte hain jo point E par milte hain.',
            descriptionEnglish: 'Draw internal bisector of ∠B and external bisector of ∠ACD meeting at point E.',
            examTip: 'Angle at point E (∠BEC) is always exactly half of vertex angle A.',
          ),
          DiagramStepInfo(
            title: 'Excentre Angle Result: ∠BEC = ½ ∠BAC',
            descriptionHindi: 'Direct Formula: ∠BEC = ½ ∠A. Agar ∠A = 48° hai toh ∠BEC = 24° hoga.',
            descriptionEnglish: 'First Result: Angle at E is exactly half of vertex angle A: ∠BEC = ½ ∠BAC.',
            examTip: 'SSC Graduation Level Direct PYQ: ∠BEC = 24° ➔ ∠A = 48°!',
          ),
          DiagramStepInfo(
            title: 'Draw Altitude AD ⊥ BC & Angle Bisector AE',
            descriptionHindi: 'Ab vertex A se altitude AD perpendicular to BC aur internal angle bisector AE khinchte hain.',
            descriptionEnglish: 'From vertex A, draw altitude AD ⊥ BC and angle bisector AE.',
            examTip: 'The angle between altitude and bisector equals half the difference of base angles.',
          ),
          DiagramStepInfo(
            title: 'Altitude-Bisector Angle: ∠DAE = |∠B − ∠C| / 2',
            descriptionHindi: 'Master Result: ∠DAE = (∠B − ∠C) / 2. Angle between altitude and bisector = half base angle difference!',
            descriptionEnglish: 'Second Result: ∠DAE = |∠B − ∠C| / 2. Directly tested across SSC and Railway exams.',
            examTip: '∠B = 62°, ∠C = 36° ➔ ∠DAE = (62 − 36)/2 = 13° [SSC CGL 2020 Tier-I]!',
          ),
        ];
      case 'tri_exterior_bisector_theorem':
        return const [
          DiagramStepInfo(
            title: 'Draw Triangle ABC',
            descriptionHindi: 'Pehle triangle ABC draw karte hain jisme AB > AC hai.',
            descriptionEnglish: 'Construct triangle ABC with side AB longer than AC.',
            examTip: 'The exterior angle bisector meets the extension of base side BC.',
          ),
          DiagramStepInfo(
            title: 'Extend Side BA Through A to Point D',
            descriptionHindi: 'Side BA ko A ke aage point D tak extend karte hain jisse exterior angle ∠CAD banta hai.',
            descriptionEnglish: 'Produce side BA through vertex A to point D to form exterior angle ∠CAD.',
            examTip: 'Exterior angle ∠CAD = ∠B + ∠C (sum of two opposite interior angles).',
          ),
          DiagramStepInfo(
            title: 'Extend Base BC to Meet External Bisector at E',
            descriptionHindi: 'Angle CAD ka exterior bisector draw karte hain jo base BC ke produced line ko point E par cut karta hai.',
            descriptionEnglish: 'Draw exterior bisector of ∠CAD meeting BC produced at point E.',
            examTip: 'Point E lies outside base BC, so BE = BC + CE.',
          ),
          DiagramStepInfo(
            title: 'External Division Ratio: BE / CE = AB / AC',
            descriptionHindi: 'Exterior Angle Bisector Theorem: External segment ratio adjacent sides ke barabar hota hai: BE / CE = AB / AC.',
            descriptionEnglish: 'External segment proportion: BE / CE = AB / AC = c / b.',
            examTip: 'Let CE = x, then (BC + x) / x = AB / AC [SSC CGL 2020].',
          ),
          DiagramStepInfo(
            title: 'Calculate Exterior Segment Length',
            descriptionHindi: 'Shortcut: CE = BC × AC / (AB − AC). Fast 3-second solution for competitive exams!',
            descriptionEnglish: 'Shortcut Formula: CE = BC × AC / (AB − AC).',
            examTip: 'AB:AC = 5:2, BC = 9 ➔ CE = 9 × 2 / (5 − 2) = 6 cm [Direct PYQ Answer]!',
          ),
        ];
      case 'tri_angle_bisector_length':
        return const [
          DiagramStepInfo(
            title: 'Construct Triangle ABC with Vertex Angle ∠C',
            descriptionHindi: 'Triangle ABC draw karte hain jahan sides a = CB aur b = CA hain, aur vertex angle ∠C hai.',
            descriptionEnglish: 'Construct triangle ABC with vertex angle ∠C and adjacent sides a and b.',
            examTip: 'The angle bisector splits the vertex angle into two equal halves θ and θ.',
          ),
          DiagramStepInfo(
            title: 'Draw Angle Bisector CD = x (Half-Angle θ)',
            descriptionHindi: 'Vertex C se angle bisector CD = x khinchte hain jahan θ = ∠C / 2 hai.',
            descriptionEnglish: 'Draw angle bisector CD of length x bisecting ∠C into two equal halves θ.',
            examTip: 'This bisector divides the triangle into two sub-triangles ΔACD and ΔBCD.',
          ),
          DiagramStepInfo(
            title: 'Area Sum Principle: Area₁ + Area₂ = Total Area',
            descriptionHindi: 'Area(ΔACD) + Area(ΔBCD) = Area(ΔABC): ½·b·x·sin θ + ½·a·x·sin θ = ½·a·b·sin(2θ).',
            descriptionEnglish: 'Area balance: ½ b x sin θ + ½ a x sin θ = ½ a b sin(2θ).',
            examTip: 'Trigonometric identity applied: sin(2θ) = 2 sin θ cos θ.',
          ),
          DiagramStepInfo(
            title: 'Derive Bisector Length Formula: 2ab cos θ / (a + b)',
            descriptionHindi: 'sin θ cancel karne par: x(a + b) = 2ab cos θ ➔ x = 2ab cos θ / (a + b).',
            descriptionEnglish: 'Cancelling sin θ yields: x = 2ab cos θ / (a + b).',
            examTip: 'RPSC & State Exam PYQ: Length of bisector = 2bc cos(A/2) / (b + c).',
          ),
          DiagramStepInfo(
            title: 'Special 120° Case Rule: 1/x = 1/a + 1/b',
            descriptionHindi: 'Jab vertex angle 120° ho (θ = 60°): cos 60° = ½ ➔ x = ab / (a + b), yaani 1/CD = 1/a + 1/b!',
            descriptionEnglish: 'Special 120° Case: cos 60° = ½ ➔ CD = ab / (a + b), so 1/CD = 1/a + 1/b.',
            examTip: 'CA = 6, CB = 3, ∠C = 120° ➔ CD = (6 × 3) / (6 + 3) = 18 / 9 = 2 cm!',
          ),
        ];
      case 'tri_ceva_theorem':
        return const [
          DiagramStepInfo(
            title: 'Draw Triangle ABC',
            descriptionHindi: 'Pehle base triangle ABC draw karte hain jisme sides AB, BC aur CA hain.',
            descriptionEnglish: 'Construct reference triangle ABC.',
            examTip: 'A cevian is any line drawn from a vertex to the opposite side.',
          ),
          DiagramStepInfo(
            title: 'Draw Three Concurrent Cevians (AD, BE, CF)',
            descriptionHindi: 'Vertices A, B, C se teen cevians AD, BE, CF draw karte hain jo common interior point O par intersect karte hain.',
            descriptionEnglish: 'Draw three cevians AD, BE, CF intersecting at common interior point O.',
            examTip: "Medians, angle bisectors, and altitudes all satisfy Ceva's Theorem.",
          ),
          DiagramStepInfo(
            title: 'Mark Side Segments in Cyclic Order',
            descriptionHindi: 'Sides par cut huye segments mark karein: AB par AF aur FB, BC par BD aur DC, CA par CE aur EA.',
            descriptionEnglish: 'Label divided segments along each side: AF, FB, BD, DC, CE, EA.',
            examTip: 'Go cyclically in clockwise direction around the perimeter.',
          ),
          DiagramStepInfo(
            title: "Cyclic Ratio Product: Ceva's Theorem = 1",
            descriptionHindi: 'Ceva\'s Theorem: Triangle ke perimeter par ek direction me ghumte hue segment ratios ka product hamesha 1 hota hai.',
            descriptionEnglish: 'Ceva\'s Theorem: The product of the three segment ratios in cyclic order strictly equals 1.',
            examTip: 'Direct DSSSB & SSC Exam Rule: The cyclic product of segment ratios is strictly 1.',
          ),
          DiagramStepInfo(
            title: "Calculate Missing Segment via Ceva's Theorem",
            descriptionHindi: 'CE/EA = 3/5, BD/DC = 5/7 hone par AF/FB = 1 / ((5/7)·(3/5)) = 7/3. Side AB = 14 cm ➔ AF = 9.8 cm, FB = 4.2 cm.',
            descriptionEnglish: 'Direct DSSSB & SSC Exam Application: Solve missing segments using product equality to 1.',
            examTip: 'AF = 14 × 7/10 = 9.8 cm, FB = 4.2 cm [DSSSB TGT Maths PYQ]!',
          ),
        ];
      case 'tri_thales_theorem':
        return const [
          DiagramStepInfo(
            title: 'Draw Triangle ABC',
            descriptionHindi: 'Pehle triangle ABC draw karte hain jisme base BC hai.',
            descriptionEnglish: 'Construct reference triangle ABC with base BC.',
            examTip: 'The exterior angle bisector meets the extension of base side BC.',
          ),
          DiagramStepInfo(
            title: 'Draw Line DE Parallel to Base BC',
            descriptionHindi: 'Side AB par point D aur AC par point E lekar line DE draw karte hain jo BC ke parallel hai.',
            descriptionEnglish: 'Draw line segment DE parallel to base BC intersecting AB at D and AC at E.',
            examTip: 'Parallel line segment DE intersects AB at D and AC at E.',
          ),
          DiagramStepInfo(
            title: 'Match Corresponding Angles',
            descriptionHindi: 'Parallel lines hone ki wajah se ∠ADE = ∠B aur ∠AED = ∠C corresponding angles barabar hote hain.',
            descriptionEnglish: 'Mark matching corresponding angles: ∠ADE = ∠ABC and ∠AED = ∠ACB.',
            examTip: 'AAA criterion guarantees similarity, but does not imply congruency!',
          ),
          DiagramStepInfo(
            title: 'Basic Proportionality Ratio: AD / DB = AE / EC',
            descriptionHindi: 'Thales Formula: AD / DB = AE / EC. Dono sides par kate hue hisso ka ratio bilkul barabar hota hai.',
            descriptionEnglish: 'Basic Proportionality: AD / DB = AE / EC.',
            examTip: 'AD = 3, DB = 6, AE = 4 ➔ 3/6 = 4/EC ➔ EC = 8 [SSC CGL 2025 Tier-I]!',
          ),
          DiagramStepInfo(
            title: 'Parallel Side Ratio & Area Rule: DE/BC = AD/AB',
            descriptionHindi: 'Warning: DE / BC ratio ke liye whole side AD/AB use karein, AD/DB nahi! Area(ADE) : Area(ABC) = (AD/AB)².',
            descriptionEnglish: 'Parallel side ratio: DE / BC = AD / AB. Area ratio = (AD/AB)². Trapezium Area = Area(ABC) − Area(ADE).',
            examTip: 'DE:BC = 6:7 ➔ Area ADE : Trapezium BCED = 36 : (49 − 36) = 36 : 13 [SSC CGL Tier 2]!',
          ),
        ];
      case 'tri_stewart_theorem':
        return const [
          DiagramStepInfo(
            title: 'Construct Triangle ABC with Sides a, b, c',
            descriptionHindi: 'Sides a = BC, b = AC aur base c = AB ke saath triangle ABC draw karte hain.',
            descriptionEnglish: 'Construct triangle ABC with sides a, b, and base c.',
            examTip: "Stewart's Theorem is the universal master formula for the length of any cevian.",
          ),
          DiagramStepInfo(
            title: 'Draw Arbitrary Cevian CD of Length x',
            descriptionHindi: 'Vertex C se base AB par cevian CD of length x draw karte hain.',
            descriptionEnglish: 'Draw cevian CD of length x connecting vertex C to point D on base AB.',
            examTip: 'Point D can be a median, angle bisector, or any arbitrary point on the base.',
          ),
          DiagramStepInfo(
            title: 'Label Base Segments m and n (c = m + n)',
            descriptionHindi: 'Base par do segments mark karein: BD = m aur DA = n, jahan m + n = c hai.',
            descriptionEnglish: 'Label segments on base: BD = m and DA = n such that c = m + n.',
            examTip: 'Multiply each side square with the far segment: side a² with n and side b² with m.',
          ),
          DiagramStepInfo(
            title: "Stewart's Formula: a²n + b²m = c(x² + mn)",
            descriptionHindi: 'Formula yaad rakhne ki trick: a²n + b²m = x²c + mnc (man + dad = bmb + cnc).',
            descriptionEnglish: 'Stewart Equation: a²n + b²m = c(x² + mn). Each side squared is multiplied by the far segment.',
            examTip: 'Equilateral / Isosceles shortcut (a = b): x² = a² − mn (Superfast 3-second shortcut)!',
          ),
          DiagramStepInfo(
            title: 'Equilateral Triangle Cevian Shortcut: AD² = a² − mn',
            descriptionHindi: 'Equilateral triangle of side 18 cm me BD = ⅓ BC (m = 6, n = 12): AD² = 18² − 6×12 = 324 − 72 = 252 ➔ AD = 6√7 cm!',
            descriptionEnglish: 'Equilateral cevian shortcut: AD² = a² − mn = 324 − 72 = 252 ➔ AD = 6√7 cm.',
            examTip: 'SSC CGL 2020 Tier-I Direct PYQ: AD = 6√7 cm!',
          ),
        ];
      case 'tri_british_flag_theorem':
        return const [
          DiagramStepInfo(
            title: 'Construct Rectangle ABCD',
            descriptionHindi: 'Charon 90° corners A, B, C, D ke saath rectangle ABCD draw karte hain.',
            descriptionEnglish: 'Construct rectangle ABCD with four right-angled vertices.',
            examTip: 'The British Flag Theorem holds true for any interior point P in a rectangle.',
          ),
          DiagramStepInfo(
            title: 'Place Arbitrary Interior Point P',
            descriptionHindi: 'Rectangle ke andar kahi bhi ek arbitrary point P mark karte hain.',
            descriptionEnglish: 'Place an arbitrary point P anywhere inside the rectangle.',
            examTip: 'The theorem holds wherever point P is placed inside the rectangle.',
          ),
          DiagramStepInfo(
            title: 'Connect Opposite Corners (A, C) to Point P',
            descriptionHindi: 'Point P se opposite corners A aur C ko glowing Cyan color lines se jodein (PA aur PC).',
            descriptionEnglish: 'Connect point P to opposite pair of corners A and C with line segments PA and PC.',
            examTip: 'PA² + PC² represents the sum of squares of distances to the first opposite pair.',
          ),
          DiagramStepInfo(
            title: 'Connect Other Opposite Corners (B, D) to Point P',
            descriptionHindi: 'Point P se baaki do opposite corners B aur D ko glowing Rose color lines se jodein (PB aur PD).',
            descriptionEnglish: 'Connect point P to the other pair of opposite corners B and D (PB and PD).',
            examTip: 'PB² + PD² represents the sum of squares of distances to the second opposite pair.',
          ),
          DiagramStepInfo(
            title: 'Master British Flag Formula: PA² + PC² = PB² + PD²',
            descriptionHindi: 'British Flag Theorem: PA² + PC² = PB² + PD²! Sum of squares of distances to opposite corners are equal.',
            descriptionEnglish: 'Master Formula: PA² + PC² = PB² + PD².',
            examTip: 'PA = 98, PB = 91, PC = 21 ➔ PD² = 98² + 21² − 91² = 1764 ➔ PD = 42 cm [RRB Group D 2025]!',
          ),
        ];
      case 'tri_incircle_tangent_lengths':
        return const [
          DiagramStepInfo(
            title: 'Construct Triangle ABC with Incircle',
            descriptionHindi: 'Triangle ABC ke andar inscribed circle draw karte hain jo teeno sides ko touch karta hai.',
            descriptionEnglish: 'Construct triangle ABC with its inscribed circle tangent to all three sides.',
            examTip: 'The incircle touches all three sides at internal tangency points R, P, Q.',
          ),
          DiagramStepInfo(
            title: 'Mark Tangency Points (R on AB, P on BC, Q on AC)',
            descriptionHindi: 'AB par point R, BC par point P, aur AC par point Q touch points mark karte hain.',
            descriptionEnglish: 'Mark tangency points: R on side AB, P on side BC, Q on side AC.',
            examTip: 'The lengths of two tangents drawn from any external vertex to a circle are always equal.',
          ),
          DiagramStepInfo(
            title: 'Highlight Equal Tangent Pairs (x, y, z)',
            descriptionHindi: 'Vertex A se: AP = AR = x; Vertex B se: BP = BQ = y; Vertex C se: CQ = CR = z color code karein.',
            descriptionEnglish: 'Color-code equal tangent pairs: AP = AR = x, BP = BQ = y, CQ = CR = z.',
            examTip: 'Semi-perimeter s = x + y + z. Tangent from each vertex = s − opposite side!',
          ),
          DiagramStepInfo(
            title: 'Tangent Formula: x = s − a, y = s − b, z = s − c',
            descriptionHindi: 'Master Tangent Rule: x = s − a, y = s − b, z = s − c. Aur AD + BE + CF = s.',
            descriptionEnglish: 'Tangent lengths: x = s − a, y = s − b, z = s − c, where s is semi-perimeter.',
            examTip: 'One tangent from each vertex sums to semi-perimeter s [SSC CHSL 2020]!',
          ),
          DiagramStepInfo(
            title: 'Heron\'s Area Formula via Tangents: Area = √[s · xyz]',
            descriptionHindi: 'Heron\'s Formula via Tangents: Area Δ = √[(x + y + z) · xyz] = √[s · xyz]! No side subtraction needed!',
            descriptionEnglish: 'Heron\'s Tangent Formula: Area = √[(x + y + z) × xyz] = √[s · xyz].',
            examTip: 'AQ = 6.5, PC = 7.5, BR = 9 ➔ Perimeter = 2(6.5 + 7.5 + 9) = 2 × 23 = 46 cm [SSC CHSL 2020]!',
          ),
        ];
      default:
        return const [
          DiagramStepInfo(
            title: 'Base Geometry Framework',
            descriptionHindi: 'Pehle base geometric lines aur frame draw karte hain.',
            descriptionEnglish: 'Construct the base geometric frame and coordinates.',
            examTip: 'Symmetry and parallel properties are foundational in geometric constructions.',
          ),
          DiagramStepInfo(
            title: 'Critical Points & Intersections',
            descriptionHindi: 'Ab transversal lines, tangents aur intersection points mark karte hain.',
            descriptionEnglish: 'Mark critical points, tangents, and intersections.',
            examTip: 'Identify intersection angles and proportional side segments.',
          ),
          DiagramStepInfo(
            title: 'Formula Derivation & Exam Rules',
            descriptionHindi: 'Theorems aur final formula relationships ko highlight karte hain.',
            descriptionEnglish: 'Highlight key theorems, ratios, and exam formulas.',
            examTip: 'Direct application for competitive examinations.',
          ),
        ];
    }
  }
}

class ConceptGeometryVisualizer extends StatefulWidget {
  final String? diagramType;
  final Color themeColor;
  final double height;
  final bool showControls;
  final bool showStepByStep;
  final EdgeInsetsGeometry? margin;

  const ConceptGeometryVisualizer({
    super.key,
    required this.diagramType,
    required this.themeColor,
    this.height = 220,
    this.showControls = true,
    this.showStepByStep = false,
    this.margin = const EdgeInsets.only(bottom: 18),
  });

  @override
  State<ConceptGeometryVisualizer> createState() => _ConceptGeometryVisualizerState();
}

class _ConceptGeometryVisualizerState extends State<ConceptGeometryVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _currentStep = 1;
  Timer? _autoPlayTimer;
  bool _isAutoPlaying = false;
  bool _showHindiSubtitle = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ConceptGeometryVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.diagramType != widget.diagramType) {
      _currentStep = 1;
      _stopAutoPlay();
      _replay();
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _isAutoPlaying = false;
  }

  void _toggleAutoPlay() {
    if (_isAutoPlaying) {
      setState(() => _stopAutoPlay());
      return;
    }

    final steps = DiagramStepInfo.getStepsForDiagram(widget.diagramType ?? '');
    setState(() {
      _isAutoPlaying = true;
      if (_currentStep >= steps.length) {
        _currentStep = 1;
      }
    });

    _goToStep(_currentStep);

    _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 3200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final s = DiagramStepInfo.getStepsForDiagram(widget.diagramType ?? '');
      if (_currentStep < s.length) {
        _goToStep(_currentStep + 1);
      } else {
        setState(() => _stopAutoPlay());
      }
    });
  }

  void _goToStep(int step) {
    final steps = DiagramStepInfo.getStepsForDiagram(widget.diagramType ?? '');
    if (step < 1 || step > steps.length) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
    setState(() {
      _currentStep = step;
    });
    _controller.reset();
    _controller.forward();
  }

  void _replay() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.diagramType == null || widget.diagramType == 'none') {
      return const SizedBox.shrink();
    }

    final steps = DiagramStepInfo.getStepsForDiagram(widget.diagramType!);
    final activeStepIndex = math.min(_currentStep, steps.length) - 1;
    final currentStepInfo = steps[activeStepIndex];

    final canvasWidget = Container(
      width: double.infinity,
      height: widget.height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1628),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.themeColor.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: GestureDetector(
          onTap: _replay,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Background subtle grid
              CustomPaint(
                size: Size.infinite,
                painter: _GridBackgroundPainter(),
              ),
              // Custom Geometry Vector Painter with Live Drawing Animation & Pulsing Glow
              AnimatedBuilder(
                animation: Listenable.merge([_animation, _pulseAnimation]),
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _GeometryVectorPainter(
                      diagramType: widget.diagramType!,
                      themeColor: widget.themeColor,
                      progress: _animation.value,
                      pulse: _pulseAnimation.value,
                      currentStep: widget.showStepByStep ? _currentStep : 5,
                    ),
                  );
                },
              ),
              // Top-right Replay button
              if (widget.showControls)
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: _replay,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: widget.themeColor.withValues(alpha: 0.6)),
                        boxShadow: [
                          BoxShadow(
                            color: widget.themeColor.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.brush_rounded, size: 12, color: widget.themeColor),
                          const SizedBox(width: 5),
                          Text(
                            _controller.isAnimating ? 'DRAWING...' : 'RE-DRAW',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: widget.themeColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (!widget.showStepByStep) {
      return Container(
        margin: widget.margin,
        child: canvasWidget,
      );
    }

    // Step-by-Step Interactive Teacher Guide Layout
    return Container(
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          canvasWidget,
          const SizedBox(height: 10),

          // 1. Teacher Explanation Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF13192B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.themeColor.withValues(alpha: 0.35), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.themeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'STEP $_currentStep OF ${steps.length}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: widget.themeColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        currentStepInfo.title,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() => _showHindiSubtitle = !_showHindiSubtitle);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: _showHindiSubtitle
                              ? const Color(0xFF10B981).withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _showHindiSubtitle ? const Color(0xFF10B981) : Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.translate_rounded,
                              size: 11,
                              color: _showHindiSubtitle ? const Color(0xFF34D399) : Colors.white70,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _showHindiSubtitle ? 'HI Sub: ON' : 'EN',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: _showHindiSubtitle ? const Color(0xFF34D399) : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currentStepInfo.descriptionEnglish,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
                ),
                if (_showHindiSubtitle && currentStepInfo.descriptionHindi.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    currentStepInfo.descriptionHindi,
                    style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.65), height: 1.3),
                  ),
                ],
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_rounded, size: 14, color: Colors.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          currentStepInfo.examTip,
                          style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 2. Interactive Navigation Bar & Auto-Play Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1628),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                // Prev Step
                IconButton(
                  onPressed: _currentStep > 1 ? () => _goToStep(_currentStep - 1) : null,
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                  color: _currentStep > 1 ? widget.themeColor : Colors.white24,
                  tooltip: 'Previous Step',
                  visualDensity: VisualDensity.compact,
                ),

                // Step Numbers
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(steps.length, (i) {
                      final stepNum = i + 1;
                      final isSelected = stepNum == _currentStep;
                      final isPast = stepNum < _currentStep;

                      return GestureDetector(
                        onTap: () => _goToStep(stepNum),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? widget.themeColor
                                : (isPast ? widget.themeColor.withValues(alpha: 0.25) : Colors.white10),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : (isPast ? widget.themeColor.withValues(alpha: 0.5) : Colors.transparent),
                            ),
                          ),
                          child: Text(
                            '$stepNum',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Next Step
                IconButton(
                  onPressed: _currentStep < steps.length ? () => _goToStep(_currentStep + 1) : null,
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  color: _currentStep < steps.length ? widget.themeColor : Colors.white24,
                  tooltip: 'Next Step',
                  visualDensity: VisualDensity.compact,
                ),

                const SizedBox(width: 4),

                // Auto-Play Button
                InkWell(
                  onTap: _toggleAutoPlay,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isAutoPlaying
                          ? Colors.amber.withValues(alpha: 0.25)
                          : widget.themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isAutoPlaying ? Colors.amber : widget.themeColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isAutoPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 13,
                          color: _isAutoPlaying ? Colors.amber : widget.themeColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _isAutoPlaying ? 'PAUSE' : 'AUTO-PLAY',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: _isAutoPlaying ? Colors.amber : widget.themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const double step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GeometryVectorPainter extends CustomPainter {
  final String diagramType;
  final Color themeColor;
  final double progress;
  final double pulse;
  final int currentStep;

  _GeometryVectorPainter({
    required this.diagramType,
    required this.themeColor,
    this.progress = 1.0,
    this.pulse = 0.0,
    this.currentStep = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (progress < 1.0) {
      final double clipWidth = size.width * progress;
      canvas.clipRect(Rect.fromLTWH(0, 0, clipWidth, size.height));
    }

    switch (diagramType) {
      case 'circle_tangent':
        _drawCircleTangentSecant(canvas, size);
        break;
      case 'circle_common_tangents':
        _drawCommonTangents(canvas, size);
        break;
      case 'frustum':
        _drawFrustum(canvas, size);
        break;
      case 'trig_triangle':
        _drawTrigTriangle(canvas, size);
        break;
      case 'coord_reflection':
        _drawCoordReflection(canvas, size);
        break;
      case 'cyclic_quad':
        _drawCyclicQuadrilateral(canvas, size);
        break;
      case 'concentric_ring':
        _drawConcentricRing(canvas, size);
        break;
      case 'rhombus_trapezium':
        _drawRhombusTrapezium(canvas, size);
        break;
      case 'lines_intercept_theorem':
        _drawInterceptTheorem(canvas, size, step: currentStep);
        break;
      case 'lines_arrow_rule':
        _drawArrowRule(canvas, size, step: currentStep);
        break;
      case 'lines_zigzag_rule':
        _drawZigZagRule(canvas, size, step: currentStep);
        break;
      case 'lines_transversal_angles':
      case 'parallel_lines':
        _drawParallelLinesTransversal(canvas, size, step: currentStep);
        break;
      case 'tri_formation_condition':
        _drawFormationCondition(canvas, size, step: currentStep);
        break;
      case 'tri_type_identification':
        _drawTypeIdentification(canvas, size, step: currentStep);
        break;
      case 'tri_similarity':
        _drawSimilarityTriangles(canvas, size, step: currentStep);
        break;
      case 'tri_congruency':
        _drawCongruencyTriangles(canvas, size, step: currentStep);
        break;
      case 'tri_sine_rule':
        _drawSineRule(canvas, size, step: currentStep);
        break;
      case 'tri_cosine_rule':
        _drawCosineRule(canvas, size, step: currentStep);
        break;
      case 'incenter_circumcenter':
      case 'tri_centres_properties':
        _drawIncenterCircumcenter(canvas, size, step: currentStep);
        break;
      case 'tri_angle_bisector_results':
        _drawAngleBisectorResults(canvas, size, step: currentStep);
        break;
      case 'angle_bisector':
      case 'tri_interior_bisector_theorem':
        _drawAngleBisector(canvas, size, step: currentStep);
        break;
      case 'tri_exterior_bisector_theorem':
        _drawExteriorBisector(canvas, size, step: currentStep);
        break;
      case 'tri_angle_bisector_length':
        _drawBisectorLength(canvas, size, step: currentStep);
        break;
      case 'tri_ceva_theorem':
        _drawCevaTheorem(canvas, size, step: currentStep);
        break;
      case 'tri_thales_theorem':
      case 'tri_similarity_thales':
        _drawThalesTheorem(canvas, size, step: currentStep);
        break;
      case 'tri_stewart_theorem':
        _drawStewartTheorem(canvas, size, step: currentStep);
        break;
      case 'tri_british_flag_theorem':
        _drawBritishFlag(canvas, size, step: currentStep);
        break;
      case 'apollonius':
      case 'tri_apollonius_medians':
        _drawApolloniusTriangle(canvas, size, step: currentStep);
        break;
      case 'right_triangle_altitudes':
      case 'tri_altitude_hypotenuse':
        _drawRightTriangleAltitudes(canvas, size, step: currentStep);
        break;
      case 'tri_incircle_tangent_lengths':
        _drawIncircleTangents(canvas, size, step: currentStep);
        break;
      default:
        _drawParallelLinesTransversal(canvas, size, step: currentStep);
    }

    canvas.restore();

    // Laser / Pencil Drawing Indicator along the leading edge
    if (progress > 0.0 && progress < 1.0) {
      final double laserX = size.width * progress;
      final laserPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            themeColor.withValues(alpha: 0.0),
            Colors.white,
            themeColor,
            themeColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(laserX - 2, 0, 4, size.height))
        ..strokeWidth = 2.5;
      canvas.drawLine(Offset(laserX, 0), Offset(laserX, size.height), laserPaint);

      // Glowing pencil laser dot
      final dotPaint = Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(laserX, size.height * 0.5), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GeometryVectorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.diagramType != diagramType ||
        oldDelegate.themeColor != themeColor ||
        oldDelegate.pulse != pulse ||
        oldDelegate.currentStep != currentStep;
  }

  // 1. Apollonius Triangle with Median AD
  void _drawApolloniusTriangle(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pA = Offset(w * 0.45, h * 0.20);
    final pB = Offset(w * 0.16, h * 0.78);
    final pC = Offset(w * 0.84, h * 0.78);
    final pD = Offset((pB.dx + pC.dx) / 2, pB.dy); // Midpoint

    // STEP 1: Triangle ABC
    final strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final triangleFill = Paint()
      ..color = themeColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(pA.dx, pA.dy)
      ..lineTo(pB.dx, pB.dy)
      ..lineTo(pC.dx, pC.dy)
      ..close();
    canvas.drawPath(path, triangleFill);
    canvas.drawPath(path, strokePaint);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C', alignRight: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Triangle ABC With Sides a, b, c', Offset(w * 0.20, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Midpoint D
    _drawPointWithLabel(canvas, pD, 'D', alignBottom: true, pointColor: Colors.amberAccent);
    if (step < 3) {
      _drawText(canvas, 'Step 2: Mark Midpoint D of Base BC (BD = DC)', Offset(w * 0.16, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Median AD & Equal Ticks
    final medianPaint = Paint()
      ..color = step == 3 ? themeColor.withValues(alpha: 0.85 + 0.15 * pulse) : themeColor
      ..strokeWidth = step == 3 ? 3.4 : 2.6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pA, pD, medianPaint);

    final tickPaint = Paint()..color = Colors.amberAccent..strokeWidth = 1.8;
    final midBD = Offset((pB.dx + pD.dx) / 2, pB.dy);
    canvas.drawLine(Offset(midBD.dx - 2, midBD.dy - 4), Offset(midBD.dx - 2, midBD.dy + 4), tickPaint);
    canvas.drawLine(Offset(midBD.dx + 2, midBD.dy - 4), Offset(midBD.dx + 2, midBD.dy + 4), tickPaint);

    final midDC = Offset((pD.dx + pC.dx) / 2, pC.dy);
    canvas.drawLine(Offset(midDC.dx - 2, midDC.dy - 4), Offset(midDC.dx - 2, midDC.dy + 4), tickPaint);
    canvas.drawLine(Offset(midDC.dx + 2, midDC.dy - 4), Offset(midDC.dx + 2, midDC.dy + 4), tickPaint);

    _drawText(canvas, 'Median AD', Offset(w * 0.48, h * 0.44), color: themeColor, fontSize: 11, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Draw Median AD from Vertex A to Midpoint D', Offset(w * 0.10, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4 & 5: Formula Banners
    if (step == 4) {
      _drawText(canvas, 'Step 4: AB² + AC² = 2(AD² + BD²) [Apollonius Theorem]', Offset(w * 0.08, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    _drawText(canvas, 'AB² + AC² = 2(AD² + BD²) | 3(a²+b²+c²) = 4(m_a²+m_b²+m_c²)', Offset(w * 0.06, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // 2. Circle Tangent & Secant (PT² = PA × PB)
  void _drawCircleTangentSecant(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final center = Offset(w * 0.65, h * 0.52);
    final radius = h * 0.36;

    final circleFill = Paint()
      ..color = themeColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circleFill);

    final circleStroke = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, circleStroke);

    // External point P
    final pP = Offset(w * 0.08, h * 0.52);

    final dist = (center - pP).distance;
    final tangentLength = math.sqrt(dist * dist - radius * radius);
    final angleToCenter = math.atan2(center.dy - pP.dy, center.dx - pP.dx);
    final alpha = math.asin(radius / dist);
    final angleTangent = angleToCenter - alpha;

    final pT = Offset(
      pP.dx + tangentLength * math.cos(angleTangent),
      pP.dy + tangentLength * math.sin(angleTangent),
    );

    // Tangent Line PT
    final tangentPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.5;
    canvas.drawLine(pP, pT, tangentPaint);

    // Radius OT (Perpendicular to PT)
    final radiusPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(center, pT, radiusPaint);

    // Secant Line PAB through circle
    final pA = Offset(center.dx - radius, center.dy);
    final pB = Offset(center.dx + radius, center.dy);

    final secantPaint = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 2.2;
    canvas.drawLine(pP, pB, secantPaint);

    // Vertex points & Labels
    _drawPointWithLabel(canvas, center, 'O', alignBottom: true, pointColor: Colors.white70);
    _drawPointWithLabel(canvas, pP, 'P', alignLeft: true, pointColor: Colors.white);
    _drawPointWithLabel(canvas, pT, 'T', alignTop: true, pointColor: const Color(0xFF10B981));
    _drawPointWithLabel(canvas, pA, 'A', alignBottom: true, pointColor: Colors.amberAccent);
    _drawPointWithLabel(canvas, pB, 'B', alignRight: true, pointColor: Colors.amberAccent);

    // Formula label on canvas
    _drawText(canvas, 'PT² = PA × PB', Offset(w * 0.12, h * 0.14), color: const Color(0xFF10B981), fontSize: 13, bold: true);
  }

  // 3. Direct & Transverse Common Tangents
  void _drawCommonTangents(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final c1 = Offset(w * 0.28, h * 0.52);
    final r1 = h * 0.30;
    final c2 = Offset(w * 0.72, h * 0.52);
    final r2 = h * 0.20;

    // Draw circles
    final cPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(c1, r1, cPaint);
    canvas.drawCircle(c2, r2, cPaint);

    // Centers
    _drawPointWithLabel(canvas, c1, 'O₁', alignBottom: true);
    _drawPointWithLabel(canvas, c2, 'O₂', alignBottom: true);

    // Line joining centers d
    final dPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(c1, c2, dPaint);

    // Direct Common Tangent (Top line)
    final dctPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.4;
    final dctP1 = Offset(c1.dx, c1.dy - r1);
    final dctP2 = Offset(c2.dx, c2.dy - r2);
    canvas.drawLine(dctP1, dctP2, dctPaint);

    // Transverse Common Tangent (Crossing diagonal line)
    final tctPaint = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 2.2;
    final tctP1 = Offset(c1.dx + r1 * 0.7, c1.dy - r1 * 0.7);
    final tctP2 = Offset(c2.dx - r2 * 0.7, c2.dy + r2 * 0.7);
    canvas.drawLine(tctP1, tctP2, tctPaint);

    _drawText(canvas, 'DCT = √(d² - (r₁ - r₂)²)', Offset(w * 0.15, h * 0.10), color: const Color(0xFF10B981), fontSize: 11, bold: true);
    _drawText(canvas, 'TCT = √(d² - (r₁ + r₂)²)', Offset(w * 0.15, h * 0.88), color: Colors.amberAccent, fontSize: 11, bold: true);
  }

  // 4. Frustum of a Cone
  void _drawFrustum(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final topCenter = Offset(w * 0.5, h * 0.24);
    final bottomCenter = Offset(w * 0.5, h * 0.76);
    final topRx = w * 0.18;
    final topRy = h * 0.07;
    final bottomRx = w * 0.32;
    final bottomRy = h * 0.11;

    final wirePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Bottom Ellipse
    final bottomRect = Rect.fromCenter(center: bottomCenter, width: bottomRx * 2, height: bottomRy * 2);
    canvas.drawOval(bottomRect, fillPaint);
    canvas.drawOval(bottomRect, wirePaint);

    // Top Ellipse
    final topRect = Rect.fromCenter(center: topCenter, width: topRx * 2, height: topRy * 2);
    canvas.drawOval(topRect, fillPaint);
    canvas.drawOval(topRect, wirePaint);

    // Slant Sides
    final leftTop = Offset(topCenter.dx - topRx, topCenter.dy);
    final leftBottom = Offset(bottomCenter.dx - bottomRx, bottomCenter.dy);
    final rightTop = Offset(topCenter.dx + topRx, topCenter.dy);
    final rightBottom = Offset(bottomCenter.dx + bottomRx, bottomCenter.dy);

    final slantPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 2.4;
    canvas.drawLine(leftTop, leftBottom, slantPaint);
    canvas.drawLine(rightTop, rightBottom, slantPaint);

    // Height vertical center axis
    final hPaint = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 1.5;
    canvas.drawLine(topCenter, bottomCenter, hPaint);

    // Radii horizontal lines
    final rPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 1.5;
    canvas.drawLine(topCenter, rightTop, rPaint);
    canvas.drawLine(bottomCenter, rightBottom, rPaint);

    _drawText(canvas, 'r (Top)', Offset(topCenter.dx + topRx * 0.35, topCenter.dy - 16), color: Colors.cyanAccent, fontSize: 11, bold: true);
    _drawText(canvas, 'R (Base)', Offset(bottomCenter.dx + bottomRx * 0.35, bottomCenter.dy + 8), color: Colors.cyanAccent, fontSize: 11, bold: true);
    _drawText(canvas, 'h', Offset(topCenter.dx - 14, h * 0.48), color: Colors.amberAccent, fontSize: 12, bold: true);
    _drawText(canvas, 'Slant l', Offset(rightTop.dx + 6, h * 0.48), color: themeColor, fontSize: 11, bold: true);
  }

  // 5. Right Triangle (30°-60°-90°)
  void _drawTrigTriangle(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pRight = Offset(w * 0.70, h * 0.80); // 90 deg corner
    final pTop = Offset(w * 0.70, h * 0.20);   // 60 deg corner
    final pLeft = Offset(w * 0.20, h * 0.80);  // 30 deg corner

    final path = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..lineTo(pLeft.dx, pLeft.dy)
      ..close();

    final fillPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

    // Right angle box (90°)
    const double boxSize = 13.0;
    final boxPath = Path()
      ..moveTo(pRight.dx - boxSize, pRight.dy)
      ..lineTo(pRight.dx - boxSize, pRight.dy - boxSize)
      ..lineTo(pRight.dx, pRight.dy - boxSize);
    canvas.drawPath(
      boxPath,
      Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Angle arc at 30°
    final arcPaint = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawArc(Rect.fromCircle(center: pLeft, radius: 24), -0.55, 0.55, false, arcPaint);

    // Ratio values on sides
    _drawText(canvas, '1 unit', Offset(pRight.dx + 8, h * 0.48), color: Colors.cyanAccent, fontSize: 12, bold: true);
    _drawText(canvas, '√3 units', Offset(w * 0.40, pRight.dy + 8), color: Colors.cyanAccent, fontSize: 12, bold: true);
    _drawText(canvas, '2 units (Hyp)', Offset(w * 0.32, h * 0.44), color: themeColor, fontSize: 12, bold: true);

    // Angle texts
    _drawText(canvas, '30°', Offset(pLeft.dx + 28, pLeft.dy - 16), color: Colors.amberAccent, fontSize: 11, bold: true);
    _drawText(canvas, '60°', Offset(pTop.dx - 28, pTop.dy + 12), color: Colors.amberAccent, fontSize: 11, bold: true);
  }

  // 6. Incenter & Circumcenter Triangle
  void _drawIncenterCircumcenter(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pA = Offset(w * 0.5, h * 0.18);
    final pB = Offset(w * 0.18, h * 0.80);
    final pC = Offset(w * 0.82, h * 0.80);

    // STEP 1: Triangle ABC
    final path = Path()
      ..moveTo(pA.dx, pA.dy)
      ..lineTo(pB.dx, pB.dy)
      ..lineTo(pC.dx, pC.dy)
      ..close();

    canvas.drawPath(path, Paint()..color = themeColor.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = Colors.white..strokeWidth = 2.2..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C', alignRight: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Triangle ABC Framework', Offset(w * 0.28, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Incentre I & Angle Bisectors
    final incenter = Offset(w * 0.50, h * 0.56);
    final inradius = h * 0.22;

    final bisectorPaint = Paint()
      ..color = step == 2 ? const Color(0xFF10B981).withValues(alpha: 0.85 + 0.15 * pulse) : const Color(0xFF10B981)
      ..strokeWidth = step == 2 ? 2.6 : 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pB, incenter, bisectorPaint);
    canvas.drawLine(pC, incenter, bisectorPaint);
    _drawPointWithLabel(canvas, incenter, 'I', alignTop: true, pointColor: const Color(0xFF10B981));

    if (step < 3) {
      _drawText(canvas, 'Step 2: Incentre I (∠BIC = 90° + A/2)', Offset(w * 0.22, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Incircle of radius r = Δ/s
    final incirclePaint = Paint()
      ..color = step == 3 ? const Color(0xFFF59E0B).withValues(alpha: 0.85 + 0.15 * pulse) : const Color(0xFFF59E0B)
      ..strokeWidth = step == 3 ? 2.8 : 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(incenter, inradius, incirclePaint);
    _drawText(canvas, 'Inradius r = Δ/s', Offset(incenter.dx + 8, incenter.dy + 8), color: const Color(0xFFF59E0B), fontSize: 10, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Incircle Tangent to All 3 Sides (r = Δ / s)', Offset(w * 0.10, h * 0.90), color: const Color(0xFFF59E0B), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: Circumcentre O & Circumcircle R
    final circumcenter = Offset(w * 0.50, h * 0.50);
    final circumradius = h * 0.38;
    final circumPaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.5)..strokeWidth = 1.6..style = PaintingStyle.stroke;
    canvas.drawCircle(circumcenter, circumradius, circumPaint);
    _drawPointWithLabel(canvas, circumcenter, 'O (R)', alignRight: true, pointColor: const Color(0xFF38BDF8));

    if (step < 5) {
      _drawText(canvas, 'Step 4: Circumcentre O (R = abc / 4Δ) & ∠BOC = 2∠A', Offset(w * 0.10, h * 0.90), color: const Color(0xFF38BDF8), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 5: Full Formula Banner
    _drawText(canvas, '∠BIC = 90°+A/2 | ∠BHC = 180°−A | r = Δ/s | R = abc/4Δ', Offset(w * 0.06, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // 7. Coordinate Reflection Transformation
  void _drawCoordReflection(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final origin = Offset(w * 0.5, h * 0.5);

    final axisPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(w * 0.1, origin.dy), Offset(w * 0.9, origin.dy), axisPaint); // X axis
    canvas.drawLine(Offset(origin.dx, h * 0.1), Offset(origin.dx, h * 0.9), axisPaint); // Y axis

    // Point P(x, y)
    final pP = Offset(w * 0.72, h * 0.30);
    final pRefX = Offset(w * 0.72, h * 0.70);
    final pRefY = Offset(w * 0.28, h * 0.30);

    final dashPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.4;
    canvas.drawLine(pP, pRefX, dashPaint);
    canvas.drawLine(pP, pRefY, dashPaint);

    _drawPointWithLabel(canvas, pP, 'P (x, y)', alignTop: true, pointColor: Colors.amberAccent);
    _drawPointWithLabel(canvas, pRefX, 'P\' (x, -y)', alignBottom: true, pointColor: const Color(0xFF10B981));
    _drawPointWithLabel(canvas, pRefY, 'P\'\' (-x, y)', alignLeft: true, pointColor: Colors.cyanAccent);

    _drawText(canvas, 'X-Axis', Offset(w * 0.88, origin.dy - 14), color: Colors.white54, fontSize: 10, bold: true);
    _drawText(canvas, 'Y-Axis', Offset(origin.dx + 6, h * 0.08), color: Colors.white54, fontSize: 10, bold: true);
  }

  // 8. Right-Angled Triangle Altitudes & Geometric Mean
  void _drawRightTriangleAltitudes(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pC = Offset(w * 0.50, h * 0.20); // 90° top vertex
    final pA = Offset(w * 0.15, h * 0.78); // Left vertex on hypotenuse
    final pB = Offset(w * 0.85, h * 0.78); // Right vertex on hypotenuse
    final pD = Offset(w * 0.50, h * 0.78); // Foot of perpendicular from C

    // STEP 1: Right-Angled Triangle Framework
    final trianglePath = Path()
      ..moveTo(pC.dx, pC.dy)
      ..lineTo(pA.dx, pA.dy)
      ..lineTo(pB.dx, pB.dy)
      ..close();

    canvas.drawPath(trianglePath, Paint()..color = themeColor.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(trianglePath, Paint()..color = Colors.white..strokeWidth = 2.4..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pC, 'C (90°)', alignTop: true, pointColor: Colors.amberAccent);
    _drawPointWithLabel(canvas, pA, 'A', alignLeft: true);
    _drawPointWithLabel(canvas, pB, 'B', alignRight: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Right-Angled Triangle ABC at C (∠C = 90°)', Offset(w * 0.14, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Altitude CD ⊥ AB
    final altPaint = Paint()
      ..color = step == 2 ? const Color(0xFF10B981).withValues(alpha: 0.85 + 0.15 * pulse) : const Color(0xFF10B981)
      ..strokeWidth = step == 2 ? 3.4 : 2.4;
    canvas.drawLine(pC, pD, altPaint);

    const double bSize = 11.0;
    final boxD = Path()
      ..moveTo(pD.dx - bSize, pD.dy)
      ..lineTo(pD.dx - bSize, pD.dy - bSize)
      ..lineTo(pD.dx, pD.dy - bSize);
    canvas.drawPath(boxD, Paint()..color = Colors.white70..style = PaintingStyle.stroke..strokeWidth = 1.4);
    _drawPointWithLabel(canvas, pD, 'D', alignBottom: true, pointColor: const Color(0xFF10B981));

    if (step < 3) {
      _drawText(canvas, 'Step 2: Drop Altitude CD Perpendicular to Hypotenuse AB', Offset(w * 0.08, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Segments AD and BD
    _drawText(canvas, 'AD', Offset((pA.dx + pD.dx) / 2, pA.dy + 8), color: Colors.amberAccent, fontSize: 10.5, bold: true);
    _drawText(canvas, 'BD', Offset((pB.dx + pD.dx) / 2, pB.dy + 8), color: Colors.amberAccent, fontSize: 10.5, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Hypotenuse Segmented into AD and BD', Offset(w * 0.16, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: Altitude Squared = AD × BD
    _drawText(canvas, 'CD² = AD × BD', Offset(w * 0.54, h * 0.46), color: const Color(0xFF10B981), fontSize: 11, bold: true);

    if (step < 5) {
      _drawText(canvas, 'Step 4: Geometric Mean: CD² = AD × BD | CD = (a·b) / c', Offset(w * 0.08, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 5: Full Formula Banner
    _drawText(canvas, 'CD² = BD×AD | BC² = BD×AB | AC² = AD×AB | CD = ab/c', Offset(w * 0.04, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // 9. Angle Bisector Theorem (Interior & Exterior)
  void _drawAngleBisector(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pA = Offset(w * 0.45, h * 0.20);
    final pB = Offset(w * 0.16, h * 0.78);
    final pC = Offset(w * 0.84, h * 0.78);
    final pD = Offset(w * 0.42, h * 0.78); // Foot of angle bisector

    // STEP 1: Triangle ABC
    final path = Path()
      ..moveTo(pA.dx, pA.dy)
      ..lineTo(pB.dx, pB.dy)
      ..lineTo(pC.dx, pC.dy)
      ..close();

    canvas.drawPath(path, Paint()..color = themeColor.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = Colors.white..strokeWidth = 2.4..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C', alignRight: true);

    _drawText(canvas, 'c', Offset(w * 0.25, h * 0.46), color: Colors.cyanAccent, fontSize: 11, bold: true);
    _drawText(canvas, 'b', Offset(w * 0.68, h * 0.46), color: Colors.cyanAccent, fontSize: 11, bold: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Triangle ABC With Adjacent Sides c = AB, b = AC', Offset(w * 0.08, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Bisector AD of ∠A
    final bisectorPaint = Paint()
      ..color = step == 2 ? const Color(0xFFEC4899).withValues(alpha: 0.85 + 0.15 * pulse) : const Color(0xFFEC4899)
      ..strokeWidth = step == 2 ? 3.4 : 2.4;
    canvas.drawLine(pA, pD, bisectorPaint);
    _drawPointWithLabel(canvas, pD, 'D', alignBottom: true, pointColor: const Color(0xFFEC4899));

    if (step < 3) {
      _drawText(canvas, 'Step 2: Draw Interior Angle Bisector AD Bisecting ∠A', Offset(w * 0.10, h * 0.90), color: const Color(0xFFEC4899), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Segments m and n
    _drawText(canvas, 'm (BD)', Offset(w * 0.26, h * 0.82), color: Colors.amberAccent, fontSize: 10, bold: true);
    _drawText(canvas, 'n (DC)', Offset(w * 0.56, h * 0.82), color: Colors.amberAccent, fontSize: 10, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Base Side BC Divided into Segments m and n', Offset(w * 0.12, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: Ratio AB / AC = BD / DC
    if (step == 4) {
      _drawText(canvas, 'Step 4: Angle Bisector Theorem: AB / AC = BD / DC', Offset(w * 0.12, h * 0.90), color: const Color(0xFFEC4899), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 5: Full Formula Banner
    _drawText(canvas, 'AB / AC = BD / DC = m / n  |  AD² = c·b − m·n', Offset(w * 0.10, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // 10. Cyclic Quadrilateral
  void _drawCyclicQuadrilateral(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final center = Offset(w * 0.50, h * 0.50);
    final radius = h * 0.38;

    // Circle
    canvas.drawCircle(center, radius, Paint()..color = Colors.white30..strokeWidth = 1.8..style = PaintingStyle.stroke);

    // 4 Inscribed points on circle
    final pA = Offset(center.dx + radius * math.cos(-1.9), center.dy + radius * math.sin(-1.9));
    final pB = Offset(center.dx + radius * math.cos(-0.4), center.dy + radius * math.sin(-0.4));
    final pC = Offset(center.dx + radius * math.cos(1.2), center.dy + radius * math.sin(1.2));
    final pD = Offset(center.dx + radius * math.cos(3.2), center.dy + radius * math.sin(3.2));

    final quadPath = Path()
      ..moveTo(pA.dx, pA.dy)
      ..lineTo(pB.dx, pB.dy)
      ..lineTo(pC.dx, pC.dy)
      ..lineTo(pD.dx, pD.dy)
      ..close();

    canvas.drawPath(quadPath, Paint()..color = themeColor.withValues(alpha: 0.14)..style = PaintingStyle.fill);
    canvas.drawPath(quadPath, Paint()..color = themeColor..strokeWidth = 2.4..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignRight: true);
    _drawPointWithLabel(canvas, pC, 'C', alignBottom: true);
    _drawPointWithLabel(canvas, pD, 'D', alignLeft: true);

    _drawText(canvas, '∠A + ∠C = 180°', Offset(w * 0.12, h * 0.12), color: themeColor, fontSize: 11, bold: true);
    _drawText(canvas, '∠B + ∠D = 180°', Offset(w * 0.62, h * 0.12), color: Colors.amberAccent, fontSize: 11, bold: true);
  }

  // 11. Concentric Circles Ring & Tangent Chord
  void _drawConcentricRing(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final center = Offset(w * 0.50, h * 0.50);
    final bigR = h * 0.38;
    final smallR = h * 0.22;

    // Shaded Ring
    final ringPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, bigR, ringPaint);
    canvas.drawCircle(center, smallR, Paint()..color = const Color(0xFF0F1628)..style = PaintingStyle.fill);

    // Outlines
    final strokePaint = Paint()
      ..color = Colors.white60
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, bigR, strokePaint);
    canvas.drawCircle(center, smallR, strokePaint);

    // Chord AB of outer circle tangent to inner circle at M (top)
    final pM = Offset(center.dx, center.dy - smallR);
    final halfChord = math.sqrt(bigR * bigR - smallR * smallR);
    final pA = Offset(center.dx - halfChord, pM.dy);
    final pB = Offset(center.dx + halfChord, pM.dy);

    final chordPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.4;
    canvas.drawLine(pA, pB, chordPaint);

    _drawPointWithLabel(canvas, center, 'O', alignBottom: true);
    _drawPointWithLabel(canvas, pA, 'A', alignLeft: true, pointColor: const Color(0xFF10B981));
    _drawPointWithLabel(canvas, pB, 'B', alignRight: true, pointColor: const Color(0xFF10B981));
    _drawPointWithLabel(canvas, pM, 'M', alignTop: true, pointColor: Colors.amberAccent);

    _drawText(canvas, 'Chord AB is tangent to inner circle', Offset(w * 0.18, h * 0.12), color: Colors.white70, fontSize: 10, bold: true);
    _drawText(canvas, 'Ring Area = π(R² - r²) = (π/4) × AB²', Offset(w * 0.20, h * 0.88), color: const Color(0xFF10B981), fontSize: 11, bold: true);
  }

  // 12. Rhombus & Trapezium
  void _drawRhombusTrapezium(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final center = Offset(w * 0.50, h * 0.50);
    final halfD1 = w * 0.32;
    final halfD2 = h * 0.30;

    final pTop = Offset(center.dx, center.dy - halfD2);
    final pBottom = Offset(center.dx, center.dy + halfD2);
    final pLeft = Offset(center.dx - halfD1, center.dy);
    final pRight = Offset(center.dx + halfD1, center.dy);

    final path = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..lineTo(pBottom.dx, pBottom.dy)
      ..lineTo(pLeft.dx, pLeft.dy)
      ..close();

    canvas.drawPath(path, Paint()..color = themeColor.withValues(alpha: 0.12)..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = themeColor..strokeWidth = 2.4..style = PaintingStyle.stroke);

    // Diagonals d1 & d2
    final d1Paint = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 1.8;
    canvas.drawLine(pLeft, pRight, d1Paint);

    final d2Paint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 1.8;
    canvas.drawLine(pTop, pBottom, d2Paint);

    _drawPointWithLabel(canvas, pTop, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pRight, 'B', alignRight: true);
    _drawPointWithLabel(canvas, pBottom, 'C', alignBottom: true);
    _drawPointWithLabel(canvas, pLeft, 'D', alignLeft: true);

    _drawText(canvas, 'Area = 1/2 × d₁ × d₂', Offset(w * 0.12, h * 0.12), color: Colors.amberAccent, fontSize: 11, bold: true);
    _drawText(canvas, '4a² = d₁² + d₂²', Offset(w * 0.65, h * 0.12), color: const Color(0xFF10B981), fontSize: 11, bold: true);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint, {double dashWidth = 5, double dashSpace = 4}) {
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double distance = math.sqrt(dx * dx + dy * dy);
    if (distance == 0) return;
    final double unitX = dx / distance;
    final double unitY = dy / distance;

    double current = 0.0;
    while (current < distance) {
      final double next = math.min(current + dashWidth, distance);
      canvas.drawLine(
        Offset(p1.dx + unitX * current, p1.dy + unitY * current),
        Offset(p1.dx + unitX * next, p1.dy + unitY * next),
        paint,
      );
      current += dashWidth + dashSpace;
    }
  }

  void _drawParallelArrow(Canvas canvas, Offset pos, Paint paint, {double size = 6}) {
    final path = Path()
      ..moveTo(pos.dx - size, pos.dy - size * 0.8)
      ..lineTo(pos.dx, pos.dy)
      ..lineTo(pos.dx - size, pos.dy + size * 0.8);
    canvas.drawPath(path, paint);
  }

  void _drawInterceptTheorem(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final transPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = themeColor.withValues(alpha: 0.8 + 0.2 * pulse)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;

    final double y1 = h * 0.22;
    final double y2 = h * 0.50;
    final double y3 = h * 0.78;
    final double xStart = w * 0.08;
    final double xEnd = w * 0.92;

    // STEP 1: Three Parallel lines L1, L2, L3
    final pL1 = step == 1 ? activePaint : linePaint;
    canvas.drawLine(Offset(xStart, y1), Offset(xEnd, y1), pL1);
    canvas.drawLine(Offset(xStart, y2), Offset(xEnd, y2), pL1);
    canvas.drawLine(Offset(xStart, y3), Offset(xEnd, y3), pL1);

    _drawParallelArrow(canvas, Offset(w * 0.86, y1), arrowPaint);
    _drawParallelArrow(canvas, Offset(w * 0.86, y2), arrowPaint);
    _drawParallelArrow(canvas, Offset(w * 0.86, y3), arrowPaint);

    _drawText(canvas, 'L₁', Offset(xStart - 4, y1 - 16), color: Colors.white60, fontSize: 10, bold: true);
    _drawText(canvas, 'L₂', Offset(xStart - 4, y2 - 16), color: Colors.white60, fontSize: 10, bold: true);
    _drawText(canvas, 'L₃', Offset(xStart - 4, y3 - 16), color: Colors.white60, fontSize: 10, bold: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: 3 Parallel Lines (L₁ ∥ L₂ ∥ L₃)', Offset(w * 0.18, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // Two Transversals: S (left) and T (right)
    final Offset sStart = Offset(w * 0.28, h * 0.10);
    final Offset sEnd = Offset(w * 0.20, h * 0.90);
    final Offset tStart = Offset(w * 0.70, h * 0.10);
    final Offset tEnd = Offset(w * 0.80, h * 0.90);

    double sX(double y) => sStart.dx + (sEnd.dx - sStart.dx) * ((y - sStart.dy) / (sEnd.dy - sStart.dy));
    double tX(double y) => tStart.dx + (tEnd.dx - tStart.dx) * ((y - tStart.dy) / (tEnd.dy - tStart.dy));

    final Offset ptA = Offset(sX(y1), y1);
    final Offset ptB = Offset(sX(y2), y2);
    final Offset ptC = Offset(sX(y3), y3);

    final Offset ptD = Offset(tX(y1), y1);
    final Offset ptE = Offset(tX(y2), y2);
    final Offset ptF = Offset(tX(y3), y3);

    // STEP 2: Transversal S & Points A, B, C
    final pTransS = step == 2 ? activePaint : transPaint;
    canvas.drawLine(sStart, sEnd, pTransS);
    _drawPointWithLabel(canvas, ptA, 'A', alignLeft: true, pointColor: step == 2 ? const Color(0xFF38BDF8) : themeColor);
    _drawPointWithLabel(canvas, ptB, 'B', alignLeft: true, pointColor: step == 2 ? const Color(0xFF38BDF8) : themeColor);
    _drawPointWithLabel(canvas, ptC, 'C', alignLeft: true, pointColor: step == 2 ? const Color(0xFF38BDF8) : themeColor);
    _drawText(canvas, 'Transversal S', Offset(sStart.dx - 45, sStart.dy - 8), color: const Color(0xFF38BDF8), fontSize: 9.5, bold: true);

    if (step < 3) {
      _drawText(canvas, 'Step 2: Transversal S cuts lines at A, B, C', Offset(w * 0.16, h * 0.90), color: const Color(0xFF38BDF8), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Transversal T & Points D, E, F
    final pTransT = step == 3 ? activePaint : transPaint;
    canvas.drawLine(tStart, tEnd, pTransT);
    _drawPointWithLabel(canvas, ptD, 'D', alignRight: true, pointColor: step == 3 ? const Color(0xFF10B981) : themeColor);
    _drawPointWithLabel(canvas, ptE, 'E', alignRight: true, pointColor: step == 3 ? const Color(0xFF10B981) : themeColor);
    _drawPointWithLabel(canvas, ptF, 'F', alignRight: true, pointColor: step == 3 ? const Color(0xFF10B981) : themeColor);
    _drawText(canvas, 'Transversal T', Offset(tStart.dx - 10, tStart.dy - 8), color: const Color(0xFF38BDF8), fontSize: 9.5, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Transversal T cuts lines at D, E, F', Offset(w * 0.16, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: Intercept labels m, n and ratio equality
    _drawText(canvas, 'm', Offset((ptA.dx + ptB.dx) / 2 - 18, (ptA.dy + ptB.dy) / 2 - 8), color: Colors.amberAccent, fontSize: 11.5, bold: true);
    _drawText(canvas, 'n', Offset((ptB.dx + ptC.dx) / 2 - 18, (ptB.dy + ptC.dy) / 2 - 8), color: Colors.amberAccent, fontSize: 11.5, bold: true);

    _drawText(canvas, 'm', Offset((ptD.dx + ptE.dx) / 2 + 10, (ptD.dy + ptE.dy) / 2 - 8), color: const Color(0xFF10B981), fontSize: 11.5, bold: true);
    _drawText(canvas, 'n', Offset((ptE.dx + ptF.dx) / 2 + 10, (ptE.dy + ptF.dy) / 2 - 8), color: const Color(0xFF10B981), fontSize: 11.5, bold: true);

    if (step == 4) {
      _drawText(canvas, 'Step 4: AB / BC = DE / EF = m / n [Intercept Theorem]', Offset(w * 0.10, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 5: Trapezium Internal Divider Formula BE = (a·n + b·m)/(m+n)
    final trapPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    _drawDashedLine(canvas, ptA, ptD, trapPaint);
    _drawDashedLine(canvas, ptC, ptF, trapPaint);

    final dividerPaint = Paint()
      ..color = const Color(0xFFEC4899)
      ..strokeWidth = 2.8 + 0.8 * pulse
      ..style = PaintingStyle.stroke;
    canvas.drawLine(ptB, ptE, dividerPaint);

    _drawText(canvas, 'a (Top)', Offset((ptA.dx + ptD.dx) / 2 - 16, ptA.dy - 16), color: Colors.white70, fontSize: 10, bold: true);
    _drawText(canvas, 'b (Bottom)', Offset((ptC.dx + ptF.dx) / 2 - 24, ptC.dy + 4), color: Colors.white70, fontSize: 10, bold: true);

    // Formula Banner Pill
    _drawText(canvas, 'AB / BC = DE / EF = m / n  |  BE = (a·n + b·m)/(m+n)', Offset(w * 0.10, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  void _drawArrowRule(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final arcPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double yTop = h * 0.22;
    final double yBot = h * 0.78;
    final double xLeft = w * 0.10;

    final Offset ptA = Offset(xLeft, yTop);
    final Offset ptB = Offset(w * 0.58, yTop);
    final Offset ptC = Offset(xLeft, yBot);
    final Offset ptD = Offset(w * 0.58, yBot);
    final Offset ptO = Offset(w * 0.76, h * 0.50);

    // STEP 1: Parallel lines AB and CD
    canvas.drawLine(ptA, ptB, linePaint);
    canvas.drawLine(ptC, ptD, linePaint);

    _drawPointWithLabel(canvas, ptA, 'A', alignTop: true, pointColor: Colors.white70);
    _drawPointWithLabel(canvas, ptB, 'B', alignTop: true, pointColor: themeColor);
    _drawPointWithLabel(canvas, ptC, 'C', alignBottom: true, pointColor: Colors.white70);
    _drawPointWithLabel(canvas, ptD, 'D', alignBottom: true, pointColor: themeColor);

    _drawParallelArrow(canvas, Offset(w * 0.35, yTop), Paint()..color = themeColor..strokeWidth = 2.0..style = PaintingStyle.stroke);
    _drawParallelArrow(canvas, Offset(w * 0.35, yBot), Paint()..color = themeColor..strokeWidth = 2.0..style = PaintingStyle.stroke);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Do Parallel Lines Draw Karein (AB ∥ CD)', Offset(w * 0.12, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Arrowhead segments BO and DO
    final activeArrowPaint = Paint()
      ..color = step == 2 ? themeColor.withValues(alpha: 0.85 + 0.15 * pulse) : themeColor
      ..strokeWidth = step == 2 ? 3.4 : 2.6
      ..style = PaintingStyle.stroke;

    canvas.drawLine(ptB, ptO, activeArrowPaint);
    canvas.drawLine(ptD, ptO, activeArrowPaint);
    _drawPointWithLabel(canvas, ptO, 'O', alignRight: true, pointColor: const Color(0xFFFBBF24));

    if (step < 3) {
      _drawText(canvas, 'Step 2: Rays BO & DO Vertex O Par Milte Hain (Arrowhead)', Offset(w * 0.08, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Auxiliary dashed line through O parallel to AB and produced rays
    final Offset ptProducedTop = Offset(ptO.dx + (ptO.dx - ptB.dx) * 0.45, ptO.dy + (ptO.dy - ptB.dy) * 0.45);
    final Offset ptProducedBot = Offset(ptO.dx + (ptO.dx - ptD.dx) * 0.45, ptO.dy + (ptO.dy - ptD.dy) * 0.45);
    _drawDashedLine(canvas, ptO, ptProducedTop, dashPaint);
    _drawDashedLine(canvas, ptO, ptProducedBot, dashPaint);

    final auxPaint = Paint()
      ..color = step == 3 ? const Color(0xFF38BDF8) : Colors.white38
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    _drawDashedLine(canvas, Offset(w * 0.35, ptO.dy), Offset(w * 0.94, ptO.dy), auxPaint);
    _drawText(canvas, 'Aux ∥ AB', Offset(w * 0.36, ptO.dy - 12), color: const Color(0xFF38BDF8), fontSize: 9.5, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Vertex O Se Auxiliary Parallel Line Khinchein', Offset(w * 0.10, h * 0.90), color: const Color(0xFF38BDF8), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: Co-Interior Angles α & β
    canvas.drawArc(Rect.fromCircle(center: ptB, radius: 18), 0.1, 0.9, false, arcPaint);
    _drawText(canvas, 'α', Offset(ptB.dx - 30, ptB.dy + 6), color: const Color(0xFFFBBF24), fontSize: 11.5, bold: true);

    canvas.drawArc(Rect.fromCircle(center: ptD, radius: 18), -1.0, 0.9, false, arcPaint);
    _drawText(canvas, 'β', Offset(ptD.dx - 30, ptD.dy - 18), color: const Color(0xFFFBBF24), fontSize: 11.5, bold: true);

    if (step < 5) {
      _drawText(canvas, 'Step 4: Co-Interior Pairs: 180° + 180° = 360°', Offset(w * 0.14, h * 0.90), color: const Color(0xFFFBBF24), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 5: Reflex Angle γ and Arrow Rule Formula
    final reflexArcPaint = Paint()
      ..color = const Color(0xFFF43F5E)
      ..strokeWidth = 2.4 + 0.6 * pulse
      ..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: ptO, radius: 16), -0.8, 1.6, false, reflexArcPaint);
    _drawText(canvas, 'γ', Offset(ptO.dx + 16, ptO.dy - 7), color: const Color(0xFFF43F5E), fontSize: 12, bold: true);

    // Formula label
    _drawText(canvas, 'Arrow Rule: α + β + γ = 360° (∠ABO + ∠CDO + ∠BOD = 360°)', Offset(w * 0.08, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  void _drawZigZagRule(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final lhsArcPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final rhsArcPaint = Paint()
      ..color = const Color(0xFFF43F5E)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final double yTop = h * 0.20;
    final double yBot = h * 0.80;

    // STEP 1: Parallel lines AB and CD
    canvas.drawLine(Offset(w * 0.08, yTop), Offset(w * 0.92, yTop), linePaint);
    canvas.drawLine(Offset(w * 0.08, yBot), Offset(w * 0.92, yBot), linePaint);

    _drawText(canvas, 'A', Offset(w * 0.08, yTop - 16), color: Colors.white70, fontSize: 11, bold: true);
    _drawText(canvas, 'B', Offset(w * 0.88, yTop - 16), color: Colors.white70, fontSize: 11, bold: true);
    _drawText(canvas, 'C', Offset(w * 0.08, yBot + 4), color: Colors.white70, fontSize: 11, bold: true);
    _drawText(canvas, 'D', Offset(w * 0.88, yBot + 4), color: Colors.white70, fontSize: 11, bold: true);

    _drawParallelArrow(canvas, Offset(w * 0.82, yTop), Paint()..color = themeColor..strokeWidth = 2.0..style = PaintingStyle.stroke);
    _drawParallelArrow(canvas, Offset(w * 0.82, yBot), Paint()..color = themeColor..strokeWidth = 2.0..style = PaintingStyle.stroke);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Boundary Parallel Lines AB ∥ CD Draw Karein', Offset(w * 0.10, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // Vertices of the zig-zag
    final Offset vStart = Offset(w * 0.26, yTop);
    final Offset ptP = Offset(w * 0.68, h * 0.35);
    final Offset ptQ = Offset(w * 0.38, h * 0.52);
    final Offset ptR = Offset(w * 0.72, h * 0.67);
    final Offset vEnd = Offset(w * 0.32, yBot);

    // STEP 2: Zig-Zag Path
    final path = Path()
      ..moveTo(vStart.dx, vStart.dy)
      ..lineTo(ptP.dx, ptP.dy)
      ..lineTo(ptQ.dx, ptQ.dy)
      ..lineTo(ptR.dx, ptR.dy)
      ..lineTo(vEnd.dx, vEnd.dy);

    final activeZigPaint = Paint()
      ..color = step == 2 ? themeColor.withValues(alpha: 0.85 + 0.15 * pulse) : themeColor
      ..strokeWidth = step == 2 ? 3.6 : 2.8
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, activeZigPaint);

    _drawPointWithLabel(canvas, ptP, 'P', alignRight: true, pointColor: Colors.white);
    _drawPointWithLabel(canvas, ptQ, 'Q', alignLeft: true, pointColor: Colors.white);
    _drawPointWithLabel(canvas, ptR, 'R', alignRight: true, pointColor: Colors.white);

    if (step < 3) {
      _drawText(canvas, 'Step 2: Multi-Bend Path (P, Q, R) Draw Karein', Offset(w * 0.14, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Left-opening angles (LHS: m, n) in Emerald Green
    canvas.drawArc(Rect.fromCircle(center: ptP, radius: 15), math.pi - 0.7, 1.4, false, lhsArcPaint);
    _drawText(canvas, 'm (←)', Offset(ptP.dx - 34, ptP.dy - 6), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);

    canvas.drawArc(Rect.fromCircle(center: ptR, radius: 15), math.pi - 0.7, 1.4, false, lhsArcPaint);
    _drawText(canvas, 'n (←)', Offset(ptR.dx - 34, ptR.dy - 6), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Left-Opening Angles Highlighted: (m + n)', Offset(w * 0.12, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: Right-opening angles (RHS: α, β, γ) in Coral Red
    canvas.drawArc(Rect.fromCircle(center: vStart, radius: 14), 0.2, 0.8, false, rhsArcPaint);
    _drawText(canvas, 'α (→)', Offset(vStart.dx + 16, vStart.dy + 4), color: const Color(0xFFF43F5E), fontSize: 10.5, bold: true);

    canvas.drawArc(Rect.fromCircle(center: ptQ, radius: 15), -0.7, 1.4, false, rhsArcPaint);
    _drawText(canvas, 'β (→)', Offset(ptQ.dx + 16, ptQ.dy - 6), color: const Color(0xFFF43F5E), fontSize: 10.5, bold: true);

    canvas.drawArc(Rect.fromCircle(center: vEnd, radius: 14), -1.1, 0.8, false, rhsArcPaint);
    _drawText(canvas, 'γ (→)', Offset(vEnd.dx + 16, vEnd.dy - 16), color: const Color(0xFFF43F5E), fontSize: 10.5, bold: true);

    if (step < 5) {
      _drawText(canvas, 'Step 4: Right-Opening Angles Highlighted: (α + β + γ)', Offset(w * 0.10, h * 0.90), color: const Color(0xFFF43F5E), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 5: Zig-Zag Balance Formula Banner
    _drawText(canvas, 'LHS (m+n) = RHS (α+β+γ)  |  Left-opening = Right-opening', Offset(w * 0.08, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  void _drawParallelLinesTransversal(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final bisectorPaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final double y1 = h * 0.28;
    final double y2 = h * 0.70;
    final double xStart = w * 0.08;
    final double xEnd = w * 0.92;

    // STEP 1: Parallel lines l and m
    canvas.drawLine(Offset(xStart, y1), Offset(xEnd, y1), linePaint);
    canvas.drawLine(Offset(xStart, y2), Offset(xEnd, y2), linePaint);

    _drawParallelArrow(canvas, Offset(xEnd - 24, y1), Paint()..color = themeColor..strokeWidth = 2.0..style = PaintingStyle.stroke);
    _drawParallelArrow(canvas, Offset(xEnd - 24, y2), Paint()..color = themeColor..strokeWidth = 2.0..style = PaintingStyle.stroke);

    _drawText(canvas, 'Line l', Offset(xStart, y1 - 16), color: Colors.white60, fontSize: 10, bold: true);
    _drawText(canvas, 'Line m', Offset(xStart, y2 + 6), color: Colors.white60, fontSize: 10, bold: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Do Parallel Lines l ∥ m Draw Karein', Offset(w * 0.16, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // Transversal line
    final Offset tStart = Offset(w * 0.32, h * 0.10);
    final Offset tEnd = Offset(w * 0.68, h * 0.90);

    // STEP 2: Transversal line & Intersections E and F
    final activeTrans = Paint()
      ..color = step == 2 ? themeColor.withValues(alpha: 0.85 + 0.15 * pulse) : themeColor
      ..strokeWidth = step == 2 ? 3.4 : 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(tStart, tEnd, activeTrans);
    _drawText(canvas, 'Transversal t', Offset(tStart.dx - 12, tStart.dy - 8), color: themeColor, fontSize: 9.5, bold: true);

    final double xE = tStart.dx + (tEnd.dx - tStart.dx) * ((y1 - tStart.dy) / (tEnd.dy - tStart.dy));
    final double xF = tStart.dx + (tEnd.dx - tStart.dx) * ((y2 - tStart.dy) / (tEnd.dy - tStart.dy));
    final Offset ptE = Offset(xE, y1);
    final Offset ptF = Offset(xF, y2);

    _drawPointWithLabel(canvas, ptE, 'E', alignTop: true, pointColor: themeColor);
    _drawPointWithLabel(canvas, ptF, 'F', alignBottom: true, pointColor: themeColor);

    if (step < 3) {
      _drawText(canvas, 'Step 2: Transversal Line t Cuts l at E and m at F', Offset(w * 0.10, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Numbered Angle Labels (1 to 4 at E, 5 to 8 at F)
    // Acute angles (1, 3, 5, 7) in Emerald Green, Obtuse (2, 4, 6, 8) in Amber
    final Color acuteColor = const Color(0xFF10B981);
    final Color obtuseColor = const Color(0xFFF59E0B);

    _drawText(canvas, '1', Offset(ptE.dx + 16, ptE.dy - 18), color: acuteColor, fontSize: 11, bold: true);
    _drawText(canvas, '2', Offset(ptE.dx - 22, ptE.dy - 18), color: obtuseColor, fontSize: 11, bold: true);
    _drawText(canvas, '3', Offset(ptE.dx - 22, ptE.dy + 8), color: acuteColor, fontSize: 11, bold: true);
    _drawText(canvas, '4', Offset(ptE.dx + 16, ptE.dy + 8), color: obtuseColor, fontSize: 11, bold: true);

    _drawText(canvas, '5', Offset(ptF.dx + 16, ptF.dy - 18), color: acuteColor, fontSize: 11, bold: true);
    _drawText(canvas, '6', Offset(ptF.dx - 22, ptF.dy - 18), color: obtuseColor, fontSize: 11, bold: true);
    _drawText(canvas, '7', Offset(ptF.dx - 22, ptF.dy + 8), color: acuteColor, fontSize: 11, bold: true);
    _drawText(canvas, '8', Offset(ptF.dx + 16, ptF.dy + 8), color: obtuseColor, fontSize: 11, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: 8 Angles Formed: Acute (Green) & Obtuse (Orange)', Offset(w * 0.08, h * 0.90), color: acuteColor, fontSize: 10, bold: true);
      return;
    }

    // STEP 4: Corresponding & Alternate Angles Rule Highlight
    if (step == 4) {
      final zPaint = Paint()
        ..color = acuteColor.withValues(alpha: 0.6 + 0.3 * pulse)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(ptE.dx - 16, ptE.dy + 12), 10, zPaint);
      canvas.drawCircle(Offset(ptF.dx + 20, ptF.dy - 12), 10, zPaint);

      _drawText(canvas, 'Step 4: Alt Int (∠3=∠5, Z-shape) | Corr (∠1=∠5) | Co-Int (∠4+∠5=180°)', Offset(w * 0.04, h * 0.90), color: acuteColor, fontSize: 9.5, bold: true);
      return;
    }

    // STEP 5: Bisector Rays of interior angles on same side (∠4 and ∠5) meeting at G (90°)
    final Offset ptG = Offset(w * 0.74, (y1 + y2) / 2);
    canvas.drawLine(ptE, ptG, bisectorPaint);
    canvas.drawLine(ptF, ptG, bisectorPaint);
    _drawPointWithLabel(canvas, ptG, 'G (90°)', alignRight: true, pointColor: const Color(0xFF8B5CF6));

    // Right-angle box at G
    final squarePaint = Paint()..color = const Color(0xFF8B5CF6)..strokeWidth = 1.6..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromCenter(center: Offset(ptG.dx - 8, ptG.dy), width: 10, height: 10), squarePaint);

    // Formula Banner
    _drawText(canvas, 'Alt Int: ∠3=∠5 | Co-Int: ∠4+∠5=180° | Bisectors: ∠EGF=90°', Offset(w * 0.08, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }


  // =========================================================================
  // TRIANGLE DRAWING METHODS (18 CONCEPTS WITH STEP-BY-STEP TEACHER WALKTHROUGH)
  // =========================================================================

  // Concept 1: Condition for Formation of a Triangle
  void _drawFormationCondition(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pB = Offset(w * 0.18, h * 0.78);
    final pC = Offset(w * 0.82, h * 0.78);
    final pA = Offset(w * 0.52, h * 0.22);

    // STEP 1: Base side a (BC)
    final basePaint = Paint()
      ..color = step == 1 ? themeColor.withValues(alpha: 0.85 + 0.15 * pulse) : Colors.white70
      ..strokeWidth = step == 1 ? 3.4 : 2.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pB, pC, basePaint);

    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C', alignRight: true);
    _drawText(canvas, 'a (Base)', Offset((pB.dx + pC.dx) / 2 - 20, pB.dy + 8), color: Colors.amberAccent, fontSize: 11, bold: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Construct Base Side a (Segment BC)', Offset(w * 0.16, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Arc of radius b from C
    final arcPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: step == 2 ? 0.8 + 0.2 * pulse : 0.4)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: pC, radius: (pC - pA).distance), math.pi + 0.5, 0.8, false, arcPaint);

    if (step < 3) {
      _drawText(canvas, 'Step 2: Draw Arc of Length b from Vertex C', Offset(w * 0.18, h * 0.90), color: const Color(0xFF38BDF8), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Arc of radius c from B & complete triangle
    final arcBPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: step == 3 ? 0.8 + 0.2 * pulse : 0.4)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: pB, radius: (pB - pA).distance), -1.3, 0.8, false, arcBPaint);

    final sidePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pA, pB, sidePaint);
    canvas.drawLine(pA, pC, sidePaint);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true, pointColor: themeColor);
    _drawText(canvas, 'c', Offset((pA.dx + pB.dx) / 2 - 16, (pA.dy + pB.dy) / 2 - 8), color: Colors.cyanAccent, fontSize: 11, bold: true);
    _drawText(canvas, 'b', Offset((pA.dx + pC.dx) / 2 + 8, (pA.dy + pC.dy) / 2 - 8), color: Colors.cyanAccent, fontSize: 11, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Arcs Intersect at A (b + c > a Guaranteed)', Offset(w * 0.12, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: Inequalities
    if (step == 4) {
      _drawText(canvas, 'Step 4: |b − c| < a < b + c | a + b > c | b + c > a', Offset(w * 0.12, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 5: Master Formula Banner
    _drawText(canvas, '|b − c| < a < b + c  |  Side < Perimeter / 2', Offset(w * 0.18, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // Concept 2: Identification of Type of Triangle
  void _drawTypeIdentification(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pB = Offset(w * 0.20, h * 0.76);
    final pC = Offset(w * 0.80, h * 0.76);

    // Reference vertices
    final pRight = Offset(w * 0.20, h * 0.24); // 90° at B
    final pAcute = Offset(w * 0.44, h * 0.24); // Acute angle at B
    final pObtuse = Offset(w * 0.08, h * 0.38); // Obtuse angle at B

    // STEP 1: Base side BC
    canvas.drawLine(pB, pC, Paint()..color = Colors.white70..strokeWidth = 2.4);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C (largest side c opposite)', alignRight: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Construct Base a (BC) & Vertex B', Offset(w * 0.20, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Right Triangle (c² = a² + b²)
    final rightPaint = Paint()..color = Colors.amberAccent.withValues(alpha: step == 2 ? 0.9 : 0.3)..strokeWidth = 2.0..style = PaintingStyle.stroke;
    canvas.drawLine(pB, pRight, rightPaint);
    canvas.drawLine(pRight, pC, rightPaint);
    canvas.drawRect(Rect.fromLTWH(pB.dx, pB.dy - 10, 10, 10), Paint()..color = Colors.amberAccent..style = PaintingStyle.stroke..strokeWidth = 1.2);
    _drawPointWithLabel(canvas, pRight, 'Right (90°)', alignTop: true, pointColor: Colors.amberAccent);

    if (step < 3) {
      _drawText(canvas, 'Step 2: Right Triangle Benchmark: c² = a² + b²', Offset(w * 0.16, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Acute Triangle (c² < a² + b²)
    final acutePaint = Paint()..color = const Color(0xFF10B981).withValues(alpha: step == 3 ? 0.95 : 0.35)..strokeWidth = 2.2..style = PaintingStyle.stroke;
    canvas.drawLine(pB, pAcute, acutePaint);
    canvas.drawLine(pAcute, pC, acutePaint);
    _drawPointWithLabel(canvas, pAcute, 'Acute (<90°)', alignTop: true, pointColor: const Color(0xFF10B981));

    if (step < 4) {
      _drawText(canvas, 'Step 3: Acute Triangle: Largest Side c² < a² + b²', Offset(w * 0.14, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: Obtuse Triangle (c² > a² + b²)
    final obtusePaint = Paint()..color = const Color(0xFFF43F5E).withValues(alpha: step == 4 ? 0.95 : 0.35)..strokeWidth = 2.2..style = PaintingStyle.stroke;
    canvas.drawLine(pB, pObtuse, obtusePaint);
    canvas.drawLine(pObtuse, pC, obtusePaint);
    _drawPointWithLabel(canvas, pObtuse, 'Obtuse (>90°)', alignLeft: true, pointColor: const Color(0xFFF43F5E));

    if (step < 5) {
      _drawText(canvas, 'Step 4: Obtuse Triangle: Largest Side c² > a² + b²', Offset(w * 0.14, h * 0.90), color: const Color(0xFFF43F5E), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 5: Master Classification Banner
    _drawText(canvas, 'c² < a²+b² (Acute) | c² = a²+b² (Right) | c² > a²+b² (Obtuse)', Offset(w * 0.05, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // Concept 3: Similarity of Triangles
  void _drawSimilarityTriangles(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    // Triangle 1: ΔABC (smaller, left)
    final pA = Offset(w * 0.24, h * 0.28);
    final pB = Offset(w * 0.08, h * 0.78);
    final pC = Offset(w * 0.40, h * 0.78);

    // Triangle 2: ΔDEF (larger, right, scale k = 1.4)
    final pD = Offset(w * 0.72, h * 0.18);
    final pE = Offset(w * 0.50, h * 0.78);
    final pF = Offset(w * 0.94, h * 0.78);

    // STEP 1: Triangle 1 (ΔABC)
    final t1Path = Path()..moveTo(pA.dx, pA.dy)..lineTo(pB.dx, pB.dy)..lineTo(pC.dx, pC.dy)..close();
    canvas.drawPath(t1Path, Paint()..color = themeColor.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(t1Path, Paint()..color = Colors.white70..strokeWidth = 2.2..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C', alignRight: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Construct Reference Triangle ΔABC', Offset(w * 0.18, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Scaled Triangle 2 (ΔDEF)
    final t2Path = Path()..moveTo(pD.dx, pD.dy)..lineTo(pE.dx, pE.dy)..lineTo(pF.dx, pF.dy)..close();
    canvas.drawPath(t2Path, Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(t2Path, Paint()..color = const Color(0xFF10B981)..strokeWidth = 2.4..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pD, 'D', alignTop: true, pointColor: const Color(0xFF10B981));
    _drawPointWithLabel(canvas, pE, 'E', alignLeft: true, pointColor: const Color(0xFF10B981));
    _drawPointWithLabel(canvas, pF, 'F', alignRight: true, pointColor: const Color(0xFF10B981));

    if (step < 3) {
      _drawText(canvas, 'Step 2: Construct Scaled Triangle ΔDEF (Ratio k)', Offset(w * 0.16, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Matching angle arcs
    final arcPaint = Paint()..color = Colors.amberAccent..strokeWidth = 1.6..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: pB, radius: 12), -0.6, 0.6, false, arcPaint);
    canvas.drawArc(Rect.fromCircle(center: pE, radius: 14), -0.6, 0.6, false, arcPaint);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Corresponding Angles Are Strictly Equal (∠B = ∠E)', Offset(w * 0.10, h * 0.90), color: Colors.amberAccent, fontSize: 10, bold: true);
      return;
    }

    // STEP 4: Side Ratio k
    _drawText(canvas, 'Ratio k', Offset(w * 0.41, h * 0.48), color: Colors.cyanAccent, fontSize: 11, bold: true);

    if (step < 5) {
      _drawText(canvas, 'Step 4: All Linear Ratios (Sides, Perimeters, Altitudes) = k', Offset(w * 0.08, h * 0.90), color: Colors.cyanAccent, fontSize: 10, bold: true);
      return;
    }

    // STEP 5: Master Area Ratio Rule
    _drawText(canvas, 'AB/DE = BC/EF = AC/DF = k  |  Area(ABC)/Area(DEF) = k²', Offset(w * 0.06, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // Concept 4: Congruency of Triangles
  void _drawCongruencyTriangles(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pA = Offset(w * 0.24, h * 0.24);
    final pB = Offset(w * 0.08, h * 0.78);
    final pC = Offset(w * 0.42, h * 0.78);

    final pD = Offset(w * 0.74, h * 0.24);
    final pE = Offset(w * 0.58, h * 0.78);
    final pF = Offset(w * 0.92, h * 0.78);

    // STEP 1 & 2: Both identical triangles
    final t1 = Path()..moveTo(pA.dx, pA.dy)..lineTo(pB.dx, pB.dy)..lineTo(pC.dx, pC.dy)..close();
    final t2 = Path()..moveTo(pD.dx, pD.dy)..lineTo(pE.dx, pE.dy)..lineTo(pF.dx, pF.dy)..close();

    canvas.drawPath(t1, Paint()..color = themeColor.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(t1, Paint()..color = Colors.white..strokeWidth = 2.2..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C', alignRight: true);

    if (step >= 2) {
      canvas.drawPath(t2, Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.1)..style = PaintingStyle.fill);
      canvas.drawPath(t2, Paint()..color = const Color(0xFF10B981)..strokeWidth = 2.2..style = PaintingStyle.stroke);
      _drawPointWithLabel(canvas, pD, 'D', alignTop: true, pointColor: const Color(0xFF10B981));
      _drawPointWithLabel(canvas, pE, 'E', alignLeft: true, pointColor: const Color(0xFF10B981));
      _drawPointWithLabel(canvas, pF, 'F', alignRight: true, pointColor: const Color(0xFF10B981));
    }

    if (step < 2) {
      _drawText(canvas, 'Step 1: Construct Base Triangle ΔABC', Offset(w * 0.24, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }
    if (step < 3) {
      _drawText(canvas, 'Step 2: Construct Identical Matching Triangle ΔDEF', Offset(w * 0.16, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: SSS Tick marks
    final tick = Paint()..color = Colors.amberAccent..strokeWidth = 2.0;
    // Single tick on AB & DE
    canvas.drawLine(Offset((pA.dx + pB.dx) / 2 - 3, (pA.dy + pB.dy) / 2), Offset((pA.dx + pB.dx) / 2 + 3, (pA.dy + pB.dy) / 2), tick);
    canvas.drawLine(Offset((pD.dx + pE.dx) / 2 - 3, (pD.dy + pE.dy) / 2), Offset((pD.dx + pE.dx) / 2 + 3, (pD.dy + pE.dy) / 2), tick);

    // Double tick on BC & EF
    final mBC = (pB.dx + pC.dx) / 2;
    canvas.drawLine(Offset(mBC - 2, pB.dy - 3), Offset(mBC - 2, pB.dy + 3), tick);
    canvas.drawLine(Offset(mBC + 2, pB.dy - 3), Offset(mBC + 2, pB.dy + 3), tick);

    final mEF = (pE.dx + pF.dx) / 2;
    canvas.drawLine(Offset(mEF - 2, pE.dy - 3), Offset(mEF - 2, pE.dy + 3), tick);
    canvas.drawLine(Offset(mEF + 2, pE.dy - 3), Offset(mEF + 2, pE.dy + 3), tick);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Mark SSS Equal Sides (AB = DE, BC = EF, AC = DF)', Offset(w * 0.08, h * 0.90), color: Colors.amberAccent, fontSize: 10, bold: true);
      return;
    }

    // STEP 4: SAS / RHS Angles
    final arcP = Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 1.6..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: pB, radius: 12), -0.6, 0.6, false, arcP);
    canvas.drawArc(Rect.fromCircle(center: pE, radius: 12), -0.6, 0.6, false, arcP);

    if (step < 5) {
      _drawText(canvas, 'Step 4: Criteria: SSS, SAS, ASA, AAS, RHS (AAA is NOT valid!)', Offset(w * 0.06, h * 0.90), color: const Color(0xFF38BDF8), fontSize: 10, bold: true);
      return;
    }

    // STEP 5: Banner
    _drawText(canvas, 'ΔABC ≅ ΔDEF by SSS/SAS/ASA/RHS | CPCT Equal Parts', Offset(w * 0.08, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // Concept 5: Sine Rule
  void _drawSineRule(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final center = Offset(w * 0.50, h * 0.48);
    final radius = h * 0.36;

    // STEP 1: Circumcircle of radius R
    final circlePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: step == 1 ? 0.8 : 0.35)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, circlePaint);
    _drawPointWithLabel(canvas, center, 'O (R)', alignRight: true, pointColor: const Color(0xFF38BDF8));

    if (step < 2) {
      _drawText(canvas, 'Step 1: Construct Circumcircle of Radius R and Centre O', Offset(w * 0.10, h * 0.90), color: const Color(0xFF38BDF8), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Inscribed triangle ABC
    final pA = Offset(center.dx + radius * math.cos(-1.4), center.dy + radius * math.sin(-1.4));
    final pB = Offset(center.dx + radius * math.cos(2.2), center.dy + radius * math.sin(2.2));
    final pC = Offset(center.dx + radius * math.cos(0.7), center.dy + radius * math.sin(0.7));

    final tPath = Path()..moveTo(pA.dx, pA.dy)..lineTo(pB.dx, pB.dy)..lineTo(pC.dx, pC.dy)..close();
    canvas.drawPath(tPath, Paint()..color = themeColor.withValues(alpha: 0.12)..style = PaintingStyle.fill);
    canvas.drawPath(tPath, Paint()..color = Colors.white..strokeWidth = 2.2..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C', alignRight: true);

    _drawText(canvas, 'a', Offset((pB.dx + pC.dx) / 2, pB.dy + 8), color: Colors.amberAccent, fontSize: 11, bold: true);

    if (step < 3) {
      _drawText(canvas, 'Step 2: Inscribe Triangle ABC with Side a Opposite to ∠A', Offset(w * 0.10, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Diameter segment BD = 2R
    final pD = Offset(center.dx - (center.dx - pB.dx), center.dy - (center.dy - pB.dy));
    final diamPaint = Paint()..color = Colors.amberAccent..strokeWidth = 2.0..style = PaintingStyle.stroke;
    canvas.drawLine(pB, pD, diamPaint);
    _drawPointWithLabel(canvas, pD, 'D', alignRight: true, pointColor: Colors.amberAccent);
    _drawText(canvas, '2R', Offset(center.dx - 14, center.dy - 12), color: Colors.amberAccent, fontSize: 10.5, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Draw Circumdiameter BD = 2R Through Centre O', Offset(w * 0.10, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: Subtended Right Angle
    canvas.drawLine(pD, pC, Paint()..color = Colors.white38..strokeWidth = 1.4);

    if (step < 5) {
      _drawText(canvas, 'Step 4: In Right ΔBCD: sin A = a / 2R ➔ a / sin A = 2R', Offset(w * 0.10, h * 0.90), color: const Color(0xFF38BDF8), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 5: Banner
    _drawText(canvas, 'a/sin A = b/sin B = c/sin C = 2R  |  Area = abc / 4R', Offset(w * 0.10, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // Concept 6: Cosine Rule
  void _drawCosineRule(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pA = Offset(w * 0.45, h * 0.22);
    final pB = Offset(w * 0.14, h * 0.78);
    final pC = Offset(w * 0.86, h * 0.78);
    final pD = Offset(pA.dx, pB.dy); // Altitude foot

    // STEP 1: Triangle ABC
    final tPath = Path()..moveTo(pA.dx, pA.dy)..lineTo(pB.dx, pB.dy)..lineTo(pC.dx, pC.dy)..close();
    canvas.drawPath(tPath, Paint()..color = themeColor.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(tPath, Paint()..color = Colors.white..strokeWidth = 2.4..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C', alignRight: true);

    _drawText(canvas, 'c', Offset((pA.dx + pB.dx) / 2 - 16, (pA.dy + pB.dy) / 2), color: Colors.cyanAccent, fontSize: 11, bold: true);
    _drawText(canvas, 'b', Offset((pA.dx + pC.dx) / 2 + 10, (pA.dy + pC.dy) / 2), color: Colors.cyanAccent, fontSize: 11, bold: true);
    _drawText(canvas, 'a', Offset((pB.dx + pC.dx) / 2, pB.dy + 8), color: Colors.amberAccent, fontSize: 11, bold: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Construct Triangle ABC With Side Lengths a, b, c', Offset(w * 0.10, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Altitude AD = h
    final altPaint = Paint()..color = const Color(0xFFEC4899)..strokeWidth = 2.2;
    canvas.drawLine(pA, pD, altPaint);
    _drawPointWithLabel(canvas, pD, 'D (90°)', alignBottom: true, pointColor: const Color(0xFFEC4899));
    _drawText(canvas, 'h', Offset(pD.dx + 6, (pA.dy + pD.dy) / 2), color: const Color(0xFFEC4899), fontSize: 11, bold: true);

    if (step < 3) {
      _drawText(canvas, 'Step 2: Drop Perpendicular Altitude AD ⊥ BC of Height h', Offset(w * 0.08, h * 0.90), color: const Color(0xFFEC4899), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Base projections
    _drawText(canvas, 'c·cos B', Offset((pB.dx + pD.dx) / 2 - 14, pB.dy - 14), color: Colors.amberAccent, fontSize: 10, bold: true);
    _drawText(canvas, 'a − c·cos B', Offset((pD.dx + pC.dx) / 2 - 14, pB.dy - 14), color: Colors.amberAccent, fontSize: 10, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Base Divided into c·cos B and (a − c·cos B)', Offset(w * 0.12, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: Pythagoras
    if (step < 5) {
      _drawText(canvas, 'Step 4: In ΔACD: b² = h² + (a − c·cos B)² ➔ b² = a² + c² − 2ac·cos B', Offset(w * 0.04, h * 0.90), color: Colors.amberAccent, fontSize: 9.5, bold: true);
      return;
    }

    // STEP 5: Banner
    _drawText(canvas, 'cos A = (b² + c² − a²) / 2bc  |  a² = b² + c² − 2bc cos A', Offset(w * 0.08, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // Concept 8: Angle Bisector Results (Excentre & Altitude Difference)
  void _drawAngleBisectorResults(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pA = Offset(w * 0.38, h * 0.22);
    final pB = Offset(w * 0.12, h * 0.76);
    final pC = Offset(w * 0.60, h * 0.76);
    final pD = Offset(w * 0.88, h * 0.76); // BC produced

    // STEP 1: Triangle ABC & BC produced to D
    final tPath = Path()..moveTo(pA.dx, pA.dy)..lineTo(pB.dx, pB.dy)..lineTo(pC.dx, pC.dy)..close();
    canvas.drawPath(tPath, Paint()..color = themeColor.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(tPath, Paint()..color = Colors.white..strokeWidth = 2.2..style = PaintingStyle.stroke);
    canvas.drawLine(pC, pD, Paint()..color = Colors.white38..strokeWidth = 1.6);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C', alignBottom: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Triangle ABC with Base Side BC Produced to D', Offset(w * 0.10, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Bisectors meeting at E
    final pE = Offset(w * 0.82, h * 0.36);
    final bisPaint = Paint()..color = const Color(0xFF10B981)..strokeWidth = 2.2;
    canvas.drawLine(pB, pE, bisPaint);
    canvas.drawLine(pC, pE, bisPaint);
    _drawPointWithLabel(canvas, pE, 'E (½∠A)', alignRight: true, pointColor: const Color(0xFF10B981));

    if (step < 3) {
      _drawText(canvas, 'Step 2: Internal Bisector of B & External of C Meet at E', Offset(w * 0.08, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Highlight ∠BEC = ½∠A
    if (step == 3) {
      _drawText(canvas, 'Step 3: Master Result 1: ∠BEC = ½ ∠BAC (Half of Vertex A)', Offset(w * 0.08, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: Altitude and angle bisector from A
    final pAlt = Offset(pA.dx, pB.dy);
    final pBis = Offset(w * 0.44, pB.dy);
    canvas.drawLine(pA, pAlt, Paint()..color = const Color(0xFFF43F5E)..strokeWidth = 2.0);
    canvas.drawLine(pA, pBis, Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 2.0);

    if (step < 5) {
      _drawText(canvas, 'Step 4: Altitude AD ⊥ BC and Bisector AE from Same Vertex A', Offset(w * 0.06, h * 0.90), color: const Color(0xFF38BDF8), fontSize: 10, bold: true);
      return;
    }

    // STEP 5: Banner
    _drawText(canvas, '∠BEC = ½∠A  |  Angle Between Alt & Bisector: ∠DAE = |B−C|/2', Offset(w * 0.04, h * 0.90), color: Colors.white, fontSize: 10, bold: true);
  }

  // Concept 10: Exterior Angle Bisector Theorem
  void _drawExteriorBisector(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pA = Offset(w * 0.40, h * 0.32);
    final pB = Offset(w * 0.12, h * 0.78);
    final pC = Offset(w * 0.54, h * 0.78);
    final pE = Offset(w * 0.88, h * 0.78); // BC produced to E

    // STEP 1: Triangle ABC
    final tPath = Path()..moveTo(pA.dx, pA.dy)..lineTo(pB.dx, pB.dy)..lineTo(pC.dx, pC.dy)..close();
    canvas.drawPath(tPath, Paint()..color = themeColor.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(tPath, Paint()..color = Colors.white..strokeWidth = 2.2..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C', alignBottom: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Triangle ABC With AB > AC', Offset(w * 0.22, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Produce BA to D
    final pD = Offset(pA.dx + (pA.dx - pB.dx) * 0.5, pA.dy + (pA.dy - pB.dy) * 0.5);
    canvas.drawLine(pA, pD, Paint()..color = Colors.white38..strokeWidth = 1.6);
    _drawPointWithLabel(canvas, pD, 'D', alignTop: true, pointColor: Colors.white60);

    if (step < 3) {
      _drawText(canvas, 'Step 2: Produce Side BA to Point D to Form Exterior Angle', Offset(w * 0.08, h * 0.90), color: Colors.white60, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Exterior bisector AE to produced BC
    canvas.drawLine(pC, pE, Paint()..color = Colors.white38..strokeWidth = 1.6);
    final bisPaint = Paint()..color = const Color(0xFF10B981)..strokeWidth = 2.4;
    canvas.drawLine(pA, pE, bisPaint);
    _drawPointWithLabel(canvas, pE, 'E', alignBottom: true, pointColor: const Color(0xFF10B981));

    if (step < 4) {
      _drawText(canvas, 'Step 3: Draw Exterior Bisector AE Meeting BC Produced at E', Offset(w * 0.08, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: External segments
    _drawText(canvas, 'BC', Offset((pB.dx + pC.dx) / 2 - 8, pB.dy + 8), color: Colors.amberAccent, fontSize: 10, bold: true);
    _drawText(canvas, 'CE', Offset((pC.dx + pE.dx) / 2 - 8, pB.dy + 8), color: const Color(0xFF10B981), fontSize: 10, bold: true);

    if (step < 5) {
      _drawText(canvas, 'Step 4: External Segment Division: BE / CE = AB / AC', Offset(w * 0.12, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 5: Banner
    _drawText(canvas, 'AB / AC = BE / CE  |  CE = BC × AC / (AB − AC)', Offset(w * 0.10, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // Concept 11: Length of Angle Bisector (when θ is given)
  void _drawBisectorLength(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pC = Offset(w * 0.50, h * 0.20); // Vertex angle
    final pA = Offset(w * 0.16, h * 0.78);
    final pB = Offset(w * 0.84, h * 0.78);
    final pD = Offset(w * 0.46, h * 0.78);

    // STEP 1: Triangle ABC with sides b = CA, a = CB
    final tPath = Path()..moveTo(pC.dx, pC.dy)..lineTo(pA.dx, pA.dy)..lineTo(pB.dx, pB.dy)..close();
    canvas.drawPath(tPath, Paint()..color = themeColor.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(tPath, Paint()..color = Colors.white..strokeWidth = 2.2..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pC, 'C (2θ)', alignTop: true, pointColor: Colors.amberAccent);
    _drawPointWithLabel(canvas, pA, 'A', alignLeft: true);
    _drawPointWithLabel(canvas, pB, 'B', alignRight: true);

    _drawText(canvas, 'b', Offset((pA.dx + pC.dx) / 2 - 14, (pA.dy + pC.dy) / 2), color: Colors.cyanAccent, fontSize: 11, bold: true);
    _drawText(canvas, 'a', Offset((pB.dx + pC.dx) / 2 + 8, (pB.dy + pC.dy) / 2), color: Colors.cyanAccent, fontSize: 11, bold: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Triangle ABC with Adjacent Sides a, b & Vertex ∠C', Offset(w * 0.08, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Bisector CD = x
    final bisPaint = Paint()..color = const Color(0xFFEC4899)..strokeWidth = 2.4;
    canvas.drawLine(pC, pD, bisPaint);
    _drawPointWithLabel(canvas, pD, 'D', alignBottom: true, pointColor: const Color(0xFFEC4899));
    _drawText(canvas, 'x', Offset(pD.dx - 12, (pC.dy + pD.dy) / 2), color: const Color(0xFFEC4899), fontSize: 11, bold: true);

    if (step < 3) {
      _drawText(canvas, 'Step 2: Draw Angle Bisector CD = x Splitting ∠C into θ and θ', Offset(w * 0.06, h * 0.90), color: const Color(0xFFEC4899), fontSize: 10, bold: true);
      return;
    }

    // STEP 3: Two area components
    if (step == 3) {
      _drawText(canvas, 'Step 3: Area Balance: Area(ACD) + Area(BCD) = Total Area(ABC)', Offset(w * 0.06, h * 0.90), color: Colors.amberAccent, fontSize: 10, bold: true);
      return;
    }

    // STEP 4: Sine expansion
    if (step == 4) {
      _drawText(canvas, 'Step 4: ½bx sin θ + ½ax sin θ = ½ab sin(2θ) ➔ x = 2ab cos θ / (a + b)', Offset(w * 0.04, h * 0.90), color: Colors.amberAccent, fontSize: 9.5, bold: true);
      return;
    }

    // STEP 5: Banner
    _drawText(canvas, 'CD = x = 2ab cos θ / (a + b)  |  If 120°: 1/CD = 1/a + 1/b', Offset(w * 0.08, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // Concept 12: Ceva\'s Theorem
  void _drawCevaTheorem(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pA = Offset(w * 0.48, h * 0.20);
    final pB = Offset(w * 0.14, h * 0.78);
    final pC = Offset(w * 0.86, h * 0.78);

    // Concurrent point O
    final pO = Offset(w * 0.48, h * 0.54);

    final pD = Offset(w * 0.48, h * 0.78); // on BC
    final pE = Offset(w * 0.67, h * 0.49); // on CA
    final pF = Offset(w * 0.31, h * 0.49); // on AB

    // STEP 1: Triangle ABC
    final tPath = Path()..moveTo(pA.dx, pA.dy)..lineTo(pB.dx, pB.dy)..lineTo(pC.dx, pC.dy)..close();
    canvas.drawPath(tPath, Paint()..color = themeColor.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(tPath, Paint()..color = Colors.white..strokeWidth = 2.2..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C', alignRight: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Construct Triangle ABC Framework', Offset(w * 0.20, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Three concurrent cevians meeting at O
    final cevPaint = Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 1.8;
    canvas.drawLine(pA, pD, cevPaint);
    canvas.drawLine(pB, pE, cevPaint);
    canvas.drawLine(pC, pF, cevPaint);

    _drawPointWithLabel(canvas, pO, 'O', alignRight: true, pointColor: Colors.amberAccent);
    _drawPointWithLabel(canvas, pD, 'D', alignBottom: true, pointColor: const Color(0xFF38BDF8));
    _drawPointWithLabel(canvas, pE, 'E', alignRight: true, pointColor: const Color(0xFF38BDF8));
    _drawPointWithLabel(canvas, pF, 'F', alignLeft: true, pointColor: const Color(0xFF38BDF8));

    if (step < 3) {
      _drawText(canvas, 'Step 2: Three Cevians AD, BE, CF Concur at Point O', Offset(w * 0.12, h * 0.90), color: const Color(0xFF38BDF8), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Segments labeled
    _drawText(canvas, 'AF', Offset(w * 0.36, h * 0.34), color: Colors.amberAccent, fontSize: 9.5, bold: true);
    _drawText(canvas, 'FB', Offset(w * 0.18, h * 0.62), color: Colors.amberAccent, fontSize: 9.5, bold: true);
    _drawText(canvas, 'BD', Offset(w * 0.28, pB.dy + 6), color: Colors.amberAccent, fontSize: 9.5, bold: true);
    _drawText(canvas, 'DC', Offset(w * 0.64, pB.dy + 6), color: Colors.amberAccent, fontSize: 9.5, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Label Six Segments Formed on the Sides', Offset(w * 0.16, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: Cyclic product
    if (step == 4) {
      _drawText(canvas, 'Step 4: Go Cyclically: (AF/FB) × (BD/DC) × (CE/EA) = 1', Offset(w * 0.10, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 5: Banner
    _drawText(canvas, '(AF/FB) × (BD/DC) × (CE/EA) = 1  |  Ceva\'s Theorem', Offset(w * 0.10, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // Concept 13: Thales Theorem (Basic Proportionality Theorem)
  void _drawThalesTheorem(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pA = Offset(w * 0.50, h * 0.20);
    final pB = Offset(w * 0.15, h * 0.78);
    final pC = Offset(w * 0.85, h * 0.78);

    // Parallel line DE
    final pD = Offset(w * 0.36, h * 0.49);
    final pE = Offset(w * 0.64, h * 0.49);

    // STEP 1: Triangle ABC
    final tPath = Path()..moveTo(pA.dx, pA.dy)..lineTo(pB.dx, pB.dy)..lineTo(pC.dx, pC.dy)..close();
    canvas.drawPath(tPath, Paint()..color = themeColor.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(tPath, Paint()..color = Colors.white..strokeWidth = 2.2..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C', alignRight: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Construct Triangle ABC Framework', Offset(w * 0.20, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Line DE ∥ BC
    final dePaint = Paint()
      ..color = step == 2 ? const Color(0xFF10B981).withValues(alpha: 0.85 + 0.15 * pulse) : const Color(0xFF10B981)
      ..strokeWidth = step == 2 ? 3.4 : 2.4;
    canvas.drawLine(pD, pE, dePaint);
    _drawPointWithLabel(canvas, pD, 'D', alignLeft: true, pointColor: const Color(0xFF10B981));
    _drawPointWithLabel(canvas, pE, 'E', alignRight: true, pointColor: const Color(0xFF10B981));

    // Parallel arrows
    _drawParallelArrow(canvas, Offset((pD.dx + pE.dx) / 2, pD.dy), Paint()..color = const Color(0xFF10B981)..strokeWidth = 1.8..style = PaintingStyle.stroke);
    _drawParallelArrow(canvas, Offset((pB.dx + pC.dx) / 2, pB.dy), Paint()..color = Colors.white70..strokeWidth = 1.8..style = PaintingStyle.stroke);

    if (step < 3) {
      _drawText(canvas, 'Step 2: Draw Line Segment DE Parallel to Base BC (DE ∥ BC)', Offset(w * 0.08, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Segments AD, DB, AE, EC
    _drawText(canvas, 'AD', Offset(w * 0.38, h * 0.34), color: Colors.amberAccent, fontSize: 10, bold: true);
    _drawText(canvas, 'DB', Offset(w * 0.20, h * 0.64), color: Colors.amberAccent, fontSize: 10, bold: true);
    _drawText(canvas, 'AE', Offset(w * 0.58, h * 0.34), color: Colors.amberAccent, fontSize: 10, bold: true);
    _drawText(canvas, 'EC', Offset(w * 0.76, h * 0.64), color: Colors.amberAccent, fontSize: 10, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Corresponding Equal Angles: ∠ADE = ∠B, ∠AED = ∠C', Offset(w * 0.06, h * 0.90), color: Colors.amberAccent, fontSize: 10, bold: true);
      return;
    }

    // STEP 4: BPT Ratio
    if (step == 4) {
      _drawText(canvas, 'Step 4: Thales BPT: AD / DB = AE / EC  |  DE / BC = AD / AB', Offset(w * 0.08, h * 0.90), color: const Color(0xFF10B981), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 5: Banner
    _drawText(canvas, 'AD/DB = AE/EC  |  DE/BC = AD/AB  |  Area(ADE)/Area(ABC) = (AD/AB)²', Offset(w * 0.04, h * 0.90), color: Colors.white, fontSize: 9.5, bold: true);
  }

  // Concept 14: Stewart\'s Theorem
  void _drawStewartTheorem(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pC = Offset(w * 0.48, h * 0.20);
    final pB = Offset(w * 0.14, h * 0.78);
    final pA = Offset(w * 0.86, h * 0.78);
    final pD = Offset(w * 0.40, h * 0.78); // Cevian foot

    // STEP 1: Triangle ABC
    final tPath = Path()..moveTo(pC.dx, pC.dy)..lineTo(pB.dx, pB.dy)..lineTo(pA.dx, pA.dy)..close();
    canvas.drawPath(tPath, Paint()..color = themeColor.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(tPath, Paint()..color = Colors.white..strokeWidth = 2.2..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pC, 'C', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pA, 'A', alignRight: true);

    _drawText(canvas, 'a', Offset((pB.dx + pC.dx) / 2 - 16, (pB.dy + pC.dy) / 2), color: Colors.cyanAccent, fontSize: 11, bold: true);
    _drawText(canvas, 'b', Offset((pA.dx + pC.dx) / 2 + 10, (pA.dy + pC.dy) / 2), color: Colors.cyanAccent, fontSize: 11, bold: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Construct Triangle ABC With Sides a, b, c', Offset(w * 0.16, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Cevian CD = x
    final cevPaint = Paint()..color = const Color(0xFFEC4899)..strokeWidth = 2.4;
    canvas.drawLine(pC, pD, cevPaint);
    _drawPointWithLabel(canvas, pD, 'D', alignBottom: true, pointColor: const Color(0xFFEC4899));
    _drawText(canvas, 'x', Offset(pD.dx + 6, (pC.dy + pD.dy) / 2), color: const Color(0xFFEC4899), fontSize: 11, bold: true);

    if (step < 3) {
      _drawText(canvas, 'Step 2: Draw Arbitrary Cevian CD of Length x to Base AB', Offset(w * 0.08, h * 0.90), color: const Color(0xFFEC4899), fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Segments m and n
    _drawText(canvas, 'm (BD)', Offset((pB.dx + pD.dx) / 2 - 10, pB.dy + 8), color: Colors.amberAccent, fontSize: 10.5, bold: true);
    _drawText(canvas, 'n (DA)', Offset((pD.dx + pA.dx) / 2 - 10, pB.dy + 8), color: Colors.amberAccent, fontSize: 10.5, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Base Divided into Segments m and n (c = m + n)', Offset(w * 0.10, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 4: Mnemonic
    if (step == 4) {
      _drawText(canvas, 'Step 4: Mnemonic: a²n + b²m = x²c + mnc (man + dad = bmb + cnc)', Offset(w * 0.04, h * 0.90), color: Colors.amberAccent, fontSize: 9.5, bold: true);
      return;
    }

    // STEP 5: Banner
    _drawText(canvas, 'a²n + b²m = x²c + mnc  |  Isosceles: x² = a² − mn', Offset(w * 0.10, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // Concept 15: British Flag Theorem
  void _drawBritishFlag(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pA = Offset(w * 0.15, h * 0.22);
    final pB = Offset(w * 0.85, h * 0.22);
    final pC = Offset(w * 0.85, h * 0.78);
    final pD = Offset(w * 0.15, h * 0.78);

    final pP = Offset(w * 0.62, h * 0.52); // Point P inside

    // STEP 1: Rectangle ABCD
    final rectPath = Path()..moveTo(pA.dx, pA.dy)..lineTo(pB.dx, pB.dy)..lineTo(pC.dx, pC.dy)..lineTo(pD.dx, pD.dy)..close();
    canvas.drawPath(rectPath, Paint()..color = themeColor.withValues(alpha: 0.08)..style = PaintingStyle.fill);
    canvas.drawPath(rectPath, Paint()..color = Colors.white70..strokeWidth = 2.4..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignTop: true);
    _drawPointWithLabel(canvas, pC, 'C', alignBottom: true);
    _drawPointWithLabel(canvas, pD, 'D', alignBottom: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Construct Rectangle ABCD With 4 Right Angles', Offset(w * 0.12, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Interior point P
    _drawPointWithLabel(canvas, pP, 'P', alignTop: true, pointColor: Colors.amberAccent);

    if (step < 3) {
      _drawText(canvas, 'Step 2: Place Arbitrary Interior Point P', Offset(w * 0.22, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: PA and PC (Cyan rays)
    final cyanPaint = Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 2.4;
    canvas.drawLine(pP, pA, cyanPaint);
    canvas.drawLine(pP, pC, cyanPaint);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Connect Point P to Opposite Corners A and C (PA, PC)', Offset(w * 0.08, h * 0.90), color: const Color(0xFF38BDF8), fontSize: 10, bold: true);
      return;
    }

    // STEP 4: PB and PD (Rose rays)
    final rosePaint = Paint()..color = const Color(0xFFF43F5E)..strokeWidth = 2.4;
    canvas.drawLine(pP, pB, rosePaint);
    canvas.drawLine(pP, pD, rosePaint);

    if (step < 5) {
      _drawText(canvas, 'Step 4: Connect Point P to Other Opposite Corners B and D', Offset(w * 0.08, h * 0.90), color: const Color(0xFFF43F5E), fontSize: 10, bold: true);
      return;
    }

    // STEP 5: Banner
    _drawText(canvas, 'PA² + PC² = PB² + PD²  |  British Flag Theorem', Offset(w * 0.12, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // Concept 18: Important Result: Incircle Tangent Lengths
  void _drawIncircleTangents(Canvas canvas, Size size, {int step = 5}) {
    final w = size.width;
    final h = size.height;

    final pA = Offset(w * 0.50, h * 0.20);
    final pB = Offset(w * 0.14, h * 0.78);
    final pC = Offset(w * 0.86, h * 0.78);

    // Tangency points
    final pR = Offset(w * 0.32, h * 0.49); // on AB
    final pQ = Offset(w * 0.68, h * 0.49); // on AC
    final pP = Offset(w * 0.50, h * 0.78); // on BC

    final center = Offset(w * 0.50, h * 0.58);
    final radius = h * 0.20;

    // STEP 1: Triangle ABC
    final tPath = Path()..moveTo(pA.dx, pA.dy)..lineTo(pB.dx, pB.dy)..lineTo(pC.dx, pC.dy)..close();
    canvas.drawPath(tPath, Paint()..color = themeColor.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(tPath, Paint()..color = Colors.white..strokeWidth = 2.2..style = PaintingStyle.stroke);

    _drawPointWithLabel(canvas, pA, 'A', alignTop: true);
    _drawPointWithLabel(canvas, pB, 'B', alignLeft: true);
    _drawPointWithLabel(canvas, pC, 'C', alignRight: true);

    if (step < 2) {
      _drawText(canvas, 'Step 1: Construct Triangle ABC Framework', Offset(w * 0.20, h * 0.90), color: themeColor, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 2: Incircle
    final incPaint = Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 2.0..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, incPaint);

    _drawPointWithLabel(canvas, pR, 'R', alignLeft: true, pointColor: Colors.amberAccent);
    _drawPointWithLabel(canvas, pQ, 'Q', alignRight: true, pointColor: Colors.amberAccent);
    _drawPointWithLabel(canvas, pP, 'P', alignBottom: true, pointColor: Colors.amberAccent);

    if (step < 3) {
      _drawText(canvas, 'Step 2: Incircle Touches Sides at Points R, P, Q', Offset(w * 0.16, h * 0.90), color: Colors.amberAccent, fontSize: 10.5, bold: true);
      return;
    }

    // STEP 3: Equal Tangent Pairs (x, y, z)
    _drawText(canvas, 'x', Offset(w * 0.40, h * 0.32), color: const Color(0xFF10B981), fontSize: 11, bold: true);
    _drawText(canvas, 'x', Offset(w * 0.60, h * 0.32), color: const Color(0xFF10B981), fontSize: 11, bold: true);

    _drawText(canvas, 'y', Offset(w * 0.21, h * 0.64), color: const Color(0xFF38BDF8), fontSize: 11, bold: true);
    _drawText(canvas, 'y', Offset(w * 0.32, pB.dy + 8), color: const Color(0xFF38BDF8), fontSize: 11, bold: true);

    _drawText(canvas, 'z', Offset(w * 0.68, pB.dy + 8), color: const Color(0xFFEC4899), fontSize: 11, bold: true);
    _drawText(canvas, 'z', Offset(w * 0.79, h * 0.64), color: const Color(0xFFEC4899), fontSize: 11, bold: true);

    if (step < 4) {
      _drawText(canvas, 'Step 3: Tangents from Each Vertex Equal: AR=AQ=x, BP=BR=y, CP=CQ=z', Offset(w * 0.04, h * 0.90), color: const Color(0xFF10B981), fontSize: 9.5, bold: true);
      return;
    }

    // STEP 4: Semi-perimeter & Tangent Form
    if (step == 4) {
      _drawText(canvas, 'Step 4: x = s − a, y = s − b, z = s − c  |  Semi-perimeter s = x + y + z', Offset(w * 0.06, h * 0.90), color: const Color(0xFF38BDF8), fontSize: 10, bold: true);
      return;
    }

    // STEP 5: Banner
    _drawText(canvas, 'x = s−a, y = s−b, z = s−c  |  Area Δ = √[(x+y+z)xyz]', Offset(w * 0.08, h * 0.90), color: Colors.white, fontSize: 10.5, bold: true);
  }

  // --- Measured, Non-Overlapping Helper Methods ---
  void _drawPointWithLabel(
    Canvas canvas,
    Offset point,
    String label, {
    bool alignTop = false,
    bool alignBottom = false,
    bool alignLeft = false,
    bool alignRight = false,
    Color pointColor = Colors.white,
  }) {
    // Point circle with pulsating neon glow
    final glowPaint = Paint()
      ..color = pointColor.withValues(alpha: 0.25 + 0.18 * pulse)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(point, 5.0 + 1.8 * pulse, glowPaint);

    final dotPaint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(point, 3.0, dotPaint);

    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: pointColor,
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        fontFamily: 'sans-serif',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    double dx = point.dx - textPainter.width / 2;
    double dy = point.dy;

    if (alignTop) {
      dy = point.dy - textPainter.height - 6;
    } else if (alignBottom) {
      dy = point.dy + 6;
    } else {
      dy = point.dy - textPainter.height / 2;
    }

    if (alignLeft) {
      dx = point.dx - textPainter.width - 7;
    } else if (alignRight) {
      dx = point.dx + 7;
    }

    textPainter.paint(canvas, Offset(dx, dy));
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    Color color = Colors.white,
    double fontSize = 11,
    bool bold = false,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
        fontFamily: 'sans-serif',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }
}
