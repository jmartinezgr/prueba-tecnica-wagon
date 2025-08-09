/**
 * AuthService handles authentication logic for user registration, login, profile retrieval, and token refresh.
 *
 * - Provides methods for registering and logging in users with JWT-based authentication.
 * - Handles password hashing, token generation, and validation.
 * - Exposes methods to get user profile and refresh authentication tokens.
 */
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
import { AppJwtPayload } from '../types/auth.guard.types';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * Registers a new user, hashes their password, and returns JWT tokens and user data.
   * @param payload - Registration data (email, password, etc.)
   * @returns Object containing accessToken, refreshToken, and user info (without password).
   * @throws BadRequestException if the user already exists.
   */
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
      ...{ ...createdUser, password: undefined },
    };
  }

  /**
   * Authenticates a user and returns JWT tokens and user data if credentials are valid.
   * @param payload - Login data (email and password).
   * @returns Object containing accessToken, refreshToken, and user info (without password).
   * @throws UnauthorizedException if credentials are invalid.
   */
  async login(payload: LoginDTO) {
    const user = await this.usersService.findOneByEmail(payload.email);
    if (!user) {
      throw new UnauthorizedException('Credenciales erroneas');
    }
    const isPasswordValid = await bcryptjs.compare(
      payload.password,
      user.password,
    );
    if (!isPasswordValid) {
      throw new UnauthorizedException('Credenciales erroneas');
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
      user: { ...user, password: undefined },
    };
  }

  /**
   * Retrieves the profile of the authenticated user.
   * @param userPayload - JWT payload containing user identification.
   * @returns User object without the password field.
   */
  async getProfile(userPayload: AppJwtPayload) {
    const user = await this.usersService.findOneByEmail(userPayload.email);
    const userWithoutPassword = { ...user, password: undefined };

    return userWithoutPassword;
  }

  /**
   * Validates and refreshes JWT tokens using a valid refresh token.
   * @param refreshToken - The refresh token string.
   * @returns Object containing new accessToken and refreshToken.
   * @throws UnauthorizedException if the refresh token is invalid or user does not exist.
   */
  async refreshToken(refreshToken: string) {
    try {
      const payload: AppJwtPayload = this.jwtService.verify(refreshToken);
      const user = await this.usersService.findOneByEmail(payload.email);
      if (!user) {
        throw new UnauthorizedException('Invalid refresh token');
      }

      const newAccessToken = this.jwtService.sign(
        { email: user.email, sub: user.id },
        { expiresIn: '1h' },
      );

      const newRefreshToken = this.jwtService.sign(
        { email: user.email, sub: user.id },
        { expiresIn: '7d' },
      );

      return {
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      };
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }
}
