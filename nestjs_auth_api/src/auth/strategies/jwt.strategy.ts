import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class JwtStrategy {
  // Kept as a small strategy service for learning. JwtAuthGuard performs verification directly.
  constructor(private readonly jwt: JwtService) {}
}
