import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart' as PM;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';

class MapDetailPage extends StatefulWidget {
  final int mapIndex;
  const MapDetailPage({Key? key, required this.mapIndex}) : super(key: key);

  @override
  State<MapDetailPage> createState() => _MapDetailPageState();
}

class _MapDetailPageState extends State<MapDetailPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  final GlobalKey _boundaryKey = GlobalKey();

  bool _locationGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    final status = await Permission.location.request();
    setState(() {
      _locationGranted = status == PermissionStatus.granted;
    });
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(localization.translate('location_permission_required_title')),
            content: Text(localization.translate('location_permission_required_content')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localization.translate('ok_button')),
              ),
              TextButton(
                onPressed: () => openAppSettings(),
                child: Text(localization.translate('open_settings_button')),
              ),
            ],
          ),
        );
      }
    }
  }

  // Tahcabo, Yucatán coordinates
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(21.056118, -88.081966),
    zoom: 14.47,
  );

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            const Icon(Icons.map_outlined, color: Color(0xFF217055), size: 28),
            const SizedBox(width: 8),
            Text(
              localization.translate('map_item_title_${widget.mapIndex}'),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.black),
            onPressed: _takeScreenshotAndSave,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFA8D5BA),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80, left: 12, right: 12, bottom: 90),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              clipBehavior: Clip.antiAlias,
              child: RepaintBoundary(
                key: _boundaryKey,
                child: GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: _initialPosition,
                  onMapCreated: (GoogleMapController controller) {
                    print('DEBUG: GoogleMap onMapCreated');
                    _mapController.complete(controller);
                  },
                  myLocationEnabled: _locationGranted,
                  myLocationButtonEnabled: _locationGranted,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: true,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Card(
              color: Colors.white.withOpacity(0.92),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.translate('map_item_title_${widget.mapIndex}'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tahcabo, Yucatán, México',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF217055),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '21.056118, -88.081966',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF217055),
        child: const Icon(Icons.my_location, color: Colors.white),
        onPressed: () async {
    final controller = await _mapController.future;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(_initialPosition),
          );
        },
        tooltip: 'Centrar en Tahcabo',
      ),
    );
  }

  Future<void> _takeScreenshotAndSave() async {
    try {
    final PM.PermissionState ps = await PM.PhotoManager.requestPermissionExtend();
    if (ps != PM.PermissionState.authorized && ps != PM.PermissionState.limited) {
        if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permission denied'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => PM.PhotoManager.openSetting(),
          ),
        ),
      );
        }
      return;
    }

      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Could not find boundary');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Could not convert image to bytes');
      }

      final pngBytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/map_${widget.mapIndex}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      final PM.AssetEntity? saved = await PM.PhotoManager.editor.saveImage(
        pngBytes,
        filename: 'map_${widget.mapIndex}_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved != null
                ? 'Screenshot saved to gallery!'
                : 'Failed to save screenshot.',
          ),
        ),
      );
      }
    } catch (e) {
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing screenshot: $e')),
      );
    }
  }
  }
} 