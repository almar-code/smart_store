import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../data/models/country_model.dart';
import '../constants/app_endpoints.dart';

class CountryPickerBottomSheet extends StatefulWidget {
  final List<CountryModel> countries;
  final Function(CountryModel) onSelect;

  const CountryPickerBottomSheet({
    super.key,
    required this.countries,
    required this.onSelect,
  });

  @override
  State<CountryPickerBottomSheet> createState() =>
      _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<CountryPickerBottomSheet> {
  final TextEditingController searchController = TextEditingController();
  List<CountryModel> filteredCountries = [];

  @override
  void initState() {
    super.initState();
    filteredCountries = widget.countries;
  }

  void onSearch(String value) {
    setState(() {
      filteredCountries = widget.countries.where((country) {
        return country.nameAr.contains(value) ||
            country.nameEn.toLowerCase().contains(value.toLowerCase()) ||
            country.dialCode.contains(value);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: onSearch,
              decoration: const InputDecoration(
                hintText: 'ابحث عن دولة',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = filteredCountries[index];

                  return ListTile(
                    leading: Text(country.flag,style: TextStyle(fontSize: 20),),
                    title: Text(
                      context.locale.languageCode == 'ar' ? country.nameAr : country.nameEn,
                    ),
                    subtitle: Text(country.dialCode),
                    onTap: () {
                      widget.onSelect(country);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}