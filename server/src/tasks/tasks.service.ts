import { Injectable } from '@nestjs/common';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { InjectConnection, InjectModel } from '@nestjs/mongoose';
import { Connection, ConnectionStates, Model } from 'mongoose';
import { Task, TaskDocument } from './schema/task.schema';

@Injectable()
export class TasksService {
  constructor(
    @InjectConnection() private readonly mongoConnection: Connection,
    @InjectModel(Task.name) private readonly taskModel: Model<TaskDocument>,
  ) {}

  onModuleInit() {
    const isConnected =
      this.mongoConnection.readyState === ConnectionStates.connected;
    if (!isConnected) {
      throw new Error('MongoDB connection is not established');
    } else {
      console.log('MongoDB connection is established');
    }
  }

  create(createTaskDto: CreateTaskDto, userId: number) {
    const createdTask = new this.taskModel({
      ...createTaskDto,
      userId,
    });
    return createdTask.save();
  }

  async findUserTasksByUserId(userId: number, date?: string, status?: boolean) {
    const query: Record<string, any> = { userId };

    if (date) {
      const start = new Date(date);
      start.setUTCHours(0, 0, 0, 0);

      const end = new Date(start);
      end.setUTCDate(start.getUTCDate() + 1);

      query.estimatedDate = { $gte: start, $lt: end };
    }

    if (status !== undefined) {
      query.isCompleted = status;
    }

    return this.taskModel.find(query).exec();
  }

  findOne(id: number) {
    return this.taskModel.findById(id).exec();
  }

  update(id: number, updateTaskDto: UpdateTaskDto) {
    return this.taskModel.findByIdAndUpdate(id, updateTaskDto).exec();
  }

  remove(id: number) {
    return this.taskModel.findByIdAndDelete(id).exec();
  }
}
