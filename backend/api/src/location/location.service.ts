import { Injectable, OnModuleDestroy } from '@nestjs/common';
import Redis from 'ioredis';

@Injectable()
export class LocationService implements OnModuleDestroy {
  private readonly redis: Redis;

  constructor() {
    this.redis = new Redis({
      host: process.env.REDIS_HOST || '127.0.0.1',
      port: Number(process.env.REDIS_PORT) || 6379,
    });
  }

  /**
   * Save driver's live location in Redis
   */
  async updateDriverLocation(
    driverId: string,
    lat: number,
    lng: number,
  ): Promise<void> {
    const key = `driver:location:${driverId}`;

    await this.redis.set(
      key,
      JSON.stringify({
        lat,
        lng,
        updatedAt: Date.now(),
      }),
      'EX',
      30, // expires in 30 seconds
    );
  }

  /**
   * Fetch last known driver location
   */
  async getDriverLocation(
    driverId: string,
  ): Promise<{ lat: number; lng: number; updatedAt: number } | null> {
    const data = await this.redis.get(`driver:location:${driverId}`);
    return data ? JSON.parse(data) : null;
  }

  async onModuleDestroy() {
    await this.redis.quit();


  }

  async clearDriverLocation(driverId: string) {
  await this.redis.del(`driver:location:${driverId}`);
}

}
