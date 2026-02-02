import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

class WebMapWidget extends StatelessWidget {
  const WebMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const String viewId = 'google-map-iframe';

    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) => html.IFrameElement()
        ..src =
            'https://www.google.com/maps?q=19.432608,-99.133209&z=15&output=embed'
        ..style.border = '0'
        ..width = '100%'
        ..height = '100%',
    );

    return const HtmlElementView(viewType: viewId);
  }
}
