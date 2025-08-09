import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

/**
 * Bootstraps the NestJS application.
 *
 * - Creates the main application instance using the root AppModule.
 * - Sets a global API prefix for all routes (api/v1).
 * - Applies a global validation pipe to enforce DTO validation and transformation.
 * - Starts the HTTP server on port 3000.
 */
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.setGlobalPrefix('api/v1');

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  await app.listen(3000);
}
// Start the application by calling the bootstrap function
void bootstrap();
