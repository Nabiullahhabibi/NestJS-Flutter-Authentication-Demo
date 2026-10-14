import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { UsersService } from '../users/users.service';
import { User, UserRole } from '../users/entities/user.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import type { SignOptions } from 'jsonwebtoken';

@Injectable()
export class AuthService {
  constructor(private readonly users: UsersService, private readonly jwt: JwtService, private readonly config: ConfigService) {}

  async register(dto: RegisterDto) {
    const email = dto.email.trim().toLowerCase();
    if (await this.users.findByEmail(email)) throw new ConflictException('Email already registered');
    const passwordHash = await bcrypt.hash(dto.password, 12);
    const user = await this.users.create({ name: dto.name.trim(), email, passwordHash });
    return this.issueTokens(user);
  }

  async login(dto: LoginDto) {
    const user = await this.users.findByEmail(dto.email.toLowerCase());
    if (!user || !(await bcrypt.compare(dto.password, user.passwordHash))) throw new UnauthorizedException('Invalid credentials');
    return this.issueTokens(user);
  }

  async refresh(refreshToken: string) {
    let payload: any;
    try { payload = this.jwt.verify(refreshToken, { secret: this.config.getOrThrow<string>('jwt.refreshSecret') }); }
    catch { throw new UnauthorizedException('Invalid or expired refresh token'); }
    const user = await this.users.findById(payload.userId);
    if (!user?.refreshTokenHash || !(await bcrypt.compare(refreshToken, user.refreshTokenHash))) throw new UnauthorizedException('Refresh token revoked');
    return this.issueTokens(user);
  }

  async logout(userId: number) { await this.users.saveRefreshHash(userId, null); return { message: 'Logged out' }; }


private async issueTokens(user: User) {
  const accessSecret =
    this.config.getOrThrow<string>('jwt.accessSecret');

  const refreshSecret =
    this.config.getOrThrow<string>('jwt.refreshSecret');

  const accessTtl =
    this.config.get<SignOptions['expiresIn']>('jwt.accessTtl') ?? '15m';

  const refreshTtl =
    this.config.get<SignOptions['expiresIn']>('jwt.refreshTtl') ?? '7d';

  const accessToken = await this.jwt.signAsync(
    {
      userId: user.id,
      email: user.email,
      role: user.role,
    },
    {
      secret: accessSecret,
      expiresIn: accessTtl,
    },
  );

  const refreshToken = await this.jwt.signAsync(
    {
      userId: user.id,
      type: 'refresh',
    },
    {
      secret: refreshSecret,
      expiresIn: refreshTtl,
    },
  );

  await this.users.saveRefreshHash(
    user.id,
    await bcrypt.hash(refreshToken, 12),
  );

  return {
    accessToken,
    refreshToken,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
  };
}

}
