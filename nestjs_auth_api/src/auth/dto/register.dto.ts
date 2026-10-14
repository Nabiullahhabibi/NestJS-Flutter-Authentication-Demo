
import {
  IsEmail,
  IsString,
  MinLength,
  MaxLength,
} from 'class-validator';
import { Transform } from 'class-transformer';

export class RegisterDto {
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name!: string;

  @IsEmail()
  @Transform(({ value }) => typeof value === 'string' ? value.trim().toLowerCase() : value)
  email!: string;

  @IsString()
  @MinLength(8)
  @MaxLength(72)
  password!: string;
}
