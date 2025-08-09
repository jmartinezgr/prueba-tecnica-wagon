/**
 * UsersModule provides the structure for user management features.
 *
 * - Imports the TypeOrmModule for the User entity.
 * - Registers UsersController and UsersService for handling user-related logic and requests.
 * - Exports UsersService for use in other modules.
 */
import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
