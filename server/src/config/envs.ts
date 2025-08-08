import * as Joi from 'joi';
import * as dotenv from 'dotenv';

// Cargar variables del archivo .env si no están en process.env
dotenv.config();

interface EnvVars {
  POSTGRES_PORT: number;
  POSTGRES_HOST: string;
  POSTGRES_USER: string;
  POSTGRES_PASSWORD: string;
  POSTGRES_DB: string;
  SECRET: string;
}

// Definir el esquema de validación
const envsSchema = Joi.object<EnvVars>({
  POSTGRES_PORT: Joi.number().default(5432),
  POSTGRES_HOST: Joi.string().required(),
  POSTGRES_USER: Joi.string().required(),
  POSTGRES_PASSWORD: Joi.string().required(),
  POSTGRES_DB: Joi.string().required(),
  SECRET: Joi.string().required(),
}).unknown(true); // Permite variables adicionales en `process.env`

// Validar las variables de entorno
const validationResult = envsSchema.validate(process.env);

if (validationResult.error) {
  throw new Error(`Config validation error: ${validationResult.error.message}`);
}

// Extraer los valores validados
const envVars: EnvVars = validationResult.value;

export const envs = {
  POSTGRES_HOST: envVars.POSTGRES_HOST,
  POSTGRES_PORT: envVars.POSTGRES_PORT,
  POSTGRES_USER: envVars.POSTGRES_USER,
  POSTGRES_PASSWORD: envVars.POSTGRES_PASSWORD,
  POSTGRES_DB: envVars.POSTGRES_DB,
  SECRET: envVars.SECRET,
};
