/**
 * UsersService provides business logic for managing users in the SQL database.
 *
 * - Handles creation and retrieval of user records using TypeORM.
 * - Exposes methods to create users, find all users, and find users by email.
 */
import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { InjectRepository } from '@nestjs/typeorm';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  /**
   * Creates a new user in the database.
   * @param createUserDto - Data for the new user.
   * @returns The created user entity.
   */
  create(createUserDto: CreateUserDto) {
    return this.usersRepository.save(createUserDto);
  }

  /**
   * Retrieves all users from the database.
   * @returns Array of user entities.
   */
  findAll() {
    return this.usersRepository.find();
  }

  /**
   * Finds a user by their email address.
   * @param email - The user's email address.
   * @returns The found user entity or null.
   */
  findOneByEmail(email: string) {
    return this.usersRepository.findOneBy({ email });
  }
}
