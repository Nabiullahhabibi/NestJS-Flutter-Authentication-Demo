import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import configuration from './config/configuration';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { User } from './users/entities/user.entity';
import { RequestIdMiddleware } from './common/middleware/request-id.middleware';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, load: [configuration], cache: true }),
    TypeOrmModule.forRootAsync({ inject: [ConfigService], useFactory: (config: ConfigService) => ({ type: 'mysql', host: config.getOrThrow('database.host'), port: config.getOrThrow('database.port'), username: config.getOrThrow('database.username'), password: config.getOrThrow('database.password'), database: config.getOrThrow('database.name'), entities: [User], synchronize: config.get('NODE_ENV') !== 'production' }) }),
    AuthModule, UsersModule,
  ],
})
export class AppModule implements NestModule { configure(consumer: MiddlewareConsumer) { consumer.apply(RequestIdMiddleware).forRoutes('*'); } }
