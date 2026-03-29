import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0); // الصفحة الافتراضية هي الأولى (Home)

  void updateIndex(int index) => emit(index);
}