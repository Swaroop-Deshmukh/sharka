import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

export enum VoteStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
  EXPIRED = 'EXPIRED',
}

@Entity()
export class TripVote {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  tripId: number;

  @Column()
  candidatePassengerId: string; // Passenger B

  @Column({ nullable: true })
  driverVote: boolean;

  @Column({ nullable: true })
  passengerVote: boolean; // Passenger A

  @Column({
    type: 'enum',
    enum: VoteStatus,
    default: VoteStatus.PENDING,
  })
  status: VoteStatus;

  @Column()
  expiresAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}
