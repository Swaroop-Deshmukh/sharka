import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

export enum TripStatus {
  REQUESTED = 'REQUESTED',
  ACCEPTED = 'ACCEPTED',
  STARTED = 'STARTED',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED',
}


@Entity()
export class Trip {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  passengerId: string;

  @Column({ nullable: true })
  driverId: string;

  @Column({
  type: 'enum',
  enum: TripStatus,
  default: TripStatus.REQUESTED,
})
status: TripStatus;

@Column('float', { nullable: true })
startLat: number;

@Column('float', { nullable: true })
startLng: number;

@Column('float', { nullable: true })
endLat: number;

@Column('float', { nullable: true })
endLng: number;



}
