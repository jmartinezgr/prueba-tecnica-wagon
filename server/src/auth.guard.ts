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
/**
 * AuthGuard is a custom authentication guard for protecting routes using JWT.
 *
 * - Validates the presence and validity of a JWT in the Authorization header.
 * - Attaches the decoded user payload to the request object if valid.
 * - Throws appropriate UnauthorizedException errors for expired, invalid, or missing tokens.
 */
@Injectable()
export class AuthGuard implements CanActivate {
  /**
   * Constructs the AuthGuard with a JwtService instance for token verification.
   * @param jwtService - Service for handling JWT operations.
   */
  constructor(private readonly jwtService: JwtService) {}

  /**
   * Determines if the current request is authenticated by validating the JWT.
   *
   * @param context - The execution context containing the HTTP request.
   * @returns True if authentication is successful; otherwise, throws an exception.
   * @throws UnauthorizedException if the token is missing, expired, invalid, or not yet valid.
   */
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

  /**
   * Extracts the Bearer token from the Authorization header of the request.
   *
   * @param request - The HTTP request object.
   * @returns The JWT string if present and properly formatted; otherwise, undefined.
   */
  private extractToken(request: AuthenticatedRequest): string | undefined {
    const token = request.headers['authorization'];
    const [type, tokenValue] = token?.split(' ') ?? [];
    return type === 'Bearer' ? tokenValue : undefined;
  }
}
