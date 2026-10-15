import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/order_repo.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepo repo;

  OrderCubit(this.repo) : super(OrderInitial());

  Future<void> fetchOrders(int customerId) async {
    emit(OrderLoading());
    try {
      final orders = await repo.getOrders(customerId);
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> cancelOrder(int orderId, int customerId) async {
    try {
      await repo.cancelOrder(orderId);
      fetchOrders(customerId); // تحديث القائمة بعد الإلغاء
    } catch (e) {
      emit(OrderError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}