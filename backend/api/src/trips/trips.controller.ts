import { Controller, Post, Patch, Get, Body, Param } from '@nestjs/common';
import { TripsService } from './trips.service';
import { TripStatus } from '../database/entities/trip.entity';

@Controller('trips')
export class TripsController {
  constructor(private service: TripsService) {}

  @Post()
  create(@Body() body: any) {
    return this.service.create(body.pickupLat, body.pickupLng);
  }

  @Patch(':id/status')
  updateStatus(
    @Param('id') id: number,
    @Body('status') status: TripStatus,
  ) {
    return this.service.updateStatus(id, status);
  }

  @Get()
  findAll() {
    return this.service.findAll();
  }
}
