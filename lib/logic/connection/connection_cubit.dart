import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/network_service.dart';

// checking: الفحص الأول عند فتح التطبيق (بدون طبقة)
// offline: لا يوجد إنترنت | retrying: إعادة الفحص من زر التحديث
enum ConnectionStatus { checking, online, offline, retrying }

class ConnectionCubit extends Cubit<ConnectionStatus> {
  ConnectionCubit() : super(ConnectionStatus.checking);

  // ترجع true إذا كان الاتصال متوفراً
  Future<bool> check() async {
    emit(state == ConnectionStatus.offline
        ? ConnectionStatus.retrying
        : ConnectionStatus.checking);

    final bool connected = await NetworkService.hasInternet();
    emit(connected ? ConnectionStatus.online : ConnectionStatus.offline);

    return connected;
  }
}
