import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDTO } from './dto/register.dto';
import { LoginDTO } from './dto/login.dto';

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
}
