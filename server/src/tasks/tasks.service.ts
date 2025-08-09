import { Injectable, UnauthorizedException } from '@nestjs/common';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { InjectConnection, InjectModel } from '@nestjs/mongoose';
import { Connection, ConnectionStates, Model } from 'mongoose';
import { Task, TaskDocument } from './schema/task.schema';

/**
 * TasksService provides business logic for managing user tasks.
 *
 * - Handles creation, retrieval, updating, and deletion of tasks in MongoDB.
 * - Ensures only authorized users can modify or delete their own tasks.
 * - Validates MongoDB connection on module initialization.
 */
@Injectable()
export class TasksService {
  constructor(
    @InjectConnection() private readonly mongoConnection: Connection,
    @InjectModel(Task.name) private readonly taskModel: Model<TaskDocument>,
  ) {}

  /**
   * Checks MongoDB connection status when the module initializes.
   * @throws Error if the connection is not established.
   */
  onModuleInit() {
    const isConnected =
      this.mongoConnection.readyState === ConnectionStates.connected;
    if (!isConnected) {
      throw new Error('MongoDB connection is not established');
    } else {
      console.log('MongoDB connection is established');
    }
  }

  /**
   * Creates a new task for a user.
   * @param createTaskDto - Data for the new task.
   * @param userId - ID of the user creating the task.
   * @returns The created task document.
   */
  create(createTaskDto: CreateTaskDto, userId: number) {
    const createdTask = new this.taskModel({
      ...createTaskDto,
      userId,
    });
    return createdTask.save();
  }

  /**
   * Finds tasks for a user, optionally filtered by date, status, or scheduling.
   * @param userId - ID of the user whose tasks to retrieve.
   * @param date - (Optional) Date string to filter tasks by estimatedDate.
   * @param status - (Optional) Filter by completion status.
   * @param scheduled - (Optional) If false, finds unscheduled tasks.
   * @returns Array of matching task documents.
   */
  async findUserTasksByUserId(
    userId: number,
    date?: string,
    status?: boolean,
    scheduled: boolean = true,
  ) {
    const query: Record<string, any> = { userId };

    if (date) {
      const start = new Date(date);
      start.setUTCHours(0, 0, 0, 0);

      const end = new Date(start);
      end.setUTCDate(start.getUTCDate() + 1);

      query.estimatedDate = { $gte: start, $lt: end };
    } else {
      if (!scheduled) {
        query.$or = [
          { estimatedDate: { $exists: false } },
          { estimatedDate: null },
        ];
      }
    }

    if (status !== undefined) {
      query.isCompleted = status;
    }

    return this.taskModel.find(query).exec();
  }

  /**
   * Finds a single task by its ID.
   * @param id - The task's MongoDB document ID.
   * @returns The found task document or null.
   */
  findOne(id: string) {
    return this.taskModel.findById(id).exec();
  }

  /**
   * Updates a task if it belongs to the user.
   * @param id - The task's MongoDB document ID.
   * @param updateTaskDto - Data to update the task with.
   * @param userId - ID of the user attempting the update.
   * @returns The updated task document.
   * @throws Error if the task is not found.
   * @throws UnauthorizedException if the user does not own the task.
   */
  async update(id: string, updateTaskDto: UpdateTaskDto, userId: number) {
    const task = await this.taskModel.findById(id).exec();
    if (!task) {
      throw new Error('Task not found');
    }

    if (task.userId !== userId) {
      throw new UnauthorizedException();
    }

    return this.taskModel
      .findByIdAndUpdate(
        id,
        { $set: updateTaskDto },
        { new: true, runValidators: true },
      )
      .exec();
  }

  /**
   * Deletes a task if it belongs to the user.
   * @param id - The task's MongoDB document ID.
   * @param userId - ID of the user attempting the deletion.
   * @returns The deleted task document.
   * @throws Error if the task is not found.
   * @throws UnauthorizedException if the user does not own the task.
   */
  async remove(id: string, userId: number) {
    const task = await this.taskModel.findById(id).exec();
    if (!task) {
      throw new Error('Task not found');
    }

    if (task.userId !== userId) {
      throw new UnauthorizedException();
    }

    return this.taskModel.findByIdAndDelete(id).exec();
  }
}
