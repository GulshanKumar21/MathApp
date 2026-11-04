import 'package:flutter/foundation.dart';

/// Represents a single road/arm branching out from the central number in a Chauraha.
@immutable
class ChaurahaBranch {
  final String label; // e.g. "12 × 9" or "× 12 = 300"
  final int factorA;
  final int factorB;
  final int product;
  final String? badge; // e.g. "Cube of 6", "Square of 12", "Base 25"
  final bool isBaseFormat; // If true: center is 25, label shows multiplier & result

  const ChaurahaBranch({
    required this.label,
    required this.factorA,
    required this.factorB,
    required this.product,
    this.badge,
    this.isBaseFormat = false,
  });
}

/// A practice question with exactly 4 options where EXACTLY 2 OPTIONS ARE CORRECT.
/// The user must select both correct options before advancing.
@immutable
class ChaurahaQuestion {
  final String id;
  final String prompt; // e.g. "Which 2 pairs multiply to give 108?"
  final int target; // e.g. 108
  final List<String> options; // Exactly 4 options
  final List<int> correctIndices; // Exactly 2 indices, e.g. [0, 2]
  final String explanation; // Explanation showing both correct pairs

  const ChaurahaQuestion({
    required this.id,
    required this.prompt,
    required this.target,
    required this.options,
    required this.correctIndices,
    required this.explanation,
  });
}

/// Represents a complete "Important Product Chauraha" (Crossways of Multiplications)
/// as featured in standard SSC/Banking calculation mastery curriculum.
@immutable
class ProductChaurahaModel {
  final String id;
  final String title;
  final String subtitle;
  final int targetNumber;
  final bool isBaseFormat; // e.g. Base 25 crossroads
  final int? baseNumber;
  final String primeFactorization;
  final String examTip;
  final ChaurahaBranch topBranch;
  final ChaurahaBranch bottomBranch;
  final ChaurahaBranch leftBranch;
  final ChaurahaBranch rightBranch;
  final ChaurahaBranch? extraBranch1;
  final ChaurahaBranch? extraBranch2;
  final List<String> allFactorPairs;
  final List<ChaurahaQuestion> questions;

  const ProductChaurahaModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.targetNumber,
    this.isBaseFormat = false,
    this.baseNumber,
    required this.primeFactorization,
    required this.examTip,
    required this.topBranch,
    required this.bottomBranch,
    required this.leftBranch,
    required this.rightBranch,
    this.extraBranch1,
    this.extraBranch2,
    required this.allFactorPairs,
    required this.questions,
  });
}
