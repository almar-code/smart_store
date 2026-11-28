import '../../data/models/saved_size_model.dart';

class SavedSizesState {
  final List<SavedSizeModel> items;
  final String? openId; // البطاقة المفتوحة حالياً

  const SavedSizesState({this.items = const [], this.openId});

  SavedSizesState copyWith({List<SavedSizeModel>? items, String? openId, bool clearOpen = false}) {
    return SavedSizesState(
      items: items ?? this.items,
      openId: clearOpen ? null : (openId ?? this.openId),
    );
  }
}
