import { Controller, Post, Patch, Get, Body, Param, ParseIntPipe } from '@nestjs/common';
import { TripsService } from './trips.service';
import { TripStatus } from './trip.entity';

@Controller('trips')
export class TripsController {
  constructor(private readonly tripsService: TripsService) {}

  // ======================
  // Passenger Endpoints
  // ======================

  // Passenger requests a trip
  @Post('request')
  requestTrip(@Body() body: {
    passengerId: string;
    startLat: number;
    startLng: number;
    endLat: number;
    endLng: number;
  }) {
    return this.tripsService.requestTrip(body);
  }

  // ======================
  // Driver Endpoints
  // ======================

  // Driver accepts a trip
  @Patch(':id/accept')
  async driverAcceptTrip(
    @Param('id', ParseIntPipe) tripId: number, // converts string to number automatically
    @Body('driverId') driverId: string,
  ) {
    return this.tripsService.acceptTrip(tripId, driverId);
  }

  // Driver starts a trip
  @Patch(':id/start')
  async startTrip(
    @Param('id', ParseIntPipe) tripId: number,
    @Body('driverId') driverId: string,
  ) {
    return this.tripsService.startTrip(tripId, driverId);
  }

  // Driver ends a trip
  @Patch(':id/end')
  async endTrip(@Param('id', ParseIntPipe) tripId: number) {
    return this.tripsService.endTrip(tripId);
  }

  // ======================
  // Get trips by passenger or driver
  // ======================

  @Get('passenger/:id')
  getPassengerTrips(@Param('id') passengerId: string) {
    return this.tripsService.findTripsByPassenger(passengerId);
  }

  @Get('driver/:id')
  getDriverTrips(@Param('id') driverId: string) {
    return this.tripsService.findTripsByDriver(driverId);
  }

  // ======================
  // Get all trips
  // ======================

  @Get()
  findAll() {
    return this.tripsService.findAll();
  }
}
