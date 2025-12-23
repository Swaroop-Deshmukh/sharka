import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Trip, TripStatus } from '../database/entities/trip.entity';

@Injectable()
export class TripsService {
  constructor(
    @InjectRepository(Trip)
    private repo: Repository<Trip>,
  ) {}

  create(pickupLat: number, pickupLng: number) {
    return this.repo.save({
      pickupLat,
      pickupLng,
      status: TripStatus.SEARCHING,
    });
  }

  updateStatus(id: number, status: TripStatus) {
    return this.repo.update(id, { status });
  }

  findAll() {
    return this.repo.find();
  }
}
