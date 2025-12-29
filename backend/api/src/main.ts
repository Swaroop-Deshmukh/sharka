import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { IoAdapter } from '@nestjs/platform-socket.io';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 🔐 Enable global DTO validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // 🔥 THIS LINE FIXES SOCKET.IO
  app.enableCors({ origin: '*' });
  app.useWebSocketAdapter(new IoAdapter(app));

  await app.listen(3000);
  console.log('🚀 Server running on http://localhost:3000');
}

bootstrap();
