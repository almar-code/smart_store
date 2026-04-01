import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(2); // الصفحة الافتراضية هي الأولى (Home)
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  void updateIndex(int index) => emit(index);
  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }
}