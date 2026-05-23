class CommentModel {

  final int id;
  final String commentText;
  final String customerName;
  final String? customerImage;
  final int videoId;
  final String createdAt;
  final bool isSending;

  CommentModel({
    required this.id,
    required this.commentText,
    required this.customerName,
    this.customerImage,
    required this.videoId,
    required this.createdAt,
    this.isSending = false,
  });

  factory CommentModel.fromJson(
      Map<String, dynamic> json) {

    return CommentModel(

      id: int.parse(
        json['id'].toString(),
      ),

      commentText:
      json['commentText'] ?? '',

      customerName:
      json['customerName'] ?? '',

      customerImage:
      json['customerImage'],

      videoId: int.parse(
        json['videoId'].toString(),
      ),

      createdAt:
      json['createdAt'] ?? '',

      isSending: false,
    );
  }
}