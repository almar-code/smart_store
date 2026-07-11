// import 'package:easy_localization/easy_localization.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import '../../logic/countries_cubit/countries_cubit.dart';
// import '../../logic/countries_cubit/countries_state.dart';
// import '../../data/models/country_model.dart';
// import '../constants/app_endpoints.dart';
// import 'app_form_field.dart';
// import 'country_picker_bottom_sheet.dart';
//
// class PhoneNumberField extends StatelessWidget {
//   const PhoneNumberField({super.key});
//
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<CountriesCubit,bool>(
//         builder: (context, state) {
//           final cubit = context.read<CountriesCubit>();
//
//           if (cubit.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           return Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: InkWell(
//                   onTap: () {
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       builder: (_) => FractionallySizedBox(
//                         heightFactor: 0.85,
//                         child: CountryPickerBottomSheet(
//                           countries: state.countries,
//                           onSelect: (country) {
//                             context.read<CountriesCubit>().selectCountry(country);
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     height: 58,
//                     padding: const EdgeInsets.symmetric(horizontal: 5),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade400),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                           width: 30,
//                           height: 15,
//                           child: SvgPicture.network(
//                             ApiEndpoints.countryFlag(selectedCountry?.flag.toLowerCase()),
//                           ),
//                         ),
//                         const SizedBox(width: 3),
//                         Text(
//                           selectedCountry?.dialCode ?? '',
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                         const SizedBox(width: 2),
//                         const Icon(Icons.arrow_drop_down),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 flex: 2,
//                 child: CustomFormField(name: 'phone_number',
//                     keyboardType:TextInputType.phone ,
//                     label: tr('phone_number'),
//                     icon: Icons.phone,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly, // 👈 هذا السطر يمنع كتابة أي شيء عدا الأرقام (0-9)
//                     ],
//                     validators: [FormBuilderValidators.required(
//                         errorText: tr("phone_required_error"),
//                     )],
//                 ),
//               ),
//             ],
//           );
//         }
//
//         return const SizedBox();
//       },
//     );
//   }
// }

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/countries_cubit/countries_cubit.dart';
import '../constants/app_endpoints.dart';
import '../di/injection_container.dart' as di;
import 'app_form_field.dart';
import 'circularProgress.dart';
import 'country_picker_bottom_sheet.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({super.key});

  @override
  Widget build(BuildContext context) {
    return  BlocBuilder<CountriesCubit, int>(
      builder: (context, state) {
        final cubit = context.read<CountriesCubit>();

        if (cubit.isLoading) {
          return const Center(child: CircularProgress(size: 35));
        }

        return InkWell(
              onTap: () {
                if (cubit.countries.isEmpty) return;

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => FractionallySizedBox(
                    heightFactor: 0.85,
                    child: CountryPickerBottomSheet(
                      countries: cubit.countries,
                      onSelect: (country) {
                        context.read<CountriesCubit>().selectCountry(country);
                      },
                    ),
                  ),
                );
              },
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (cubit.selectedCountry != null)
                      Text(
                        cubit.selectedCountry?.flag ?? "",
                        style: TextStyle(fontSize: 20),
                      ),
                    const SizedBox(width: 5),
                    Text(
                      cubit.selectedCountry?.dialCode ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            );
      },
    );
  }
}
