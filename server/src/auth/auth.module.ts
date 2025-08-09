import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UsersModule } from 'src/users/users.module';
import { JwtModule } from '@nestjs/jwt';
import { envs } from 'src/config';

/**
 * AuthModule handles authentication features for the application.
 *
 * - Imports user and JWT modules for authentication logic and token management.
 * - Provides AuthService and AuthController for handling authentication requests.
 * - Exports AuthService for use in other modules.
 */
@Module({
  imports: [
    UsersModule,
    JwtModule.register({
      global: true,
      secret: envs.SECRET,
    }),
  ],
  providers: [AuthService],
  controllers: [AuthController],
  exports: [AuthService],
})
export class AuthModule {}
