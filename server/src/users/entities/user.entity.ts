/**
 * TypeORM entity representing a user in the SQL database.
 *
 * - Maps to the users table and defines columns for user data and timestamps.
 */
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
} from 'typeorm';

@Entity()
export class User {
  /**
   * Primary key: Unique user ID (auto-generated).
   */
  @PrimaryGeneratedColumn()
  id: number;

  /**
   * User's email address (unique).
   */
  @Column({ unique: true })
  email: string;

  /**
   * User's hashed password.
   */
  @Column()
  password: string;

  /**
   * User's full name.
   */
  @Column()
  name: string;

  /**
   * Timestamp when the user was created.
   */
  @CreateDateColumn()
  createdAt: Date;

  /**
   * Timestamp when the user was last updated.
   */
  @UpdateDateColumn()
  updatedAt: Date;

  /**
   * Timestamp when the user was soft-deleted (nullable).
   */
  @DeleteDateColumn()
  deletedAt: Date;
}
