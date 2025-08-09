import { Transform } from 'class-transformer';
import { IsEmail, IsString, MinLength } from 'class-validator';

/**
 * Data Transfer Object for user login requests.
 *
 * - Validates and transforms email and password fields for login.
 * - Ensures email is in valid format and password meets minimum length.
 */
export class LoginDTO {
  /**
   * User email address (must be valid and is transformed to lowercase/trimmed).
   */
  @IsEmail({}, { message: 'Email en formato inválido' })
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  email: string;

  /**
   * User password (must be a string, trimmed, and at least 6 characters).
   */
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.trim() : value,
  )
  @IsString()
  @MinLength(6, { message: 'La contraseña debe tener al menos 6 caracteres' })
  password: string;
}
