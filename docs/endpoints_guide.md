# Documentación de Endpoints de la API

## Descripción General

La aplicación cuenta actualmente con dos módulos principales implementados de los 3 mencionados en la [arquitectura.md](architecture.md):

- **Módulo de Autenticación (Auth)**: Gestiona registro, login y renovación de tokens
- **Módulo de Tareas (Tasks)**: Maneja las operaciones CRUD de tareas

A continuación se detalla la documentación completa de cada endpoint disponible.

---

## Módulo de Autenticación

**Prefijo de rutas:** `/auth`

### POST `/auth/login`
**Descripción:** Iniciar sesión en la aplicación

**Parámetros del body:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Respuesta exitosa (200):**
```json
{
  "accessToken": "string",
  "refreshToken": "string",
  "user": {
    "id": "12345",
    "email": "usuario@ejemplo.com",
    "name": "Juan Pérez",
    "createdAt": "2025-08-08T20:38:17.010Z",
    "updatedAt": "2025-08-08T20:38:17.010Z",
    "deletedAt": null
  }
}
```

**Errores comunes:**
- `401 Unauthorized`: Credenciales inválidas

---

### POST `/auth/register`
**Descripción:** Registrar un nuevo usuario en el sistema

**Parámetros del body:**
```json
{
  "name": "string",
  "email": "string",
  "password": "string"
}
```

**Respuesta exitosa (201):**
```json
{
  "id": "string",
  "email": "string",
  "name": "string",
  "accessToken": "string",
  "refreshToken": "string"
}
```

**Errores comunes:**
- `400 Bad Request`: Datos inválidos o email ya existente

---

### POST `/auth/refresh`
**Descripción:** Renovar el token de acceso utilizando el refresh token

**Parámetros del body:**
```json
{
  "refreshToken": "string"
}
```

**Respuesta exitosa (200):**
```json
{
  "accessToken": "string",
  "refreshToken": "string"
}
```

**Errores comunes:**
- `401 Unauthorized`: Refresh token inválido o expirado

---

## Módulo de Tareas (Tasks)

**Prefijo de rutas:** `/tasks`

> **Nota:** Todos los endpoints de este módulo requieren autenticación mediante Bearer Token en el header `Authorization`.

### POST `/tasks`
**Descripción:** Crear una nueva tarea para el usuario autenticado

**Headers requeridos:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Parámetros del body:**
```json
{
  "title": "string",
  "description": "string",
  "estimatedDate": "2025-08-10T14:30:00.000Z",
  "isCompleted": false,
  "subTasks": [
    {
      "title": "string",
      "isCompleted": false
    }
  ],
  "repeat": "daily | weekly | monthly"
}
```

> **Nota:** En la implementación actual del frontend solo se utilizan `title`, `description` y `estimatedDate`. Los campos `isCompleted`, `subTasks` y `repeat` están preparados para futuras funcionalidades.

**Respuesta exitosa (201):**
```json
{
  "_id": "66b5a1b2c3d4e5f6a7b8c9d0",
  "title": "Completar documentación",
  "description": "Finalizar la documentación de la API",
  "estimatedDate": "2025-08-10T14:30:00.000Z",
  "isCompleted": false,
  "subTasks": [
    {
      "title": "Revisar endpoints",
      "isCompleted": false
    }
  ],
  "repeat": null,
  "userId": "12345",
  "createdAt": "2025-08-09T10:15:30.000Z",
  "updatedAt": "2025-08-09T10:15:30.000Z"
}
```

**Errores comunes:**
- `401 Unauthorized`: Token inválido o expirado
- `400 Bad Request`: Datos de entrada inválidos

---

### GET `/tasks`
**Descripción:** Obtener todas las tareas del usuario autenticado con filtros opcionales

**Headers requeridos:**
```
Authorization: Bearer <access_token>
```

**Parámetros de consulta (opcionales):**
- `date` (string): Filtrar por fecha específica (formato: YYYY-MM-DD)
- `status` (boolean): Filtrar por estado de completado (true/false)
- `scheduled` (boolean): Filtrar tareas programadas (true) o sin programar (false)

**Ejemplos de uso:**
```
GET /tasks
GET /tasks?date=2025-08-10
GET /tasks?status=true
GET /tasks?scheduled=false&status=false
```

**Respuesta exitosa (200):**
```json
[
  {
    "_id": "66b5a1b2c3d4e5f6a7b8c9d0",
    "title": "Revisar código",
    "description": "Hacer code review del módulo de auth",
    "estimatedDate": "2025-08-10T16:00:00.000Z",
    "isCompleted": false,
    "subTasks": [],
    "repeat": "weekly",
    "userId": "12345",
    "createdAt": "2025-08-09T10:15:30.000Z",
    "updatedAt": "2025-08-09T10:15:30.000Z"
  }
]
```

**Errores comunes:**
- `401 Unauthorized`: Token inválido o expirado

---

### GET `/tasks/:id`
**Descripción:** Obtener una tarea específica por su ID

**Headers requeridos:**
```
Authorization: Bearer <access_token>
```

**Parámetros de ruta:**
- `id` (string): ID único de la tarea (ObjectId de MongoDB)

