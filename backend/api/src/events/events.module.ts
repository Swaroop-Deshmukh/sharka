import { Module, forwardRef } from '@nestjs/common';
import { EventsGateway } from './events.gateway';
import { TripsModule } from '../trips/trips.module';
import { LocationModule } from '../location/location.module';

@Module({
  imports: [
    forwardRef(() => TripsModule), // 🔁 breaks circular dependency
    LocationModule,               // 📍 driver location handling
  ],
  providers: [
    EventsGateway,                // 🔌 WebSocket gateway
  ],
  exports: [
    EventsGateway,                // 🟢 needed by TripsService
  ],
})
export class EventsModule {}
