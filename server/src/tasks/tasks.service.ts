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

  findAll() {
    return this.taskModel.find().exec();
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
