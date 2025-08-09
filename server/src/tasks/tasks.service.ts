import { Injectable } from '@nestjs/common';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { InjectConnection } from '@nestjs/mongoose';
import { Connection, ConnectionStates } from 'mongoose';

@Injectable()
export class TasksService {
  constructor(
    @InjectConnection() private readonly mongoConnection: Connection,
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

  create(createTaskDto: CreateTaskDto) {
    return 'This action adds a new task';
  }

  findAll() {
    return `This action returns all tasks`;
  }

  findOne(id: number) {
    return `This action returns a #${id} task`;
  }

  update(id: number, updateTaskDto: UpdateTaskDto) {
    return `This action updates a #${id} task`;
  }

  remove(id: number) {
    return `This action removes a #${id} task`;
  }
}
