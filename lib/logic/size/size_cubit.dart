// logic/products/dialog_size_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart'; // تأكد من مسار الموديل لديك

// الحالة هنا عبارة عن كائن SizeModel يقبل أن يكون null في البداية
class DialogSizeCubit extends Cubit<SizeModel?> {
  // الحالة الابتدائية هي null (لا يوجد مقاس مختار عند الفتح)
  DialogSizeCubit() : super(null);

  // دالة لتحديث المقاس المختار
  void selectSize(SizeModel size) {
    emit(size);
  }
}