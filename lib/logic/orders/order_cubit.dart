import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/user_local.dart';
import '../../data/repos/order_repo.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepo repo;
  Future<int?> _customerId() => UserLocal().getCustomerId();
  OrderCubit(this.repo) : super(OrderInitial());

  Future<void> fetchOrders() async {
    emit(OrderLoading());
    try {
      final orders = await repo.getOrders( await _customerId());
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> cancelOrder(int orderId, int customerId) async {
    try {
      await repo.cancelOrder(orderId);
      fetchOrders(); // تحديث القائمة بعد الإلغاء
    } catch (e) {
      emit(OrderError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}