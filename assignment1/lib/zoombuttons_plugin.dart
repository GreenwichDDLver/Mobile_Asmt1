import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class FlutterMapZoomButtons extends StatelessWidget {
  final MapController? controller;
  final int minZoom;
  final int maxZoom;
  final bool mini;
  final double padding;
  final Alignment alignment;

  const FlutterMapZoomButtons({
    Key? key,
    this.controller,
    this.minZoom = 4,
    this.maxZoom = 19,
    this.mini = false,
    this.padding = 10,
    this.alignment = Alignment.bottomRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MapController mapController = controller ?? MapController.of(context);

    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "zoomIn",
              mini: mini,
              onPressed: () {
                final zoom = mapController.camera.zoom;
                if (zoom < maxZoom) {
                  mapController.move(mapController.camera.center, zoom + 1);
                }
              },
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: "zoomOut",
              mini: mini,
              onPressed: () {
                final zoom = mapController.camera.zoom;
                if (zoom > minZoom) {
                  mapController.move(mapController.camera.center, zoom - 1);
                }
              },
              child: const Icon(Icons.remove),
            ),
          ],
        ),
      ),
    );
  }
}