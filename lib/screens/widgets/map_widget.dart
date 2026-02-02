import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'map_widget_mobile.dart';
import 'map_widget_web.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebMapWidget();
    } else {
      return const MobileMapWidget();
    }
  }
}
