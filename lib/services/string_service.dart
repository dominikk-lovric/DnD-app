import 'package:flutter/services.dart';

class StringService {
  static String CapitalizeWord(String word) {
    return word[0].trim().toUpperCase() + word.substring(1);
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

  static String titleFromKey(String key) {
    int last = 0;
    String res = "";
    for (int i = 0; i < key.length; i++) {
      if (key[i].toUpperCase() == key[i] &&
          key[i].toLowerCase() != key[i] &&
          i != 0) {
        res += CapitalizeWord(key.substring(last, i)) + " ";
        last = i;
      }
    }
    res += CapitalizeWord(key.substring(last, key.length));
    return res;
  }
}
