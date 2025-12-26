import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
} from 'typeorm';
import { User } from '../../users/user.entity';

export enum VehicleCategory {
  STANDARD = 'STANDARD',
  PRESTIGE = 'PRESTIGE',
}

@Entity()
export class Vehicle {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  model: string; // Audi A4, Swift, etc.

  @Column({ unique: true })
  plateNumber: string;

  @Column({
    type: 'enum',
    enum: VehicleCategory,
  })
  category: VehicleCategory;

  // Driver who owns the vehicle
  @ManyToOne(() => User)
  driver: User;
}
