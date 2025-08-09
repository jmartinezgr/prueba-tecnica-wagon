/**
 * Data Transfer Object for creating a new user.
 *
 * - Defines the required fields for user creation: email, password, and name.
 */

export class CreateUserDto {
  /**
   * User's email address.
   */
  email: string;
  /**
   * User's password.
   */
  password: string;
  /**
   * User's full name.
   */
  name: string;
}
