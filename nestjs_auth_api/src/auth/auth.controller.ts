
import {
  Body,
  Controller,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) { }

  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.auth.register(dto);
  }

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }

  @Post('refresh')
  refresh(@Body() dto: RefreshTokenDto) {
    return this.auth.refresh(dto.refreshToken);
  }

  @UseGuards(JwtAuthGuard)
  @Post('logout')
  logout(@Req() req: { user: { userId: number } }) {
    return this.auth.logout(req.user.userId);
  }
}
