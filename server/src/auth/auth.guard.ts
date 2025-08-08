import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import {
  JsonWebTokenError,
  NotBeforeError,
  TokenExpiredError,
} from 'jsonwebtoken';
import { JwtService } from '@nestjs/jwt';
import { envs } from 'src/config';
import { AppJwtPayload, AuthenticatedRequest } from './types/auth.guard.types';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private readonly jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request: AuthenticatedRequest = context
      .switchToHttp()
      .getRequest<AuthenticatedRequest>();
    const token = this.extractToken(request);
    if (!token) throw new UnauthorizedException();
    try {
      const payload: AppJwtPayload =
        await this.jwtService.verifyAsync<AppJwtPayload>(token, {
          secret: envs.SECRET,
        });
      request['user'] = payload;
    } catch (error) {
      if (error instanceof TokenExpiredError) {
        throw new UnauthorizedException(
          'Tu sesión ha expirado. Inicia sesión nuevamente.',
        );
      } else if (error instanceof JsonWebTokenError) {
        throw new UnauthorizedException(
          'Token inválido. Verifica tu autenticación.',
        );
      } else if (error instanceof NotBeforeError) {
        throw new UnauthorizedException('El token aún no es válido.');
      } else {
        throw new UnauthorizedException('Error de autenticación.');
      }
    }

    return true;
  }

  private extractToken(request: AuthenticatedRequest): string | undefined {
    const token = request.headers.authorization;
    const [type, tokenValue] = token?.split(' ') ?? [];

    return type === 'Bearer' ? tokenValue : undefined;
  }
}
