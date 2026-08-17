import 'package:flutter/services.dart';

class StringService {
  static String CapitalizeWord(String word) {
    return word[0].toUpperCase() + word.substring(1);
  }

  static String capitalizeWords(String text, [String split = " "]) {
    List<String> words = text.split(split);
    for (int i = 0; i < words.length; i++) {
      words[i] = CapitalizeWord(words[i]);
    }
    return words.join(split);
  }
}
