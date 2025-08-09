/**
 * Data Transfer Object for creating a new task.
 *
 * - Validates and transforms fields for task creation, including subtasks and repeat options.
 * - Ensures required and optional fields are properly typed and validated.
 */
import {
  IsString,
  IsOptional,
  IsBoolean,
  IsArray,
  IsDateString,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

/**
 * DTO for a subtask within a task.
 */
class SubTaskDto {
  /**
   * Title of the subtask (required).
   */
  @IsString()
  title: string;

  /**
   * Completion status of the subtask (optional, default: false).
   */
  @IsBoolean()
  @IsOptional()
  isCompleted?: boolean = false;
}

/**
 * DTO for creating a new task.
 */
export class CreateTaskDto {
  /**
   * Title of the task (required).
   */
  @IsString({ message: 'El título debe ser una cadena de texto' })
  title: string;

  /**
   * Optional description of the task.
   */
  @IsString({ message: 'La descripción debe ser una cadena de texto' })
  @IsOptional()
  description?: string;

  /**
   * Optional estimated date for task completion.
   */
  @IsDateString({}, { message: 'La fecha estimada debe ser una fecha válida' })
  @IsOptional()
  estimatedDate?: Date;

  /**
   * Completion status of the task (optional).
   */
  @IsBoolean({
    message: 'El estado de finalización debe ser un valor booleano',
  })
  @IsOptional()
  isCompleted?: boolean;

  /**
   * Optional array of subtasks for the task.
   */
  @IsArray({ message: 'Las subtareas deben ser un arreglo' })
  @ValidateNested({ each: true })
  @Type(() => SubTaskDto)
  @IsOptional()
  subTasks?: SubTaskDto[];

  /**
   * Optional repeat pattern for the task (e.g., 'daily', 'weekly').
   */
  @IsString({ message: 'El campo de repetición debe ser una cadena de texto' })
  @IsOptional()
  repeat?: string;
}
