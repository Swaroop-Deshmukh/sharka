import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../users/user.entity';

export enum TripStatus {
  SEARCHING = 'SEARCHING',
  ACTIVE = 'ACTIVE',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED',
}

@Entity()
export class Trip {
  @PrimaryGeneratedColumn()
  id: number;

  @Column('decimal')
  pickupLat: number;

  @Column('decimal')
  pickupLng: number;

  @Column({
    type: 'enum',
    enum: TripStatus,
    default: TripStatus.SEARCHING,
  })
  status: TripStatus;

  @ManyToOne(() => User)
  passenger: User;

  @ManyToOne(() => User, { nullable: true })
  driver: User;

  @CreateDateColumn()
  createdAt: Date;
}
