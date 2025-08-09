/**
 * Type definitions for authentication guard and JWT payload.
 *
 * - Defines the structure of the authenticated request and JWT payload used in the application.
 */
import { Request } from 'express';

/**
 * Extends Express Request to include the authenticated user payload.
 */
export interface AuthenticatedRequest extends Request {
  user: AppJwtPayload;
  headers: Request['headers']; // Asegura que tenga el tipo correcto de headers
}

/**
 * JWT payload structure for authenticated users.
 *
 * @property sub - User ID (subject)
 * @property email - User email address
 * @property iat - Issued at timestamp (optional)
 * @property exp - Expiration timestamp (optional)
 */
export interface AppJwtPayload {
  sub: number;
  email: string;
  iat?: number;
  exp?: number;
}
