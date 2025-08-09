import { Body, Controller, Get, Post, UseGuards, Req } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDTO } from './dto/register.dto';
import { LoginDTO } from './dto/login.dto';
import { AuthGuard } from '../auth.guard';
import * as authGuardTypes from '../types/auth.guard.types';

/**
 * AuthController handles HTTP requests related to authentication.
 *
 * - Provides endpoints for user registration, login, profile retrieval, and token refresh.
 * - Uses AuthService for business logic and AuthGuard for protected routes.
 */
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * Registers a new user.
   * @param registerPayload - Registration data (DTO).
   * @returns The result of the registration process from AuthService.
   */
  @Post('register')
  register(@Body() registerPayload: RegisterDTO) {
    return this.authService.register(registerPayload);
  }

  /**
   * Authenticates a user and returns tokens if credentials are valid.
   * @param loginPayload - Login data (DTO).
   * @returns The result of the login process from AuthService.
   */
  @Post('login')
  login(@Body() loginPayload: LoginDTO) {
    return this.authService.login(loginPayload);
  }

  /**
   * Retrieves the profile of the authenticated user.
   * @param req - The request object containing the authenticated user.
   * @returns The user's profile from AuthService.
   */
  @Get('profile')
  @UseGuards(AuthGuard)
  getProfile(@Req() req: authGuardTypes.AuthenticatedRequest) {
    return this.authService.getProfile(req.user);
  }

  /**
   * Refreshes JWT tokens using a valid refresh token.
   * @param payload - Object containing the refresh token.
   * @returns New access and refresh tokens from AuthService.
   */
  @Post('refresh')
  refresh(@Body() payload: { refreshToken: string }) {
    return this.authService.refreshToken(payload.refreshToken);
  }
}
