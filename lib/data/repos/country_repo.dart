import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import '../models/country_model.dart';

class CountryRepo {

  Future<List<CountryModel>> getCountries(BuildContext context) async {
    final List<Country> allCountries = CountryService().getAll();

    final List<CountryModel> countries = allCountries.map<CountryModel>((country) {
      return CountryModel.fromPackage(country, context);
    }).toList();

    final String currentLang = Localizations.localeOf(context).languageCode;
    countries.sort((a, b) => currentLang == 'ar'
        ? a.nameAr.compareTo(b.nameAr)
        : a.nameEn.compareTo(b.nameEn));

    return countries;
  }
}