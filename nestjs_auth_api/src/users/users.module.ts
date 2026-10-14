
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';

import { User } from './entities/user.entity';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';

@Module({
  imports: [TypeOrmModule.forFeature([User]), JwtModule.register({})],
  providers: [UsersService, JwtAuthGuard, RolesGuard],
  exports: [UsersService, JwtAuthGuard, RolesGuard],
})
export class UsersModule {}
