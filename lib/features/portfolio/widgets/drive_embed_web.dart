import 'dart:js_interop';
import 'dart:math' as math;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Drive's player has a minimum layout width, so the iframe is always laid
/// out on a phone-sized canvas and scaled down with plain CSS to fit whatever
/// space the mockup gives it. (Scaling with a Flutter transform shifts platform
/// views on web, which is why the video looked cropped.)
const double _canvasWidth = 400;
const double _canvasHeight = 844;

final Set<String> _registered = <String>{};

/// Google Drive's own player inside an iframe. The file must be shared as
/// "Anyone with the link" or Drive shows an access-request page instead.
Widget buildDriveEmbed(String fileId, String openUrl) {
  final viewType = 'drive-embed-$fileId';

  if (_registered.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = 'https://drive.google.com/file/d/$fileId/preview'
        ..allow = 'autoplay; fullscreen'
        ..style.border = 'none'
        ..style.position = 'absolute'
        ..style.width = '${_canvasWidth}px'
        ..style.height = '${_canvasHeight}px'
        ..style.transformOrigin = '0 0';

      final box = web.HTMLDivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.position = 'relative'
        ..style.overflow = 'hidden'
        ..appendChild(iframe);

      void fit() {
        final w = box.clientWidth.toDouble();
        final h = box.clientHeight.toDouble();
        if (w <= 0 || h <= 0) return;
        final k = math.min(w / _canvasWidth, h / _canvasHeight);
        iframe.style
          ..transform = 'scale($k)'
          ..left = '${(w - _canvasWidth * k) / 2}px'
          ..top = '${(h - _canvasHeight * k) / 2}px';
      }

      final observer = web.ResizeObserver(
        ((JSAny entries, JSAny source) => fit()).toJS,
      );
      observer.observe(box);

      return box;
    });
  }

  return HtmlElementView(viewType: viewType);
}
