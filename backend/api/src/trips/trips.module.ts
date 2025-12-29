import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Trip } from './trip.entity';
import { TripsService } from './trips.service';
import { TripsController } from './trips.controller';
import { TripVote } from './trip-vote.entity';
import { TripVoteService } from './trip-vote.service';
import { EventsGateway } from '../events/events.gateway';

@Module({
  imports: [TypeOrmModule.forFeature([Trip, TripVote])],
  providers: [TripsService, TripVoteService, EventsGateway],
  controllers: [TripsController],
})
export class TripsModule {}
