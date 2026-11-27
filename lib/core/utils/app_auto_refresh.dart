import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/categories/category_cubit.dart';
import '../../logic/products/product_cubit.dart';
import '../../logic/subcategories/subcategory_cubit.dart';

// تحديث المنتجات والاقسام والفئات بالخلفية كل 10 دقائق
class AppAutoRefresh extends StatefulWidget {
  final Widget child;
  final Duration interval;

  const AppAutoRefresh({
    super.key,
    required this.child,
    this.interval = const Duration(minutes: 10),
  });

  @override
  State<AppAutoRefresh> createState() => _AppAutoRefreshState();
}

class _AppAutoRefreshState extends State<AppAutoRefresh> with WidgetsBindingObserver {
  Timer? _timer;
  DateTime _lastRun = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (_) => _refresh());
  }

  // عند الرجوع للتطبيق بعد غياب طويل نحدث فورا
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      if (DateTime.now().difference(_lastRun) >= widget.interval) _refresh();
      _start();
    }
  }

  void _refresh() {
    if (!mounted) return;
    _lastRun = DateTime.now();
    context.read<CategoryCubit>().getCategories(silent: true);
    context.read<SubcategoryCubit>().refreshSilently();
    context.read<ProductCubit>().refreshSilently();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
