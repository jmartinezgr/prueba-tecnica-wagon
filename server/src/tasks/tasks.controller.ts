import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Req,
  Query,
} from '@nestjs/common';
import { TasksService } from './tasks.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { AuthGuard } from 'src/auth.guard';

/**
 * TasksController handles HTTP requests for task management.
 *
 * - Provides endpoints for creating, retrieving, updating, and deleting user tasks.
 * - Uses TasksService for business logic and AuthGuard for route protection.
 */
@Controller('tasks')
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  /**
   * Creates a new task for the authenticated user.
   * @param req - The request object containing the authenticated user.
   * @param createTaskDto - Data for the new task.
   * @returns The created task document.
   */
  @UseGuards(AuthGuard)
  @Post()
  create(
    @Req() req: authGuardTypes.AuthenticatedRequest,
    @Body() createTaskDto: CreateTaskDto,
  ) {
    const userId = req.user.sub;
    return this.tasksService.create(createTaskDto, userId);
  }

  /**
   * Retrieves tasks for the authenticated user, optionally filtered by date, status, or scheduling.
   * @param req - The request object containing the authenticated user.
   * @param date - (Optional) Date string to filter tasks.
   * @param status - (Optional) Filter by completion status.
   * @param scheduled - (Optional) Filter by scheduled/unscheduled tasks.
   * @returns Array of matching task documents.
   */
  @UseGuards(AuthGuard)
  @Get()
  findUserTasks(
    @Req() req: authGuardTypes.AuthenticatedRequest,
    @Query('date') date?: string,
    @Query('status') status?: boolean,
    @Query('scheduled') scheduled?: boolean,
  ) {
    const userId = req.user.sub;
    return this.tasksService.findUserTasksByUserId(
      userId,
      date,
      status,
      scheduled,
    );
  }

  /**
   * Retrieves a single task by its ID.
   * @param id - The task's MongoDB document ID.
   * @returns The found task document or null.
   */
  @UseGuards(AuthGuard)
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.tasksService.findOne(id);
  }

  /**
   * Updates a task if it belongs to the authenticated user.
   * @param req - The request object containing the authenticated user.
   * @param id - The task's MongoDB document ID.
   * @param updateTaskDto - Data to update the task with.
   * @returns The updated task document.
   */
  @UseGuards(AuthGuard)
  @Patch(':id')
  update(
    @Req() req: authGuardTypes.AuthenticatedRequest,
    @Param('id') id: string,
    @Body() updateTaskDto: UpdateTaskDto,
  ) {
    const userId = req.user.sub;
    return this.tasksService.update(id, updateTaskDto, userId);
  }

  /**
   * Deletes a task if it belongs to the authenticated user.
   * @param req - The request object containing the authenticated user.
   * @param id - The task's MongoDB document ID.
   * @returns The deleted task document.
   */
  @UseGuards(AuthGuard)
  @Delete(':id')
  remove(
    @Req() req: authGuardTypes.AuthenticatedRequest,
    @Param('id') id: string,
  ) {
    const userId = req.user.sub;
    return this.tasksService.remove(id, userId);
  }
}
import * as authGuardTypes from 'src/types/auth.guard.types';
