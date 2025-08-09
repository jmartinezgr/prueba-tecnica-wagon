/**
 * Mongoose schema and TypeScript class for Task documents.
 *
 * - Defines the structure and types for tasks stored in MongoDB.
 * - Includes fields for title, description, estimated date, user ID, completion status, subtasks, and repeat options.
 */
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

/**
 * Type representing a hydrated Task document from MongoDB.
 */
export type TaskDocument = HydratedDocument<Task>;

@Schema({ timestamps: true })
export class Task {
  /**
   * Title of the task (required).
   */
  @Prop({ required: true })
  title: string;

  /**
   * Optional description of the task.
   */
  @Prop({ required: false })
  description?: string;

  /**
   * Optional estimated date for task completion.
   */
  @Prop({ required: false })
  estimatedDate?: Date; // fecha tentativa de realización

  /**
   * ID of the user who owns the task (required, references SQL user).
   */
  @Prop({ required: true })
  userId: number; // ID del usuario en SQL

  /**
   * Completion status of the task (default: false).
   */
  @Prop({ default: false })
  isCompleted: boolean;

  /**
   * List of subtasks, each with a title and completion status.
   */
  @Prop({
    type: [
      {
        title: { type: String, required: true },
        isCompleted: { type: Boolean, default: false },
      },
    ],
    default: [],
  })
  subTasks: { title: string; isCompleted: boolean }[];

  /**
   * Optional repeat pattern for the task (e.g., 'daily', 'weekly').
   */
  @Prop({ required: false })
  repeat?: string; // 'daily', 'weekly', etc. - para el futuro
}

export const TaskSchema = SchemaFactory.createForClass(Task);
