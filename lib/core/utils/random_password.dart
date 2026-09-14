import 'dart:developer' as log;
import 'dart:math';

import '/core/utils/string_extension.dart';

class RandomPassword {
  // A list of special characters, numbers, and uppercase letters.

  static const _characters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  static const _num = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  static const _specialChar = ['@', '#', '%', '&', '*'];

  // Generate a random word that starts with a capital letter and consists of special characters and numbers.
  static String generateWord() {
    // Create an empty string to store the word.

    String word = '';

    String num = '';
    final random = Random();
    // Generate a random uppercase letter and append it to the word.
    String specialChar = _specialChar[random.nextInt(_specialChar.length)];

    // Generate 4 more random num and append them to the word.

    for (int i = 0; i < 4; i++) {
      num += _num[random.nextInt(_num.length)];
    }

    // Generate 4 more random characters and append them to the word.
    for (int i = 0; i < 4; i++) {
      word += _characters[random.nextInt(_characters.length)].toLowerCase();
    }
    var password = '${word.toCapitalized()}$specialChar$num';
    log.log(password.toString());
    return password;
  }
}
