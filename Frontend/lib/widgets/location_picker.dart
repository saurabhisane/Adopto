import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../constants.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String _location = 'Fetching location...';
  String _city = '';
  String _country = '';
  bool _isLoading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = 'Location services disabled';
        _isLoading = false;
      });
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = 'Location permissions denied';
          _permissionDenied = true;
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = 'Location permissions permanently denied';
        _permissionDenied = true;
        _isLoading = false;
      });
      return;
    }

    // Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _city = place.locality ?? place.subAdministrativeArea ?? '';
          _country = place.country ?? '';
          _location = '$_city${_city.isNotEmpty && _country.isNotEmpty ? ', ' : ''}$_country';
          _isLoading = false;
        });
      } else {
        setState(() {
          _location = 'Unknown location';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _location = 'Unable to get location';
        _isLoading = false;
      });
    }
  }

  Future<void> _retryLocation() async {
    setState(() {
      _isLoading = true;
      _permissionDenied = false;
    });
    await _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _permissionDenied 
              ? Colors.red.withOpacity(0.2)
              : kPrimaryColor.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _permissionDenied
                  ? Colors.red.withOpacity(0.1)
                  : kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _permissionDenied ? Colors.red : kPrimaryColor,
                    ),
                  )
                : Icon(
                    _permissionDenied 
                        ? Icons.location_off_outlined
                        : Icons.location_on_outlined,
                    color: _permissionDenied ? Colors.red : kPrimaryColor,
                    size: 22,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _permissionDenied ? 'Location Access' : 'Current Location',
                  style: TextStyle(
                    fontSize: 12,
                    color: _permissionDenied 
                        ? Colors.red
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              child: Row(
                                children: [
                                  Text(
                                    'Fetching location',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Text(
                              _location,
                              style: TextStyle(
                                fontSize: 16,
                                color: _permissionDenied 
                                    ? Colors.red
                                    : Colors.grey[800],
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    if (_permissionDenied || _location == 'Location services disabled')
                      const SizedBox(width: 8),
                    if (_permissionDenied || _location == 'Location services disabled')
                      GestureDetector(
                        onTap: _retryLocation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _permissionDenied
                                ? Colors.red.withOpacity(0.1)
                                : kPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              fontSize: 12,
                              color: _permissionDenied ? Colors.red : kPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}