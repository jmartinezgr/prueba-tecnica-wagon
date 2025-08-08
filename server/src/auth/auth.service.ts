import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { UsersService } from 'src/users/users.service';
import { RegisterDTO } from './dto/register.dto';

import * as bcryptjs from 'bcryptjs';
import { LoginDTO } from './dto/login.dto';
import { JwtService } from '@nestjs/jwt';
import { AppJwtPayload } from './types/auth.guard.types';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async register(payload: RegisterDTO) {
    const user = await this.usersService.findOneByEmail(payload.email);
    if (user) {
      throw new BadRequestException('User already exists');
    }
    const hashedPassword = await bcryptjs.hash(payload.password, 10);

    const createdUser = await this.usersService.create({
      ...payload,
      password: hashedPassword,
    });

    const JWTpayload = {
      email: createdUser.email,
      sub: createdUser.id,
    };

    const accessToken = this.jwtService.sign(JWTpayload, { expiresIn: '1h' });
    const refreshToken = this.jwtService.sign(JWTpayload, { expiresIn: '7d' });

    return {
      accessToken,
      refreshToken,
      ...createdUser,
    };
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

    const JWTpayload = {
      email: user.email,
      sub: user.id,
    };

    const accessToken = this.jwtService.sign(JWTpayload, { expiresIn: '1h' });
    const refreshToken = this.jwtService.sign(JWTpayload, { expiresIn: '7d' });

    return {
      message: 'Login successful',
      accessToken,
      refreshToken,
      user: { email: user.email, name: user.name },
    };
  }

  async getProfile(userPayload: AppJwtPayload) {
    const user = await this.usersService.findOneByEmail(userPayload.email);
    const userWithoutPassword = { ...user, password: undefined };

    return userWithoutPassword;
  }
}
