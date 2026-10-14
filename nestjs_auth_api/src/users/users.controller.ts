import { Body, Controller, ForbiddenException, Get, Param, ParseIntPipe, Patch, Req, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/guards/roles.decorator';
import { UserRole } from './entities/user.entity';
import { UpdateRoleDto } from './dto/update-role.dto';

@Controller('users')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @UseGuards(JwtAuthGuard)
  @Get('me')
  async me(@Req() req: any) { const user = await this.users.findById(req.user.userId); return this.safe(user); }

  @Roles(UserRole.ADMIN)
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Get()
  list() { return this.users.listSafe(); }

  @Roles(UserRole.ADMIN)
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Patch(':id/role')
  async updateRole(
    @Req() req: { user: { userId: number } },
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateRoleDto,
  ) {
    if (id === req.user.userId) {
      throw new ForbiddenException('You cannot change your own role');
    }
    return this.safe(await this.users.setRole(id, dto.role));
  }

  private safe(user: any) { if (!user) return null; const { passwordHash, refreshTokenHash, ...safe } = user; return safe; }
}
