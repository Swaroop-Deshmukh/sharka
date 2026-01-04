import 'dart:math' show cos, sqrt, asin;

class DeviationLogic {
  
  // 1. Calculate Distance between two points (Haversine Formula)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // 2. Calculate "Time Cost" of a detour
  // Assumptions: Average city speed = 30 km/h (0.5 km/min)
  // Pickup Time + Dropoff Detour Time
  int calculateDetourTime(double driverLat, double driverLng, double newPassengerLat, double newPassengerLng) {
    
    double distanceToNewUser = calculateDistance(driverLat, driverLng, newPassengerLat, newPassengerLng);
    
    // Time = Distance / Speed
    // At 30km/h, 1 km takes 2 minutes.
    // We add 2 mins constant for "boarding time" (stopping car, user getting in)
    double timeInMinutes = (distanceToNewUser * 2) + 2; 

    return timeInMinutes.round();
  }

  // 3. Fairness Check
  // If detour is > 10 mins, it's unfair to the current rider.
  bool isFairDetour(int extraMinutes) {
    return extraMinutes <= 10;
  }
}