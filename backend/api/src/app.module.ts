import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { TripsModule } from './trips/trips.module';
import { VehiclesModule } from './vehicles/vehicles.module';
import { EventsGateway } from './events/events.gateway';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),

    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || '127.0.0.1', // ✅ FIX
      port: Number(process.env.DB_PORT) || 5432,
      username: process.env.DB_USER || 'sharka',
      password: process.env.DB_PASSWORD || 'sharka',
      database: process.env.DB_NAME || 'sharka_db',
      autoLoadEntities: true,
      synchronize: true, // ⚠️ dev only
    }),

    UsersModule,
    AuthModule,
    TripsModule,
    VehiclesModule,
  ],
  providers: [EventsGateway],
})
export class AppModule {}
