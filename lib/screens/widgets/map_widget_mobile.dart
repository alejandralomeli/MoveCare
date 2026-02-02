import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/location_service.dart';

class MobileMapWidget extends StatefulWidget {
  const MobileMapWidget({super.key});

  @override
  State<MobileMapWidget> createState() => _MobileMapWidgetState();
}

class _MobileMapWidgetState extends State<MobileMapWidget> {
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final position = await LocationService.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentPosition!,
        zoom: 15,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}
