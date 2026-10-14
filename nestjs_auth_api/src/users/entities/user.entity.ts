import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

export enum UserRole { USER = 'USER', ADMIN = 'ADMIN' }

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ length: 100 })
  name!: string;

  @Column({ unique: true, length: 255 })
  email!: string;

  @Column({ name: 'password_hash', length: 255 })
  passwordHash!: string;

  @Column({ type: 'enum', enum: UserRole, default: UserRole.USER })
  role!: UserRole;

  @Column({ name: 'refresh_token_hash', type: 'varchar', length: 255, nullable: true })
  refreshTokenHash!: string | null;

  @Column({ name: 'created_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt!: Date;
}
