import '../../data/models/product_comment_model.dart';

abstract class ProductCommentState {}

class ProductCommentInitial extends ProductCommentState {}

class ProductCommentLoading extends ProductCommentState {}

class ProductCommentLoaded extends ProductCommentState {
  final List<ProductCommentModel> comments;
  ProductCommentLoaded(this.comments);
}

class ProductCommentError extends ProductCommentState {
  final String message;
  ProductCommentError(this.message);
}