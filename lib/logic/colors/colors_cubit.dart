import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart';

// الحالة تخزن كائن اللون النشط حالياً بداخل القائمة
class DialogProductCubit extends Cubit<ColorModel> {
  DialogProductCubit(ColorModel initialColor) : super(initialColor);

  // دالة لتغيير اللون المختار عند الضغط عليه
  void selectColor(ColorModel color) {
    emit(color);
  }
}