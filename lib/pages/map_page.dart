import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching directions link

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  Position? currentPosition;
  final Set<Marker> _markers = {};
  late GooglePlace googlePlace;

  // Store currently selected hospital details to show custom info card
  DetailsResult? selectedHospitalDetails;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(
      "YOUR_API_KEY_HERE",
    ); // Replace with your actual API Key
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentPosition = position;
    });
    _moveCameraToPosition(position.latitude, position.longitude);
    _loadNearbyHospitals(position.latitude, position.longitude);
  }

  void _moveCameraToPosition(double lat, double lng) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 14,
        ), // Zoom 14 is typical city-level
      ),
    );
  }

  Future<void> _loadNearbyHospitals(double lat, double lng) async {
    final response = await googlePlace.search.getNearBySearch(
      Location(lat: lat, lng: lng),
      3000,
      type: "hospital",
    );

    if (response != null && response.results != null) {
      setState(() {
        _markers.clear();
        for (var place in response.results!) {
          var loc = place.geometry?.location;
          if (loc != null) {
            _markers.add(
              Marker(
                markerId: MarkerId(place.placeId ?? loc.lat.toString()),
                position: LatLng(loc.lat!, loc.lng!),
                // Remove default infoWindow to avoid conflicts
                // Use onTap to show custom info card
                onTap: () {
                  if (place.placeId != null) {
                    _showHospitalDetails(place.placeId!);
                  }
                },
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ), // Red markers for hospitals
              ),
            );
          }
        }
      });
    }
  }

  void _showHospitalDetails(String placeId) async {
    var details = await googlePlace.details.get(placeId);

    if (details != null && details.result != null) {
      setState(() {
        selectedHospitalDetails = details.result!;
      });
    }
  }

  // Helper to launch directions in Google Maps app/browser
  void _launchMapsDirections(double lat, double lng) async {
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open maps for directions")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // TODO: Add search bar widget here if desired

          // Header or title for the map section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Nearby Hospitals",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: (controller) =>
                            mapController = controller,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            currentPosition!.latitude,
                            currentPosition!.longitude,
                          ),
                          zoom: 14,
                        ),
                        markers: _markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        // When map is tapped outside markers, hide info card
                        onTap: (_) {
                          setState(() {
                            selectedHospitalDetails = null;
                          });
                        },
                      ),

                      // Custom hospital info card shown when marker tapped
                      if (selectedHospitalDetails != null)
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 20,
                          child: _HospitalInfoCard(
                            details: selectedHospitalDetails!,
                            onClose: () {
                              setState(() {
                                selectedHospitalDetails = null;
                              });
                            },
                            onDirections: () {
                              final loc =
                                  selectedHospitalDetails!.geometry?.location;
                              if (loc != null) {
                                _launchMapsDirections(loc.lat!, loc.lng!);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// Widget for custom hospital info card
class _HospitalInfoCard extends StatelessWidget {
  final DetailsResult details;
  final VoidCallback onClose;
  final VoidCallback onDirections;

  const _HospitalInfoCard({
    Key? key,
    required this.details,
    required this.onClose,
    required this.onDirections,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    details.name ?? "Unknown Hospital",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(icon: Icon(Icons.close), onPressed: onClose),
              ],
            ),
            SizedBox(height: 8),
            if (details.formattedAddress != null)
              Row(
                children: [
                  Icon(Icons.location_on, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text(details.formattedAddress!)),
                ],
              ),
            if (details.rating != null)
              Row(
                children: [
                  Icon(Icons.star, size: 20, color: Colors.amber),
                  SizedBox(width: 8),
                  Text("${details.rating} / 5"),
                ],
              ),
            if (details.openingHours?.openNow != null)
              Row(
                children: [
                  Icon(Icons.access_time, size: 20),
                  SizedBox(width: 8),
                  Text(
                    details.openingHours!.openNow! ? "Open Now" : "Closed Now",
                  ),
                ],
              ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.directions),
              label: Text("Get Directions"),
              onPressed: onDirections,
            ),
          ],
        ),
      ),
    );
  }
}
