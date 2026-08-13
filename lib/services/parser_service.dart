import 'package:flutter/services.dart';

class ParserService {
  static const Map<String, String> modifiers = {
    "strMod": "Strength modifier",
    "dexMod": "Dexterity modifier",
    "conMod": "Constitution modifier",
    "intMod": "Intelligence modifier",
    "wisMod": "Wisdom modifier",
    "chaMod": "Charisma modifier",
    "proficiencyBonus": "Proficiency bonus",
    "all": "All",
  };

  static String getModifier(String text) {
    return modifiers[text] ?? "";
  }

  static String getCondition(String conditionName) {
    return conditionName
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        )
        .replaceFirstMapped(
          RegExp(r'^[a-z]'),
          (match) => match.group(0)!.toUpperCase(),
        );
  }
}
