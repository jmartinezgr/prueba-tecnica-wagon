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
  @IsString()
  title: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsDateString()
  @IsOptional()
  estimatedDate?: Date;

  @IsBoolean()
  @IsOptional()
  isCompleted?: boolean;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SubTaskDto)
  @IsOptional()
  subTasks?: SubTaskDto[];

  @IsString()
  @IsOptional()
  repeat?: string;
}
