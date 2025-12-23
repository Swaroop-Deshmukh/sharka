import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 🔐 Enable global DTO validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,            // strips unknown properties
      forbidNonWhitelisted: true, // throws error for extra fields
      transform: true,            // auto-convert payloads to DTO classes
    }),
  );

  await app.listen(3000);
  console.log('🚀 Server running on http://localhost:3000');
}

bootstrap();
