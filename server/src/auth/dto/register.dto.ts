import { Transform } from 'class-transformer';
import {
  IsEmail,
  IsString,
  MinLength,
  MaxLength,
  Matches,
} from 'class-validator';

/**
 * Data Transfer Object for user registration requests.
 *
 * - Validates and transforms name, email, and password fields for registration.
 * - Ensures name and email are properly formatted and password meets security requirements.
 */
export class RegisterDTO {
  /**
   * User's full name (letters and spaces only, 3-50 characters).
   */
  @IsString()
  @MinLength(3)
  @MaxLength(50)
  @Matches(/^[a-zA-Z\s]+$/, {
    message: 'El nombre solo puede contener letras y espacios',
  })
  name: string;

  /**
   * User email address (must be valid and is transformed to lowercase/trimmed).
   */
  @IsEmail({}, { message: 'Email en formato inválido' })
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  email: string;

  /**
   * User password (must be strong, trimmed, and meet complexity requirements).
   * - At least 6 characters, no spaces, one uppercase, one lowercase, one number, and one special character.
   */
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.trim() : value,
  )
  @IsString()
  @MinLength(6)
  @Matches(/^\S*$/, { message: 'La contraseña no puede contener espacios' })
  @Matches(
    /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&+])[A-Za-z\d@$!%*?&+]{6,}$/,
    {
      message:
        'La contraseña debe tener al menos una letra mayúscula, una letra minúscula, un número y un carácter especial',
    },
  )
  password: string;
}
