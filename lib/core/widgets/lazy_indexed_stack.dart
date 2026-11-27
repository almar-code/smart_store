import 'package:flutter/material.dart';

// مثل IndexedStack لكن لا يبني الصفحة الا عند اول زيارة لها
// الصفحات في preload تبنى من البداية مع فتح التطبيق
class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Set<int> preload;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.preload = const {},
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  // الصفحات المبنية
  late final Set<int> _visited = {...widget.preload};

  @override
  Widget build(BuildContext context) {
    _visited.add(widget.index);
    return IndexedStack(
      index: widget.index,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _visited.contains(i) ? widget.children[i] : const SizedBox.shrink(),
      ],
    );
  }
}