/**
 * UsersController handles HTTP requests related to user management.
 *
 * - Currently serves as a placeholder for user-related endpoints.
 * - Uses UsersService for business logic.
 */
import { Controller } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  /**
   * Injects UsersService for user-related operations.
   */
  constructor(private readonly usersService: UsersService) {}
}