**Respuesta exitosa (200):**
```json
{
  "_id": "66b5a1b2c3d4e5f6a7b8c9d0",
  "title": "Tarea específica",
  "description": "Descripción de la tarea",
  "estimatedDate": "2025-08-10T14:30:00.000Z",
  "isCompleted": true,
  "subTasks": [
    {
      "title": "Subtarea completada",
      "isCompleted": true
    }
  ],
  "repeat": null,
  "userId": "12345",
  "createdAt": "2025-08-09T10:15:30.000Z",
  "updatedAt": "2025-08-09T12:30:45.000Z"
}
```

**Errores comunes:**
- `401 Unauthorized`: Token inválido o expirado
- `404 Not Found`: Tarea no encontrada
- `400 Bad Request`: ID de tarea inválido

---

### PATCH `/tasks/:id`
**Descripción:** Actualizar una tarea existente (solo si pertenece al usuario autenticado)

**Headers requeridos:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Parámetros de ruta:**
- `id` (string): ID único de la tarea

**Parámetros del body (todos opcionales):**
```json
{
  "title": "string",
  "description": "string",
  "estimatedDate": "2025-08-11T09:00:00.000Z",
  "isCompleted": true,
  "subTasks": [
    {
      "title": "string",
      "isCompleted": false
    }
  ],
  "repeat": "daily | weekly | monthly"
}
```

**Respuesta exitosa (200):**
```json
{
  "_id": "66b5a1b2c3d4e5f6a7b8c9d0",
  "title": "Tarea actualizada",
  "description": "Nueva descripción",
  "estimatedDate": "2025-08-11T09:00:00.000Z",
  "isCompleted": true,
  "subTasks": [
    {
      "title": "Nueva subtarea",
      "isCompleted": false
    }
  ],
  "repeat": "daily",
  "userId": "12345",
  "createdAt": "2025-08-09T10:15:30.000Z",
  "updatedAt": "2025-08-09T14:25:10.000Z"
}
```

**Errores comunes:**
- `401 Unauthorized`: Token inválido o expirado
- `404 Not Found`: Tarea no encontrada o no pertenece al usuario
- `400 Bad Request`: Datos de entrada inválidos

---

### DELETE `/tasks/:id`
**Descripción:** Eliminar una tarea (solo si pertenece al usuario autenticado)

**Headers requeridos:**
```
Authorization: Bearer <access_token>
```

**Parámetros de ruta:**
- `id` (string): ID único de la tarea

**Respuesta exitosa (200):**
```json
{
  "_id": "66b5a1b2c3d4e5f6a7b8c9d0",
  "title": "Tarea eliminada",
  "description": "Esta tarea fue eliminada",
  "deleted": true
}
```

**Errores comunes:**
- `401 Unauthorized`: Token inválido o expirado
- `404 Not Found`: Tarea no encontrada o no pertenece al usuario
- `400 Bad Request`: ID de tarea inválido

---

## Tipos de Datos

### UserData
Estructura del objeto usuario devuelto por la API:

```json
{
  "id": "67890",
  "email": "ejemplo@correo.com",
  "name": "María González",
  "createdAt": "2025-08-08T20:38:17.010Z",
  "updatedAt": "2025-08-08T20:38:17.010Z",
  "deletedAt": null
}
```

**Propiedades:**
- `id` (string): Identificador único del usuario
- `email` (string): Correo electrónico del usuario
- `name` (string): Nombre completo del usuario
- `createdAt` (string): Fecha de creación en formato ISO
- `updatedAt` (string): Fecha de última actualización en formato ISO
- `deletedAt` (string | null): Fecha de eliminación lógica (null si está activo)

### TaskData
Estructura del objeto tarea devuelto por la API:

```json
{
  "_id": "66b5a1b2c3d4e5f6a7b8c9d0",
  "title": "Ejemplo de tarea",
  "description": "Descripción detallada de la tarea",
  "estimatedDate": "2025-08-10T14:30:00.000Z",
  "isCompleted": false,
  "subTasks": [
    {
      "title": "Subtarea ejemplo",
      "isCompleted": false
    }
  ],
  "repeat": "weekly",
  "userId": "12345",
  "createdAt": "2025-08-09T10:15:30.000Z",
  "updatedAt": "2025-08-09T10:15:30.000Z"
}
```

**Propiedades:**
- `_id` (string): Identificador único de la tarea (ObjectId de MongoDB)
- `title` (string): Título de la tarea *(requerido)*
- `description` (string): Descripción detallada de la tarea *(opcional)*
- `estimatedDate` (string | null): Fecha estimada de finalización en formato ISO *(opcional)*
- `isCompleted` (boolean): Estado de completado de la tarea *(opcional, default: false)*
- `subTasks` (array): Lista de subtareas *(opcional)*
  - `title` (string): Título de la subtarea
  - `isCompleted` (boolean): Estado de la subtarea *(default: false)*
- `repeat` (string | null): Patrón de repetición ("daily", "weekly", "monthly") *(opcional)*
- `userId` (string): ID del usuario propietario de la tarea
- `createdAt` (string): Fecha de creación en formato ISO
- `updatedAt` (string): Fecha de última actualización en formato ISO

> **Implementación actual:** El frontend utiliza únicamente `title`, `description` y `estimatedDate`. Los demás campos están preparados para funcionalidades futuras.

---

## Notas Importantes

- Todos los endpoints requieren headers `Content-Type: application/json`
- Los tokens de acceso tienen un tiempo de vida limitado
- Utiliza el refresh token para obtener nuevos access tokens sin requerir login
- Las fechas están en formato ISO 8601 (UTC)