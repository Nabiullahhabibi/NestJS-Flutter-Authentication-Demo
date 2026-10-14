import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(@InjectRepository(User) private readonly users: Repository<User>) { }

  findByEmail(email: string) { return this.users.findOne({ where: { email } }); }
  findById(id: number) { return this.users.findOne({ where: { id } }); }
  create(data: Pick<User, 'name' | 'email' | 'passwordHash'>) { return this.users.save(this.users.create(data)); }
  async saveRefreshHash(id: number, hash: string | null) {
    const user = await this.findById(id); if (!user) throw new NotFoundException('User not found');
    user.refreshTokenHash = hash; return this.users.save(user);
  }
  async setRole(id: number, role: UserRole) {
    const user = await this.findById(id); if (!user) throw new NotFoundException('User not found');
    user.role = role; return this.users.save(user);
  }
  async listSafe() {
    const users = await this.users.find({ order: { id: 'ASC' } });
    return users.map(({ passwordHash, refreshTokenHash, ...safe }) => safe);
  }
}
