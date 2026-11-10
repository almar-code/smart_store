import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../../logic/live_try_on/live_try_on_cubit.dart';
import '../../../logic/live_try_on/live_try_on_state.dart';
import 'frame/live_try_on_frame.dart';

/// يُركَّب مرة واحدة في MaterialApp.builder ليظهر فوق أي صفحة
class LiveTryOnOverlay extends StatelessWidget {
  final Widget child;

  const LiveTryOnOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        BlocBuilder<LiveTryOnCubit, LiveTryOnState>(
          buildWhen: (prev, curr) => prev.isOpen != curr.isOpen,
          builder: (context, state) =>
              state.isOpen ? const _LiveTryOnPanel() : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// النافذة العائمة: قابلة للتحريك بالسحب والتصغير
class _LiveTryOnPanel extends StatefulWidget {
  const _LiveTryOnPanel();

  @override
  State<_LiveTryOnPanel> createState() => _LiveTryOnPanelState();
}

class _LiveTryOnPanelState extends State<_LiveTryOnPanel> {
  static const double _headerHeight = 40;
  static const double _footerHeight = 54;
  static const double _miniSize = 54;

  Offset? _position;

  void _move(DragUpdateDetails details) {
    setState(() => _position = (_position ?? Offset.zero) + details.delta);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final bool isDesktop = screen.width > 800;
    final double width = isDesktop ? 320 : 230;
    final double videoHeight = width * 4 / 3;
    final double fullHeight = _headerHeight + videoHeight + _footerHeight;

    return BlocBuilder<LiveTryOnCubit, LiveTryOnState>(
      builder: (context, state) {
        final cubit = context.read<LiveTryOnCubit>();
        final bool minimized = state.isMinimized;
        final double panelWidth = minimized ? _miniSize : width;
        final double panelHeight = minimized ? _miniSize : fullHeight;

        // المكان الافتراضي: أسفل الشاشة على الجانب، مع منع خروج النافذة عن الشاشة
        final start = _position ?? Offset(screen.width - width - 16, screen.height - fullHeight - 100);
        final left = start.dx.clamp(0.0, (screen.width - panelWidth).clamp(0.0, double.infinity));
        final top = start.dy.clamp(0.0, (screen.height - panelHeight).clamp(0.0, double.infinity));

        return Positioned(
          left: left,
          top: top,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: panelWidth,
              height: panelHeight,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(minimized ? _miniSize : 12),
                boxShadow: [
                  BoxShadow(color: AppColors.boxShadow, blurRadius: 15, offset: const Offset(0, 5)),
                  ...AppShadow.commonShadow,
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // ⚠️ البث أول عنصر دائماً حتى لا يُعاد إنشاؤه عند التصغير فينقطع الاتصال
                  Positioned(
                    top: minimized ? 0 : _headerHeight,
                    left: 0,
                    width: minimized ? 1 : width,
                    height: minimized ? 1 : videoHeight,
                    child: LiveTryOnFrame(
                      onMessage: cubit.onPageMessage,
                      onCreated: cubit.attachSender,
                      onDisposed: cubit.detachSender,
                    ),
                  ),
                  if (minimized)
                    _MiniButton(state: state, onDrag: _move)
                  else ...[
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: _headerHeight,
                      child: _Header(onDrag: _move),
                    ),
                    Positioned(
                      top: _headerHeight,
                      left: 0,
                      width: width,
                      height: videoHeight,
                      child: _VideoOverlay(state: state),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: _footerHeight,
                      child: _Footer(state: state),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// رأس النافذة: العنوان + تصغير + إغلاق، ومنه تُسحب النافذة لتغيير مكانها
class _Header extends StatelessWidget {
  final GestureDragUpdateCallback onDrag;

  const _Header({required this.onDrag});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LiveTryOnCubit>();

    return GestureDetector(
      onPanUpdate: onDrag,
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: Container(
          color: AppColors.backgroundSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            spacing: 6,
            children: [
              Icon(Icons.checkroom_outlined, size: 18, color: AppColors.primary),
              Expanded(
                child: Text(
                  tr('live_try_on_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textColor, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              InkWell(
                onTap: cubit.toggleMinimize,
                child: Icon(Icons.remove, size: 20, color: AppColors.iconColor),
              ),
              InkWell(
                onTap: cubit.closePanel,
                child: Icon(Icons.close, size: 20, color: AppColors.iconColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ما يظهر فوق منطقة البث: التعليمات، حالة الاتصال، الأخطاء، العداد
class _VideoOverlay extends StatelessWidget {
  final LiveTryOnState state;

  const _VideoOverlay({required this.state});

  @override
  Widget build(BuildContext context) {
    // أثناء البث: العداد فقط في الأعلى
    if (state.isLive) {
      return Align(
        alignment: AlignmentDirectional.topEnd,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.redAccent),
              Text(
                _formatTime(state.remainingSeconds),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    final String messageKey;
    Widget icon;
    if (state.isConnecting) {
      messageKey = 'live_try_on_connecting';
      icon = const ThreeDotsLoader(isSmall: true);
    } else if (state.errorKey != null) {
      messageKey = state.errorKey!;
      icon = Icon(Icons.error_outline, color: AppColors.error, size: 30);
    } else if (!state.hasGarment) {
      messageKey = 'live_try_on_tap_abaya';
      icon = Icon(Icons.touch_app_outlined, color: AppColors.primary, size: 30);
    } else {
      messageKey = 'live_try_on_ready_hint';
      icon = Icon(Icons.videocam_outlined, color: AppColors.primary, size: 30);
    }

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          icon,
          Text(
            tr(messageKey),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// أسفل النافذة: العباية الحالية + زر البدء/الإيقاف
class _Footer extends StatelessWidget {
  final LiveTryOnState state;

  const _Footer({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LiveTryOnCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        spacing: 8,
        children: [
          _GarmentThumb(imageUrl: state.garmentImageUrl, size: 36),
          Expanded(
            child: Text(
              state.garmentName ?? tr('live_try_on_no_abaya'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textColor, fontSize: 12),
            ),
          ),
          SizedBox(
            height: 34,
            child: AppButton(
              label: tr(state.isRunning ? 'live_try_on_stop' : 'live_try_on_start'),
              icon: state.isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
              iconSize: 16,
              fontSize: 12,
              borderRadius: 10,
              color: state.isRunning ? AppColors.redColor : null,
              onTap: state.isRunning ? cubit.stop : cubit.start,
            ),
          ),
        ],
      ),
    );
  }
}

/// الشكل المصغّر: دائرة بصورة العباية، تُسحب لتغيير مكانها وتُفتح بالضغط
class _MiniButton extends StatelessWidget {
  final LiveTryOnState state;
  final GestureDragUpdateCallback onDrag;

  const _MiniButton({required this.state, required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: context.read<LiveTryOnCubit>().toggleMinimize,
        onPanUpdate: onDrag,
        child: Stack(
          alignment: Alignment.center,
          children: [
            state.hasGarment
                ? _GarmentThumb(imageUrl: state.garmentImageUrl, size: 46)
                : Icon(Icons.checkroom_outlined, color: AppColors.primary, size: 24),
            if (state.isLive)
              const PositionedDirectional(
                top: 6,
                end: 6,
                child: Icon(Icons.circle, size: 10, color: Colors.redAccent),
              ),
          ],
        ),
      ),
    );
  }
}

class _GarmentThumb extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const _GarmentThumb({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? Icon(Icons.checkroom_outlined, size: size * 0.5, color: AppColors.iconColor)
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.checkroom_outlined, size: size * 0.5, color: AppColors.iconColor),
            ),
    );
  }
}

String _formatTime(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
