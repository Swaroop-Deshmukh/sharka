import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TripVote, VoteStatus } from './trip-vote.entity';
import { EventsGateway } from '../events/events.gateway';

@Injectable()
export class TripVoteService {
  constructor(
    @InjectRepository(TripVote)
    private readonly voteRepo: Repository<TripVote>,
    private readonly eventsGateway: EventsGateway,
  ) {}

  // ======================
  // CREATE VOTE REQUEST
  // ======================
  async createVote(
    tripId: number,
    candidatePassengerId: string,
  ) {
    // Ensure only ONE active vote per trip
    await this.voteRepo.update(
      { tripId, status: VoteStatus.PENDING },
      { status: VoteStatus.EXPIRED },
    );

    const expiresAt = new Date(Date.now() + 15 * 1000); // 15 sec

    const vote = this.voteRepo.create({
      tripId,
      candidatePassengerId,
      expiresAt,
    });

    const savedVote = await this.voteRepo.save(vote);

    // Emit vote request
    this.eventsGateway.emitVoteRequest(tripId, savedVote);

    // Auto-expire
    setTimeout(() => {
      this.expireVote(savedVote.id);
    }, 15000);

    return savedVote;
  }

  // ======================
  // SUBMIT VOTE
  // ======================
  async submitVote(
    voteId: number,
    voter: 'DRIVER' | 'PASSENGER',
    value: boolean,
  ) {
    const vote = await this.voteRepo.findOneBy({ id: voteId });

    if (!vote) throw new Error('Vote not found');
    if (vote.status !== VoteStatus.PENDING)
      throw new Error('Vote already resolved');

    if (voter === 'DRIVER') vote.driverVote = value;
    if (voter === 'PASSENGER') vote.passengerVote = value;

    // Resolve logic
    if (vote.driverVote === false || vote.passengerVote === false) {
      vote.status = VoteStatus.REJECTED;
      await this.voteRepo.save(vote);
      this.eventsGateway.emitVoteResult(vote.tripId, 'REJECTED');
      return vote;
    }

    if (vote.driverVote === true && vote.passengerVote === true) {
      vote.status = VoteStatus.APPROVED;
      await this.voteRepo.save(vote);
      this.eventsGateway.emitVoteResult(vote.tripId, 'APPROVED');
      return vote;
    }

    return this.voteRepo.save(vote);
  }

  // ======================
  // EXPIRE VOTE
  // ======================
  async expireVote(voteId: number) {
    const vote = await this.voteRepo.findOneBy({ id: voteId });

    if (!vote || vote.status !== VoteStatus.PENDING) return;

    vote.status = VoteStatus.EXPIRED;
    await this.voteRepo.save(vote);

    this.eventsGateway.emitVoteResult(vote.tripId, 'EXPIRED');
  }
}
