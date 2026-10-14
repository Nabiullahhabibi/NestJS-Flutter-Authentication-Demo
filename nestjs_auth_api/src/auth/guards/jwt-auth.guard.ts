import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UsersService } from '../../users/users.service';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    private readonly users: UsersService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest();
    const header = req.headers.authorization as string | undefined;
    if (!header?.startsWith('Bearer ')) throw new UnauthorizedException('Bearer token required');
    let payload: { userId: number };
    try {
      payload = this.jwt.verify(header.substring(7), {
        secret: this.config.getOrThrow<string>('jwt.accessSecret'),
      });
    } catch {
      throw new UnauthorizedException('Invalid or expired access token');
    }

    // Use the current database role so role changes take effect immediately.
    const user = await this.users.findById(payload.userId);
    if (!user) throw new UnauthorizedException('User account no longer exists');

    req.user = { userId: user.id, email: user.email, role: user.role };
    return true;
  }
}
