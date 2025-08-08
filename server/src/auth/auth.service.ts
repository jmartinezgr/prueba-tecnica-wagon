import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { UsersService } from 'src/users/users.service';
import { RegisterDTO } from './dto/register.dto';

import * as bcryptjs from 'bcryptjs';
import { LoginDTO } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(private readonly usersService: UsersService) {}

  async register(payload: RegisterDTO) {
    const user = await this.usersService.findOneByEmail(payload.email);
    if (user) {
      throw new BadRequestException('User already exists');
    }
    const hashedPassword = await bcryptjs.hash(payload.password, 10);
    return await this.usersService.create({
      ...payload,
      password: hashedPassword,
    });
  }

  async login(payload: LoginDTO) {
    const user = await this.usersService.findOneByEmail(payload.email);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    const isPasswordValid = await bcryptjs.compare(
      payload.password,
      user.password,
    );
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return { message: 'Login successful' };
  }
}
