import 'package:flutter/material.dart';

import 'circularProgress.dart';

class ShowLoading {
 static void progressLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgress(size: 35,)),
    );
  }
}