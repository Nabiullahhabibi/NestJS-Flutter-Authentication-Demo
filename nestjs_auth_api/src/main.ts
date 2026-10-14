import 'reflect-metadata';
import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';
import { ConfigService } from '@nestjs/config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));
  app.useGlobalFilters(new HttpExceptionFilter());
  app.useGlobalInterceptors(new LoggingInterceptor());
  // app.enableCors({ origin: true });
  app.enableCors({
    origin: '*', // Development only
  });

  const config = app.get(ConfigService);
  const port = config.get<number>('port') ?? 3000;
  await app.listen(port, '0.0.0.0');
  console.log(`API running on port ${port}`);
}
bootstrap();
