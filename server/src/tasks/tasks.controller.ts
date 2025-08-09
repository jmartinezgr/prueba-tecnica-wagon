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

@Controller('tasks')
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  @UseGuards(AuthGuard)
  @Post()
  create(
    @Req() req: authGuardTypes.AuthenticatedRequest,
    @Body() createTaskDto: CreateTaskDto,
  ) {
    const userId = req.user.sub;
    return this.tasksService.create(createTaskDto, userId);
  }

  @UseGuards(AuthGuard)
  @Get()
  findUserTasks(
    @Req() req: authGuardTypes.AuthenticatedRequest,
    @Query('date') date?: string,
    @Query('status') status?: boolean,
  ) {
    const userId = req.user.sub;
    return this.tasksService.findUserTasksByUserId(userId, date, status);
  }

  @UseGuards(AuthGuard)
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.tasksService.findOne(id);
  }

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
