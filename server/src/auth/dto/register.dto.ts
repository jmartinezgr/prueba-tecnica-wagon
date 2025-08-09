import { Transform } from 'class-transformer';
import {
  IsEmail,
  IsString,
  MinLength,
  MaxLength,
  Matches,
} from 'class-validator';

export class RegisterDTO {
  @IsString()
  @MinLength(3)
  @MaxLength(50)
  @Matches(/^[a-zA-Z\s]+$/, {
    message: 'El nombre solo puede contener letras y espacios',
  })
  name: string;

  @IsEmail({}, { message: 'Email en formato inválido' })
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  email: string;

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
