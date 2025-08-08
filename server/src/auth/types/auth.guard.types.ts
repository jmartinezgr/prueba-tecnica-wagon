import { Request } from 'express';

export interface AuthenticatedRequest extends Request {
  user: AppJwtPayload;
}

export interface AppJwtPayload {
  sub: number;
  email: string;
  iat?: number;
  exp?: number;
}
