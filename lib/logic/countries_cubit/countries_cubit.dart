import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/country_model.dart';
import '../../data/repos/country_repo.dart';

class CountriesCubit extends Cubit<int> {
  final CountryRepo repo;
  CountriesCubit(this.repo) : super(0);

  List<CountryModel> countries = [];
  CountryModel? selectedCountry;
  bool isLoading = false;

  Future<void> loadCountries(BuildContext context) async {
    try {
      isLoading = true;
      emit(state + 1);

      // جلب البيانات محلياً من الـ Repo المحدث
      countries = await repo.getCountries(context);

      if (countries.isNotEmpty) {
        if (selectedCountry != null) {
          selectedCountry = countries.firstWhere(
                (c) => c.dialCode == selectedCountry!.dialCode,
            orElse: () => countries.first,
          );
        } else {
          try {
            selectedCountry = countries.firstWhere((c) => c.dialCode == '+967');
          } catch (_) {
            selectedCountry = countries.first;
          }
        }
      }
      isLoading = false;
      emit(state + 1);
    } catch (e) {
      isLoading = false;
      emit(state + 1);
      print('CountriesCubit Error: $e');
    }
  }

  void selectCountry(CountryModel country) {
    selectedCountry = country;
    emit(state + 1);
  }
}