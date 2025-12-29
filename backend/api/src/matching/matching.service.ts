import { Injectable } from '@nestjs/common';

@Injectable()
export class MatchingService {
  findNearestDriver() {
    // fake driver for now
    return {
      driverId: 'driver-99',
      lat: 18.5204,
      lng: 73.8567,
    };
  }
}
