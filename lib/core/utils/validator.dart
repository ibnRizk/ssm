import 'values/strings.dart';

abstract class Validator {
  static String? call({required String? value, required ValidatorType type}) {
    String? validateNotEmpty = _notEmpty(value);
    if (validateNotEmpty == null) {
      return type.condition.call(value!) ?? validateNotEmpty;
    }
    return validateNotEmpty;
  }

  static String? _notEmpty(String? value) {
    if (value != null && value.trim().isEmpty) {
      return Strings.fieldRequired;
    }
    return null;
  }

  static String? _name(String value) {
    if (value.trim().split(' ').length < 2) {
      return Strings.invalidName;
    }
    return null;
  }

  // static String? _phone(String value) {
  //   const pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
  //   final regExp = RegExp(pattern);
  //   if (!regExp.hasMatch(value)) {
  //     return Strings.invalidPhone;
  //   }
  //   return null;
  // }

  static String? _phone(String value) {
    // Remove spaces and dashes for basic digit length check
    final cleaned = value.replaceAll(RegExp(r'\D'), '');

    // Require at least 8 digits (can adjust to 10+ if needed)
    if (cleaned.length < 8) {
      return Strings.invalidPhone;
    }

    // Basic phone number regex allowing +, (), -, spaces
    const pattern = r'^\+?[0-9\s\-\(\)]{8,20}$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(value)) {
      return Strings.invalidPhone;
    }

    return null;
  }

  static String? _email(String value) {
    const pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return Strings.invalidEmail;
    }
    return null;
  }

  static String? _numbersOnly(String value) {
    final int? number = int.tryParse(value);
    if (number == null) {
      return Strings.invalidNumbers;
    }
    return null;
  }

  static String? _password(String value) {
    // const pattern =
    //     r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    // final regExp = RegExp(pattern);
    // if (!regExp.hasMatch(value)) {
    //   return Strings.passwordTooShort;
    // }
    // return null;

    value = value.trim();
    // if (value.length < 6) return TranslationBase.of(context).passwordValidate;
    if (value.length < 6) return Strings.passwordTooShort;

    return null;
  }

  static String? _confirmPassword(String value, String? password) {
    final String? notEmptyPassword = _notEmpty(password);
    if (notEmptyPassword != null) {
      if (value != password) {
        return Strings.passwordsDoNotMatch;
      }
    }
    return null;
  }
}

enum ValidatorType {
  standard,
  name,
  email,
  phone,
  numbersOnly,
  password,
  confirmPassword,
}

extension ValidatorTypeExtension on ValidatorType {
  get condition {
    switch (this) {
      case ValidatorType.standard:
        return Validator._notEmpty;
      case ValidatorType.name:
        return Validator._name;
      case ValidatorType.email:
        return Validator._email;
      case ValidatorType.phone:
        return Validator._phone;
      case ValidatorType.numbersOnly:
        return Validator._numbersOnly;
      case ValidatorType.password:
        return Validator._password;
      case ValidatorType.confirmPassword:
        return Validator._confirmPassword;
    }
  }
}
