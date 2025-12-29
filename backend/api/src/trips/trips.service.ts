import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Trip, TripStatus } from './trip.entity';
import { EventsGateway } from '../events/events.gateway';

@Injectable()
export class TripsService {
  constructor(
    @InjectRepository(Trip)
    private readonly tripRepo: Repository<Trip>,
    private readonly eventsGateway: EventsGateway,
  ) {}

  // ======================
  // Passenger: Request Trip
  // ======================
  async requestTrip(data: {
    passengerId: string;
    startLat: number;
    startLng: number;
    endLat: number;
    endLng: number;
  }) {
    const trip = this.tripRepo.create({
      passengerId: data.passengerId,
      startLat: data.startLat,
      startLng: data.startLng,
      endLat: data.endLat,
      endLng: data.endLng,
      status: TripStatus.REQUESTED,
    });

    return this.tripRepo.save(trip);
  }

  // ======================
  // Driver: Accept Trip
  // ======================
  async acceptTrip(tripId: number, driverId: string) {
    const trip = await this.tripRepo.findOne({ where: { id: tripId } });

    if (!trip) {
      throw new HttpException('Trip not found', HttpStatus.NOT_FOUND);
    }

    if (trip.status === TripStatus.ACCEPTED) {
      throw new HttpException('Trip already taken', HttpStatus.CONFLICT);
    }

    // Assign trip to driver
    trip.status = TripStatus.ACCEPTED;
    trip.driverId = driverId;

    await this.tripRepo.save(trip);

    // Emit event with single argument (tripId)
    this.eventsGateway.emitTripAccepted(tripId);

    return trip;
  }

  // ======================
  // Driver: Start Trip
  // ======================
  async startTrip(tripId: number, driverId: string) {
    const trip = await this.tripRepo.findOne({ where: { id: tripId } });

    if (!trip) {
      throw new HttpException('Trip not found', HttpStatus.NOT_FOUND);
    }

    if (trip.driverId !== driverId) {
      throw new HttpException('Unauthorized', HttpStatus.UNAUTHORIZED);
    }

    if (trip.status !== TripStatus.ACCEPTED) {
      throw new HttpException('Trip not accepted yet', HttpStatus.CONFLICT);
    }

    trip.status = TripStatus.STARTED;
    await this.tripRepo.save(trip);

    this.eventsGateway.emitTripStarted(tripId);

    return trip;
  }

  // ======================
  // Driver: End Trip
  // ======================
  async endTrip(tripId: number) {
    const trip = await this.tripRepo.findOne({ where: { id: tripId } });

    if (!trip) {
      throw new HttpException('Trip not found', HttpStatus.NOT_FOUND);
    }

    if (trip.status !== TripStatus.STARTED) {
      throw new HttpException('Trip not started yet', HttpStatus.CONFLICT);
    }

    trip.status = TripStatus.COMPLETED;
    const savedTrip = await this.tripRepo.save(trip);

    this.eventsGateway.emitTripCompleted(tripId);

    return savedTrip;
  }

  // ======================
  // Get trips by passenger
  // ======================
  async findTripsByPassenger(passengerId: string) {
    return this.tripRepo.find({ where: { passengerId } });
  }

  // ======================
  // Get trips by driver
  // ======================
  async findTripsByDriver(driverId: string) {
    return this.tripRepo.find({ where: { driverId } });
  }

  // ======================
  // Get all trips
  // ======================
  async findAll() {
    return this.tripRepo.find();
  }
}
