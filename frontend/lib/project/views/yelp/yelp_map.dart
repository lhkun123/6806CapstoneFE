import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constants/app_style.dart';

class YelpMap extends StatefulWidget {
  double latitude, longitude;
  String location, title;
  YelpMap({super.key, required this.latitude,required this.longitude,required this.location, required this.title});
  @override
  _YelpMapState createState() => _YelpMapState();
}
class _YelpMapState extends State<YelpMap> {
  late GoogleMapController mapController;

  late final LatLng _center;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  @override
  void initState() {
    _center=LatLng(widget.latitude, widget.longitude);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 16,
          ),
          markers: {
            Marker(
              markerId: const MarkerId("Destination"),
              position: _center,
              infoWindow: InfoWindow(
                title: widget.title,
                snippet: widget.location,
              ), // InfoWindow
            ), //Mar // Marker
          },

        ),
      );
  }
}