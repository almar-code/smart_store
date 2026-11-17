import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// التحقق من الأرقام حسب بيانات جوجل، بالاسم المختصر pn لتجنب تعارض الأسماء
import 'package:phone_numbers_parser/phone_numbers_parser.dart' as pn;

class CountryModel {
  final String nameAr;
  final String nameEn;
  final String dialCode;
  final String flag;
  final String countryCode;
  // رقم مثال للدولة، نأخذ منه عدد الأرقام
  final String example;

  CountryModel({
    required this.nameAr,
    required this.nameEn,
    required this.dialCode,
    required this.flag,
    required this.countryCode,
    this.example = '',
  });

  // عدد أرقام الجوال للدولة
  int get maxDigits => example.isEmpty ? 15 : example.length;

  // دول أرقامها تبدأ بصفر فعلا
  bool get keepsLeadingZero => example.startsWith('0');

  // أرقام فقط، بدون الصفر الأول، وبحد عدد أرقام الدولة
  TextInputFormatter get phoneFormatter => TextInputFormatter.withFunction((oldValue, newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (!keepsLeadingZero) digits = digits.replaceFirst(RegExp(r'^0+'), '');
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  });

  // الرقم صحيح إذا طوله نفس عدد أرقام الدولة
  bool isValidPhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    return example.isEmpty ? digits.length >= 6 : digits.length == maxDigits;
  }

  // رقم جوال صحيح لهذه الدولة، يشمل بدايات الشركات وعدد الأرقام
  bool isValidMobile(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return false;

    final iso = _isoCode;
    // دولة غير معروفة للمكتبة نكتفي بعدد الأرقام
    if (iso == null) return isValidPhone(value);

    try {
      final phone = pn.PhoneNumber.parse(digits, destinationCountry: iso);
      return phone.isValid(type: pn.PhoneNumberType.mobile);
    } catch (_) {
      return false;
    }
  }

  pn.IsoCode? get _isoCode {
    try {
      return pn.IsoCode.values.byName(countryCode.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  // الرقم بالصيغة الدولية
  String fullPhone(String value) => '$dialCode${value.replaceAll(RegExp(r'\D'), '')}';

  factory CountryModel.fromPackage(Country country, BuildContext context) {

    String displayNameAr = CountryLocalizations.of(context)?.countryName(
      countryCode: country.countryCode,
    ) ?? country.name;

    return CountryModel(
      countryCode: country.countryCode,
      nameEn: country.name,
      nameAr: displayNameAr,
      dialCode: country.phoneCode.startsWith('+') ? country.phoneCode : '+${country.phoneCode}',
      flag: country.flagEmoji,
      example: country.example.replaceAll(RegExp(r'\D'), ''),
    );
  }
}