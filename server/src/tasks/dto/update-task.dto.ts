/**
 * Data Transfer Object for updating an existing task.
 *
 * - Extends CreateTaskDto with all fields optional, allowing partial updates.
 * - Used for PATCH requests to update one or more fields of a task.
 */
import { PartialType } from '@nestjs/mapped-types';
import { CreateTaskDto } from './create-task.dto';

/**
 * DTO for updating a task. All fields are optional.
 */
export class UpdateTaskDto extends PartialType(CreateTaskDto) {}
