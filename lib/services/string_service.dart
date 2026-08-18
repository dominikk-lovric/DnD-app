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

  static String choicesFromString(List<dynamic> list, String end) {
    String res = "";
    for (int i = 0; i < list.length; i++) {
      res += list[i].toString();
      if (i != list.length - 1 || i != list.length - 2) {
        res += ", ";
      } else if (i != list.length - 2) {
        res += " " + end + " ";
      }
    }
    return res;
  }
}
