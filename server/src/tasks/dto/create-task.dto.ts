import {
  IsString,
  IsOptional,
  IsBoolean,
  IsArray,
  IsDateString,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

class SubTaskDto {
  @IsString()
  title: string;

  @IsBoolean()
  @IsOptional()
  isCompleted?: boolean = false;
}

export class CreateTaskDto {
  @IsString({ message: 'El título debe ser una cadena de texto' })
  title: string;

  @IsString({ message: 'La descripción debe ser una cadena de texto' })
  @IsOptional()
  description?: string;

  @IsDateString({}, { message: 'La fecha estimada debe ser una fecha válida' })
  @IsOptional()
  estimatedDate?: Date;

  @IsBoolean({
    message: 'El estado de finalización debe ser un valor booleano',
  })
  @IsOptional()
  isCompleted?: boolean;

  @IsArray({ message: 'Las subtareas deben ser un arreglo' })
  @ValidateNested({ each: true })
  @Type(() => SubTaskDto)
  @IsOptional()
  subTasks?: SubTaskDto[];

  @IsString({ message: 'El campo de repetición debe ser una cadena de texto' })
  @IsOptional()
  repeat?: string;
}
