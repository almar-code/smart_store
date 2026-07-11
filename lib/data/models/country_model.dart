import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

class CountryModel {
  final String nameAr;
  final String nameEn;
  final String dialCode;
  final String flag;
  final String countryCode;

  CountryModel({
    required this.nameAr,
    required this.nameEn,
    required this.dialCode,
    required this.flag,
    required this.countryCode,
  });

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
    );
  }
}