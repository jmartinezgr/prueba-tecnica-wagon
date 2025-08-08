import { Injectable } from '@nestjs/common';
import { UsersService } from 'src/users/users.service';

@Injectable()
export class AuthService {
  constructor(private readonly usersService: UsersService) {}

  register() {
    return 'User registered successfully';
  }

  login() {
    return 'Login successful';
  }
}
