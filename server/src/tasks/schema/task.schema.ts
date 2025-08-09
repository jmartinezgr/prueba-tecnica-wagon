import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type TaskDocument = HydratedDocument<Task>;

@Schema({ timestamps: true })
export class Task {
  @Prop({ required: true })
  title: string;

  @Prop({ required: false })
  description?: string;

  @Prop({ required: false })
  estimatedDate?: Date; // fecha tentativa de realización

  @Prop({ required: true })
  userId: number; // ID del usuario en SQL

  @Prop({ default: false })
  isCompleted: boolean;

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

  @Prop({ required: false })
  repeat?: string; // 'daily', 'weekly', etc. - para el futuro
}

export const TaskSchema = SchemaFactory.createForClass(Task);
