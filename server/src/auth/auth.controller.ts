import { Body, Controller, Get, Post, UseGuards, Req } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDTO } from './dto/register.dto';
import { LoginDTO } from './dto/login.dto';
import { AuthGuard } from '../auth.guard';
import * as authGuardTypes from '../types/auth.guard.types';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  register(@Body() registerPayload: RegisterDTO) {
    return this.authService.register(registerPayload);
  }

  @Post('login')
  login(@Body() loginPayload: LoginDTO) {
    return this.authService.login(loginPayload);
  }

  @Get('profile')
  @UseGuards(AuthGuard)
  getProfile(@Req() req: authGuardTypes.AuthenticatedRequest) {
    return this.authService.getProfile(req.user);
  }
}
