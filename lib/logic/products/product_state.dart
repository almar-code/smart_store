// cubit/product_state.dart
import '../../data/models/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}
class ProductLoading extends ProductState {}
class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final bool hasMore;
  ProductLoaded({required this.products, required this.hasMore});
}
class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
class AllProductsUnfilteredInitial extends ProductState {}
class AllProductsUnfilteredLoading extends ProductState {}
class AllProductsUnfilteredLoaded extends ProductState {
  final List<ProductModel> products;
  AllProductsUnfilteredLoaded({required this.products});
}
class AllProductsUnfilteredError extends ProductState {
  final String message;
  AllProductsUnfilteredError(this.message);
}