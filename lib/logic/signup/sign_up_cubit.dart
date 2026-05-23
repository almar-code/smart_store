import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpCubit extends Cubit<int> {
  SignUpCubit() : super(0);

  void next() {
    emit(state + 1);
  }

  void previous() {
    if (state > 0) {
      emit(state - 1);
    }
  }
  void remove() {
    emit(0);
  }
}