import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { envs } from './config';
import { UsersModule } from './users/users.module';
import { AuthController } from './auth/auth.controller';
import { AuthService } from './auth/auth.service';
import { MongooseModule } from '@nestjs/mongoose';
import { TasksModule } from './tasks/tasks.module';

/**
 * The root module of the application.
 *
 * - Imports and configures all feature modules, database connections, controllers, and providers.
 * - Sets up TypeORM for PostgreSQL and Mongoose for MongoDB using environment variables.
 * - Registers global controllers and services for the application.
 */
@Module({
  imports: [
    AuthModule,
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: envs.POSTGRES_HOST,
      port: envs.POSTGRES_PORT,
      username: envs.POSTGRES_USER,
      password: envs.POSTGRES_PASSWORD,
      database: envs.POSTGRES_DB,
      autoLoadEntities: true,
      synchronize: true,
    }),
    MongooseModule.forRoot(envs.MONGODB_URI, {}),
    UsersModule,
    TasksModule,
  ],
  controllers: [AppController, AuthController],
  providers: [AppService, AuthService],
})
export class AppModule {}
